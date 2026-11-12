import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/account_provider.dart';
import 'package:arena_soccer/features/auth/domain/usecases/clear_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/delete_user_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/save_user_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignOutUseCase signOutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final GetCachedUserUseCase getCachedUserUseCase;
  final SaveUserCacheUseCase saveUserCacheUseCase;
  final DeleteUserCacheUseCase deleteUserCacheUseCase;
  final ClearCacheUseCase clearCacheUseCase;

  /// Onde o modo jogador do admin fica guardado (nulo nos testes antigos).
  final PreferencesService? preferences;

  SessionCubit(
    this.getCurrentUserUseCase,
    this.signOutUseCase,
    this.deleteAccountUseCase,
    this.getCachedUserUseCase,
    this.saveUserCacheUseCase,
    this.deleteUserCacheUseCase,
    this.clearCacheUseCase, [
    this.preferences,
  ]) : super(const CheckingSessionState());

  /// O modo jogador guardado para a conta (só conta admin).
  Future<bool> _savedPlayerMode(UserDTO user) async {
    final prefs = preferences;
    if (!user.isAdmin || prefs == null) return false;
    return prefs.getPlayerMode(user.id);
  }

  Future<AuthenticatedSessionState> _authenticated(UserDTO user) async =>
      AuthenticatedSessionState(user: user, playerMode: await _savedPlayerMode(user));

  /// Liga/desliga o modo jogador do admin (toggle do topo da home).
  Future<void> setPlayerMode(bool value) async {
    final user = state.user;
    if (user == null || !user.isAdmin || state.playerMode == value) return;
    emit(AuthenticatedSessionState(user: user, playerMode: value));
    await preferences?.setPlayerMode(user.id, value);
  }

  static const String _logName = 'SessionCubit';

  /// Restaura a sessão do FirebaseAuth (auto-login). Com a conta salva no
  /// cache, entra na hora (funciona sem rede) e revalida sempre em seguida:
  /// mudou (admin, time, foto), atualiza; falhou, fica com a do cache.
  Future<void> restore() async {
    emit(const CheckingSessionState());
    final cachedResponse = await getCachedUserUseCase();
    final cached = cachedResponse.isRight ? cachedResponse.right?.data : null;
    if (cached != null) emit(await _authenticated(cached));

    final response = await getCurrentUserUseCase();
    if (response.isLeft) {
      if (cached == null) {
        emit(const GuestSessionState());
      } else {
        AppLogger.d('restore falhou, mantendo o cache: ${response.left}', name: _logName);
      }
      return;
    }
    final user = response.right;
    if (user == null) {
      await deleteUserCacheUseCase();
      emit(const GuestSessionState());
      return;
    }
    await saveUserCacheUseCase(user);
    if (user != cached) emit(await _authenticated(user));
  }

  Future<void> signedIn(UserDTO user) async {
    emit(await _authenticated(user));
    await saveUserCacheUseCase(user);
  }

  /// Atualiza os dados do usuário logado (ex.: time escolhido na etapa 2).
  Future<void> updateUser(UserDTO user) async {
    if (!state.isAuthenticated) return;
    // Mantém o modo (deixou de ser admin, o modo some sozinho: `isAccountAdmin`).
    emit(AuthenticatedSessionState(user: user, playerMode: state.playerMode && user.isAdmin));
    await saveUserCacheUseCase(user);
  }

  void continueAsGuest() => emit(const GuestSessionState());

  /// Sai da conta e apaga todo o cache local.
  Future<void> signOut() async {
    await signOutUseCase();
    await clearCacheUseCase();
    emit(const GuestSessionState());
  }

  AccountProvider get accountProvider => deleteAccountUseCase.provider;

  /// Exclui a conta logada. Devolve a falha (nula = excluída; código
  /// [deleteAccountCanceledCode] = o usuário desistiu na folha do Google/Apple).
  /// O resultado vai direto para o sheet de confirmação, que mostra o erro nele.
  Future<Failure?> deleteAccount({String? password}) async {
    final response = await deleteAccountUseCase(password: password);
    if (response.isLeft) return response.left;
    // Conta excluída: nada dela fica no aparelho (como no logout).
    await clearCacheUseCase();
    emit(const GuestSessionState());
    return null;
  }
}
