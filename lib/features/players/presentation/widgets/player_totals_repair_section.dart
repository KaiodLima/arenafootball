import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_totals_repair_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Manutenção "Corrigir números dos atletas" da temporada [season]: o geral
/// volta a ser a soma das competições e os amistosos ficam à parte.
class PlayerTotalsRepairSection extends StatelessWidget {
  final String season;

  const PlayerTotalsRepairSection({super.key, required this.season});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<PlayerTotalsRepairCubit, PlayerTotalsRepairState>(
      listenWhen: (previous, current) => previous.running && !current.running,
      listener: (context, state) {
        if (state.errorMessage != null) {
          showSnackBar(context: context, message: state.errorMessage!, isSuccess: false);
        } else if (state.fixed != null) {
          showSnackBar(context: context, message: l10n.seasonsRepairTotalsDone(state.fixed!));
        }
      },
      builder: (context, state) => ArenaCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(AppSizes.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.seasonsRepairTotals,
              style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
            ),
            const SizedBox(height: AppSizes.s6),
            Text(l10n.seasonsRepairTotalsHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            if (state.fixed != null) ...[
              const SizedBox(height: AppSizes.s8),
              Text(
                l10n.seasonsRepairTotalsDone(state.fixed!),
                style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
              ),
            ],
            const SizedBox(height: AppSizes.s12),
            ArenaButton.outlined(
              title: l10n.seasonsRepairTotals,
              isLoading: state.running,
              function: state.running ? null : () => BlocProvider.of<PlayerTotalsRepairCubit>(context).run(season),
            ),
          ],
        ),
      ),
    );
  }
}
