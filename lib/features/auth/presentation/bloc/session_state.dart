import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

/// Sessão do app. Substitui o `Usuario`/`isAdmin` que era passado de
/// construtor em construtor.
class SessionState extends Equatable {
  final UserDTO? user;

  /// Modo jogador do admin (toggle do topo da home): o app trata a conta como
  /// a de um jogador — [isAdmin] fica falso e as telas escondem o que é do
  /// admin. Guardado no aparelho por conta; só vale para conta admin.
  final bool playerMode;

  const SessionState({this.user, this.playerMode = false});

  bool get isAuthenticated => user != null;

  /// A conta é admin de verdade (o toggle e os avisos de admin usam este).
  bool get isAccountAdmin => user?.isAdmin ?? false;

  /// Admin em uso nas telas: a conta admin fora do modo jogador.
  bool get isAdmin => isAccountAdmin && !playerMode;

  /// Admin no modo jogador.
  bool get inPlayerMode => isAccountAdmin && playerMode;

  @override
  List<Object?> get props => [user, playerMode];
}

/// Ainda verificando se há usuário logado (splash).
class CheckingSessionState extends SessionState {
  const CheckingSessionState();
}

class AuthenticatedSessionState extends SessionState {
  const AuthenticatedSessionState({required UserDTO super.user, super.playerMode});
}

/// Sem login: entrou pelo "Pular" ou saiu da conta.
class GuestSessionState extends SessionState {
  const GuestSessionState();
}
