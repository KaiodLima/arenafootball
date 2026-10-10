import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class SignInUseCase {
  final IAuthRepository _repository;

  SignInUseCase(this._repository);

  Future<Either<Failure, UserDTO>> call({required String email, required String password}) =>
      _repository.signIn(email: email.trim(), password: password);
}
