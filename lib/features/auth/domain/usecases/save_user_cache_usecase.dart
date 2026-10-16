import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class SaveUserCacheUseCase {
  final IAuthRepository _repository;

  SaveUserCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(UserDTO user) => _repository.saveUserCache(user);
}
