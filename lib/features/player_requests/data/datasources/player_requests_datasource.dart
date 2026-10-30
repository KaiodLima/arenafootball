import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/data/dtos/player_merge.dart';

/// Pedidos "Sou jogador" (`solicitacoes_jogador/{uid}`). O usuário grava o
/// próprio pedido; o admin edita, aprova (cria o jogador) ou rejeita.
/// Aprovação de vínculo recusada: o atleta já tem outra conta.
const String claimTakenCode = 'claim-taken';

/// Aprovação de vínculo recusada: a conta já tem outro atleta na temporada.
const String claimAccountHasPlayerCode = 'claim-account-has-player';

/// Aprovação recusada: o atleta já joga por outro time nessa competição.
const String enrollmentConflictCode = 'enrollment-conflict';

/// Vínculo com a conta que já tem outro atleta ([current]) na temporada: o
/// admin confirma a junção (`approve(mergePlayerId: current.id)`).
class PlayerMergeNeeded extends ErrorWithMessage {
  final PlayerDTO current;

  PlayerMergeNeeded(this.current)
      : super('Esta conta já tem outro atleta nesta temporada.', code: claimAccountHasPlayerCode);
}

class PlayerRequestsDataSource {
  final FirebaseFirestore _firestore;

  PlayerRequestsDataSource(this._firestore);

  static const String _logName = 'PlayerRequestsDataSource';
  static const String _loadFallback = 'Não foi possível carregar as solicitações.';
  static const String _saveFallback = 'Não foi possível salvar a solicitação.';

  CollectionReference<Map<String, dynamic>> get _requests => _firestore.collection('solicitacoes_jogador');

  /// Pedido do usuário em tempo real; `null` se ele ainda não pediu.
  Stream<Either<Failure, PlayerRequestDTO?>> watchMyRequest(String userId) {
    return _requests.doc(userId).snapshots().toEither(
          (doc) => doc.exists ? PlayerRequestDTO.fromFirestore(doc) : null,
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Envia (ou reenvia) o pedido: sobrescreve o anterior e volta a "pendente".
  Future<Either<Failure, void>> submit(PlayerRequestDTO request) async {
    try {
      await _requests.doc(request.userId).set({
        ...request.toSubmitMap(),
        'data': FieldValue.serverTimestamp(),
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('submit uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> cancel(String userId) async {
    try {
      await _requests.doc(userId).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('cancel uid=$userId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Todos os pedidos, mais recentes primeiro (painel do admin).
  Stream<Either<Failure, List<PlayerRequestDTO>>> watchRequests() {
    return _requests.orderBy('data', descending: true).snapshots().toEither(
          (snapshot) => snapshot.docs.map(PlayerRequestDTO.fromFirestore).toList(),
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Pedidos para entrar no time (aba "Pedidos" do dono), mais recentes
  /// primeiro: pelo `idTime` e, nos pedidos antigos (sem id), pelo nome; quem
  /// tem o id de outro time com o mesmo nome fica de fora. Ordena em memória:
  /// com `where` + `orderBy` em campos diferentes seria preciso um índice.
  Stream<Either<Failure, List<PlayerRequestDTO>>> watchTeamRequests({String teamId = '', required String teamName}) {
    final query = teamId.isEmpty
        ? _requests.where('time', isEqualTo: teamName)
        : _requests.where(Filter.or(Filter('idTime', isEqualTo: teamId), Filter('time', isEqualTo: teamName)));
    return query.snapshots().toEither(
          (snapshot) => snapshot.docs
              .map(PlayerRequestDTO.fromFirestore)
              .where((r) => teamId.isEmpty || r.teamId.isEmpty || r.teamId == teamId)
              .toList()
            ..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0))),
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Quantos pedidos aguardam resposta (contador do menu do admin).
  Stream<Either<Failure, int>> watchPendingCount() {
    return _requests.where('status', isEqualTo: PlayerRequestStatus.pending.key).snapshots().toEither(
          (snapshot) => snapshot.size,
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Edição do admin antes de responder: nome, time e posição.
  Future<Either<Failure, void>> update(PlayerRequestDTO request) async {
    try {
      await _requests.doc(request.userId).update({
        'nome': request.name,
        'time': request.team,
        'idTime': request.teamId,
        'posicao': request.position?.key ?? '',
        // Outro time: o atleta reivindicado era do time antigo.
        'idJogadorVinculo': request.claimedPlayerId,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('update uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Id do time do pedido; pedido antigo (sem id) busca o time pelo nome na
  /// temporada do pedido ('' se não achar).
  Future<String> _teamIdOf(PlayerRequestDTO request) async {
    if (request.teamId.isNotEmpty) return request.teamId;
    final teams = await _firestore
        .collection(SeasonCollection.name('times', request.season))
        .where('nome', isEqualTo: request.team)
        .limit(1)
        .get();
    return teams.docs.isEmpty ? '' : teams.docs.first.id;
  }

  /// Aprova o pedido, numa escrita só com a marcação do pedido. Pedido de
  /// vínculo: liga a conta ao atleta reivindicado (mantém nome e números); se
  /// a conta já tem outro atleta na temporada, devolve [PlayerMergeNeeded] e,
  /// com [mergePlayerId] (o admin confirmou), junta os dois ([_merge]).
  /// Se a conta já tem atleta (saiu de outro elenco), reaproveita ele: troca
  /// time, nome, posição e foto e mantém gols e assistências. Senão, cria.
  /// Em toda aprovação: atleta já inscrito na competição do pedido por outro
  /// time = recusado (um time por competição na temporada).
  Future<Either<Failure, String>> approve(PlayerRequestDTO request, {String? mergePlayerId}) async {
    try {
      final players = _firestore.collection(SeasonCollection.name('jogadores', request.season));
      final teamId = await _teamIdOf(request);
      final existing = await players.where('idUsuario', isEqualTo: request.userId).limit(1).get();
      final batch = _firestore.batch();
      final DocumentReference<Map<String, dynamic>> playerRef;
      // Pedido com competição: acrescenta a inscrição (o atleta continua nas
      // outras). Pedido antigo (sem competição): troca o time, como antes.
      final championshipId = request.championshipId;
      final enrollment = championshipId == null
          ? null
          : PlayerEnrollment(championshipId: championshipId, teamId: teamId, team: request.team);
      if (request.isClaim) {
        playerRef = players.doc(request.claimedPlayerId);
        final claimed = await playerRef.get();
        final owner = claimed.data()?['idUsuario']?.toString() ?? '';
        if (!claimed.exists || (owner.isNotEmpty && owner != request.userId)) {
          return Left(ErrorWithMessage('Este atleta já foi vinculado a outra conta.', code: claimTakenCode));
        }
        final other = existing.docs.isNotEmpty && existing.docs.first.id != playerRef.id ? existing.docs.first : null;
        if (other != null) {
          if (mergePlayerId != other.id) return Left(PlayerMergeNeeded(PlayerDTO.fromFirestore(other)));
          return _merge(request, claimed: claimed, other: other, teamId: teamId, enrollment: enrollment);
        }
        final claimedPlayer = PlayerDTO.fromFirestore(claimed);
        final conflict = enrollment == null
            ? null
            : PlayerMerge.conflictIn(claimedPlayer, enrollment.championshipId, teamId, request.team);
        if (conflict != null) return Left(await _conflictFailure(conflict));
        batch.update(playerRef, {
          'idUsuario': request.userId,
          if (enrollment == null) ...{'time': request.team, 'idTime': teamId},
          if (enrollment != null) ...PlayersDataSource.enrollFields(claimedPlayer, enrollment),
          if (request.position != null) 'posicao': request.position!.key,
          if (request.imageUrl.isNotEmpty) 'urlImagem': request.imageUrl,
        });
      } else if (existing.docs.isNotEmpty) {
        playerRef = existing.docs.first.reference;
        final current = PlayerDTO.fromFirestore(existing.docs.first);
        final conflict = enrollment == null
            ? null
            : PlayerMerge.conflictIn(current, enrollment.championshipId, teamId, request.team);
        if (conflict != null) return Left(await _conflictFailure(conflict));
        batch.update(playerRef, {
          'nome': request.name,
          if (enrollment == null) ...{'time': request.team, 'idTime': teamId},
          if (enrollment != null) ...PlayersDataSource.enrollFields(current, enrollment),
          'posicao': request.position?.key ?? '',
          if (request.imageUrl.isNotEmpty) 'urlImagem': request.imageUrl,
        });
      } else {
        playerRef = players.doc();
        final player = PlayerDTO(
          id: playerRef.id,
          name: request.name,
          team: request.team,
          teamId: teamId,
          imageUrl: request.imageUrl,
          userId: request.userId,
          position: request.position?.key ?? '',
          enrollments: [if (enrollment != null) enrollment],
        );
        batch.set(playerRef, player.toMap());
      }
      batch.update(_requests.doc(request.userId), _approvedFields(playerRef.id));
      await batch.commit();
      return Right(playerRef.id);
    } catch (e) {
      AppLogger.e('approve uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível aprovar a solicitação.'));
    }
  }

  Map<String, Object> _approvedFields(String playerId) => {
        'status': PlayerRequestStatus.approved.key,
        'idJogador': playerId,
        'motivo': '',
        'atualizado_em': FieldValue.serverTimestamp(),
      };

  /// Junta o atleta que a conta já tinha ([other]) no reivindicado
  /// ([claimed]): inscrições com o time e os números de cada competição,
  /// Geral e amistosos somados (`PlayerMerge`). As referências ao [other]
  /// (cards de gol, listas `gols` e craque das partidas, figurinhas) passam
  /// para o [claimed] antes; por último, num lote só, o [claimed] gravado, o
  /// [other] apagado e o pedido aprovado.
  Future<Either<Failure, String>> _merge(
    PlayerRequestDTO request, {
    required DocumentSnapshot<Map<String, dynamic>> claimed,
    required DocumentSnapshot<Map<String, dynamic>> other,
    required String teamId,
    required PlayerEnrollment? enrollment,
  }) async {
    final source = PlayerDTO.fromFirestore(other);
    final result = PlayerMerge.merge(target: PlayerDTO.fromFirestore(claimed), source: source);
    if (result.conflict != null) return Left(await _conflictFailure(result.conflict!));
    var merged = result.merged!;
    if (enrollment != null) {
      final conflict = PlayerMerge.conflictIn(merged, enrollment.championshipId, teamId, request.team);
      if (conflict != null) return Left(await _conflictFailure(conflict));
      merged = PlayerMerge.withEnrollment(merged, enrollment);
    }
    // Time principal: o do reivindicado; pedido sem competição (ou atleta sem
    // time) fica com o time do pedido, como na aprovação comum.
    if (enrollment == null || (merged.team.trim().isEmpty && merged.teamId.isEmpty)) {
      merged = merged.copyWith(team: request.team, teamId: teamId);
    }
    merged = merged.copyWith(
      userId: request.userId,
      position: request.position?.key ?? merged.position,
      imageUrl: request.imageUrl.isNotEmpty ? request.imageUrl : merged.imageUrl,
    );

    final hasStats = source.goals + source.assists + source.friendlyGoals + source.friendlyAssists > 0;
    await _repointReferences(
      season: request.season,
      from: other.id,
      to: claimed.id,
      teamIds: source.teamIds,
      withStats: hasStats,
    );

    final batch = _firestore.batch()
      ..update(claimed.reference, merged.toMap())
      ..delete(other.reference)
      ..update(_requests.doc(request.userId), _approvedFields(claimed.id));
    await batch.commit();
    AppLogger.d('approve merge uid=${request.userId} ${other.id} -> ${claimed.id}', name: _logName);
    return Right(claimed.id);
  }

  /// Troca o atleta [from] por [to] onde ele é citado: craque das partidas e
  /// figurinhas do álbum sempre; com números ([withStats]), também os cards de
  /// gol e as listas `gols` das partidas dos times dele.
  Future<void> _repointReferences({
    required String season,
    required String from,
    required String to,
    required List<String> teamIds,
    required bool withStats,
  }) async {
    final updates = <(DocumentReference<Map<String, dynamic>>, Map<String, Object?>)>[];
    final matches = _firestore.collection(SeasonCollection.name('partidas', season));

    final crowned = await matches.where('craque.idJogador', isEqualTo: from).get();
    for (final doc in crowned.docs) {
      updates.add((doc.reference, {'craque.idJogador': to}));
    }

    final events = await _firestore.collection('album_eventos').get();
    for (final event in events.docs) {
      final stickers = await event.reference.collection('figurinhas').where('idJogador', isEqualTo: from).get();
      for (final doc in stickers.docs) {
        updates.add((doc.reference, {'idJogador': to}));
      }
    }

    if (withStats) {
      final news = _firestore.collection('noticias');
      for (final field in const ['autor_gol_id', 'assistencia_id']) {
        final cards = await news.where(field, isEqualTo: from).get();
        for (final doc in cards.docs) {
          updates.add((doc.reference, {field: to}));
        }
      }
      final seen = <String>{};
      for (var i = 0; i < teamIds.length; i += 30) {
        final ids = teamIds.sublist(i, i + 30 > teamIds.length ? teamIds.length : i + 30);
        for (final side in const ['idTimeC', 'idTimeF']) {
          final games = await matches.where(side, whereIn: ids).get();
          for (final doc in games.docs) {
            if (!seen.add(doc.id)) continue;
            final goals = PlayerMerge.repointGoals(doc.data()['gols'], from, to);
            if (goals != null) updates.add((doc.reference, {'gols': goals}));
          }
        }
      }
    }

    for (var i = 0; i < updates.length; i += 400) {
      final batch = _firestore.batch();
      for (final (ref, data) in updates.skip(i).take(400)) {
        batch.update(ref, data);
      }
      await batch.commit();
    }
  }

  /// Recusa por conflito de competição, com o nome dela.
  Future<Failure> _conflictFailure(EnrollmentConflict conflict) async {
    var title = 'nessa competição';
    try {
      final found = await _firestore
          .collection('campeonatos')
          .where('id_campeonato', isEqualTo: conflict.championshipId)
          .limit(1)
          .get();
      final name = found.docs.isEmpty ? '' : found.docs.first.data()['titulo']?.toString() ?? '';
      if (name.isNotEmpty) title = 'em $name';
    } catch (e) {
      AppLogger.e('conflict title ${conflict.championshipId}', name: _logName, error: e);
    }
    return ErrorWithMessage(
      'O atleta já joga pelo ${conflict.currentTeam} $title e não pode jogar também pelo ${conflict.otherTeam} '
      'na mesma competição.',
      code: enrollmentConflictCode,
    );
  }

  Future<Either<Failure, void>> reject({required String userId, required String reason}) async {
    try {
      await _requests.doc(userId).update({
        'status': PlayerRequestStatus.rejected.key,
        'motivo': reason,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('reject uid=$userId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível rejeitar a solicitação.'));
    }
  }
}
