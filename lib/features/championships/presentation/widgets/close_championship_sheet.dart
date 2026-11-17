import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_podium.dart';
import 'package:arena_soccer/features/championships/domain/usecases/close_championship_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Pódio escolhido na folha.
class ClosePodium {
  final ChampionshipPodiumTeam champion;
  final ChampionshipPodiumTeam? runnerUp;

  const ClosePodium({required this.champion, this.runnerUp});
}

/// Time da competição como pódio (cópias de nome, escudo e cores).
ChampionshipPodiumTeam podiumOf(TeamDTO team) => ChampionshipPodiumTeam(
      teamId: team.id,
      name: team.name,
      imageUrl: team.imageUrl,
      primaryColor: team.primaryColor,
      secondaryColor: team.secondaryColor,
    );

/// Admin/organizador: escolhe o campeão (e o vice) e encerra. Devolve a
/// competição atualizada (nulo = cancelou ou falhou).
Future<ChampionshipDTO?> closeChampionshipFlow(
  BuildContext context, {
  required ChampionshipDTO championship,
  required List<TeamDTO> teams,
  CloseChampionshipUseCase? useCase,
}) async {
  final l10n = AppLocalizations.of(context);
  final podium = await showModalBottomSheet<ClosePodium>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SafeArea(top: false, child: _CloseSheet(championship: championship, teams: teams)),
  );
  if (podium == null || !context.mounted) return null;
  final response = await (useCase ?? sl<CloseChampionshipUseCase>())(
    championship.id,
    champion: podium.champion,
    runnerUp: podium.runnerUp,
  );
  if (!context.mounted) return null;
  return response.fold(
    (failure) {
      showSnackBar(context: context, message: failure.toString(), isSuccess: false);
      return null;
    },
    (_) {
      showSnackBar(context: context, message: l10n.championshipClosedDone(podium.champion.name), isSuccess: true);
      return championship.copyWith(
        closed: true,
        closedAt: () => DateTime.now(),
        champion: () => podium.champion,
        runnerUp: () => podium.runnerUp,
      );
    },
  );
}

/// Reabre com confirmação. Devolve a competição atualizada (nulo = cancelou).
Future<ChampionshipDTO?> reopenChampionshipFlow(
  BuildContext context, {
  required ChampionshipDTO championship,
  ReopenChampionshipUseCase? useCase,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showArenaConfirm(
    context,
    title: l10n.championshipReopenTitle,
    message: l10n.championshipReopenMessage,
    confirmLabel: l10n.championshipReopen,
    icon: Icons.lock_open_rounded,
  );
  if (!confirmed || !context.mounted) return null;
  final response = await (useCase ?? sl<ReopenChampionshipUseCase>())(championship.id);
  if (!context.mounted) return null;
  return response.fold(
    (failure) {
      showSnackBar(context: context, message: failure.toString(), isSuccess: false);
      return null;
    },
    (_) {
      showSnackBar(context: context, message: l10n.championshipReopenDone, isSuccess: true);
      return championship.copyWith(closed: false, closedAt: () => null, champion: () => null, runnerUp: () => null);
    },
  );
}

class _CloseSheet extends StatefulWidget {
  final ChampionshipDTO championship;
  final List<TeamDTO> teams;

  const _CloseSheet({required this.championship, required this.teams});

  @override
  State<_CloseSheet> createState() => _CloseSheetState();
}

class _CloseSheetState extends State<_CloseSheet> {
  int? _champion;
  int? _runnerUp;

  void _pickChampion(int i) => setState(() {
        _champion = i;
        if (_runnerUp == i) _runnerUp = null;
      });

  void _pickRunnerUp(int i) => setState(() {
        _runnerUp = _runnerUp == i ? null : i;
        if (_champion == i) _champion = null;
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final teams = widget.teams;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.championshipCloseTitle(widget.championship.title),
                  style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
                ),
                const SizedBox(height: AppSizes.s6),
                Text(l10n.championshipCloseHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ],
            ),
          ),
          if (teams.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.s20),
              child: Text(l10n.championshipCloseNoTeams, style: AppTypography.subtitle()),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                itemCount: teams.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.s4),
                  child: Row(
                    children: [
                      TeamCrest(imageUrl: teams[i].imageUrl, size: AppSizes.s36),
                      const SizedBox(width: AppSizes.s10),
                      Expanded(
                        child: Text(
                          teams[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(color: AppColors.textPrimary),
                        ),
                      ),
                      ChoiceChip(
                        key: ValueKey('close-champion-$i'),
                        avatar:
                            const Icon(Icons.emoji_events_rounded, size: AppSizes.s16, color: AppColors.medalGoldDark),
                        label: Text(l10n.championshipChampionLabel),
                        selected: _champion == i,
                        selectedColor: AppColors.gold.withValues(alpha: 0.35),
                        onSelected: (_) => _pickChampion(i),
                      ),
                      const SizedBox(width: AppSizes.s6),
                      ChoiceChip(
                        key: ValueKey('close-vice-$i'),
                        label: Text(l10n.championshipRunnerUpLabel),
                        selected: _runnerUp == i,
                        selectedColor: AppColors.medalSilverDark.withValues(alpha: 0.25),
                        onSelected: (_) => _pickRunnerUp(i),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s12, AppSizes.s20, AppSizes.s20),
            child: FilledButton.icon(
              key: const ValueKey('close-confirm'),
              onPressed: _champion == null
                  ? null
                  : () => Navigator.pop(
                        context,
                        ClosePodium(
                          champion: podiumOf(teams[_champion!]),
                          runnerUp: _runnerUp == null ? null : podiumOf(teams[_runnerUp!]),
                        ),
                      ),
              icon: const Icon(Icons.flag_rounded),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.s14)),
              ),
              label: Text(l10n.championshipCloseConfirm, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
