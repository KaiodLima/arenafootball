import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/maintenance/data/dtos/recompress_status_dto.dart';
import 'package:arena_soccer/features/maintenance/presentation/bloc/recompress_images_cubit.dart';
import 'package:arena_soccer/features/maintenance/presentation/bloc/recompress_images_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Admin: recomprime as imagens antigas do Storage (a function faz em lotes;
/// a tela mostra o progresso ao vivo). Pode rodar de novo: só pega o que falta.
class RecompressImagesPage extends StatefulWidget {
  const RecompressImagesPage({super.key});

  @override
  State<RecompressImagesPage> createState() => _RecompressImagesPageState();
}

class _RecompressImagesPageState extends State<RecompressImagesPage> {
  late final RecompressImagesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<RecompressImagesCubit>(context)..watch();
  }

  Future<void> _confirm(AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.recompressConfirmTitle,
      message: l10n.recompressConfirmMessage,
      confirmLabel: l10n.recompressStart,
      icon: Icons.compress_rounded,
      tone: ArenaAlertTone.primary,
    );
    if (confirmed) await _cubit.request();
  }

  static String _megabytes(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.recompressTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      body: BlocConsumer<RecompressImagesCubit, RecompressImagesState>(
        listener: (context, state) {
          if (state is ErrorRecompressImagesState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
        },
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          final status = state.status;
          final running = status.isRunning;
          final phaseLabel = switch (status.phase) {
            RecompressPhase.idle => l10n.recompressIdle,
            RecompressPhase.requested => l10n.recompressRequested,
            RecompressPhase.running => l10n.recompressRunning(status.folder),
            RecompressPhase.done => l10n.recompressDone,
            RecompressPhase.error => l10n.recompressError(status.error),
          };

          return ListView(
            padding: const EdgeInsets.all(AppSizes.s16),
            children: [
              Text(l10n.recompressIntro, style: AppTypography.subtitle()),
              const SizedBox(height: AppSizes.s16),
              ArenaCard(
                padding: const EdgeInsets.all(AppSizes.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (running)
                          const SizedBox.square(
                            dimension: AppSizes.s18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        else
                          Icon(
                            status.phase == RecompressPhase.error
                                ? Icons.error_outline_rounded
                                : status.phase == RecompressPhase.done
                                    ? Icons.check_circle_rounded
                                    : Icons.image_outlined,
                            color: status.phase == RecompressPhase.error ? AppColors.danger : AppColors.primary,
                          ),
                        const SizedBox(width: AppSizes.s10),
                        Expanded(child: Text(phaseLabel, style: AppTypography.label(color: AppColors.textPrimary))),
                      ],
                    ),
                    if (status.phase != RecompressPhase.idle) ...[
                      const SizedBox(height: AppSizes.s12),
                      Text(
                        l10n.recompressStats(status.seen, status.rewritten),
                        style: AppTypography.body(),
                      ),
                      const SizedBox(height: AppSizes.s4),
                      Text(
                        l10n.recompressSaved(_megabytes(status.savedBytes), _megabytes(status.bytesBefore)),
                        style: AppTypography.body(color: AppColors.primaryDark).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.s20),
              ArenaButton.primary(
                title: status.phase == RecompressPhase.idle ? l10n.recompressStart : l10n.recompressAgain,
                function: running || state.requesting ? null : () => _confirm(l10n),
              ),
            ],
          );
        },
      ),
    );
  }
}
