import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

/// Troca o nome da conta. O nome chega já validado (`ProfileName`).
class UpdateUserNameUseCase {
  final IAuthRepository _repository;

  UpdateUserNameUseCase(this._repository);

  Future<Either<Failure, void>> call({required String userId, required String name}) =>
      _repository.updateName(userId: userId, name: name.trim());
}
