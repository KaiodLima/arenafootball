import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_totals_repair_section.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/seasons/presentation/bloc/seasons_panel_cubit.dart';
import 'package:arena_soccer/features/seasons/presentation/bloc/seasons_panel_state.dart';
import 'package:arena_soccer/features/seasons/presentation/widgets/team_links_section.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Painel do admin: temporada atual, as disponíveis, "Iniciar temporada" e a
/// manutenção "Vincular times por id".
class SeasonsPanelPage extends StatefulWidget {
  const SeasonsPanelPage({super.key});

  @override
  State<SeasonsPanelPage> createState() => _SeasonsPanelPageState();
}

class _SeasonsPanelPageState extends State<SeasonsPanelPage> {
  late final SeasonsPanelCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<SeasonsPanelCubit>(context)..load();
  }

  Future<void> _confirmStart(SeasonsPanelState state, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.seasonsConfirmTitle(state.next),
      message: l10n.seasonsConfirmMessage(state.next),
      confirmLabel: l10n.seasonsConfirmAction,
      icon: Icons.event_repeat_rounded,
      tone: ArenaAlertTone.warning,
    );
    if (confirmed) await _cubit.startNext();
  }

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
          l10n.seasonsPanelTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      body: BlocConsumer<SeasonsPanelCubit, SeasonsPanelState>(
        listener: (context, state) {
          if (state is StartedSeasonsPanelState) {
            showSnackBar(context: context, message: l10n.seasonsStarted(state.current));
            // O seletor de temporada do app passa a mostrar a nova como atual.
            BlocProvider.of<RegionCubit>(context).reloadSeasons();
          }
          if (state is ErrorSeasonsPanelState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
        },
        builder: (context, state) {
          final starting = state is StartingSeasonsPanelState;
          final seasons = state.seasons.reversed.toList();

          return ListView(
            padding: const EdgeInsets.all(AppSizes.s16),
            children: [
              // Atual
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                child: ArenaHeroBackground(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.s20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.seasonsCurrentLabel, style: AppTypography.subtitle(color: AppColors.whiteSoft)),
                        Text(
                          state.current,
                          style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s48),
                        ),
                        Text(l10n.seasonsCurrentInfo, style: AppTypography.subtitle(color: AppColors.whiteSoft)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.s20),

              // Disponíveis
              Text(l10n.seasonsAvailable, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
              const SizedBox(height: AppSizes.s10),
              Wrap(
                spacing: AppSizes.s8,
                runSpacing: AppSizes.s8,
                children: [
                  for (final season in seasons)
                    Chip(
                      avatar: Icon(
                        season == state.current ? Icons.play_circle_fill_rounded : Icons.inventory_2_outlined,
                        size: AppSizes.s18,
                        color: season == state.current ? AppColors.primary : AppColors.textSecondary,
                      ),
                      label: Text(
                        season == state.current ? '$season · ${l10n.seasonsCurrentTag}' : season,
                        style: AppTypography.label(color: AppColors.textPrimary),
                      ),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: season == state.current ? AppColors.primary : AppColors.greyLight),
                      shape: const StadiumBorder(),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.s24),

              // Iniciar a próxima
              Container(
                padding: const EdgeInsets.all(AppSizes.s16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: AppColors.greyLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.seasonsStartTitle(state.next),
                      style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
                    ),
                    const SizedBox(height: AppSizes.s6),
                    Text(l10n.seasonsStartInfo(state.current), style: AppTypography.subtitle()),
                    const SizedBox(height: AppSizes.s12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: state.copyTeams,
                      activeThumbColor: AppColors.primary,
                      onChanged: starting ? null : _cubit.setCopyTeams,
                      title: Text(l10n.seasonsCopyTeams, style: AppTypography.label(color: AppColors.textPrimary)),
                      subtitle: Text(
                        l10n.seasonsCopyTeamsHint,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                    const SizedBox(height: AppSizes.s12),
                    ArenaButton.primary(
                      title: l10n.seasonsStartButton(state.next),
                      isLoading: starting,
                      function: starting ? null : () => _confirmStart(state, l10n),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.s16),
              if (state.seasons.isNotEmpty)
                TeamLinksSection(
                  // Nova temporada iniciada: recomeça na atual.
                  key: ValueKey(state.current),
                  seasons: state.seasons,
                  current: state.current,
                ),
              const SizedBox(height: AppSizes.s16),
              // Geral = soma das competições; amistosos à parte.
              PlayerTotalsRepairSection(season: state.current),
            ],
          );
        },
      ),
    );
  }
}
