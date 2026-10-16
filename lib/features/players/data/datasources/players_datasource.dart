import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

class PlayersDataSource {
  final FirebaseFirestore _firestore;

  PlayersDataSource(this._firestore);

  static const String _loadFallback = 'Não foi possível carregar os jogadores.';
  static const String _saveFallback = 'Não foi possível salvar o jogador.';

  CollectionReference<Map<String, dynamic>> _players(String? season) =>
      _firestore.collection(SeasonCollection.name('jogadores', season));

  /// Elenco de um time: pelo `idTime` e, nos jogadores antigos (sem id),
  /// pelo nome. A consulta traz os dois e o filtro descarta quem tem o id de
  /// outro time com o mesmo nome. Sem [teamId], só pelo nome.
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers({
    String teamId = '',
    required String teamName,
    String? season,
  }) {
    final query = teamId.isEmpty
        ? _players(season).where('time', isEqualTo: teamName)
        : _players(season).where(Filter.or(Filter('idTime', isEqualTo: teamId), Filter('time', isEqualTo: teamName)));
    return query.snapshots().toEither(
          (snapshot) => snapshot.docs
              .map(PlayerDTO.fromFirestore)
              .where((p) => teamId.isEmpty || p.teamId.isEmpty || p.teamId == teamId)
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

  /// Regrava o documento inteiro (`set` com os valores absolutos), como o
  /// app antigo fazia a cada edição de nome, foto, gols ou assistências.
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) async {
    try {
      await _players(season).doc(player.id).set(player.toMap());
      return const Right(null);
    } catch (e) {
      AppLogger.e('updatePlayer id=${player.id}', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Soma [goals] gols e [assists] assistências ao jogador, de forma atômica
  /// (`FieldValue.increment`): não lê nem regrava o documento, então duas
  /// somas ao mesmo tempo não se perdem.
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    String? season,
  }) async {
    if (goals == 0 && assists == 0) return const Right(null);
    try {
      await _players(season).doc(playerId).update({
        if (goals != 0) 'nGols': FieldValue.increment(goals),
        if (assists != 0) 'nAssistencias': FieldValue.increment(assists),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('incrementStats id=$playerId', name: 'PlayersDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
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

  /// Tira o jogador vinculado a uma conta do elenco: fica sem time e mantém
  /// gols e assistências. O pedido "Sou jogador" dele vira "removido" (na
  /// mesma escrita), o que libera pedir outro time.
  Future<Either<Failure, void>> removeFromSquad(PlayerDTO player, {String? season}) async {
    try {
      final batch = _firestore.batch()..update(_players(season).doc(player.id), {'time': '', 'idTime': ''});
      if (player.userId.isNotEmpty) {
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
}
