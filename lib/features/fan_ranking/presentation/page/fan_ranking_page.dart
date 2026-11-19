import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/core/services/tour_service.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/page/choose_team_page.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';
import 'package:arena_soccer/features/fan_ranking/domain/fan_ranking_view.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/bloc/fan_ranking_cubit.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/bloc/fan_ranking_state.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/widgets/fan_ranking_widgets.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_picker_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/tour/tour_step.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Compartilhar texto (trocável no teste).
Future<void> Function(String text) fanRankingShare = ShareService.shareText;

/// "Guerra das torcidas": o líder em destaque nas cores dele, a divisão das
/// torcidas, a torcida da conta (posição, quem está acima e "Convocar a
/// torcida") e o ranking completo — da região ou do app ("Geral"). Tudo do
/// doc `ranking_torcidas/{temporada}` (uma leitura, com cache).
class FanRankingPage extends StatefulWidget {
  const FanRankingPage({super.key});

  @override
  State<FanRankingPage> createState() => _FanRankingPageState();
}

class _FanRankingPageState extends State<FanRankingPage> {
  late final FanRankingCubit _cubit;
  final _tourScope = GlobalKey();
  final _tourLeader = GlobalKey();
  final _tourMine = GlobalKey();
  bool _tourRequested = false;

  /// Tour da guerra das torcidas na 1ª visita (com o ranking na tela).
  void _requestTour() {
    if (_tourRequested) return;
    _tourRequested = true;
    final l10n = AppLocalizations.of(context);
    TourService.request(
      context,
      TourIds.fanRanking,
      () => [
        TourStep(
          target: _tourScope,
          icon: Icons.public_rounded,
          title: l10n.tourFanRankingScopeTitle,
          body: l10n.tourFanRankingScopeBody,
        ),
        TourStep(
          target: _tourLeader,
          icon: Icons.emoji_events_rounded,
          title: l10n.tourFanRankingLeaderTitle,
          body: l10n.tourFanRankingLeaderBody,
        ),
        TourStep(
          target: _tourMine,
          icon: Icons.groups_rounded,
          title: l10n.tourFanRankingMineTitle,
          body: l10n.tourFanRankingMineBody,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<FanRankingCubit>(context);
    _load();
  }

  Future<void> _load({bool force = false}) => _cubit.load(
        season: SeasonCollection.currentSeason,
        region: _cubit.state.region.isNotEmpty
            ? _cubit.state.region
            : BlocProvider.of<RegionCubit>(context).state.selectedRegion,
        force: force,
      );

  Future<void> _pickRegion(String current) async {
    final regions = BlocProvider.of<RegionCubit>(context).state;
    final picked = await showRegionPicker(
      context,
      regions: regions.regions,
      selected: current,
      recent: regions.recentRegions,
    );
    if (picked != null) {
      _cubit
        ..selectRegion(picked)
        ..selectScope(FanRankingScope.region);
    }
  }

  void _rally(FanRankingEntry team) {
    fanRankingShare(AppLocalizations.of(context).fanRankingRallyText(team.name, appLink));
  }

  Future<void> _chooseTeam() async {
    await Navigator.pushNamed(context, AppRoutes.chooseTeamPage, arguments: const ChooseTeamArgs(canGoBack: true));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<SessionCubit>().state.user;

    return BlocBuilder<FanRankingCubit, FanRankingState>(
      builder: (context, state) {
        final entries = state.entries;
        final overall = state.scope == FanRankingScope.overall;
        final total = FanRankingView.total(entries);
        bool isMine(FanRankingEntry e) =>
            user != null && user.hasFavoriteTeam && e.isTeam(id: user.favoriteTeamId, teamName: user.favoriteTeam);
        final mineIndex = entries.indexWhere(isMine);
        final leaders = FanRankingView.leaders(entries);
        final slices = FanRankingView.slices(entries);
        if (!state.loading && entries.isNotEmpty) _requestTour();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              l10n.fanRankingTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.s12),
                child: _RegionPill(region: state.region, onTap: () => _pickRegion(state.region)),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _load(force: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, safeBottom(context, AppSizes.s32)),
              children: [
                KeyedSubtree(
                  key: _tourScope,
                  child: _ScopeToggle(scope: state.scope, region: state.region, onChanged: _cubit.selectScope),
                ),
                const SizedBox(height: AppSizes.s14),
                if (state.loading && state.ranking == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.s48),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (state.ranking == null)
                  ArenaEmptyState(message: state.errorMessage ?? l10n.fanRankingError, icon: Icons.cloud_off_rounded)
                else if (state.ranking!.isEmpty)
                  ArenaEmptyState(message: l10n.fanRankingPreparing, icon: Icons.hourglass_top_rounded)
                else if (entries.isEmpty)
                  ArenaEmptyState(message: l10n.fanRankingNoTeams, icon: Icons.shield_outlined)
                else ...[
                  if (leaders.isNotEmpty) ...[
                    KeyedSubtree(
                      key: _tourLeader,
                      child: FanLeaderHero(leaders: leaders, total: total, region: overall ? '' : state.region),
                    ),
                    const SizedBox(height: AppSizes.s14),
                  ],
                  if (user != null && !user.hasFavoriteTeam) ...[
                    KeyedSubtree(key: _tourMine, child: FanChooseTeamCard(onChoose: _chooseTeam)),
                    const SizedBox(height: AppSizes.s14),
                  ] else if (mineIndex >= 0) ...[
                    KeyedSubtree(
                      key: _tourMine,
                      child: FanMyCrowdCard(
                        entry: entries[mineIndex],
                        position: state.positionAt(mineIndex),
                        total: total,
                        next: FanRankingView.gapToNext(entries, entries[mineIndex]),
                        onRally: () => _rally(entries[mineIndex]),
                      ),
                    ),
                    const SizedBox(height: AppSizes.s14),
                  ],
                  if (slices.length > 1) ...[
                    FanSplitBar(slices: slices),
                    const SizedBox(height: AppSizes.s8),
                  ],
                  _SectionTitle(l10n.fanRankingFullRanking),
                  if (entries.length > 1)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 1; i < 3; i++) ...[
                          if (i > 1) const SizedBox(width: AppSizes.s10),
                          Expanded(
                            child: i < entries.length
                                ? FanRunnerUpCard(
                                    entry: entries[i],
                                    position: state.positionAt(i),
                                    total: total,
                                    mine: isMine(entries[i]),
                                    showRegion: overall,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: AppSizes.s10),
                  for (var i = 3; i < entries.length; i++)
                    FanRankRow(
                      entry: entries[i],
                      position: state.positionAt(i),
                      leaderFans: entries.first.fans,
                      total: total,
                      mine: isMine(entries[i]),
                      showRegion: overall,
                    ),
                  if (state.ranking!.updatedAt != null) ...[
                    const SizedBox(height: AppSizes.s12),
                    Text(
                      l10n.fanRankingUpdatedAt(_updatedLabel(context, state.ranking!.updatedAt!)),
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// "14:00" hoje; em outro dia, "16/10 14:00".
  String _updatedLabel(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final sameDay = now.year == date.year && now.month == date.month && now.day == date.day;
    return sameDay ? DateFormat.Hm(locale).format(date) : DateFormat.Md(locale).add_Hm().format(date);
  }
}

/// Região atual num botão-pílula (abre a busca de regiões).
class _RegionPill extends StatelessWidget {
  final String region;
  final VoidCallback onTap;

  const _RegionPill({required this.region, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.14),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.s120),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place_rounded, size: AppSizes.s16, color: AppColors.white),
                const SizedBox(width: AppSizes.s4),
                Flexible(
                  child: Text(
                    region,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                  ),
                ),
                const Icon(Icons.expand_more_rounded, size: AppSizes.s18, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Floresta | Geral": a região escolhida ou o app inteiro.
class _ScopeToggle extends StatelessWidget {
  final FanRankingScope scope;
  final String region;
  final ValueChanged<FanRankingScope> onChanged;

  const _ScopeToggle({required this.scope, required this.region, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget option(FanRankingScope value, String label, IconData icon) {
      final selected = scope == value;
      return Expanded(
        child: Material(
          color: selected ? AppColors.primaryDark : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.s20),
          child: InkWell(
            key: ValueKey('fan-scope-${value.name}'),
            borderRadius: BorderRadius.circular(AppSizes.s20),
            onTap: () => onChanged(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: AppSizes.s16, color: selected ? AppColors.gold : AppColors.textSecondary),
                  const SizedBox(width: AppSizes.s6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(color: selected ? AppColors.white : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s24),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          option(FanRankingScope.region, region.isEmpty ? l10n.fanRankingScopeRegion : region, Icons.place_rounded),
          option(FanRankingScope.overall, l10n.fanRankingScopeOverall, Icons.public_rounded),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s8, AppSizes.s4, AppSizes.s10),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12, letterSpacing: 1.1),
      ),
    );
  }
}
