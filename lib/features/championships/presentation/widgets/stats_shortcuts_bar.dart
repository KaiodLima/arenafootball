import 'package:flutter/material.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

const _condensed = 'BarlowCondensed';

/// Rodapé de grupos/classificação: dois cartões que abrem direto a
/// artilharia (dourado) e as assistências (verde) da região/temporada.
class StatsShortcutsBar extends StatelessWidget {
  final String region;
  final String season;

  const StatsShortcutsBar({super.key, required this.region, required this.season});

  void _open(BuildContext context, StatsRankingType type) => Navigator.pushNamed(
        context,
        AppRoutes.statsRankingPage,
        arguments: {'type': type, 'region': region, 'season': season},
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s20, offset: Offset(0, -AppSizes.s2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s12, AppSizes.s10),
          child: Row(
            children: [
              Expanded(
                child: _ShortcutCard(
                  icon: Icons.sports_soccer_rounded,
                  title: l10n.matchesTopScorers,
                  hint: l10n.statsShortcutGoalsHint,
                  colors: const [AppColors.medalGoldLight, AppColors.gold, AppColors.medalGoldDark],
                  foreground: AppColors.textPrimary,
                  onTap: () => _open(context, StatsRankingType.goals),
                ),
              ),
              const SizedBox(width: AppSizes.s10),
              Expanded(
                child: _ShortcutCard(
                  icon: Icons.redo_rounded,
                  title: l10n.matchesAssists,
                  hint: l10n.statsShortcutAssistsHint,
                  colors: const [AppColors.primary, AppColors.primaryStrong, AppColors.primaryDark],
                  foreground: AppColors.white,
                  onTap: () => _open(context, StatsRankingType.assists),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão-botão: ícone num círculo translúcido, título em caixa-alta, a linha
/// curta embaixo, seta e o ícone grande apagado no canto.
class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final List<Color> colors;
  final Color foreground;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.hint,
    required this.colors,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.s16);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        boxShadow: [
          BoxShadow(color: colors[1].withValues(alpha: 0.35), blurRadius: AppSizes.s10, offset: const Offset(0, 3))
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: AppSizes.s64,
            child: Stack(
              children: [
                Positioned(
                  right: -AppSizes.s10,
                  bottom: -AppSizes.s14,
                  child: Icon(icon, size: AppSizes.s64, color: foreground.withValues(alpha: 0.1)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s10, AppSizes.s8, AppSizes.s4, AppSizes.s8),
                  child: Row(
                    children: [
                      Container(
                        width: AppSizes.s36,
                        height: AppSizes.s36,
                        decoration: BoxDecoration(
                          color: foreground.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: foreground, size: AppSizes.s20),
                      ),
                      const SizedBox(width: AppSizes.s8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: _condensed,
                                fontWeight: FontWeight.w700,
                                fontSize: AppSizes.s18,
                                height: 1.1,
                                letterSpacing: 0.8,
                                color: foreground,
                              ),
                            ),
                            Text(
                              hint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: _condensed,
                                fontWeight: FontWeight.w600,
                                fontSize: AppSizes.s14,
                                height: 1.1,
                                color: foreground.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: foreground.withValues(alpha: 0.8), size: AppSizes.s20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
