import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

class AuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthDataSource(this._auth, this._firestore);

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('usuarios');

  Future<Either<Failure, UserDTO>> signIn({required String email, required String password}) async {
    const fallback = 'Não foi possível entrar. Tente novamente.';
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return getUser(credential.user!.uid);
    } catch (e) {
      AppLogger.e('signIn', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  Future<Either<Failure, UserDTO>> signUp({
    required String name,
    required String email,
    required String password,
    required String favoriteTeam,
  }) async {
    const fallback = 'Não foi possível criar a conta. Tente novamente.';
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = UserDTO(id: credential.user!.uid, name: name, email: email, favoriteTeam: favoriteTeam);
      await _users.doc(user.id).set(user.toMap());
      return Right(user);
    } catch (e) {
      AppLogger.e('signUp', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  Future<Either<Failure, void>> signOut() async {
    const fallback = 'Não foi possível sair da conta.';
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      AppLogger.e('signOut', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  Future<Either<Failure, void>> sendPasswordReset(String email) async {
    const fallback = 'Não foi possível enviar o link de recuperação.';
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } catch (e) {
      AppLogger.e('sendPasswordReset', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  String? get currentUserId => _auth.currentUser?.uid;

  Future<Either<Failure, UserDTO>> getUser(String userId) async {
    const fallback = 'Não foi possível carregar os dados do usuário.';
    try {
      final doc = await _users.doc(userId).get();
      if (doc.exists) return Right(UserDTO.fromFirestore(doc));

      // Contas antigas podem ter id de documento diferente do uid.
      final result = await _users.where('idUsuario', isEqualTo: userId).limit(1).get();
      if (result.docs.isEmpty) return Left(ErrorWithMessage(fallback, code: 'user-data-not-found'));
      return Right(UserDTO.fromFirestore(result.docs.first));
    } catch (e) {
      AppLogger.e('getUser id=$userId', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }
}
