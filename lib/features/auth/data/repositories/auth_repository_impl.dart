import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/datasources/auth_datasource.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/account_provider.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthDataSource _dataSource;
  final CacheStore _cache;

  AuthRepositoryImpl(this._dataSource, this._cache);

  @override
  Future<Either<Failure, UserDTO>> signIn({required String email, required String password}) =>
      _dataSource.signIn(email: email, password: password);

  @override
  Future<Either<Failure, UserDTO?>> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<Either<Failure, UserDTO?>> signInWithApple() => _dataSource.signInWithApple();

  @override
  AccountProvider get accountProvider => _dataSource.accountProvider;

  @override
  Future<Either<Failure, void>> deleteAccount({String? password}) => _dataSource.deleteAccount(password: password);

  @override
  Future<Either<Failure, UserDTO>> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _dataSource.signUp(name: name, email: email, password: password);

  @override
  Future<Either<Failure, void>> updateFavoriteTeam(
          {required String userId, required String team, required String teamId}) =>
      _dataSource.updateFavoriteTeam(userId: userId, team: team, teamId: teamId);

  @override
  Future<Either<Failure, void>> signOut() => _dataSource.signOut();

  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) => _dataSource.sendPasswordReset(email);

  @override
  Future<Either<Failure, UserDTO?>> getCurrentUser() async {
    final userId = _dataSource.currentUserId;
    if (userId == null) return const Right(null);
    final result = await _dataSource.getUser(userId);
    return result.fold((failure) => Left(failure), (user) => Right(user));
  }

  @override
  Future<Either<Failure, void>> updatePhoto({required String userId, required String photoUrl}) =>
      _dataSource.updatePhoto(userId: userId, photoUrl: photoUrl);

  @override
  DateTime? get accountCreatedAt => _dataSource.accountCreatedAt;

  @override
  Future<Either<Failure, CachedValue<UserDTO>?>> getCachedUser() async {
    final userId = _dataSource.currentUserId;
    if (userId == null) return const Right(null);
    return _cache.read(
      CacheKeys.user(userId),
      (json) => UserDTO.fromCache(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<Either<Failure, void>> saveUserCache(UserDTO user) =>
      _cache.save(CacheKeys.user(_dataSource.currentUserId ?? user.id), user.toCache());

  @override
  Future<Either<Failure, void>> deleteUserCache() async {
    final userId = _dataSource.currentUserId;
    if (userId == null) return const Right(null);
    return _cache.delete(CacheKeys.user(userId));
  }

  @override
  Future<void> clearCache() => _cache.clear();
}
