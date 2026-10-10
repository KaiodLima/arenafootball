import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

/// Erro de validação de um campo, traduzido na página via l10n.
enum RegisterFieldError { required, nameTooShort, invalidEmail, passwordTooShort }

/// O estado base carrega o formulário inteiro, para ele sobreviver às
/// transições Editing → Submitting → Error.
class RegisterUserState extends Equatable {
  final String name;
  final String email;
  final String password;
  final List<String> regions;
  final String? selectedRegion;
  final List<String> teams;
  final String? selectedTeam;

  const RegisterUserState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.selectedTeam,
  });

  RegisterFieldError? get nameError {
    if (name.isEmpty) return RegisterFieldError.required;
    if (name.trim().length < 3) return RegisterFieldError.nameTooShort;
    return null;
  }

  RegisterFieldError? get emailError {
    if (email.isEmpty) return RegisterFieldError.required;
    if (!email.contains('@') || !email.contains('.')) return RegisterFieldError.invalidEmail;
    return null;
  }

  RegisterFieldError? get passwordError {
    if (password.isEmpty) return RegisterFieldError.required;
    if (password.length < 8) return RegisterFieldError.passwordTooShort;
    return null;
  }

  bool get canSubmit => nameError == null && emailError == null && passwordError == null && selectedTeam != null;

  @override
  List<Object?> get props => [name, email, password, regions, selectedRegion, teams, selectedTeam];
}

class EditingRegisterUserState extends RegisterUserState {
  const EditingRegisterUserState({
    super.name,
    super.email,
    super.password,
    super.regions,
    super.selectedRegion,
    super.teams,
    super.selectedTeam,
  });

  EditingRegisterUserState copyWith({
    String? name,
    String? email,
    String? password,
    List<String>? regions,
    String? selectedRegion,
    List<String>? teams,
    String? selectedTeam,
    bool clearTeam = false,
  }) {
    return EditingRegisterUserState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      teams: teams ?? this.teams,
      selectedTeam: clearTeam ? null : (selectedTeam ?? this.selectedTeam),
    );
  }
}

class SubmittingRegisterUserState extends RegisterUserState {
  SubmittingRegisterUserState(RegisterUserState form)
      : super(
          name: form.name,
          email: form.email,
          password: form.password,
          regions: form.regions,
          selectedRegion: form.selectedRegion,
          teams: form.teams,
          selectedTeam: form.selectedTeam,
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
          regions: form.regions,
          selectedRegion: form.selectedRegion,
          teams: form.teams,
          selectedTeam: form.selectedTeam,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
