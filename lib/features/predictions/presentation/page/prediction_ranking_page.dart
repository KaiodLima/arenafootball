import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/presentation/bloc/prediction_ranking_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Bolão: ranking de palpiteiros da região na temporada atual. Pódio dos 3
/// primeiros, a lista até o 50º e "Sua posição" fixa embaixo.
class PredictionRankingPage extends StatefulWidget {
  const PredictionRankingPage({super.key});

  @override
  State<PredictionRankingPage> createState() => _PredictionRankingPageState();
}

class _PredictionRankingPageState extends State<PredictionRankingPage> {
  late final PredictionRankingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<PredictionRankingCubit>(context);
    _load(BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  Future<void> _load(String region) => _cubit.load(
        region: region,
        uid: BlocProvider.of<SessionCubit>(context).state.user?.id ?? '',
        season: SeasonCollection.currentSeason,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final regions = context.watch<RegionCubit>().state.regions;
    final uid = context.watch<SessionCubit>().state.user?.id ?? '';

    return BlocBuilder<PredictionRankingCubit, PredictionRankingState>(
      builder: (context, state) {
        final entries = state.entries;
        final myIndex = uid.isEmpty ? -1 : entries.indexWhere((e) => e.uid == uid);
        final myPosition = myIndex >= 0 ? state.positionAt(myIndex) : state.myPosition;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              l10n.predictionRankingTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
          ),
          bottomNavigationBar:
              uid.isEmpty || state.loading ? null : _MyPositionBar(entry: state.mine, position: myPosition),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _load(state.region),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s32),
              children: [
                SizedBox(
                  height: AppSizes.s40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: regions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s8),
                    itemBuilder: (context, index) => ArenaChoiceChip(
                      label: regions[index],
                      icon: Icons.place_outlined,
                      selected: regions[index] == state.region,
                      onTap: () => _load(regions[index]),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.s8),
                Text(
                  l10n.predictionRules,
                  textAlign: TextAlign.center,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                const SizedBox(height: AppSizes.s16),
                if (state.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.s48),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (state.errorMessage != null)
                  ArenaEmptyState(message: l10n.predictionRankingError, icon: Icons.cloud_off_rounded)
                else if (entries.isEmpty)
                  ArenaEmptyState(message: l10n.predictionRankingEmpty, icon: Icons.scoreboard_outlined)
                else ...[
                  _Podium(entries: entries.take(3).toList(), positionAt: state.positionAt, uid: uid),
                  const SizedBox(height: AppSizes.s16),
                  for (var i = 3; i < entries.length; i++)
                    _RankingRow(entry: entries[i], position: state.positionAt(i), mine: entries[i].uid == uid),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Inicial do nome num círculo (o ranking não tem foto).
class _Initial extends StatelessWidget {
  final String name;
  final double size;
  final Color border;

  const _Initial({required this.name, required this.size, this.border = AppColors.greyLight});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: AppSizes.s2),
      ),
      child: Text(initial, style: AppTypography.title(color: AppColors.primaryDark).copyWith(fontSize: size * 0.4)),
    );
  }
}

/// Pódio: 2º, 1º e 3º lado a lado, o 1º mais alto.
class _Podium extends StatelessWidget {
  final List<PredictionRankingEntry> entries;
  final int Function(int index) positionAt;
  final String uid;

  const _Podium({required this.entries, required this.positionAt, required this.uid});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final order = [if (entries.length > 1) 1, 0, if (entries.length > 2) 2];
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s16, AppSizes.s8, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final index in order)
            Expanded(
              child: Builder(builder: (context) {
                final entry = entries[index];
                final position = positionAt(index);
                final first = index == 0;
                final medal = switch (position) { 1 => AppColors.gold, 2 => AppColors.silver, _ => AppColors.bronze };
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (first) const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s28),
                      _Initial(name: entry.name, size: first ? AppSizes.s64 : AppSizes.s52, border: medal),
                      const SizedBox(height: AppSizes.s6),
                      Text(
                        entry.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(
                          color: entry.uid == uid ? AppColors.primaryDark : AppColors.textPrimary,
                        ).copyWith(fontSize: AppSizes.s12, height: 1.15),
                      ),
                      Text(
                        l10n.predictionRankingPoints(entry.points),
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                      const SizedBox(height: AppSizes.s8),
                      Container(
                        height: switch (index) { 0 => AppSizes.s80, 1 => AppSizes.s60, _ => AppSizes.s44 },
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: medal.withValues(alpha: 0.85),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.s10)),
                        ),
                        child: Text('$positionº', style: AppTypography.title(color: AppColors.white)),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

/// Linha do 4º em diante: posição, inicial, nome, exatos/palpites e pontos.
class _RankingRow extends StatelessWidget {
  final PredictionRankingEntry entry;
  final int position;
  final bool mine;

  const _RankingRow({required this.entry, required this.position, required this.mine});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
      decoration: BoxDecoration(
        color: mine ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        border: Border.all(color: mine ? AppColors.primary : AppColors.greyLight),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.s32,
            child: Text('$positionº', style: AppTypography.label(color: AppColors.textSecondary)),
          ),
          _Initial(name: entry.name, size: AppSizes.s36),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary),
                ),
                Text(
                  l10n.predictionRankingStats(entry.exact, entry.count),
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
          Text(l10n.predictionRankingPoints(entry.points), style: AppTypography.label(color: AppColors.primaryDark)),
        ],
      ),
    );
  }
}

/// "Sua posição", fixa embaixo (mesmo fora do top 50).
class _MyPositionBar extends StatelessWidget {
  final PredictionRankingEntry? entry;
  final int? position;

  const _MyPositionBar({required this.entry, required this.position});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = this.entry;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_pin_rounded, color: AppColors.white, size: AppSizes.s28),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.predictionRankingYou, style: AppTypography.subtitle(color: AppColors.white)),
                  Text(
                    entry == null
                        ? l10n.predictionRankingNotRanked
                        : '${l10n.predictionRankingPoints(entry.points)} · '
                            '${l10n.predictionRankingStats(entry.exact, entry.count)}',
                    style: AppTypography.label(color: AppColors.white),
                  ),
                ],
              ),
            ),
            if (entry != null && position != null)
              Text('$positionº', style: AppTypography.display(color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}
