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

  static const String _userDataNotFound = 'user-data-not-found';

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('usuarios');

  Future<Either<Failure, UserDTO>> signIn({required String email, required String password}) async {
    const fallback = 'Não foi possível entrar. Tente novamente.';
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final authUser = credential.user!;
      final result = await getUser(authUser.uid);
      if (result.isRight) return result;

      // Conta criada no Auth sem o documento (cadastro interrompido): recria.
      final failure = result.left;
      if (failure is ErrorWithMessage && failure.code == _userDataNotFound) {
        final user = UserDTO(id: authUser.uid, name: authUser.displayName ?? '', email: authUser.email ?? email);
        await _users.doc(user.id).set(user.toMap());
        return Right(user);
      }

      // Sem os dados do usuário não há sessão válida: não deixa o Auth logado pela metade.
      await _auth.signOut();
      return result;
    } catch (e) {
      AppLogger.e('signIn', name: 'AuthDataSource', error: e);
      if (_auth.currentUser != null) await _auth.signOut();
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  Future<Either<Failure, UserDTO>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    const fallback = 'Não foi possível criar a conta. Tente novamente.';
    final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      AppLogger.e('signUp createUser', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }

    final authUser = credential.user!;
    try {
      await authUser.updateDisplayName(name);
    } catch (e) {
      // Só cosmético: o nome que vale é o do documento em `usuarios`.
      AppLogger.e('signUp updateDisplayName', name: 'AuthDataSource', error: e);
    }

    // Time fica vazio aqui: é escolhido na etapa 2, já com o usuário logado.
    final user = UserDTO(id: authUser.uid, name: name, email: email);
    try {
      await _users.doc(user.id).set(user.toMap());
      return Right(user);
    } catch (e) {
      AppLogger.e('signUp saveUser', name: 'AuthDataSource', error: e);
      // Desfaz a conta no Auth para o e-mail não ficar preso sem documento.
      try {
        await authUser.delete();
      } catch (rollbackError) {
        AppLogger.e('signUp rollback', name: 'AuthDataSource', error: rollbackError);
      }
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

  /// Documento do usuário: pelo uid; contas antigas podem ter id de documento
  /// diferente do uid, e aí busca pelo campo `idUsuario`.
  Future<DocumentSnapshot<Map<String, dynamic>>?> _findUserDoc(String userId) async {
    final doc = await _users.doc(userId).get();
    if (doc.exists) return doc;
    final result = await _users.where('idUsuario', isEqualTo: userId).limit(1).get();
    return result.docs.isEmpty ? null : result.docs.first;
  }

  Future<Either<Failure, UserDTO>> getUser(String userId) async {
    const fallback = 'Não foi possível carregar os dados do usuário.';
    try {
      final doc = await _findUserDoc(userId);
      if (doc == null) return Left(ErrorWithMessage(fallback, code: _userDataNotFound));
      return Right(UserDTO.fromFirestore(doc));
    } catch (e) {
      AppLogger.e('getUser id=$userId', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  Future<Either<Failure, void>> updateFavoriteTeam({required String userId, required String team}) async {
    const fallback = 'Não foi possível salvar o seu time.';
    try {
      final doc = await _findUserDoc(userId);
      if (doc == null) return Left(ErrorWithMessage(fallback, code: _userDataNotFound));
      await doc.reference.update({'time': team});
      return const Right(null);
    } catch (e) {
      AppLogger.e('updateFavoriteTeam id=$userId', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }
}
