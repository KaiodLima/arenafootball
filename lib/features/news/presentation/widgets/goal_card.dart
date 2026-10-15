import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/goal_card_background.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Card de gol do feed, no molde da carteirinha e do card do melhor da
/// partida: formato fixo 2,4:1 com fundo próprio ([GoalCardBackground]) nas
/// cores do time que marcou (verde nos cards antigos, sem cor gravada), o
/// escudo do time dentro do escudo desenhado e o conteúdo em proporção à
/// largura.
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

  /// Cores do card. O destaque (escudo, pinceladas, "GOL!") é a principal;
  /// se ela for clara demais (ex.: branco) e a secundária não, os papéis se
  /// invertem: escurecer o branco daria cinza, que não é cor do time. Com as
  /// duas claras, o tom escuro vem da secundária. Sem cor, verde.
  static TeamPalette paletteFor(String primary, String secondary) {
    final first = colorFromHex(primary);
    final second = colorFromHex(secondary);
    if (first == null || second == null || !isLightColor(first)) return TeamPalette.orDefault(primary, secondary);
    if (!isLightColor(second)) return TeamPalette.orDefault(secondary, primary);
    final palette = TeamPalette.orDefault(primary, secondary);
    return TeamPalette(
      background: palette.background,
      onBackground: palette.onBackground,
      accent: palette.accent,
      accentDark: Color.lerp(second, AppColors.black, 0.3)!,
      onAccent: palette.onAccent,
      bar: palette.bar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = paletteFor(news.scoringTeamPrimaryColor, news.scoringTeamSecondaryColor);
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s14),
      child: AspectRatio(
        aspectRatio: 2.4,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(color: AppColors.black.withValues(alpha: 0.14), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: GoalCardBackground(
              palette: palette,
              child: Material(
                color: AppColors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.biggest;
                      final width = size.width;
                      final shield = GoalCardBackground.shieldRect(size);
                      final crestCenter = GoalCardBackground.shieldCenter(size);
                      final crestSize = shield.width * 0.62;
                      final teamStyle = AppTypography.label(color: AppColors.textPrimary)
                          .copyWith(fontSize: (width * 0.038).clamp(AppSizes.s12, AppSizes.s18), height: 1.15);

                      return Stack(
                        children: [
                          // Escudo do time num círculo branco, dentro do escudo desenhado.
                          Positioned(
                            left: crestCenter.dx - crestSize / 2,
                            top: crestCenter.dy - crestSize / 2,
                            width: crestSize,
                            height: crestSize,
                            child: Tooltip(
                              message: news.scoringTeam,
                              child: Container(
                                padding: EdgeInsets.all(crestSize * 0.1),
                                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                                child: news.scoringTeamCrest.isNotEmpty
                                    ? TeamCrest(imageUrl: news.scoringTeamCrest, size: crestSize * 0.8)
                                    : Icon(Icons.sports_soccer_rounded, size: crestSize * 0.6, color: palette.ring),
                              ),
                            ),
                          ),
                          Positioned(
                            left: GoalCardBackground.contentStart(size),
                            right: width * 0.04,
                            top: size.height * 0.08,
                            bottom: size.height * 0.08,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.newsGoalLabel}!',
                                  style: AppTypography.display(color: palette.ring).copyWith(
                                    fontSize: size.height * 0.17,
                                    fontStyle: FontStyle.italic,
                                    height: 1,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const Spacer(),
                                // Placar no centro, times dos dois lados.
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        news.homeTeam,
                                        textAlign: TextAlign.right,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: teamStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: width * 0.025),
                                      child: Text(
                                        '${news.homeGoals} × ${news.awayGoals}',
                                        style: AppTypography.display().copyWith(fontSize: width * 0.07, height: 1),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        news.awayTeam,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: teamStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (news.hasScorer)
                                  Wrap(
                                    spacing: AppSizes.s6,
                                    runSpacing: AppSizes.s4,
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
                                  )
                                else
                                  SizedBox(height: size.height * 0.12),
                              ],
                            ),
                          ),
                          if (trailing != null) Positioned(top: AppSizes.s4, right: AppSizes.s4, child: trailing!),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
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
