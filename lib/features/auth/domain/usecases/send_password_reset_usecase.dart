import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class SendPasswordResetUseCase {
  final IAuthRepository _repository;

  SendPasswordResetUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) => _repository.sendPasswordReset(email.trim());
}
