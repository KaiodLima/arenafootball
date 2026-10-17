import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/bloc/fan_ranking_cubit.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/bloc/fan_ranking_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Ranking de torcidas: times da região com mais torcedores entre os usuários
/// do app (time do coração). Pódio dos 3 primeiros, lista com barras na cor do
/// time e o destaque da torcida do próprio usuário.
class FanRankingPage extends StatefulWidget {
  const FanRankingPage({super.key});

  @override
  State<FanRankingPage> createState() => _FanRankingPageState();
}

class _FanRankingPageState extends State<FanRankingPage> {
  late final FanRankingCubit _cubit;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final regions = context.watch<RegionCubit>().state.regions;
    final user = context.watch<SessionCubit>().state.user;

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
      ),
      body: BlocBuilder<FanRankingCubit, FanRankingState>(
        builder: (context, state) {
          final entries = state.entries;
          final myPosition = user == null || !user.hasFavoriteTeam
              ? null
              : state.positionOf(teamId: user.favoriteTeamId, teamName: user.favoriteTeam);
          bool isMine(FanRankingEntry e) =>
              user != null && user.hasFavoriteTeam && e.isTeam(id: user.favoriteTeamId, teamName: user.favoriteTeam);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _load(force: true),
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
                      onTap: () => _cubit.selectRegion(regions[index]),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.s16),
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
                  if (myPosition != null) ...[
                    _MyFansCard(
                      entry: entries.firstWhere(isMine),
                      position: myPosition,
                    ),
                    const SizedBox(height: AppSizes.s16),
                  ],
                  _Podium(entries: entries.take(3).toList(), positionAt: state.positionAt, isMine: isMine),
                  const SizedBox(height: AppSizes.s16),
                  for (var i = 3; i < entries.length; i++)
                    _RankingRow(
                      entry: entries[i],
                      position: state.positionAt(i),
                      leaderFans: entries.first.fans,
                      mine: isMine(entries[i]),
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
          );
        },
      ),
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

/// Cor da barra/destaque do time (verde do app quando o time não tem cor).
Color _teamColor(FanRankingEntry entry) => TeamPalette.orDefault(entry.primaryColor, entry.secondaryColor).accent;

/// "Sua torcida": posição e torcedores do time do coração na região.
class _MyFansCard extends StatelessWidget {
  final FanRankingEntry entry;
  final int position;

  const _MyFansCard({required this.entry, required this.position});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = TeamPalette.orDefault(entry.primaryColor, entry.secondaryColor);
    return Container(
      padding: const EdgeInsets.all(AppSizes.s14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [palette.accent, palette.accentDark]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.s2),
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            child: TeamCrest(imageUrl: entry.imageUrl, size: AppSizes.s44),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.fanRankingYourFans, style: AppTypography.subtitle(color: palette.onAccent)),
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(color: palette.onAccent).copyWith(fontSize: AppSizes.s18),
                ),
                Text(l10n.fanRankingFans(entry.fans), style: AppTypography.body(color: palette.onAccent)),
              ],
            ),
          ),
          Text('$positionº', style: AppTypography.display(color: palette.onAccent)),
        ],
      ),
    );
  }
}

/// Pódio: 2º, 1º e 3º lado a lado, o 1º mais alto.
class _Podium extends StatelessWidget {
  final List<FanRankingEntry> entries;
  final int Function(int index) positionAt;
  final bool Function(FanRankingEntry entry) isMine;

  const _Podium({required this.entries, required this.positionAt, required this.isMine});

  @override
  Widget build(BuildContext context) {
    // Ordem visual: 2º, 1º, 3º (com menos de 3 times, só os que houver).
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
              child: _PodiumPlace(
                entry: entries[index],
                position: positionAt(index),
                height: switch (index) { 0 => AppSizes.s80, 1 => AppSizes.s60, _ => AppSizes.s44 },
                mine: isMine(entries[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  final FanRankingEntry entry;
  final int position;
  final double height;
  final bool mine;

  const _PodiumPlace({required this.entry, required this.position, required this.height, required this.mine});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final medal = switch (position) { 1 => AppColors.gold, 2 => AppColors.silver, _ => AppColors.bronze };
    final first = position == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (first) const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s28),
          Container(
            padding: const EdgeInsets.all(AppSizes.s2),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: medal, width: AppSizes.s2),
            ),
            child: TeamCrest(imageUrl: entry.imageUrl, size: first ? AppSizes.s64 : AppSizes.s52),
          ),
          const SizedBox(height: AppSizes.s6),
          Text(
            entry.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(color: mine ? AppColors.primaryDark : AppColors.textPrimary)
                .copyWith(fontSize: AppSizes.s12, height: 1.15),
          ),
          Text(
            l10n.fanRankingFans(entry.fans),
            textAlign: TextAlign.center,
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
          const SizedBox(height: AppSizes.s8),
          Container(
            height: height,
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
  }
}

/// Linha do 4º em diante: posição, escudo, nome, torcedores e a barra
/// proporcional ao 1º, na cor do time.
class _RankingRow extends StatelessWidget {
  final FanRankingEntry entry;
  final int position;
  final int leaderFans;
  final bool mine;

  const _RankingRow({required this.entry, required this.position, required this.leaderFans, required this.mine});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final share = leaderFans <= 0 ? 0.0 : (entry.fans / leaderFans).clamp(0.0, 1.0);
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
          TeamCrest(imageUrl: entry.imageUrl, size: AppSizes.s36),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      l10n.fanRankingFans(entry.fans),
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.s4),
                  child: LinearProgressIndicator(
                    value: share,
                    minHeight: AppSizes.s6,
                    color: _teamColor(entry),
                    backgroundColor: AppColors.greyLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
