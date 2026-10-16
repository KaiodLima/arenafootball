import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

/// Motivo de validação local, traduzido na página via l10n.
enum LoginValidationError { invalidEmail, invalidPassword }

class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class InitialLoginState extends LoginState {
  const InitialLoginState();
}

class LoadingLoginState extends LoginState {
  const LoadingLoginState();
}

/// Login com Google em andamento (spinner só no botão do Google).
class GoogleLoadingLoginState extends LoginState {
  const GoogleLoadingLoginState();
}

/// Login com Apple em andamento (spinner só no botão da Apple).
class AppleLoadingLoginState extends LoginState {
  const AppleLoadingLoginState();
}

class SuccessLoginState extends LoginState {
  final UserDTO user;

  const SuccessLoginState({required this.user});

  @override
  List<Object?> get props => [user];
}

class InvalidLoginState extends LoginState {
  final LoginValidationError error;

  const InvalidLoginState({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Enviando o e-mail de "esqueci minha senha".
class SendingPasswordResetLoginState extends LoginState {
  const SendingPasswordResetLoginState();
}

class PasswordResetSentLoginState extends LoginState {
  const PasswordResetSentLoginState();
}

class ErrorLoginState extends LoginState {
  final String errorMessage;

  const ErrorLoginState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
