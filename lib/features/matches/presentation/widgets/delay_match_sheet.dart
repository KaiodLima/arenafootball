import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delay_match_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Atrasou": folha curta com o horário atual e os atalhos +10/+15/+20/+30,
/// "Outro horário" (relógio 24h) e, se o horário já passou, "Começou agora"
/// (inicia o relógio do zero). Um toque grava e fecha.
Future<void> showDelayMatchSheet(
  BuildContext context, {
  required MatchDTO match,
  required bool canStartNow,
  required ValueChanged<String> onDelay,
  required VoidCallback onStartNow,
  required VoidCallback onPause,
}) async {
  final l10n = AppLocalizations.of(context);
  final choice = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _DelaySheet(
      match: match,
      canStartNow: canStartNow,
      canPause: match.manualStatus != MatchManualStatus.waiting,
    ),
  );
  if (choice == null || !context.mounted) return;
  HapticFeedback.mediumImpact();
  if (choice == _DelaySheet.startNow) {
    onStartNow();
    return;
  }
  if (choice == _DelaySheet.pause) {
    onPause();
    showSnackBar(context: context, message: l10n.matchPausedNotice);
    return;
  }
  onDelay(choice);
  showSnackBar(context: context, message: l10n.matchDelayedTo(choice));
}

class _DelaySheet extends StatelessWidget {
  final MatchDTO match;
  final bool canStartNow;

  /// "Pausar até começar" (some com a partida já pausada).
  final bool canPause;

  const _DelaySheet({required this.match, required this.canStartNow, required this.canPause});

  /// Resultados da folha para "Começou agora" e "Pausar" (os outros são o novo "HH:mm").
  static const String startNow = 'start';
  static const String pause = 'pause';

  Future<void> _pickOther(BuildContext context) async {
    final parts = match.time.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first.trim()) ?? 16,
        minute: parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0,
      ),
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (picked == null || !context.mounted) return;
    String two(int n) => n.toString().padLeft(2, '0');
    Navigator.of(context).pop('${two(picked.hour)}:${two(picked.minute)}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final time = match.time.trim();
    final original = match.delayed ? match.originalTime.trim() : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.schedule_rounded, color: AppColors.teamOrange),
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.matchDelayTitle, style: AppTypography.title()),
                    Text(
                      original.isEmpty ? l10n.matchDelayCurrent(time) : '${l10n.matchDelayCurrent(time)} · ${l10n.matchCardWas(original)}',
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s16),
          Wrap(
            spacing: AppSizes.s8,
            runSpacing: AppSizes.s8,
            children: [
              for (final minutes in DelayMatchUseCase.quickMinutes)
                if (DelayMatchUseCase.addMinutes(time, minutes) case final next?)
                  ArenaChoiceChip(
                    label: '${l10n.matchDelayPlus(minutes)} · $next',
                    selected: false,
                    onTap: () => Navigator.of(context).pop(next),
                  ),
              ArenaChoiceChip(
                label: l10n.matchFormOtherTime,
                icon: Icons.schedule_rounded,
                selected: false,
                onTap: () => _pickOther(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          Text(l10n.matchDelayHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          if (canPause) ...[
            const SizedBox(height: AppSizes.s16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(pause),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.teamOrange,
                side: const BorderSide(color: AppColors.teamOrange),
                minimumSize: const Size.fromHeight(AppSizes.s48),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.pause_circle_outline_rounded),
              label: Text(l10n.matchDelayPause),
            ),
          ],
          if (canStartNow) ...[
            const SizedBox(height: AppSizes.s16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(startNow),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(AppSizes.s48),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: Text(l10n.matchDelayStartedNow),
            ),
          ],
        ],
      ),
    );
  }
}
