import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card de gol do feed: filete verde, selo "GOL" e o placar em destaque.
class GoalCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;

  /// Toque no card (admin: abre o "Card de gol" com este placar).
  final VoidCallback? onTap;

  /// Toque no autor / em quem deu o passe (abre a tela do atleta). Nulos =
  /// só texto (ex.: a prévia do formulário).
  final VoidCallback? onScorerTap;
  final VoidCallback? onAssistantTap;

  const GoalCard({
    super.key,
    required this.news,
    this.trailing,
    this.onTap,
    this.onScorerTap,
    this.onAssistantTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final teamStyle = AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16);

    return ArenaCard(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: AppSizes.s6, color: AppColors.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s12, AppSizes.s8, AppSizes.s14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(AppSizes.s8),
                          ),
                          child: Text(
                            '⚽ ${l10n.newsGoalLabel}',
                            style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                          ),
                        ),
                        // Escudo do time que marcou (cards novos).
                        if (news.scoringTeamCrest.isNotEmpty) ...[
                          const SizedBox(width: AppSizes.s8),
                          Tooltip(
                            message: news.scoringTeam,
                            child: TeamCrest(imageUrl: news.scoringTeamCrest, size: AppSizes.s24),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSizes.s10),
                    Row(
                      children: [
                        Flexible(
                          child: Text(news.homeTeam, maxLines: 1, overflow: TextOverflow.ellipsis, style: teamStyle),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                          child: Text(
                            '${news.homeGoals} × ${news.awayGoals}',
                            style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
                          ),
                        ),
                        Flexible(
                          child: Text(news.awayTeam, maxLines: 1, overflow: TextOverflow.ellipsis, style: teamStyle),
                        ),
                      ],
                    ),
                    if (news.hasScorer) ...[
                      const SizedBox(height: AppSizes.s8),
                      Wrap(
                        spacing: AppSizes.s6,
                        runSpacing: AppSizes.s6,
                        children: [
                          _PersonChip(
                            icon: Icons.sports_soccer_rounded,
                            name: news.scorerName,
                            tooltip: l10n.athleteScored,
                            onTap: onScorerTap,
                          ),
                          if (news.hasAssistant)
                            _PersonChip(
                              icon: Icons.assistant_rounded,
                              name: news.assistantName,
                              tooltip: l10n.athleteAssisted,
                              onTap: onAssistantTap,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.topCenter, child: trailing!)
            else
              Padding(
                padding: const EdgeInsets.all(AppSizes.s10),
                child: Image.asset(AppImages.ballInNet, width: AppSizes.s48, fit: BoxFit.contain),
              ),
          ],
        ),
      ),
    );
  }
}

/// "⚽ Arineto" / "✦ Ariel": quem marcou ou deu o passe. Tocável quando há
/// [onTap] (o toque não chega ao card).
class _PersonChip extends StatelessWidget {
  final IconData icon;
  final String name;
  final String tooltip;
  final VoidCallback? onTap;

  const _PersonChip({required this.icon, required this.name, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s4, AppSizes.s6, AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s14, color: AppColors.primaryDark),
          const SizedBox(width: AppSizes.s4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right_rounded, size: AppSizes.s14, color: AppColors.textSecondary),
        ],
      ),
    );
    if (onTap == null) return Semantics(label: '$tooltip: $name', child: chip);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(borderRadius: BorderRadius.circular(AppSizes.s16), onTap: onTap, child: chip),
      ),
    );
  }
}
