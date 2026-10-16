import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/account_provider.dart';

abstract class IAuthRepository {
  Future<Either<Failure, UserDTO>> signIn({required String email, required String password});

  /// `Right(null)` quando o usuário cancela o seletor de contas do Google.
  Future<Either<Failure, UserDTO?>> signInWithGoogle();

  /// `Right(null)` quando o usuário fecha a folha de login da Apple.
  Future<Either<Failure, UserDTO?>> signInWithApple();

  AccountProvider get accountProvider;

  /// Reautentica e exclui a conta. Folha do Google/Apple fechada = falha com
  /// código [deleteAccountCanceledCode].
  Future<Either<Failure, void>> deleteAccount({String? password});

  Future<Either<Failure, UserDTO>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> updateFavoriteTeam(
      {required String userId, required String team, required String teamId});

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendPasswordReset(String email);

  /// Usuário logado, ou `Right(null)` quando não há sessão.
  Future<Either<Failure, UserDTO?>> getCurrentUser();

  Future<Either<Failure, void>> updatePhoto({required String userId, required String photoUrl});

  /// Quando a conta logada foi criada; nulo sem sessão.
  DateTime? get accountCreatedAt;
}
