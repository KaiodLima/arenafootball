import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';

/// Troca do time do coração: uma a cada [cooldown]. A primeira escolha (conta
/// sem time) é livre e não conta. As regras do Firestore conferem o mesmo prazo.
class TeamChangePolicy {
  static const Duration cooldown = Duration(days: 15);

  /// A partir de quando a conta pode trocar de time; nulo = já pode.
  static DateTime? nextChangeAt(UserDTO user) {
    final last = user.teamChangedAt;
    if (!user.hasFavoriteTeam || last == null) return null;
    return last.add(cooldown);
  }

  static bool canChange(UserDTO user, DateTime now) {
    final next = nextChangeAt(user);
    return next == null || !now.isBefore(next);
  }

  /// Escolher [teamId]/[team] é uma troca (sai de um time para outro)?
  static bool isChange(UserDTO user, {required String team, required String teamId}) =>
      user.hasFavoriteTeam && !sameTeam(idA: user.favoriteTeamId, nameA: user.favoriteTeam, idB: teamId, nameB: team);
}

/// Troca de time antes do prazo. [nextAt] nulo = a data não é conhecida no
/// aparelho (o servidor recusou).
class TeamChangeLockedFailure extends ErrorWithMessage {
  final DateTime? nextAt;

  TeamChangeLockedFailure(this.nextAt) : super('Troca de time ainda não liberada.', code: 'team-change-locked');
}
