import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_list.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_shortcut_button.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// "TODOS OS JOGOS": todas as partidas do campeonato na temporada, com as
/// mesmas ações da aba. Sem [region]/[season], usa o [RegionCubit].
class MatchesPage extends StatefulWidget {
  final int championshipId;
  final String? region;
  final String? season;

  const MatchesPage({super.key, required this.championshipId, this.region, this.season});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  late final String _region;
  late final String _season;

  @override
  void initState() {
    super.initState();
    final selected = BlocProvider.of<RegionCubit>(context).state;
    _region = widget.region ?? selected.selectedRegion;
    _season = widget.season ?? selected.selectedSeason;
    BlocProvider.of<MatchesCubit>(context).watch(
      championshipId: widget.championshipId,
      filter: MatchesFilter.all,
      season: _season,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        title: Text(l10n.matchesAllGamesTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.s6),
            child: MatchesShortcutButton(
              title: l10n.matchesGroups,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.groupsPage,
                arguments: {'region': _region, 'season': _season},
              ),
            ),
          ),
        ],
      ),
      body: MatchesList(season: _season, striped: true),
    );
  }
}
