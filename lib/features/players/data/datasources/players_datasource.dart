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

  /// Elenco de um time (o campo `time` guarda o nome do time).
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers({required String teamName, String? season}) {
    return _players(season).where('time', isEqualTo: teamName).snapshots().toEither(
          (snapshot) => snapshot.docs.map(PlayerDTO.fromFirestore).toList(),
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
}
