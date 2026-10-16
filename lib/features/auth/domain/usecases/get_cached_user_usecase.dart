import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

/// Usuário da sessão do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedUserUseCase {
  final IAuthRepository _repository;

  GetCachedUserUseCase(this._repository);

  Future<Either<Failure, CachedValue<UserDTO>?>> call() => _repository.getCachedUser();
}
