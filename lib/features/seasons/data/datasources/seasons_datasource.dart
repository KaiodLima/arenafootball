import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

class SeasonsDataSource {
  final FirebaseFirestore _firestore;

  SeasonsDataSource(this._firestore);

  static const String _logName = 'SeasonsDataSource';

  /// Limite de escritas por batch do Firestore (500), com folga.
  static const int _batchSize = 400;

  DocumentReference<Map<String, dynamic>> get _config => _firestore.doc('config/temporadas');

  /// Config de temporadas; nulo se ainda não foi criada (app usa o padrão).
  Future<Either<Failure, SeasonsConfigDTO?>> getConfig() async {
    try {
      final doc = await _config.get();
      return Right(doc.exists ? SeasonsConfigDTO.fromFirestore(doc) : null);
    } catch (e) {
      AppLogger.e('getConfig', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar as temporadas.'));
    }
  }

  /// Abre a temporada [season]. Com [copyTeamsFrom], copia os times dessa
  /// temporada para a nova (e cria a linha zerada da classificação de cada
  /// um). Por último troca a atual na config: se a cópia falhar no meio, a
  /// temporada em uso não muda.
  Future<Either<Failure, SeasonsConfigDTO>> startSeason({
    required String season,
    required List<String> seasons,
    String? copyTeamsFrom,
  }) async {
    try {
      if (copyTeamsFrom != null) {
        final teams = await _firestore.collection(SeasonCollection.name('times', copyTeamsFrom)).get();
        final newTeams = _firestore.collection(SeasonCollection.name('times', season));
        final newStandings = _firestore.collection(SeasonCollection.name('classificacao', season));
        final docs = teams.docs.map(TeamDTO.fromFirestore).toList();
        for (var i = 0; i < docs.length; i += _batchSize ~/ 2) {
          final batch = _firestore.batch();
          for (final team in docs.skip(i).take(_batchSize ~/ 2)) {
            batch
              ..set(newTeams.doc(team.id), team.toMap())
              ..set(newStandings.doc(team.id), team.toStandingsMap());
          }
          await batch.commit();
        }
      }
      final config = SeasonsConfigDTO(current: season, seasons: ({...seasons, season}.toList()..sort()));
      await _config.set(config.toMap());
      return Right(config);
    } catch (e) {
      AppLogger.e('startSeason season=$season', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível iniciar a temporada.'));
    }
  }
}
