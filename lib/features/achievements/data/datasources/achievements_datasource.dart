import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';

/// Conquistas: o catálogo (`conquistas`, do admin), os contadores do usuário
/// (`usuarios/{uid}/progresso/contadores`) e os desbloqueios
/// (`usuarios/{uid}/conquistas`, gravados pelas Cloud Functions).
class AchievementsDataSource {
  final FirebaseFirestore _firestore;

  AchievementsDataSource(this._firestore);

  static const String _logName = 'AchievementsDataSource';
  static const String _saveFallback = 'Não foi possível salvar a conquista.';

  CollectionReference<Map<String, dynamic>> get _catalog => _firestore.collection('conquistas');

  DocumentReference<Map<String, dynamic>> _progress(String uid) =>
      _firestore.collection('usuarios').doc(uid).collection('progresso').doc('contadores');

  CollectionReference<Map<String, dynamic>> _unlocks(String uid) =>
      _firestore.collection('usuarios').doc(uid).collection('conquistas');

  Stream<Either<Failure, List<AchievementDTO>>> watchCatalog() => _catalog.snapshots().toEither(
        (snapshot) => snapshot.docs.map(AchievementDTO.fromFirestore).toList(),
        fallbackMessage: 'Não foi possível carregar as conquistas.',
        logName: _logName,
      );

  Stream<Either<Failure, AchievementProgressDTO>> watchProgress(String uid) => _progress(uid).snapshots().toEither(
        (doc) => AchievementProgressDTO.fromMap(doc.data()),
        fallbackMessage: 'Não foi possível carregar o seu progresso.',
        logName: _logName,
      );

  Stream<Either<Failure, List<AchievementUnlockDTO>>> watchUnlocks(String uid) => _unlocks(uid).snapshots().toEither(
        (snapshot) => snapshot.docs.map(AchievementUnlockDTO.fromFirestore).toList(),
        fallbackMessage: 'Não foi possível carregar as suas conquistas.',
        logName: _logName,
      );

  /// Cria (sem id) ou atualiza a conquista.
  Future<Either<Failure, void>> saveAchievement(AchievementDTO achievement) async {
    try {
      final ref = achievement.id.isEmpty ? _catalog.doc() : _catalog.doc(achievement.id);
      await ref.set(achievement.toMap());
      return const Right(null);
    } catch (e) {
      AppLogger.e('saveAchievement ${achievement.id}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> deleteAchievement(String id) async {
    try {
      await _catalog.doc(id).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('deleteAchievement $id', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível excluir a conquista.'));
    }
  }

  /// Cria várias de uma vez (as sugeridas).
  Future<Either<Failure, void>> createAchievements(List<AchievementDTO> achievements) async {
    try {
      final batch = _firestore.batch();
      for (final achievement in achievements) {
        batch.set(_catalog.doc(), achievement.toMap());
      }
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('createAchievements', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Soma 1 numa métrica contada pelo app (a regra só aceita +1).
  Future<Either<Failure, void>> increment(String uid, AchievementMetric metric) async {
    try {
      await _progress(uid).set({metric.key: FieldValue.increment(1)}, SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      AppLogger.e('increment ${metric.key}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível registrar o progresso.'));
    }
  }

  /// Registra o dia de uso (a regra confere a hora do servidor e o dia novo).
  Future<Either<Failure, void>> recordVisit(String uid,
      {required int activeDays, required int streak, required int bestStreak}) async {
    try {
      await _progress(uid).set({
        AchievementMetric.activeDays.key: activeDays,
        AchievementProgressDTO.streakField: streak,
        AchievementMetric.bestStreak.key: bestStreak,
        AchievementProgressDTO.lastVisitField: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      AppLogger.e('recordVisit', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível registrar o progresso.'));
    }
  }

  /// O usuário viu a comemoração da conquista.
  Future<Either<Failure, void>> markSeen(String uid, String achievementId) async {
    try {
      await _unlocks(uid).doc(achievementId).update({'vista': true});
      return const Right(null);
    } catch (e) {
      AppLogger.e('markSeen $achievementId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível atualizar a conquista.'));
    }
  }
}
