import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/validators/email_validator.dart';
import 'package:arena_soccer/features/auth/domain/validators/password_strength.dart';

/// Erro de validação de um campo, traduzido na página via l10n.
enum RegisterFieldError { required, nameTooShort, invalidEmail, passwordTooShort, passwordMismatch }

/// Etapa 1 do cadastro (dados de acesso). O estado base carrega o formulário
/// inteiro, para ele sobreviver às transições Editing → Submitting → Error.
class RegisterUserState extends Equatable {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  /// Depois de uma tentativa de envio, todos os erros ficam visíveis.
  final bool submitAttempted;

  const RegisterUserState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.submitAttempted = false,
  });

  RegisterFieldError? get nameError {
    if (name.trim().isEmpty) return RegisterFieldError.required;
    if (name.trim().length < 3) return RegisterFieldError.nameTooShort;
    return null;
  }

  RegisterFieldError? get emailError {
    if (email.trim().isEmpty) return RegisterFieldError.required;
    if (!EmailValidator.isValid(email)) return RegisterFieldError.invalidEmail;
    return null;
  }

  RegisterFieldError? get passwordError {
    if (password.isEmpty) return RegisterFieldError.required;
    if (password.length < PasswordStrength.minLength) return RegisterFieldError.passwordTooShort;
    return null;
  }

  RegisterFieldError? get confirmPasswordError {
    if (confirmPassword.isEmpty) return RegisterFieldError.required;
    if (confirmPassword != password) return RegisterFieldError.passwordMismatch;
    return null;
  }

  PasswordStrength get passwordStrength => PasswordStrength.evaluate(password);

  bool get canSubmit =>
      nameError == null && emailError == null && passwordError == null && confirmPasswordError == null;

  @override
  List<Object?> get props => [name, email, password, confirmPassword, submitAttempted];
}

class EditingRegisterUserState extends RegisterUserState {
  const EditingRegisterUserState({
    super.name,
    super.email,
    super.password,
    super.confirmPassword,
    super.submitAttempted,
  });

  EditingRegisterUserState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? submitAttempted,
  }) {
    return EditingRegisterUserState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      submitAttempted: submitAttempted ?? this.submitAttempted,
    );
  }
}

class SubmittingRegisterUserState extends RegisterUserState {
  SubmittingRegisterUserState(RegisterUserState form)
      : super(
          name: form.name,
          email: form.email,
          password: form.password,
          confirmPassword: form.confirmPassword,
          submitAttempted: true,
        );
}

class SuccessRegisterUserState extends RegisterUserState {
  final UserDTO user;

  const SuccessRegisterUserState({required this.user});

  @override
  List<Object?> get props => [user];
}

class ErrorRegisterUserState extends RegisterUserState {
  final String errorMessage;

  ErrorRegisterUserState(RegisterUserState form, {required this.errorMessage})
      : super(
          name: form.name,
          email: form.email,
          password: form.password,
          confirmPassword: form.confirmPassword,
          submitAttempted: true,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
