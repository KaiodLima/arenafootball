import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignOutUseCase signOutUseCase;

  SessionCubit(this.getCurrentUserUseCase, this.signOutUseCase) : super(const CheckingSessionState());

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

  void continueAsGuest() => emit(const GuestSessionState());

  Future<void> signOut() async {
    await signOutUseCase();
    emit(const GuestSessionState());
  }
}
