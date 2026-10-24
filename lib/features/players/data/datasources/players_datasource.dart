import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

class PlayersDataSource {
  final FirebaseFirestore _firestore;

  PlayersDataSource(this._firestore);

  static const String _loadFallback = 'Não foi possível carregar os jogadores.';
  static const String _saveFallback = 'Não foi possível salvar o jogador.';

  CollectionReference<Map<String, dynamic>> _players(String? season) =>
      _firestore.collection(SeasonCollection.name('jogadores', season));

  /// Elenco geral de um time: quem tem inscrição nele em alguma competição
  /// (`idsTimes`), o time principal pelo `idTime` e, nos jogadores antigos (sem
  /// id), pelo nome. O filtro descarta quem é de outro time com o mesmo nome.
  /// Sem [teamId], só pelo nome. O elenco de uma competição sai daqui
  /// (`PlayerDTO.playsIn`), sem outra leitura.
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers({
    String teamId = '',
    required String teamName,
    String? season,
  }) {
    final query = teamId.isEmpty
        ? _players(season).where('time', isEqualTo: teamName)
        : _players(season).where(Filter.or(
            Filter(PlayerDTO.teamIdsField, arrayContains: teamId),
            Filter('idTime', isEqualTo: teamId),
            Filter('time', isEqualTo: teamName),
          ));
    return query.snapshots().toEither(
          (snapshot) => snapshot.docs
              .map(PlayerDTO.fromFirestore)
              .where((p) => teamId.isEmpty || p.playsFor(teamId: teamId, teamName: teamName))
              .toList(),
          fallbackMessage: _loadFallback,
          logName: 'PlayersDataSource',
        );
  }

  /// Um jogador em tempo real; `null` se o documento não existe.
  Stream<Either<Failure, PlayerDTO?>> watchPlayer({required String id, String? season}) {
    return _players(season).doc(id).snapshots().toEither(
          (doc) => doc.exists ? PlayerDTO.fromFirestore(doc) : null,
          fallbackMessage: _loadFallback,
          logName: 'PlayersDataSource',
        );
  }

  /// Atleta vinculado à conta [userId] na temporada, em tempo real (nulo se
  /// a conta não tem atleta).
  Stream<Either<Failure, PlayerDTO?>> watchPlayerOfUser({required String userId, String? season}) {
    return _players(season).where('idUsuario', isEqualTo: userId).limit(1).snapshots().toEither(
          (snapshot) => snapshot.docs.isEmpty ? null : PlayerDTO.fromFirestore(snapshot.docs.first),
          fallbackMessage: _loadFallback,
          logName: 'PlayersDataSource',
        );
  }

  /// Todos os jogadores da temporada (base da artilharia/assistências).
  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season}) async {
    try {
      final result = await _players(season).get();
      return Right(result.docs.map(PlayerDTO.fromFirestore).toList());
    } catch (e) {
      AppLogger.e('getPlayers season=$season', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _loadFallback));
    }
  }

  /// Limite do `whereIn` do Firestore (valores por consulta).
  static const int whereInLimit = 30;

  /// Os [limit] jogadores com mais [field] (`nGols`/`nAssistencias`) entre os
  /// times [teamIds]: uma consulta por bloco de até 30 ids (em paralelo), cada
  /// uma já ordenada e limitada no servidor; junta e corta em [limit]. Lê no
  /// máximo `blocos x limit` docs, em vez da coleção inteira.
  Future<Either<Failure, List<PlayerDTO>>> getTopPlayers({
    required List<String> teamIds,
    required String field,
    int limit = 50,
    String? season,
  }) async {
    final chunks = chunkIds(teamIds);
    if (chunks.isEmpty || limit <= 0) return const Right([]);
    try {
      final results = await Future.wait(chunks.map(
        (chunk) => _players(season).where('idTime', whereIn: chunk).orderBy(field, descending: true).limit(limit).get(),
      ));
      final lists = results.map((r) => r.docs.map(PlayerDTO.fromFirestore).toList()).toList();
      return Right(mergeTopPlayers(lists, field: field, limit: limit));
    } catch (e) {
      AppLogger.e('getTopPlayers season=$season field=$field', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _loadFallback));
    }
  }

  /// Os [limit] jogadores com mais [field] na competição [championshipId]
  /// (`inscricoes.c<id>.<field>`), em ordem decrescente. Índice de campo único
  /// (automático); quem não tem inscrição na competição não aparece.
  Future<Either<Failure, List<PlayerDTO>>> getTopPlayersInChampionship({
    required int championshipId,
    required String field,
    int limit = 50,
    String? season,
  }) async {
    if (limit <= 0) return const Right([]);
    try {
      final path = FieldPath([PlayerEnrollment.field, PlayerEnrollment.keyOf(championshipId), field]);
      final result = await _players(season).orderBy(path, descending: true).limit(limit).get();
      return Right(result.docs.map(PlayerDTO.fromFirestore).toList());
    } catch (e) {
      AppLogger.e('getTopPlayersInChampionship id=$championshipId field=$field', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _loadFallback));
    }
  }

  /// Ids sem vazios e sem repetição, em blocos de até [size].
  static List<List<String>> chunkIds(List<String> ids, {int size = whereInLimit}) {
    final unique = ids.where((id) => id.isNotEmpty).toSet().toList();
    return [
      for (var i = 0; i < unique.length; i += size)
        unique.sublist(i, i + size > unique.length ? unique.length : i + size),
    ];
  }

  /// Junta os resultados dos blocos em ordem decrescente de [field] e fica com
  /// os [limit] primeiros. Empate mantém a ordem de chegada (bloco, depois a
  /// posição no bloco).
  static List<PlayerDTO> mergeTopPlayers(List<List<PlayerDTO>> chunks, {required String field, required int limit}) {
    final indexed = chunks.expand((chunk) => chunk).toList().asMap().entries.toList()
      ..sort((a, b) {
        final byValue = b.value.statOf(field).compareTo(a.value.statOf(field));
        return byValue != 0 ? byValue : a.key.compareTo(b.key);
      });
    return indexed.take(limit).map((entry) => entry.value).toList();
  }

  /// Cria o jogador com `idJogador` = id do documento, numa escrita só
  /// (o app antigo fazia `add()` + `set()`).
  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season}) async {
    try {
      final ref = _players(season).doc();
      await ref.set(player.copyWith(id: ref.id).toMap());
      return const Right(null);
    } catch (e) {
      AppLogger.e('createPlayer', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Grava os valores do jogador (nome, foto, posição, totais) com `merge`:
  /// campos que o DTO não conhece e as inscrições de outras competições não
  /// são apagados (o app antigo regravava o documento inteiro).
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) async {
    try {
      await _players(season).doc(player.id).set(player.toMap(), SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      AppLogger.e('updatePlayer id=${player.id}', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Soma [goals] gols e [assists] assistências ao jogador, de forma atômica
  /// (`FieldValue.increment`): não lê nem regrava o documento, então duas
  /// somas ao mesmo tempo não se perdem. Com [enrollment], soma também na
  /// competição dela (e grava a inscrição, se o atleta antigo ainda não tinha).
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    PlayerEnrollment? enrollment,
    bool friendly = false,
    String? season,
  }) async {
    if (goals == 0 && assists == 0) return const Right(null);
    try {
      // Amistoso: só a contagem à parte (não entra no Geral nem em competição).
      if (friendly) {
        await _players(season).doc(playerId).update({
          if (goals != 0) PlayerDTO.friendlyGoalsField: FieldValue.increment(goals),
          if (assists != 0) PlayerDTO.friendlyAssistsField: FieldValue.increment(assists),
        });
        return const Right(null);
      }
      await _players(season).doc(playerId).update({
        if (goals != 0) PlayerDTO.goalsField: FieldValue.increment(goals),
        if (assists != 0) PlayerDTO.assistsField: FieldValue.increment(assists),
        if (enrollment != null) ...{
          ..._enrollmentFields(enrollment),
          _enrollmentPath(enrollment.championshipId, PlayerDTO.goalsField): FieldValue.increment(goals),
          _enrollmentPath(enrollment.championshipId, PlayerDTO.assistsField): FieldValue.increment(assists),
        },
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('incrementStats id=$playerId', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Manutenção do admin: acerta o Geral (soma das competições, sem os
  /// amistosos) e grava os amistosos contados nas partidas
  /// ([friendlyCounts]: id do atleta → gols/assistências). Grava só quem
  /// mudou; devolve quantos atletas foram corrigidos.
  Future<Either<Failure, int>> repairTotals(
    Map<String, ({int goals, int assists})> friendlyCounts, {
    String? season,
  }) async {
    try {
      final snapshot = await _players(season).get();
      var batch = _firestore.batch();
      var pending = 0;
      var fixed = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final friendly = friendlyCounts[doc.id];
        final changes = PlayerDTO.fromFirestore(doc).repairedTotals(
          stored: (data[PlayerDTO.goalsField] as num?)?.toInt() ?? 0,
          storedAssists: (data[PlayerDTO.assistsField] as num?)?.toInt() ?? 0,
          friendlyGoals: friendly?.goals ?? 0,
          friendlyAssists: friendly?.assists ?? 0,
        );
        if (changes == null) continue;
        batch.update(doc.reference, changes);
        fixed++;
        // Lote do Firestore: até 500 gravações.
        if (++pending == 450) {
          await batch.commit();
          batch = _firestore.batch();
          pending = 0;
        }
      }
      if (pending > 0) await batch.commit();
      return Right(fixed);
    } catch (e) {
      AppLogger.e('repairTotals', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  static FieldPath _enrollmentPath(int championshipId, String field) =>
      FieldPath([PlayerEnrollment.field, PlayerEnrollment.keyOf(championshipId), field]);

  /// Time da inscrição + `idsTimes`: os números da competição não são tocados
  /// (`increment(0)` só cria o campo se faltar).
  static Map<Object, Object?> _enrollmentFields(PlayerEnrollment enrollment) => {
        _enrollmentPath(enrollment.championshipId, 'idTime'): enrollment.teamId,
        _enrollmentPath(enrollment.championshipId, 'time'): enrollment.team,
        if (enrollment.teamId.isNotEmpty) PlayerDTO.teamIdsField: FieldValue.arrayUnion([enrollment.teamId]),
      };

  /// Inscreve o atleta na competição da [enrollment] (pelo time dela), sem
  /// mexer nas outras inscrições nem nos números. Atleta sem time principal
  /// passa a ter o desta inscrição.
  Future<Either<Failure, void>> enroll(PlayerDTO player, PlayerEnrollment enrollment, {String? season}) async {
    try {
      await _players(season).doc(player.id).update(enrollFields(player, enrollment));
      return const Right(null);
    } catch (e) {
      AppLogger.e('enroll id=${player.id}', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Campos gravados ao inscrever (também usados no batch da aprovação).
  static Map<Object, Object?> enrollFields(PlayerDTO player, PlayerEnrollment enrollment) => {
        ..._enrollmentFields(enrollment),
        _enrollmentPath(enrollment.championshipId, PlayerDTO.goalsField): FieldValue.increment(0),
        _enrollmentPath(enrollment.championshipId, PlayerDTO.assistsField): FieldValue.increment(0),
        if (player.team.trim().isEmpty && player.teamId.isEmpty) ...{
          'time': enrollment.team,
          'idTime': enrollment.teamId,
        },
      };

  /// Grava as inscrições do atleta pelo time [teamId]/[team] nas competições
  /// [selected] (entre as [teamChampionships] do time). Nada a mudar = não grava.
  Future<Either<Failure, void>> setChampionships(
    PlayerDTO player, {
    required String teamId,
    required String team,
    required Set<int> selected,
    required List<int> teamChampionships,
    String? season,
  }) async {
    final changes = enrollmentChanges(
      player,
      teamId: teamId,
      team: team,
      selected: selected,
      teamChampionships: teamChampionships,
    );
    if (changes.isEmpty) return const Right(null);
    try {
      await _players(season).doc(player.id).update(changes);
      return const Right(null);
    } catch (e) {
      AppLogger.e('setChampionships id=${player.id}', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// O que muda no atleta para jogar pelo time nas competições [selected]:
  /// - acrescenta as novas (time da inscrição, números da competição a zero);
  /// - tira as desmarcadas que eram por este time;
  /// - competição em que ele joga por outro time não é tocada;
  /// - atleta antigo (sem inscrições, conta em todas as do time): sem mudança
  ///   não grava; com mudança, as que ficaram viram inscrições;
  /// - `idsTimes` é refeito; o time principal fica (sem competição nenhuma o
  ///   atleta continua no time, no elenco geral).
  static Map<Object, Object?> enrollmentChanges(
    PlayerDTO player, {
    required String teamId,
    required String team,
    required Set<int> selected,
    required List<int> teamChampionships,
  }) {
    bool isThisTeam(PlayerEnrollment e) => sameTeam(idA: e.teamId, nameA: e.team, idB: teamId, nameB: team);
    final current = {
      for (final id in teamChampionships)
        if (player.playsIn(id, teamId: teamId, teamName: team)) id,
    };
    // Competições em que joga por outro time ficam como estão.
    final blocked = {
      for (final e in player.enrollments)
        if (!isThisTeam(e)) e.championshipId,
    };
    final wanted = selected.where((id) => teamChampionships.contains(id) && !blocked.contains(id)).toSet();
    final legacy = player.isLegacy;
    if (wanted.length == current.length && wanted.containsAll(current)) return const {};

    final add = legacy ? wanted : wanted.difference(current);
    final remove = legacy ? <int>{} : current.difference(wanted);
    final remaining = [
      for (final e in player.enrollments)
        if (!remove.contains(e.championshipId)) e,
      for (final id in add) PlayerEnrollment(championshipId: id, teamId: teamId, team: team),
    ];
    final changes = <Object, Object?>{
      for (final id in add) ...{
        ..._enrollmentFields(PlayerEnrollment(championshipId: id, teamId: teamId, team: team)),
        _enrollmentPath(id, PlayerDTO.goalsField): FieldValue.increment(0),
        _enrollmentPath(id, PlayerDTO.assistsField): FieldValue.increment(0),
      },
      for (final id in remove) FieldPath([PlayerEnrollment.field, PlayerEnrollment.keyOf(id)]): FieldValue.delete(),
    };
    // Sem competição nenhuma o atleta continua no time (elenco geral): só o
    // mapa fica vazio (e não sumido, que voltaria a valer "em todas").
    if (remaining.isEmpty) {
      changes
        ..removeWhere((key, _) => key is FieldPath)
        ..[PlayerEnrollment.field] = <String, Object?>{};
    }
    // Principal: fica; vazio, passa a ser o deste time.
    final primaryEmpty = player.team.trim().isEmpty && player.teamId.isEmpty;
    final primaryId = primaryEmpty ? teamId : player.teamId;
    if (primaryEmpty) {
      changes['time'] = team;
      changes['idTime'] = teamId;
    }
    changes[PlayerDTO.teamIdsField] = {
      if (primaryId.isNotEmpty) primaryId,
      for (final e in remaining)
        if (e.teamId.isNotEmpty) e.teamId,
    }.toList();
    return changes;
  }

  /// Exclui o jogador (só os sem conta vinculada; os vinculados saem do
  /// elenco com [removeFromSquad]).
  Future<Either<Failure, void>> deletePlayer(PlayerDTO player, {String? season}) async {
    try {
      await _players(season).doc(player.id).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('deletePlayer id=${player.id}', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível excluir o jogador.'));
    }
  }

  /// Tira o jogador do elenco e mantém gols e assistências. Com
  /// [championshipId] (atleta com inscrições), só da competição: o principal
  /// passa para a próxima inscrição; sem nenhuma, fica sem time. Ficando sem
  /// time, o pedido "Sou jogador" dele vira "removido" (na mesma escrita), o
  /// que libera pedir outro time.
  Future<Either<Failure, void>> removeFromSquad(PlayerDTO player, {int? championshipId, String? season}) async {
    try {
      final changes = squadRemovalFields(player, championshipId: championshipId);
      final batch = _firestore.batch()..update(_players(season).doc(player.id), changes);
      final leftWithoutTeam = changes['idTime'] == '' && changes['time'] == '';
      if (player.userId.isNotEmpty && leftWithoutTeam) {
        final request = await _firestore.collection('solicitacoes_jogador').doc(player.userId).get();
        if (request.exists && request.data()?['idJogador'] == player.id) {
          batch.update(request.reference, {
            'status': 'removido',
            'motivo': '',
            'atualizado_em': FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('removeFromSquad id=${player.id}', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível tirar o jogador do elenco.'));
    }
  }

  /// O que muda no atleta ao sair do elenco (da competição [championshipId],
  /// ou de tudo): a inscrição some, `idsTimes` e o principal são refeitos.
  static Map<Object, Object?> squadRemovalFields(PlayerDTO player, {int? championshipId}) {
    if (championshipId == null || player.enrollmentIn(championshipId) == null) {
      return {
        'time': '',
        'idTime': '',
        // Vazios em vez de apagados: as regras não deixam sumir o campo (o app
        // antigo regravava o atleta inteiro sem ele).
        if (!player.isLegacy) PlayerEnrollment.field: <String, Object?>{},
        if (!player.isLegacy) PlayerDTO.teamIdsField: <String>[],
      };
    }
    final remaining = player.enrollments.where((e) => e.championshipId != championshipId).toList();
    // Só sai da competição: continua no time (o principal fica).
    return {
      FieldPath([PlayerEnrollment.field, PlayerEnrollment.keyOf(championshipId)]): FieldValue.delete(),
      PlayerDTO.teamIdsField: {
        if (player.teamId.isNotEmpty) player.teamId,
        for (final e in remaining)
          if (e.teamId.isNotEmpty) e.teamId,
      }.toList(),
    };
  }
}
