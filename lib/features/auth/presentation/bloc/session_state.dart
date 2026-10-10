import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

/// Sessão do app. Substitui o `Usuario`/`isAdmin` que era passado de
/// construtor em construtor.
class SessionState extends Equatable {
  final UserDTO? user;

  const SessionState({this.user});

  bool get isAuthenticated => user != null;

  bool get isAdmin => user?.isAdmin ?? false;

  @override
  List<Object?> get props => [user];
}

/// Ainda verificando se há usuário logado (splash).
class CheckingSessionState extends SessionState {
  const CheckingSessionState();
}

class AuthenticatedSessionState extends SessionState {
  const AuthenticatedSessionState({required UserDTO super.user});
}

/// Sem login: entrou pelo "Pular" ou saiu da conta.
class GuestSessionState extends SessionState {
  const GuestSessionState();
}
