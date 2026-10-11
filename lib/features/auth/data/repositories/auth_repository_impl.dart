import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/datasources/auth_datasource.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, UserDTO>> signIn({required String email, required String password}) =>
      _dataSource.signIn(email: email, password: password);

  @override
  Future<Either<Failure, UserDTO>> signUp({
    required String name,
    required String email,
    required String password,
    required String favoriteTeam,
  }) =>
      _dataSource.signUp(name: name, email: email, password: password, favoriteTeam: favoriteTeam);

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
}
