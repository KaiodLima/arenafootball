import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:arena_soccer/features/auth/domain/usecases/clear_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/delete_user_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/save_user_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';

class _FakeAuth implements IAuthRepository {
  UserDTO? cached;
  Either<Failure, UserDTO?> remote = const Right(null);
  bool cleared = false;
  bool signedOut = false;

  @override
  Future<Either<Failure, CachedValue<UserDTO>?>> getCachedUser() async =>
      Right(cached == null ? null : CachedValue(cached!, DateTime.now()));

  @override
  Future<Either<Failure, void>> saveUserCache(UserDTO user) async {
    cached = user;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteUserCache() async {
    cached = null;
    return const Right(null);
  }

  @override
  Future<void> clearCache() async {
    cleared = true;
    cached = null;
  }

  @override
  Future<Either<Failure, UserDTO?>> getCurrentUser() async => remote;

  @override
  Future<Either<Failure, void>> signOut() async {
    signedOut = true;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const user = UserDTO(id: 'u1', name: 'Kaio', email: 'k@x.com', favoriteTeam: 'Lava Jato');
  late _FakeAuth auth;

  SessionCubit build() => SessionCubit(
        GetCurrentUserUseCase(auth),
        SignOutUseCase(auth),
        DeleteAccountUseCase(auth),
        GetCachedUserUseCase(auth),
        SaveUserCacheUseCase(auth),
        DeleteUserCacheUseCase(auth),
        ClearCacheUseCase(auth),
      );

  setUp(() => auth = _FakeAuth());

  test('com a conta no cache: entra na hora e revalida (mudou = atualiza)', () async {
    auth
      ..cached = user
      ..remote = Right(user.copyWith(favoriteTeam: 'Volta'));
    final cubit = build();
    final states = <SessionState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.restore();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(states.whereType<AuthenticatedSessionState>().map((s) => s.user?.favoriteTeam), ['Lava Jato', 'Volta']);
    expect(auth.cached?.favoriteTeam, 'Volta');
    await cubit.close();
  });

  test('sem rede com cache: fica logado com a conta do cache', () async {
    auth
      ..cached = user
      ..remote = Left(ErrorWithMessage('offline'));
    final cubit = build();
    await cubit.restore();
    expect(cubit.state, isA<AuthenticatedSessionState>());
    expect(cubit.state.user, user);
    await cubit.close();
  });

  test('sem cache e com falha: convidado (comportamento antigo)', () async {
    auth.remote = Left(ErrorWithMessage('offline'));
    final cubit = build();
    await cubit.restore();
    expect(cubit.state, isA<GuestSessionState>());
    await cubit.close();
  });

  test('sair da conta apaga o cache', () async {
    auth.cached = user;
    final cubit = build();
    await cubit.signOut();
    expect(auth.signedOut, isTrue);
    expect(auth.cleared, isTrue);
    expect(cubit.state, isA<GuestSessionState>());
    await cubit.close();
  });
}
