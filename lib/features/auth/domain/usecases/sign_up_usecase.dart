import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class SignUpUseCase {
  final IAuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Either<Failure, UserDTO>> call({
    required String name,
    required String email,
    required String password,
    required String favoriteTeam,
  }) =>
      _repository.signUp(name: name.trim(), email: email.trim(), password: password, favoriteTeam: favoriteTeam);
}
