import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel de confirmação do voto: ✓ que entra com "mola", o jogador votado e
/// a lembrança de que dá para trocar.
class VoteSuccessSheet extends StatelessWidget {
  final PlayerDTO player;

  const VoteSuccessSheet({super.key, required this.player});

  static Future<void> show(BuildContext context, PlayerDTO player) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => VoteSuccessSheet(player: player),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s24, 0, AppSizes.s24, AppSizes.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(scale: value, child: child),
              child: Container(
                width: AppSizes.s80,
                height: AppSizes.s80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: AppSizes.s24)],
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.white, size: AppSizes.s48),
              ),
            ),
            const SizedBox(height: AppSizes.s20),
            Text(l10n.votingSuccessTitle, style: AppTypography.display().copyWith(fontSize: AppSizes.s24)),
            const SizedBox(height: AppSizes.s16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlayerAvatar(player: player, size: AppSizes.s36),
                const SizedBox(width: AppSizes.s10),
                Flexible(
                  child: Text(
                    l10n.votingYouVotedFor(player.name),
                    style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.s8),
            Text(
              l10n.votingHint,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
            ),
            const SizedBox(height: AppSizes.s24),
            ArenaButton.primary(title: l10n.commonClose, function: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
