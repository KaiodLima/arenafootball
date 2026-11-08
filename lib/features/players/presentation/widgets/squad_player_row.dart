import 'package:flutter/material.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Largura de cada coluna de número (G, A), igual no título e nas linhas.
const double _statColumn = AppSizes.s32;

/// Título do setor no plural ("Goleiros"); nulo = "Sem posição".
String squadSectionTitle(AppLocalizations l10n, PlayerPosition? position) => switch (position) {
      PlayerPosition.goalkeeper => l10n.squadGoalkeepers,
      PlayerPosition.defender => l10n.squadDefenders,
      PlayerPosition.fullBack => l10n.squadFullBacks,
      PlayerPosition.defensiveMidfielder => l10n.squadDefensiveMidfielders,
      PlayerPosition.midfielder => l10n.squadMidfielders,
      PlayerPosition.forward => l10n.squadForwards,
      null => l10n.squadNoPosition,
    };

/// Ação do menu "⋮" da linha do atleta.
class SquadRowAction {
  final IconData icon;
  final String label;
  final VoidCallback onSelected;
  final bool destructive;

  const SquadRowAction({required this.icon, required this.label, required this.onSelected, this.destructive = false});
}

/// Bloco do elenco: título do setor (ou "Atletas") com a contagem e as
/// colunas G/A, e as linhas num cartão com divisórias finas (estilo das
/// páginas de time dos apps de futebol).
class SquadSectionCard extends StatelessWidget {
  final SquadSection section;
  final Color accent;
  final int Function(PlayerDTO) goalsOf;
  final int Function(PlayerDTO) assistsOf;
  final String? topScorerId;
  final void Function(PlayerDTO) onTap;
  final List<SquadRowAction> Function(PlayerDTO) actionsOf;

  const SquadSectionCard({
    super.key,
    required this.section,
    required this.accent,
    required this.goalsOf,
    required this.assistsOf,
    required this.topScorerId,
    required this.onTap,
    required this.actionsOf,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = section.grouped ? squadSectionTitle(l10n, section.position) : l10n.squadAllPlayers;
    final players = section.players;
    final hasActions = players.any((p) => actionsOf(p).isNotEmpty);
    final columnLabel = AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s4, 0, AppSizes.s12, AppSizes.s8),
            child: Row(
              children: [
                Container(
                  width: AppSizes.s4,
                  height: AppSizes.s16,
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(AppSizes.s2)),
                ),
                const SizedBox(width: AppSizes.s8),
                Text(title.toUpperCase(),
                    style: AppTypography.label(color: AppColors.textPrimary).copyWith(letterSpacing: 0.6)),
                const SizedBox(width: AppSizes.s6),
                Text('${players.length}', style: columnLabel),
                const Spacer(),
                SizedBox(
                    width: _statColumn,
                    child: Text(l10n.squadGoalsShort, textAlign: TextAlign.center, style: columnLabel)),
                SizedBox(
                    width: _statColumn,
                    child: Text(l10n.squadAssistsShort, textAlign: TextAlign.center, style: columnLabel)),
                if (hasActions) const SizedBox(width: AppSizes.s36),
              ],
            ),
          ),
          ArenaCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < players.length; i++) ...[
                  if (i > 0) const Divider(height: 1, thickness: 0.6, indent: AppSizes.s64, color: AppColors.greyLight),
                  SquadPlayerRow(
                    player: players[i],
                    rank: section.ranked ? i + 1 : null,
                    goals: goalsOf(players[i]),
                    assists: assistsOf(players[i]),
                    accent: accent,
                    isTopScorer: players[i].id == topScorerId,
                    onTap: () => onTap(players[i]),
                    actions: actionsOf(players[i]),
                    reserveActionSpace: hasActions,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha do atleta: (posição no ranking), foto com anel na cor do time, nome
/// com a coroa do artilheiro, setor e as colunas G e A alinhadas.
class SquadPlayerRow extends StatelessWidget {
  final PlayerDTO player;
  final int? rank;
  final int goals;
  final int assists;
  final Color accent;
  final bool isTopScorer;
  final VoidCallback onTap;
  final List<SquadRowAction> actions;

  /// Deixa o espaço do "⋮" mesmo sem ações (colunas alinhadas no bloco).
  final bool reserveActionSpace;

  const SquadPlayerRow({
    super.key,
    required this.player,
    required this.goals,
    required this.assists,
    required this.accent,
    required this.onTap,
    this.rank,
    this.isTopScorer = false,
    this.actions = const [],
    this.reserveActionSpace = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final position = PlayerPosition.fromKey(player.position);
    final number = AppTypography.title(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16);
    final muted = AppTypography.title(color: AppColors.greyLight).copyWith(fontSize: AppSizes.s16);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s12, AppSizes.s10),
        child: Row(
          children: [
            if (rank != null)
              SizedBox(
                width: AppSizes.s24,
                child: Text(
                  '$rank',
                  style: AppTypography.label(color: rank! <= 3 ? accent : AppColors.textSecondary),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(AppSizes.s2),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent, width: 1.5)),
              child: PlayerAvatar(player: player, size: AppSizes.s40),
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                        ),
                      ),
                      if (isTopScorer) ...[
                        const SizedBox(width: AppSizes.s4),
                        Tooltip(
                          message: l10n.playersTopScorer,
                          child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s16),
                        ),
                      ],
                    ],
                  ),
                  if (position != null)
                    Text(
                      playerPositionLabel(l10n, position),
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                ],
              ),
            ),
            SizedBox(
                width: _statColumn,
                child: Text('$goals', textAlign: TextAlign.center, style: goals > 0 ? number : muted)),
            SizedBox(
              width: _statColumn,
              child: Text('$assists', textAlign: TextAlign.center, style: assists > 0 ? number : muted),
            ),
            if (actions.isNotEmpty)
              SizedBox(
                width: AppSizes.s36,
                child: PopupMenuButton<int>(
                  tooltip: l10n.squadPlayerActions,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
                  onSelected: (index) => actions[index].onSelected(),
                  itemBuilder: (_) => [
                    for (var i = 0; i < actions.length; i++)
                      PopupMenuItem<int>(
                        value: i,
                        child: Row(
                          children: [
                            Icon(
                              actions[i].icon,
                              size: AppSizes.s20,
                              color: actions[i].destructive ? AppColors.danger : AppColors.textPrimary,
                            ),
                            const SizedBox(width: AppSizes.s10),
                            Text(actions[i].label),
                          ],
                        ),
                      ),
                  ],
                ),
              )
            else if (reserveActionSpace)
              const SizedBox(width: AppSizes.s36),
          ],
        ),
      ),
    );
  }
}
