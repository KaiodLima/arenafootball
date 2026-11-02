import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/referrals/data/dtos/referral_dto.dart';
import 'package:arena_soccer/features/referrals/domain/referral_code.dart';

/// Indique amigos: o código da conta (`codigos_indicacao`), o saldo e os
/// indicados (`indicacoes`, só as functions gravam) e o `indicadoPor` do perfil.
class ReferralsDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReferralsDataSource(this._firestore, this._auth);

  static const String _logName = 'ReferralsDataSource';

  /// Código da conta [uid], criado na 1ª vez: o de 8 caracteres, ou o de 10
  /// se o de 8 já for de outra conta (o get de código alheio é negado).
  Future<Either<Failure, String>> ensureCode(String uid) async {
    try {
      for (final length in const [ReferralCode.length, ReferralCode.longLength]) {
        final code = ReferralCode.of(uid, length: length);
        final ref = _firestore.collection('codigos_indicacao').doc(code);
        try {
          final doc = await ref.get();
          if (!doc.exists) await ref.set({'uid': uid});
          return Right(code);
        } on FirebaseException catch (e) {
          // Código de outra conta: tenta o mais longo.
          if (e.code != 'permission-denied') rethrow;
        }
      }
      return Left(ErrorWithMessage('Não foi possível criar o seu código de convite.'));
    } catch (e) {
      AppLogger.e('ensureCode uid=$uid', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível criar o seu código de convite.'));
    }
  }

  Stream<Either<Failure, ReferralDTO>> watchReferral(String uid) {
    return _firestore.collection('indicacoes').doc(uid).snapshots().toEither(
          (doc) => ReferralDTO.fromMap(doc.data()),
          fallbackMessage: 'Não foi possível carregar as suas indicações.',
          logName: _logName,
        );
  }

  Stream<Either<Failure, List<ReferredFriendDTO>>> watchFriends(String uid) {
    return _firestore
        .collection('indicacoes')
        .doc(uid)
        .collection('indicados')
        .orderBy('em', descending: true)
        .limit(50)
        .snapshots()
        .toEither(
          (snapshot) => snapshot.docs.map(ReferredFriendDTO.fromFirestore).toList(),
          fallbackMessage: 'Não foi possível carregar os seus indicados.',
          logName: _logName,
        );
  }

  /// Código de quem indicou a conta ('' = ninguém ainda).
  Future<Either<Failure, String>> getClaim(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      return Right((doc.data()?['indicadoPor'] ?? '').toString());
    } catch (e) {
      AppLogger.e('getClaim uid=$uid', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar o seu convite.'));
    }
  }

  /// Grava quem indicou a conta (uma vez; as regras barram trocar).
  Future<Either<Failure, void>> claim(String uid, String code) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({'indicadoPor': code});
      return const Right(null);
    } catch (e) {
      AppLogger.e('claim uid=$uid', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível usar este código.'));
    }
  }

  DocumentReference<Map<String, dynamic>> get _config => _firestore.collection('config').doc('indicacao');

  /// Liga/desliga do admin (leitura pública; sem o doc = desligado).
  Stream<Either<Failure, ReferralConfigDTO>> watchConfig() {
    return _config.snapshots().toEither(
          (doc) => ReferralConfigDTO.fromMap(doc.data()),
          fallbackMessage: 'Não foi possível carregar as indicações.',
          logName: _logName,
        );
  }

  /// Admin liga/desliga as indicações.
  Future<Either<Failure, void>> setEnabled(bool enabled) async {
    try {
      await _config.set({'ativo': enabled, 'atualizadoEm': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      AppLogger.e('setEnabled $enabled', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível salvar.'));
    }
  }

  /// Quando a conta logada foi criada (nulo sem login).
  DateTime? accountCreatedAt() => _auth.currentUser?.metadata.creationTime;
}
