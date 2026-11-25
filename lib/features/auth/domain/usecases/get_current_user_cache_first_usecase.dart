import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/usecases/delete_user_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/save_user_cache_usecase.dart';

/// Usuário da sessão pelo fluxo [cacheFirst] (validade [CacheTtl.user]): com
/// a conta no cache entra na hora (funciona sem rede) e só relê
/// `usuarios/{uid}` com o cache vencido ou [force]. `Right(null)` = sem
/// sessão (apaga o cache da conta). As gravações do perfil apagam o cache no
/// repositório.
class GetCurrentUserCacheFirstUseCase {
  final GetCurrentUserUseCase _getCurrentUser;
  final GetCachedUserUseCase _getCached;
  final SaveUserCacheUseCase _saveCache;
  final DeleteUserCacheUseCase _deleteCache;

  GetCurrentUserCacheFirstUseCase(this._getCurrentUser, this._getCached, this._saveCache, this._deleteCache);

  Stream<Either<Failure, UserDTO?>> call({bool force = false}) => cacheFirst<UserDTO?>(
        readCache: () async {
          final cached = await _getCached();
          final value = cached.isRight ? cached.right : null;
          return Right(value == null ? null : CachedValue<UserDTO?>(value.data, value.savedAt));
        },
        fetchRemote: _getCurrentUser.call,
        saveCache: (user) => user == null ? _deleteCache() : _saveCache(user),
        ttl: CacheTtl.user,
        force: force,
        logName: 'GetCurrentUserCacheFirstUseCase',
      );
}
