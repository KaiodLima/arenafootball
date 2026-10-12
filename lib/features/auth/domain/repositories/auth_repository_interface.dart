import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

abstract class IAuthRepository {
  Future<Either<Failure, UserDTO>> signIn({required String email, required String password});

  /// `Right(null)` quando o usuário cancela o seletor de contas do Google.
  Future<Either<Failure, UserDTO?>> signInWithGoogle();

  Future<Either<Failure, UserDTO>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> updateFavoriteTeam({required String userId, required String team});

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendPasswordReset(String email);

  /// Usuário logado, ou `Right(null)` quando não há sessão.
  Future<Either<Failure, UserDTO?>> getCurrentUser();
}
