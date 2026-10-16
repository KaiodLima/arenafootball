import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final SignInUseCase signInUseCase;
  final SendPasswordResetUseCase sendPasswordResetUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithAppleUseCase signInWithAppleUseCase;

  LoginCubit(
    this.signInUseCase,
    this.sendPasswordResetUseCase,
    this.signInWithGoogleUseCase,
    this.signInWithAppleUseCase,
  ) : super(const InitialLoginState());

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

  Future<void> signInWithGoogle() async {
    emit(const GoogleLoadingLoginState());
    final response = await signInWithGoogleUseCase();
    response.fold(
      (failure) => emit(ErrorLoginState(errorMessage: failure.toString())),
      // Seletor de contas fechado: só volta ao estado inicial, sem erro.
      (user) => emit(user == null ? const InitialLoginState() : SuccessLoginState(user: user)),
    );
  }

  Future<void> signInWithApple() async {
    emit(const AppleLoadingLoginState());
    final response = await signInWithAppleUseCase();
    response.fold(
      (failure) => emit(ErrorLoginState(errorMessage: failure.toString())),
      // Folha da Apple fechada: só volta ao estado inicial, sem erro.
      (user) => emit(user == null ? const InitialLoginState() : SuccessLoginState(user: user)),
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
