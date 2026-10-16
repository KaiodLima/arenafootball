import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

class AuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthDataSource(this._auth, this._firestore, this._googleSignIn);

  /// O plugin do Google só pode ser inicializado uma vez. No Android o client id
  /// vem do `default_web_client_id` gerado a partir do google-services.json.
  Future<void>? _googleInit;

  static const String _userDataNotFound = 'user-data-not-found';

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('usuarios');

  Future<Either<Failure, UserDTO>> signIn({required String email, required String password}) async {
    const fallback = 'Não foi possível entrar. Tente novamente.';
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return await _loadOrCreateUser(credential.user!);
    } catch (e) {
      AppLogger.e('signIn', name: 'AuthDataSource', error: e);
      if (_auth.currentUser != null) await _auth.signOut();
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  /// `Right(null)` quando o usuário fecha o seletor de contas do Google.
  Future<Either<Failure, UserDTO?>> signInWithGoogle() async {
    const fallback = 'Não foi possível entrar com o Google. Tente novamente.';
    try {
      await (_googleInit ??= _googleSignIn.initialize());
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return Left(ErrorWithMessage(fallback));

      final credential = await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      return await _loadOrCreateUser(credential.user!);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return const Right(null);
      AppLogger.e('signInWithGoogle', name: 'AuthDataSource', error: e);
      return Left(ErrorWithMessage(fallback));
    } catch (e) {
      AppLogger.e('signInWithGoogle', name: 'AuthDataSource', error: e);
      if (_auth.currentUser != null) await signOut();
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  /// Login nativo da Apple (só iOS). `Right(null)` quando o usuário fecha a folha
  /// da Apple. O nome só vem no primeiro login, e a Apple não manda foto.
  Future<Either<Failure, UserDTO?>> signInWithApple() async {
    const fallback = 'Não foi possível entrar com a Apple. Tente novamente.';
    try {
      final provider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      final credential = await _auth.signInWithProvider(provider);
      return await _loadOrCreateUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      if (_appleCanceledCodes.contains(e.code)) return const Right(null);
      AppLogger.e('signInWithApple', name: 'AuthDataSource', error: e);
      if (_auth.currentUser != null) await signOut();
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    } catch (e) {
      AppLogger.e('signInWithApple', name: 'AuthDataSource', error: e);
      if (_auth.currentUser != null) await signOut();
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  /// Códigos do FlutterFire quando o usuário fecha a folha de login da Apple.
  static const Set<String> _appleCanceledCodes = {'canceled', 'web-context-canceled'};

  /// Dados do usuário recém-autenticado. Sem documento (cadastro interrompido ou
  /// primeiro acesso pelo Google ou pela Apple), cria um com o time vazio.
  Future<Either<Failure, UserDTO>> _loadOrCreateUser(User authUser) async {
    final result = await getUser(authUser.uid);
    if (result.isRight) return result;

    final failure = result.left;
    if (failure is ErrorWithMessage && failure.code == _userDataNotFound) {
      // Primeiro acesso social: a foto da conta Google vira a foto do app (a Apple não tem).
      final user = UserDTO(
        id: authUser.uid,
        name: authUser.displayName ?? '',
        email: authUser.email ?? '',
        photoUrl: authUser.photoURL ?? '',
      );
      await _users.doc(user.id).set(user.toMap());
      return Right(user);
    }

    // Sem os dados do usuário não há sessão válida: não deixa o Auth logado pela metade.
    await signOut();
    return result;
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
      await _signOutGoogle();
      return const Right(null);
    } catch (e) {
      AppLogger.e('signOut', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  /// Sem isso o Google reaproveita a última conta e não mostra o seletor.
  Future<void> _signOutGoogle() async {
    try {
      await (_googleInit ??= _googleSignIn.initialize());
      await _googleSignIn.signOut();
    } catch (e) {
      AppLogger.e('signOut google', name: 'AuthDataSource', error: e);
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
      final user = UserDTO.fromFirestore(doc);
      // Conta Google antiga sem foto no app: usa a do Google até trocar.
      final authPhoto = _auth.currentUser?.uid == userId ? _auth.currentUser?.photoURL : null;
      return Right(user.photoUrl.isEmpty && authPhoto != null ? user.copyWith(photoUrl: authPhoto) : user);
    } catch (e) {
      AppLogger.e('getUser id=$userId', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  Future<Either<Failure, void>> updateFavoriteTeam({
    required String userId,
    required String team,
    required String teamId,
  }) async {
    const fallback = 'Não foi possível salvar o seu time.';
    try {
      final doc = await _findUserDoc(userId);
      if (doc == null) return Left(ErrorWithMessage(fallback, code: _userDataNotFound));
      await doc.reference.update({'time': team, 'idTime': teamId});
      return const Right(null);
    } catch (e) {
      AppLogger.e('updateFavoriteTeam id=$userId', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  /// Grava a foto da conta (`urlImagem`) no documento do próprio usuário.
  Future<Either<Failure, void>> updatePhoto({required String userId, required String photoUrl}) async {
    const fallback = 'Não foi possível salvar a foto.';
    try {
      final doc = await _findUserDoc(userId);
      if (doc == null) return Left(ErrorWithMessage(fallback, code: _userDataNotFound));
      await doc.reference.update({'urlImagem': photoUrl});
      return const Right(null);
    } catch (e) {
      AppLogger.e('updatePhoto id=$userId', name: 'AuthDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  /// Quando a conta logada foi criada (Firebase Auth); nulo sem sessão.
  DateTime? get accountCreatedAt => _auth.currentUser?.metadata.creationTime;
}
