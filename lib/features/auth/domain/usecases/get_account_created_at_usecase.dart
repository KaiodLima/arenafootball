import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

/// Quando a conta logada foi criada ("Torcedor desde"); nulo sem sessão.
class GetAccountCreatedAtUseCase {
  final IAuthRepository _repository;

  GetAccountCreatedAtUseCase(this._repository);

  DateTime? call() => _repository.accountCreatedAt;
}
