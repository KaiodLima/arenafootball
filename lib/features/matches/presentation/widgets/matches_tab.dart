import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_picker.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_list.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_state.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_day_switch.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/components/shortcut_tile.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Aba de tabelas da home: as partidas de ontem, hoje ou amanhã da região, de
/// todas as competições (e amistosos) ou só da escolhida no seletor (lista com
/// busca, como no cadastro de partida), com atalhos para todos os jogos,
/// grupos, artilharia e assistências. A home recria a aba (key) quando
/// região/ano mudam. [ChampionshipsCubit] e [MatchesCubit] são os da home:
/// trocar de aba e voltar não reabre as consultas; região/ano/competição
/// novos, sim.
class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  @override
  void initState() {
    super.initState();
    final region = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    BlocProvider.of<ChampionshipsCubit>(context).watch(region: region);
  }

  @override
  Widget build(BuildContext context) => const _ChampionshipMatches();
}

/// Competições da temporada que aparecem na região: as que a consulta da
/// região trouxe (inclui intermunicipais com sede em outra região); sem
/// nenhuma com `ano`, os dados antigos da região.
List<ChampionshipDTO> tableChampionships(List<ChampionshipDTO> all, {required String season}) {
  final ofSeason = all.where((c) => c.season == season).toList()
    ..sort((a, b) => a.championshipId.compareTo(b.championshipId));
  return ofSeason.isNotEmpty ? ofSeason : [if (all.isNotEmpty) all.first];
}

class _ChampionshipMatches extends StatefulWidget {
  const _ChampionshipMatches();

  @override
  State<_ChampionshipMatches> createState() => _ChampionshipMatchesState();
}

class _ChampionshipMatchesState extends State<_ChampionshipMatches> {
  /// Competição escolhida por região/temporada (ausente = todas), lembrada
  /// enquanto o app está aberto (a home recria a aba ao trocar de região).
  static final Map<String, int?> _remembered = {};

  Future<void> _pick(List<ChampionshipDTO> options, int? current, String key) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showChampionshipPickerSheet(
      context,
      championships: options,
      selectedId: current,
      noneLabel: l10n.matchesAllChampionships,
      noneIcon: Icons.format_list_bulleted_rounded,
    );
    if (picked != null && mounted) setState(() => _remembered[key] = picked.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final region = BlocProvider.of<RegionCubit>(context).state;
    final key = '${region.selectedRegion}|${region.selectedSeason}';

    return BlocBuilder<ChampionshipsCubit, ChampionshipsState>(
      builder: (context, state) {
        if (state is LoadingChampionshipsState && state.championships.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ErrorChampionshipsState && state.championships.isEmpty) {
          return ArenaEmptyState.error(message: l10n.championshipsLoadError);
        }

        final options = tableChampionships(state.championships, season: region.selectedSeason);
        final rememberedId = _remembered[key];
        final championship = options.where((c) => c.championshipId == rememberedId).firstOrNull;
        final championshipId = championship?.championshipId;
        final titles = {for (final c in options) c.championshipId: c.title};

        return Column(
          children: [
            if (options.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, 0),
                child: ChampionshipSelectTile(
                  label: l10n.matchesChampionshipFilter,
                  championship: championship,
                  noneLabel: l10n.matchesAllChampionships,
                  noneIcon: Icons.format_list_bulleted_rounded,
                  onTap: () => _pick(options, championshipId, key),
                ),
              ),
            Expanded(
              child: _DayMatches(
                key: ValueKey(championshipId),
                championshipId: championshipId,
                championships: options,
                // Em "todas as competições", cada card diz de qual é.
                championshipLabelOf: championshipId != null
                    ? null
                    : (MatchDTO match) => titles[match.championshipId] ?? l10n.matchesFriendly,
                region: region.selectedRegion,
                season: region.selectedSeason,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Atalhos, seletor de dia (ontem/hoje/amanhã) e as partidas do dia escolhido.
class _DayMatches extends StatefulWidget {
  /// Nulo = todas as competições.
  final int? championshipId;
  final List<ChampionshipDTO> championships;
  final String? Function(MatchDTO match)? championshipLabelOf;
  final String region;
  final String season;

  const _DayMatches({
    super.key,
    required this.championshipId,
    required this.championships,
    required this.championshipLabelOf,
    required this.region,
    required this.season,
  });

  @override
  State<_DayMatches> createState() => _DayMatchesState();
}

class _DayMatchesState extends State<_DayMatches> {
  late MatchesFilter _day;

  /// O cubit da home ignora o pedido se já ouve esta competição/região/ano
  /// (volta à aba); o dia na tela é o que ele já estava mostrando.
  @override
  void initState() {
    super.initState();
    final cubit = BlocProvider.of<MatchesCubit>(context);
    final resumed = cubit.isWatching(
      championshipId: widget.championshipId,
      region: widget.region,
      season: widget.season,
    );
    _day = resumed ? (cubit.filter ?? MatchesFilter.today) : MatchesFilter.today;
    cubit.watch(
      championshipId: widget.championshipId,
      filter: _day,
      region: widget.region,
      season: widget.season,
    );
  }

  void _selectDay(MatchesFilter day) {
    setState(() => _day = day);
    BlocProvider.of<MatchesCubit>(context).selectDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, empty) = switch (_day) {
      MatchesFilter.yesterday => (l10n.matchesYesterdayTitle, l10n.matchesNoGamesYesterday),
      MatchesFilter.tomorrow => (l10n.matchesTomorrowTitle, l10n.matchesNoGamesTomorrow),
      _ => (l10n.homeTodayMatches, l10n.matchesNoGamesToday),
    };

    return MatchesList(
      season: widget.season,
      emptyMessage: empty,
      championshipLabelOf: widget.championshipLabelOf,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Shortcuts(
            championshipId: widget.championshipId,
            championships: widget.championships,
            region: widget.region,
            season: widget.season,
          ),
          const SizedBox(height: AppSizes.s20),
          MatchDaySwitch(selected: _day, onChanged: _selectDay),
          const SizedBox(height: AppSizes.s16),
          BlocSelector<MatchesCubit, MatchesState, int>(
            selector: (state) => state is LoadingMatchesState ? -1 : state.visibleMatches.length,
            builder: (context, count) => SectionHeader(
              title: title,
              trailing: count > 0
                  ? Text(l10n.matchesDayCount(count), style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Atalhos para outras telas da competição, em 3 blocos iguais (artilharia e
/// assistências são a mesma tela, com o seletor lá dentro). Em "todas as
/// competições", os jogos são de todas; grupos pedem a competição antes.
class _Shortcuts extends StatelessWidget {
  final int? championshipId;
  final List<ChampionshipDTO> championships;
  final String region;
  final String season;

  const _Shortcuts({
    required this.championshipId,
    required this.championships,
    required this.region,
    required this.season,
  });

  void _openStats(BuildContext context, StatsRankingType type) => Navigator.pushNamed(
        context,
        AppRoutes.statsRankingPage,
        arguments: {'type': type, 'region': region, 'season': season, 'championshipId': championshipId},
      );

  Future<void> _openGroups(BuildContext context) async {
    var id = championshipId;
    if (id == null && championships.length == 1) id = championships.first.championshipId;
    if (id == null && championships.isNotEmpty) {
      final picked = await showChampionshipPickerSheet(context, championships: championships, showNone: false);
      // Grupos são de uma competição: "nenhuma" não abre.
      id = picked?.id;
      if (id == null) return;
    }
    if (!context.mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.groupsPage,
      arguments: {'region': region, 'season': season, 'championshipId': id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShortcutTile(
          title: l10n.matchesAllGames,
          icon: Icons.calendar_month_rounded,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.matchesPage,
            arguments: {'championshipId': championshipId, 'region': region, 'season': season},
          ),
        ),
        ShortcutTile(
          title: l10n.matchesGroups,
          icon: Icons.groups_rounded,
          onTap: () => _openGroups(context),
        ),
        ShortcutTile(
          title: l10n.statsShortcut,
          icon: Icons.sports_soccer_rounded,
          onTap: () => _openStats(context, StatsRankingType.goals),
        ),
      ],
    );
  }
}
