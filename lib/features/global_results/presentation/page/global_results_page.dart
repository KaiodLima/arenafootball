import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/global_results_cubit.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/global_results_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Resultados de jogos pelo mundo (web scraping do soccerstats.com).
class GlobalResultsPage extends StatefulWidget {
  const GlobalResultsPage({super.key});

  @override
  State<GlobalResultsPage> createState() => _GlobalResultsPageState();
}

class _GlobalResultsPageState extends State<GlobalResultsPage> {
  late final GlobalResultsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<GlobalResultsCubit>(context);
    _cubit.load(ResultsDay.today);
  }

  String _dayLabel(ResultsDay day, AppLocalizations l10n) {
    switch (day) {
      case ResultsDay.yesterday:
        return l10n.globalResultsYesterday;
      case ResultsDay.today:
        return l10n.globalResultsToday;
      case ResultsDay.tomorrow:
        return l10n.globalResultsTomorrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.globalResultsTitle)),
      body: BlocBuilder<GlobalResultsCubit, GlobalResultsState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.s8),
                child: Row(
                  children: ResultsDay.values.map((day) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                        child: ArenaButton(
                          height: AppSizes.s50,
                          title: _dayLabel(day, l10n),
                          buttonColor: state.day == day ? AppColors.primaryDark : AppColors.primary,
                          borderRadius: AppSizes.s32,
                          function: () => _cubit.load(day),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(child: _Content(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final GlobalResultsState state;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state is LoadingGlobalResultsState) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is ErrorGlobalResultsState) {
      return _Message(text: (state as ErrorGlobalResultsState).errorMessage);
    }
    if (state.day == ResultsDay.tomorrow) return _Message(text: l10n.globalResultsTomorrowUnavailable);
    if (state.matches.isEmpty) return _Message(text: l10n.globalResultsEmpty);

    final matches = state.matches;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final showLeague = i == 0 || matches[i].league != matches[i - 1].league;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showLeague && matches[i].league.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.s12, bottom: AppSizes.s4),
                child: Text(
                  matches[i].league,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            _MatchTile(match: matches[i]),
          ],
        );
      },
    );
  }
}

class _MatchTile extends StatelessWidget {
  final GlobalMatch match;

  const _MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.s4),
      padding: const EdgeInsets.all(AppSizes.s8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (match.time.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s2),
                  margin: const EdgeInsets.only(right: AppSizes.s8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.s4),
                  ),
                  child: Text(match.time, style: const TextStyle(color: AppColors.white)),
                ),
              Expanded(
                child: Text(
                  match.homeTeam,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: AppSizes.s16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                child: Text(
                  match.score,
                  style: const TextStyle(fontSize: AppSizes.s16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  match.awayTeam,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: AppSizes.s16),
                ),
              ),
            ],
          ),
          if (match.scorers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.s4),
              child: Text(match.scorers, textAlign: TextAlign.center, style: const TextStyle(fontSize: AppSizes.s12)),
            ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.s24),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: AppSizes.s16)),
      ),
    );
  }
}
