import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_board.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/achievements_cubit.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_labels.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_sheet.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Minhas conquistas": nível e XP no topo, as recentes, o filtro por
/// categoria e a grade de medalhas (bloqueadas em cinza com o progresso).
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  /// Categoria do filtro (nula = todas).
  AchievementCategory? _category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = context.watch<SessionCubit>().state.user?.name ?? '';

    return BlocBuilder<AchievementsCubit, AchievementsState>(
      builder: (context, state) {
        final board = state.board;
        final entries = board.ofCategory(_category);
        final recent = board.recent();
        final categories = [
          for (final category in AchievementCategory.values)
            if (board.entries.any((e) => e.achievement.category == category)) category,
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: AppSizes.achievementsHeaderHeight,
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.white,
                title: Text(
                  l10n.achievementsTitle,
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _LevelHeader(board: board, name: name),
                ),
              ),
              if (state.loading && board.entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (board.entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ArenaEmptyState(message: l10n.achievementsEmpty, icon: Icons.military_tech_outlined),
                )
              else ...[
                if (recent.isNotEmpty) ...[
                  _SectionTitle(l10n.achievementsRecent),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: AppSizes.s120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                        itemCount: recent.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s12),
                        itemBuilder: (context, index) => _MedalTile(entry: recent[index], compact: true),
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: AppSizes.s56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, 0),
                      children: [
                        ArenaChoiceChip(
                          label: l10n.achievementsAll,
                          selected: _category == null,
                          onTap: () => setState(() => _category = null),
                        ),
                        for (final category in categories) ...[
                          const SizedBox(width: AppSizes.s8),
                          ArenaChoiceChip(
                            label: achievementCategoryLabel(l10n, category),
                            selected: _category == category,
                            onTap: () => setState(() => _category = category),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s32),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: AppSizes.s12,
                      crossAxisSpacing: AppSizes.s12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) => _MedalTile(entry: entries[index]),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s20, AppSizes.s20, AppSizes.s10),
          child: Text(text, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
        ),
      );
}

/// Topo: selo do nível, nome, barra de XP até o próximo nível e a contagem.
class _LevelHeader extends StatelessWidget {
  final AchievementBoard board;
  final String name;

  const _LevelHeader({required this.board, required this.name});

  static AchievementTier _tierOf(FanLevel level) => switch (level) {
        FanLevel.fan => AchievementTier.bronze,
        FanLevel.loyal => AchievementTier.silver,
        FanLevel.roots || FanLevel.ultra => AchievementTier.gold,
        FanLevel.legend => AchievementTier.legend,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final xp = board.xp;
    final level = board.level;
    final next = level.next;
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryStrong],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -AppSizes.s40,
            bottom: -AppSizes.s30,
            child: Icon(
              Icons.military_tech_rounded,
              size: AppSizes.s200,
              color: AppColors.white.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(AppSizes.s20, topInset + AppSizes.s8, AppSizes.s20, AppSizes.s20),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width - AppSizes.s40,
                child: Row(
                  children: [
                    MedalBadge(
                      tier: _tierOf(level),
                      icon: 'medal',
                      unlocked: true,
                      size: AppSizes.s80,
                    ),
                    const SizedBox(width: AppSizes.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fanLevelLabel(l10n, level).toUpperCase(),
                            style: AppTypography.label(color: AppColors.gold).copyWith(
                              fontSize: AppSizes.s14,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (name.isNotEmpty)
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
                            ),
                          const SizedBox(height: AppSizes.s10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.s8),
                            child: LinearProgressIndicator(
                              value: level.progressOf(xp),
                              minHeight: AppSizes.s8,
                              color: AppColors.gold,
                              backgroundColor: AppColors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(height: AppSizes.s6),
                          Text(
                            next == null
                                ? l10n.achievementsMaxLevel
                                : '${l10n.achievementsXp(xp)}  ·  '
                                    '${l10n.achievementsNextLevel(next.minXp - xp, fanLevelLabel(l10n, next))}',
                            style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                          ),
                          const SizedBox(height: AppSizes.s2),
                          Text(
                            l10n.achievementsCount(board.unlocked.length, board.entries.length),
                            style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.8))
                                .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Medalha + nome + progresso ("7 de 10") ou o nível; toque abre os detalhes.
class _MedalTile extends StatelessWidget {
  final AchievementEntry entry;

  /// Faixa "Recentes": sem o progresso embaixo.
  final bool compact;

  const _MedalTile({required this.entry, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final achievement = entry.achievement;
    final title = entry.hidden ? l10n.achievementsSecret : achievement.title;
    final subtitle = entry.unlocked
        ? achievementTierLabel(l10n, achievement.tier)
        : entry.hidden
            ? ''
            : l10n.achievementsProgress(entry.current.clamp(0, achievement.goal), achievement.goal);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.s16),
      onTap: () => showAchievementSheet(context, entry),
      child: SizedBox(
        width: compact ? AppSizes.s80 : null,
        child: Column(
          children: [
            const SizedBox(height: AppSizes.s4),
            MedalBadge(
              tier: achievement.tier,
              icon: achievement.icon,
              unlocked: entry.unlocked,
              progress: entry.progress,
              hidden: entry.hidden,
              size: compact ? AppSizes.s56 : AppSizes.s64,
            ),
            const SizedBox(height: AppSizes.s6),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: entry.unlocked ? AppColors.textPrimary : AppColors.textSecondary)
                  .copyWith(fontSize: AppSizes.s12, height: 1.15),
            ),
            if (!compact && subtitle.isNotEmpty)
              Text(subtitle, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10)),
          ],
        ),
      ),
    );
  }
}
