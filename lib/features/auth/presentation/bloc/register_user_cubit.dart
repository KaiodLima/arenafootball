import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_state.dart';

/// Etapa 1 do cadastro: cria a conta. Região e time ficam para a etapa 2
/// ([ChooseTeamCubit]), porque sem login o Firestore não libera a leitura.
class RegisterUserCubit extends Cubit<RegisterUserState> {
  final SignUpUseCase signUpUseCase;

  RegisterUserCubit(this.signUpUseCase) : super(const EditingRegisterUserState());

  EditingRegisterUserState get _form => EditingRegisterUserState(
        name: state.name,
        email: state.email,
        password: state.password,
        confirmPassword: state.confirmPassword,
        submitAttempted: state.submitAttempted,
      );

  void changeName(String value) => emit(_form.copyWith(name: value));

  void changeEmail(String value) => emit(_form.copyWith(email: value));

  void changePassword(String value) => emit(_form.copyWith(password: value));

  void changeConfirmPassword(String value) => emit(_form.copyWith(confirmPassword: value));

  Future<void> submit() async {
    if (state is SubmittingRegisterUserState) return;
    if (!state.canSubmit) {
      // Mostra todos os erros de uma vez em vez de só travar o botão.
      emit(_form.copyWith(submitAttempted: true));
      return;
    }

    final form = state;
    emit(SubmittingRegisterUserState(form));
    final response = await signUpUseCase(name: form.name, email: form.email, password: form.password);
    response.fold(
      (failure) => emit(ErrorRegisterUserState(form, errorMessage: failure.toString())),
      (user) => emit(SuccessRegisterUserState(user: user)),
    );
  }
}
