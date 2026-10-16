import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class DeleteUserCacheUseCase {
  final IAuthRepository _repository;

  DeleteUserCacheUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.deleteUserCache();
}
