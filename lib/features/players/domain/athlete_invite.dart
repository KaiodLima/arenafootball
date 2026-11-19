import 'package:arena_soccer/l10n/app_localizations.dart';

/// Convite "Conheço esse jogador": a mensagem para quem é o atleta [name] (sem
/// conta) entrar no app, com o time, a competição (vazia = elenco geral), os
/// números e o link do atleta (que abre o perfil com o "É você?").
String athleteInviteText(
  AppLocalizations l10n, {
  required String name,
  required String team,
  String championship = '',
  int goals = 0,
  int assists = 0,
  required String link,
}) {
  final first = name.trim().split(RegExp(r'\s+')).first;
  final where =
      championship.trim().isEmpty ? l10n.athleteInviteTeam(team) : l10n.athleteInviteTeamIn(team, championship.trim());
  final numbers = goals > 0 || assists > 0 ? l10n.athleteInviteStats(goals, assists) : l10n.athleteInviteNoStats;
  return [
    l10n.athleteInviteTitle(first.isEmpty ? name : first),
    '',
    l10n.athleteInviteBody(name.trim(), where, numbers),
    '',
    l10n.athleteInviteBenefits,
    '',
    l10n.athleteInviteCta,
    link,
  ].join('\n');
}
