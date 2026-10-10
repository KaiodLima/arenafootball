import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/stats_shortcut_actions.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Classificação de um grupo. Os dois primeiros (classificados) ficam com
/// borda branca; os demais, vermelha.
class StandingsPage extends StatefulWidget {
  final String region;
  final String season;
  final String group;

  const StandingsPage({super.key, required this.region, required this.season, required this.group});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  /// Quantos times por grupo se classificam (borda branca).
  static const int _qualifiedCount = 2;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StandingsCubit>(context).watch(region: widget.region, group: widget.group, season: widget.season);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(AppImages.logo, width: AppSizes.logoWidth, height: AppSizes.logoHeight),
        actions: statsShortcutActions(context, region: widget.region, season: widget.season),
      ),
      body: BlocBuilder<StandingsCubit, StandingsState>(
        builder: (context, state) {
          if (state is LoadingStandingsState && state.standings.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ErrorStandingsState && state.standings.isEmpty) {
            return _Message(text: l10n.championshipsStandingsLoadError);
          }
          if (state.standings.isEmpty) return _Message(text: l10n.championshipsStandingsEmpty);

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.s8),
            itemCount: state.standings.length,
            itemBuilder: (context, index) => _StandingRow(
              position: index + 1,
              standing: state.standings[index],
              qualified: index < _qualifiedCount,
            ),
          );
        },
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s18),
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final int position;
  final StandingDTO standing;
  final bool qualified;

  const _StandingRow({required this.position, required this.standing, required this.qualified});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const height = AppSizes.s150;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      padding: const EdgeInsets.all(AppSizes.s8),
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: qualified ? AppColors.white : AppColors.danger),
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.s8)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              width: AppSizes.s50,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(AppSizes.s4)),
              ),
              child: Text(
                l10n.championshipsStandingsPosition(position),
                style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s24),
              ),
            ),
            const SizedBox(width: AppSizes.s10),
            SizedBox(
              width: AppSizes.s150,
              child: AutoSizeText(
                standing.teamName,
                style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s22),
              ),
            ),
            const SizedBox(width: AppSizes.s10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _Stat(label: l10n.championshipsStandingsWins, value: standing.wins),
                    _Stat(label: l10n.championshipsStandingsLosses, value: standing.losses),
                    _Stat(label: l10n.championshipsStandingsDraws, value: standing.draws),
                    _Stat(label: l10n.championshipsStandingsPoints, value: standing.points),
                  ],
                ),
                const SizedBox(height: AppSizes.s10),
                Row(
                  children: [
                    _Stat(label: l10n.championshipsStandingsGoalsFor, value: standing.goalsFor),
                    _Stat(label: l10n.championshipsStandingsGoalsAgainst, value: standing.goalsAgainst),
                    _Stat(label: l10n.championshipsStandingsGoalDifference, value: standing.goalDifference),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: AppColors.white, fontSize: AppSizes.s20);
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.s10),
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center, style: style),
          Container(
            constraints: const BoxConstraints(minWidth: AppSizes.s30),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(AppSizes.s8)),
            ),
            child: Text(value.toString(), textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );
  }
}
