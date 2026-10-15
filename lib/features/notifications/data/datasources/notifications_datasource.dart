import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/notifications/data/dtos/push_log_dto.dart';

/// Painel de notificações: liga/desliga por ação (`config/notificacoes`),
/// histórico (`notificacoes_envios`) e aviso manual (`push_avisos`, que a
/// Cloud Function envia).
class NotificationsDataSource {
  final FirebaseFirestore _firestore;

  NotificationsDataSource(this._firestore);

  static const String _loadFallback = 'Não foi possível carregar as notificações.';
  static const String _saveFallback = 'Não foi possível salvar.';
  static const int historyLimit = 100;

  DocumentReference<Map<String, dynamic>> get _config => _firestore.collection('config').doc('notificacoes');

  /// Ações gravadas (chave → ligada). Sem documento, mapa vazio.
  Stream<Either<Failure, Map<String, bool>>> watchConfig() {
    return _config.snapshots().toEither(
          (doc) => {
            for (final entry in (doc.data() ?? const <String, dynamic>{}).entries)
              if (entry.value is bool) entry.key: entry.value as bool,
          },
          fallbackMessage: _loadFallback,
          logName: 'NotificationsDataSource',
        );
  }

  Future<Either<Failure, void>> setActionEnabled({required String key, required bool enabled}) async {
    try {
      await _config.set({key: enabled}, SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      AppLogger.e('setActionEnabled $key', name: 'NotificationsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Últimos envios, mais recentes primeiro.
  Stream<Either<Failure, List<PushLogDTO>>> watchHistory() {
    return _firestore
        .collection('notificacoes_envios')
        .orderBy('data', descending: true)
        .limit(historyLimit)
        .snapshots()
        .toEither(
          (snapshot) => snapshot.docs.map(PushLogDTO.fromFirestore).toList(),
          fallbackMessage: _loadFallback,
          logName: 'NotificationsDataSource',
        );
  }

  /// Aviso manual: [region] vazia = todos os usuários.
  Future<Either<Failure, void>> sendManual({
    required String title,
    required String body,
    required String region,
  }) async {
    try {
      await _firestore.collection('push_avisos').add({
        'titulo': title,
        'corpo': body,
        ...RegionRegistry.fieldsFor(region, nameKey: 'regiao'),
        'data': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('sendManual', name: 'NotificationsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível enviar o aviso.'));
    }
  }
}
