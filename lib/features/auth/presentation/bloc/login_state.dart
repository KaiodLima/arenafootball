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

class ErrorLoginState extends LoginState {
  final String errorMessage;

  const ErrorLoginState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
