import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';

/// Sigla da vaga no campinho ("GOL", "ZAG", "MEI", "ATA", "LIVRE").
String fantasySlotLabel(AppLocalizations l10n, FantasySlot slot) => switch (slot) {
      FantasySlot.goalkeeper => l10n.fantasySlotGoalkeeper,
      FantasySlot.defender => l10n.fantasySlotDefender,
      FantasySlot.midfielder => l10n.fantasySlotMidfielder,
      FantasySlot.forward => l10n.fantasySlotForward,
      FantasySlot.flex => l10n.fantasySlotFlex,
    };

/// Sigla pela chave da posição gravada pelas functions (`gol`/`zag`/`mei`/`ata`).
String fantasyPositionLabelOfKey(AppLocalizations l10n, String key) {
  final slot = FantasySlot.fromKey(key);
  return slot == null ? '' : fantasySlotLabel(l10n, slot);
}

/// Título da folha de atletas da vaga.
String fantasyPickTitle(AppLocalizations l10n, FantasySlot slot) => switch (slot) {
      FantasySlot.goalkeeper => l10n.fantasyPickGoalkeeper,
      FantasySlot.defender => l10n.fantasyPickDefender,
      FantasySlot.midfielder => l10n.fantasyPickMidfielder,
      FantasySlot.forward => l10n.fantasyPickForward,
      FantasySlot.flex => l10n.fantasyPickFlex,
    };

/// Sigla da posição do atleta (a vaga fixa dele).
String fantasyPositionLabel(AppLocalizations l10n, String position) {
  final slot = fantasySlotOf(position);
  return slot == null ? '' : fantasySlotLabel(l10n, slot);
}

/// "Fecha em 2d 4h" / "3h 20min" / "12min" até [closesAt].
String fantasyDeadlineLabel(AppLocalizations l10n, DateTime closesAt, DateTime now) {
  final left = closesAt.difference(now);
  if (left.isNegative) return l10n.fantasyRoundLocked;
  final days = left.inDays;
  final hours = left.inHours % 24;
  final minutes = left.inMinutes % 60;
  final text = days > 0
      ? '${days}d ${hours}h'
      : left.inHours > 0
          ? '${left.inHours}h ${minutes}min'
          : '${left.inMinutes < 1 ? 1 : left.inMinutes}min';
  return l10n.fantasyClosesIn(text);
}

/// Nome da regra da pontuação (`regra` das functions).
String fantasyRuleLabel(AppLocalizations l10n, String rule) => switch (rule) {
      'base' => l10n.fantasyRuleBase,
      'gol' => l10n.fantasyRuleGoal,
      'assistencia' => l10n.fantasyRuleAssist,
      'vitoria' => l10n.fantasyRuleWin,
      'derrota' => l10n.fantasyRuleLoss,
      'empate' => l10n.fantasyRuleDraw,
      'amarelo' => l10n.fantasyRuleYellow,
      'vermelho' => l10n.fantasyRuleRed,
      'gols_sofridos' => l10n.fantasyRuleConceded,
      'gols_equipe' => l10n.fantasyRuleTeamGoals,
      'sem_sofrer_gols' => l10n.fantasyRuleCleanSheet,
      _ => rule,
    };

/// Texto do motivo (por que não pontuou / observação) do [score].
String fantasyReasonLabel(AppLocalizations l10n, FantasyScoreReason reason, FantasyAthleteScoreDTO score) =>
    switch (reason.code) {
      'minutos_insuficientes' => l10n.fantasyReasonShort(score.minMinutes, score.minutesIn(reason.matchId)),
      'bonus_minutos_insuficientes' => l10n.fantasyReasonNoBonus(score.minDefenseMinutes),
      'nao_entrou' => l10n.fantasyReasonNotOnField,
      'sem_escalacao' => l10n.fantasyReasonNoLineup,
      'substituicao_sem_minuto' => l10n.fantasyReasonSubNoMinute,
      'minutos_estimados' => l10n.fantasyReasonEstimated,
      'sem_posicao' => l10n.fantasyReasonNoPosition,
      'nao_jogou' => l10n.fantasyReasonDidNotPlay,
      'sem_partidas' => l10n.fantasyReasonNoMatches,
      _ => reason.code,
    };
