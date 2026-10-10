import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

class TeamsDataSource {
  final FirebaseFirestore _firestore;

  TeamsDataSource(this._firestore);

  static const String _fallback = 'Não foi possível carregar os times.';

  Query<Map<String, dynamic>> _teamsQuery({String? region, String? season}) {
    Query<Map<String, dynamic>> query = _firestore.collection(SeasonCollection.name('times', season));
    if (region != null) query = query.where('fk_competicao', isEqualTo: region);
    return query;
  }

  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season}) async {
    try {
      final result = await _teamsQuery(region: region, season: season).get();
      return Right(result.docs.map(TeamDTO.fromFirestore).toList());
    } catch (e) {
      AppLogger.e('getTeams region=$region season=$season', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _fallback));
    }
  }

  Future<Either<Failure, TeamDTO?>> getTeamByName(String name) async {
    try {
      final result = await _firestore.collection('times').where('nome', isEqualTo: name).limit(1).get();
      return Right(result.docs.isEmpty ? null : TeamDTO.fromFirestore(result.docs.first));
    } catch (e) {
      AppLogger.e('getTeamByName name=$name', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _fallback));
    }
  }

  /// Total de times da temporada, de todas as regiões (base do número
  /// sequencial do id de um time novo).
  Future<Either<Failure, int>> countTeams({String? season}) async {
    try {
      final result = await _firestore.collection(SeasonCollection.name('times', season)).get();
      return Right(result.docs.length);
    } catch (e) {
      AppLogger.e('countTeams season=$season', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _fallback));
    }
  }

  /// Grava o time em `times` e a linha zerada dele em `classificacao`, ambos
  /// com o id do time como id do documento. Num batch, para não sobrar um
  /// sem o outro.
  Future<Either<Failure, void>> createTeam(TeamDTO team, {String? season}) async {
    try {
      final batch = _firestore.batch();
      batch.set(_firestore.collection(SeasonCollection.name('times', season)).doc(team.id), team.toMap());
      batch.set(
        _firestore.collection(SeasonCollection.name('classificacao', season)).doc(team.id),
        team.toStandingsMap(),
      );
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('createTeam id=${team.id}', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível cadastrar o time.'));
    }
  }

  Stream<Either<Failure, List<TeamDTO>>> watchTeams({String? region, String? season}) {
    return _teamsQuery(region: region, season: season).snapshots().toEither(
          (snapshot) => snapshot.docs.map(TeamDTO.fromFirestore).toList(),
          fallbackMessage: _fallback,
          logName: 'TeamsDataSource',
        );
  }
}
