import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

abstract class IAuthRepository {
  Future<Either<Failure, UserDTO>> signIn({required String email, required String password});

  Future<Either<Failure, UserDTO>> signUp({
    required String name,
    required String email,
    required String password,
    required String favoriteTeam,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendPasswordReset(String email);

  /// Usuário logado, ou `Right(null)` quando não há sessão.
  Future<Either<Failure, UserDTO?>> getCurrentUser();
}
