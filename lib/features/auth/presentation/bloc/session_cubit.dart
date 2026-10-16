import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/account_provider.dart';
import 'package:arena_soccer/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignOutUseCase signOutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  SessionCubit(this.getCurrentUserUseCase, this.signOutUseCase, this.deleteAccountUseCase)
      : super(const CheckingSessionState());

  /// Restaura a sessão do FirebaseAuth (auto-login).
  Future<void> restore() async {
    emit(const CheckingSessionState());
    final response = await getCurrentUserUseCase();
    response.fold(
      (_) => emit(const GuestSessionState()),
      (user) => emit(user == null ? const GuestSessionState() : AuthenticatedSessionState(user: user)),
    );
  }

  void signedIn(UserDTO user) => emit(AuthenticatedSessionState(user: user));

  /// Atualiza os dados do usuário logado (ex.: time escolhido na etapa 2).
  void updateUser(UserDTO user) {
    if (state.isAuthenticated) emit(AuthenticatedSessionState(user: user));
  }

  void continueAsGuest() => emit(const GuestSessionState());

  Future<void> signOut() async {
    await signOutUseCase();
    emit(const GuestSessionState());
  }

  AccountProvider get accountProvider => deleteAccountUseCase.provider;

  /// Exclui a conta logada. Devolve a falha (nula = excluída; código
  /// [deleteAccountCanceledCode] = o usuário desistiu na folha do Google/Apple).
  /// O resultado vai direto para o sheet de confirmação, que mostra o erro nele.
  Future<Failure?> deleteAccount({String? password}) async {
    final response = await deleteAccountUseCase(password: password);
    if (response.isLeft) return response.left;
    emit(const GuestSessionState());
    return null;
  }
}
