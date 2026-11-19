import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

/// Como o admin vê o app (toggle do topo da home): admin, jogador (o atleta
/// da conta) ou torcedor (usuário comum).
enum AdminViewMode { admin, player, fan }

/// Sessão do app. Substitui o `Usuario`/`isAdmin` que era passado de
/// construtor em construtor.
class SessionState extends Equatable {
  final UserDTO? user;

  /// Modo jogador do admin (toggle do topo da home): o app trata a conta como
  /// a de um jogador — [isAdmin] fica falso e as telas escondem o que é do
  /// admin. Guardado no aparelho por conta; só vale para conta admin.
  final bool playerMode;

  /// Modo torcedor do admin: o app trata a conta como a de um usuário comum
  /// (sem admin, atleta, time, parceria nem campeonatos). Exclusivo com o
  /// [playerMode]; guardado no aparelho por conta; só vale para conta admin.
  final bool fanMode;

  const SessionState({this.user, this.playerMode = false, this.fanMode = false});

  bool get isAuthenticated => user != null;

  /// A conta é admin de verdade (o toggle e os avisos de admin usam este).
  bool get isAccountAdmin => user?.isAdmin ?? false;

  /// Admin em uso nas telas: a conta admin fora dos modos jogador e torcedor.
  bool get isAdmin => isAccountAdmin && !playerMode && !fanMode;

  /// Admin no modo jogador.
  bool get inPlayerMode => isAccountAdmin && playerMode && !fanMode;

  /// Admin no modo torcedor (vê o app como usuário comum).
  bool get inFanMode => isAccountAdmin && fanMode;

  /// O modo de visão do admin (conta comum: sempre [AdminViewMode.admin]).
  AdminViewMode get viewMode => inFanMode
      ? AdminViewMode.fan
      : inPlayerMode
          ? AdminViewMode.player
          : AdminViewMode.admin;

  @override
  List<Object?> get props => [user, playerMode, fanMode];
}

/// Ainda verificando se há usuário logado (splash).
class CheckingSessionState extends SessionState {
  const CheckingSessionState();
}

class AuthenticatedSessionState extends SessionState {
  const AuthenticatedSessionState({required UserDTO super.user, super.playerMode, super.fanMode});
}

/// Sem login: entrou pelo "Pular" ou saiu da conta.
class GuestSessionState extends SessionState {
  const GuestSessionState();
}
