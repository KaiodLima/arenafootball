import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final SignInUseCase signInUseCase;

  LoginCubit(this.signInUseCase) : super(const InitialLoginState());

  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || !email.contains('@')) {
      emit(const InvalidLoginState(error: LoginValidationError.invalidEmail));
      return;
    }
    if (password.length < 8) {
      emit(const InvalidLoginState(error: LoginValidationError.invalidPassword));
      return;
    }

    emit(const LoadingLoginState());
    final response = await signInUseCase(email: email, password: password);
    response.fold(
      (failure) => emit(ErrorLoginState(errorMessage: failure.toString())),
      (user) => emit(SuccessLoginState(user: user)),
    );
  }
}
