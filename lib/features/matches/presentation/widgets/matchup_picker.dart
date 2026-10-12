import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Confronto do cadastro de partida: mandante e visitante (escudo + nome,
/// tocar troca o time) e o botão ⇄ que inverte o mando.
class MatchupPicker extends StatelessWidget {
  final String? homeTeam;
  final String? awayTeam;
  final String? homeCrest;
  final String? awayCrest;
  final VoidCallback onPickHome;
  final VoidCallback onPickAway;
  final VoidCallback onSwap;
  final String? errorText;

  const MatchupPicker({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeCrest,
    required this.awayCrest,
    required this.onPickHome,
    required this.onPickAway,
    required this.onSwap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s16, AppSizes.s8, AppSizes.s16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Team(label: l10n.goalHome, name: homeTeam, crest: homeCrest, onTap: onPickHome),
              ),
              Tooltip(
                message: l10n.matchFormSwap,
                child: Material(
                  color: AppColors.primarySoft,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onSwap,
                    child: const Padding(
                      padding: EdgeInsets.all(AppSizes.s10),
                      child: Icon(Icons.swap_horiz_rounded, color: AppColors.primaryDark),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _Team(label: l10n.goalAway, name: awayTeam, crest: awayCrest, onTap: onPickAway),
              ),
            ],
          ),
          if (errorText != null) ...[
            const SizedBox(height: AppSizes.s10),
            Text(errorText!, style: AppTypography.label(color: AppColors.danger).copyWith(fontSize: AppSizes.s12)),
          ],
        ],
      ),
    );
  }
}

class _Team extends StatelessWidget {
  final String label;
  final String? name;
  final String? crest;
  final VoidCallback onTap;

  const _Team({required this.label, required this.name, required this.crest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.s14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.s6),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.label(color: AppColors.textSecondary)
                  .copyWith(fontSize: AppSizes.s12, letterSpacing: 1),
            ),
            const SizedBox(height: AppSizes.s8),
            TeamCrest(imageUrl: crest, size: AppSizes.s56),
            const SizedBox(height: AppSizes.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    name ?? l10n.goalPickTeam,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: name == null ? AppColors.primary : AppColors.textPrimary)
                        .copyWith(fontSize: AppSizes.s14),
                  ),
                ),
                const Icon(Icons.expand_more_rounded, size: AppSizes.s18, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
