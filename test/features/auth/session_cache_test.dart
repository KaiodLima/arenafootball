import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arena_soccer/core/firebase/test_content.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:arena_soccer/features/auth/domain/usecases/clear_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/delete_user_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_current_user_cache_first_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/save_user_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';

class _FakeAuth implements IAuthRepository {
  UserDTO? cached;

  /// Quando o cache foi gravado (padrão: agora, dentro da validade).
  DateTime? cachedAt;
  Either<Failure, UserDTO?> remote = const Right(null);
  int remoteCalls = 0;
  bool cleared = false;
  bool signedOut = false;

  @override
  Future<Either<Failure, CachedValue<UserDTO>?>> getCachedUser() async =>
      Right(cached == null ? null : CachedValue(cached!, cachedAt ?? DateTime.now()));

  @override
  Future<Either<Failure, void>> saveUserCache(UserDTO user) async {
    cached = user;
    cachedAt = DateTime.now();
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
  Future<Either<Failure, UserDTO?>> getCurrentUser() async {
    remoteCalls++;
    return remote;
  }

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

  SessionCubit build([PreferencesService? preferences]) => SessionCubit(
        GetCurrentUserCacheFirstUseCase(
          GetCurrentUserUseCase(auth),
          GetCachedUserUseCase(auth),
          SaveUserCacheUseCase(auth),
          DeleteUserCacheUseCase(auth),
        ),
        SignOutUseCase(auth),
        DeleteAccountUseCase(auth),
        SaveUserCacheUseCase(auth),
        ClearCacheUseCase(auth),
        preferences,
      );

  test('modo jogador: no modo o admin deixa de ser admin nas telas; a conta continua admin', () {
    const admin = UserDTO(id: 'adm', name: 'Admin', email: 'a@x.com', isAdmin: true);
    const normal = AuthenticatedSessionState(user: admin);
    expect((normal.isAdmin, normal.isAccountAdmin, normal.inPlayerMode), (true, true, false));
    const player = AuthenticatedSessionState(user: admin, playerMode: true);
    expect((player.isAdmin, player.isAccountAdmin, player.inPlayerMode), (false, true, true));
    // Conta comum ignora o modo.
    const fan = AuthenticatedSessionState(user: user, playerMode: true);
    expect((fan.isAdmin, fan.inPlayerMode), (false, false));
  });

  test('modo jogador: liga, fica guardado no aparelho, volta ao entrar e zera no logout', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    const admin = UserDTO(id: 'adm', name: 'Admin', email: 'a@x.com', isAdmin: true);
    final cubit = build(prefs);
    await cubit.signedIn(admin);
    expect(cubit.state.inPlayerMode, isFalse);
    await cubit.setPlayerMode(true);
    expect(cubit.state.inPlayerMode, isTrue);
    expect(cubit.state.isAdmin, isFalse);

    final again = build(prefs);
    await again.signedIn(admin);
    expect(again.state.inPlayerMode, isTrue, reason: 'lembrado no aparelho');
    await again.signOut();
    expect(again.state.inPlayerMode, isFalse);

    // Conta comum não liga o modo.
    final fan = build(prefs);
    await fan.signedIn(user);
    await fan.setPlayerMode(true);
    expect(fan.state.playerMode, isFalse);
  });

  test('modo torcedor: sem admin nas telas, exclusivo com o jogador, guardado e sem as partidas de teste', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    const admin = UserDTO(id: 'adm', name: 'Admin', email: 'a@x.com', isAdmin: true);
    const fanState = AuthenticatedSessionState(user: admin, fanMode: true);
    expect((fanState.isAdmin, fanState.isAccountAdmin, fanState.inFanMode, fanState.inPlayerMode),
        (false, true, true, false));
    expect(fanState.viewMode, AdminViewMode.fan);
    // Conta comum ignora o modo.
    expect(const AuthenticatedSessionState(user: user, fanMode: true).inFanMode, isFalse);

    final cubit = build(prefs);
    await cubit.signedIn(admin);
    expect(TestContent.visible, isTrue);
    await cubit.setViewMode(AdminViewMode.player);
    await cubit.setViewMode(AdminViewMode.fan);
    expect((cubit.state.inFanMode, cubit.state.inPlayerMode, cubit.state.isAdmin), (true, false, false));
    expect(TestContent.visible, isFalse, reason: 'o torcedor não vê partida de teste');

    final again = build(prefs);
    await again.signedIn(admin);
    expect(again.state.inFanMode, isTrue, reason: 'lembrado no aparelho');
    await again.setViewMode(AdminViewMode.admin);
    expect((again.state.isAdmin, again.state.inFanMode), (true, false));
    TestContent.configure(visible: false);
  });

  setUp(() => auth = _FakeAuth());

  test('cache vencido: entra na hora com o cache e revalida (mudou = atualiza)', () async {
    auth
      ..cached = user
      ..cachedAt = DateTime.now().subtract(const Duration(hours: 1))
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

  test('cache válido (30 min): entra com o cache sem ler o Firestore; force relê', () async {
    auth
      ..cached = user
      ..remote =
          const Right(UserDTO(id: 'u1', name: 'Kaio', email: 'k@x.com', favoriteTeam: 'Lava Jato', isAdmin: true));
    final cubit = build();
    await cubit.restore();
    expect(auth.remoteCalls, 0);
    expect(cubit.state.user, user);

    await cubit.restore(force: true);
    expect(auth.remoteCalls, 1);
    expect(cubit.state.user?.isAdmin, isTrue);
    expect(auth.cached?.isAdmin, isTrue);
    await cubit.close();
  });

  test('sessão encerrada no FirebaseAuth: convidado e sem o cache da conta', () async {
    final cubit = build();
    await cubit.restore();
    expect(auth.remoteCalls, 1);
    expect(cubit.state, isA<GuestSessionState>());
    await cubit.close();
  });

  test('sem rede com cache: fica logado com a conta do cache', () async {
    auth
      ..cachedAt = DateTime.now().subtract(const Duration(hours: 1))
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
