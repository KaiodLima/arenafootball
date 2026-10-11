import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final SignInUseCase signInUseCase;
  final SendPasswordResetUseCase sendPasswordResetUseCase;

  LoginCubit(this.signInUseCase, this.sendPasswordResetUseCase) : super(const InitialLoginState());

  /// Volta ao estado inicial antes de emitir um aviso: estados iguais
  /// (Equatable) não são reemitidos, e o snackbar não apareceria de novo.
  void _emitNotice(LoginState notice) {
    emit(const InitialLoginState());
    emit(notice);
  }

  /// Limpa avisos e erros anteriores (ex.: ao abrir o "esqueci minha senha").
  void clear() => emit(const InitialLoginState());

  static bool _isValidEmail(String email) => email.isNotEmpty && email.contains('@');

  Future<void> signIn({required String email, required String password}) async {
    if (!_isValidEmail(email)) {
      _emitNotice(const InvalidLoginState(error: LoginValidationError.invalidEmail));
      return;
    }
    if (password.length < 8) {
      _emitNotice(const InvalidLoginState(error: LoginValidationError.invalidPassword));
      return;
    }

    emit(const LoadingLoginState());
    final response = await signInUseCase(email: email, password: password);
    response.fold(
      (failure) => emit(ErrorLoginState(errorMessage: failure.toString())),
      (user) => emit(SuccessLoginState(user: user)),
    );
  }

  Future<void> sendPasswordReset(String email) async {
    if (!_isValidEmail(email.trim())) {
      _emitNotice(const InvalidLoginState(error: LoginValidationError.invalidEmail));
      return;
    }

    emit(const SendingPasswordResetLoginState());
    final response = await sendPasswordResetUseCase(email);
    response.fold(
      (failure) => emit(ErrorLoginState(errorMessage: failure.toString())),
      (_) => emit(const PasswordResetSentLoginState()),
    );
  }
}
