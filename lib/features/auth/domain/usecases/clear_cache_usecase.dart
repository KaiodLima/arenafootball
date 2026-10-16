import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

/// Apaga todo o cache local. Chamado ao sair da conta.
class ClearCacheUseCase {
  final IAuthRepository _repository;

  ClearCacheUseCase(this._repository);

  Future<void> call() => _repository.clearCache();
}
