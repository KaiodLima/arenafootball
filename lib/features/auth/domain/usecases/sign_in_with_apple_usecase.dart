import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class SignInWithAppleUseCase {
  final IAuthRepository _repository;

  SignInWithAppleUseCase(this._repository);

  /// `Right(null)` quando o usuário fecha a folha de login da Apple.
  Future<Either<Failure, UserDTO?>> call() => _repository.signInWithApple();
}
