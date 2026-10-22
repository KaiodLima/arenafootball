import 'dart:math' as math;

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
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Tier do emblema de cada nível do torcedor.
AchievementTier _levelTier(FanLevel level) => switch (level) {
      FanLevel.fan => AchievementTier.bronze,
      FanLevel.loyal => AchievementTier.silver,
      FanLevel.roots || FanLevel.ultra => AchievementTier.gold,
      FanLevel.legend => AchievementTier.legend,
    };

/// "Minhas conquistas" como sala de troféus (fundo noturno): emblema do nível
/// com o anel de XP, números, o "quase lá" e uma prateleira por categoria.
/// As medalhas entram em sequência ao abrir.
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> with SingleTickerProviderStateMixin {
  late final AnimationController _reveal =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _reveal.value = 1;
    } else if (_reveal.value == 0 && !_reveal.isAnimating) {
      _reveal.forward();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = context.watch<SessionCubit>().state.user?.name ?? '';

    return BlocBuilder<AchievementsCubit, AchievementsState>(
      builder: (context, state) {
        final board = state.board;
        final almost = board.almostThere();
        final categories = [
          for (final category in AchievementCategory.values)
            if (board.entries.any((e) => e.achievement.category == category)) category,
        ];
        var shelfIndex = 0;

        return Scaffold(
          backgroundColor: AppColors.trophyBackground,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: AppSizes.achievementsHeaderHeight,
                backgroundColor: AppColors.trophyBackground,
                surfaceTintColor: AppColors.transparent,
                foregroundColor: AppColors.white,
                title: Text(
                  l10n.achievementsTitle,
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _TrophyHeader(board: board, name: name, reveal: _reveal),
                ),
              ),
              if (state.loading && board.entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                )
              else if (board.entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      textTheme: Theme.of(context).textTheme.apply(bodyColor: AppColors.white),
                    ),
                    child: ArenaEmptyState(message: l10n.achievementsEmpty, icon: Icons.military_tech_outlined),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: AppSizes.s32),
                  sliver: SliverList.list(
                    children: [
                      if (almost != null) _AlmostThereCard(entry: almost),
                      for (final category in categories)
                        _CategoryShelf(
                          category: category,
                          entries: board.shelfOf(category),
                          reveal: _reveal,
                          order: shelfIndex++,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Topo: holofote, emblema do nível dentro do anel de XP (animado), nome, XP
/// até o próximo nível e os três números em cartões de vidro.
class _TrophyHeader extends StatelessWidget {
  final AchievementBoard board;
  final String name;
  final Animation<double> reveal;

  const _TrophyHeader({required this.board, required this.name, required this.reveal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final xp = board.xp;
    final level = board.level;
    final next = level.next;
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final ring = CurvedAnimation(parent: reveal, curve: const Interval(0, 0.7, curve: Curves.easeOutCubic));

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.35),
          radius: 0.9,
          colors: [AppColors.trophyGlow, AppColors.trophyBackground],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSizes.s16, topInset, AppSizes.s16, AppSizes.s16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width - AppSizes.s32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: AppSizes.s150,
                  height: AppSizes.s150,
                  child: AnimatedBuilder(
                    animation: ring,
                    builder: (context, child) => CustomPaint(
                      painter: _XpRingPainter(progress: level.progressOf(xp) * ring.value),
                      child: child,
                    ),
                    child: Center(
                      child: MedalBadge(
                        tier: _levelTier(level),
                        icon: 'crown',
                        unlocked: true,
                        size: AppSizes.s110,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.s6),
                Text(
                  fanLevelLabel(l10n, level).toUpperCase(),
                  style: AppTypography.display(color: AppColors.gold).copyWith(
                    fontSize: AppSizes.s22,
                    letterSpacing: 3,
                  ),
                ),
                if (name.isNotEmpty)
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s16),
                  ),
                const SizedBox(height: AppSizes.s2),
                Text(
                  next == null
                      ? l10n.achievementsMaxLevel
                      : l10n.achievementsNextLevel(next.minXp - xp, fanLevelLabel(l10n, next)),
                  style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.65))
                      .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppSizes.s16),
                Row(
                  children: [
                    _StatCard(
                        icon: Icons.military_tech_rounded,
                        value: '${board.unlocked.length}',
                        label: l10n.achievementsStatMedals),
                    const SizedBox(width: AppSizes.s10),
                    _StatCard(icon: Icons.star_rounded, value: '$xp', label: l10n.achievementsStatXp),
                    const SizedBox(width: AppSizes.s10),
                    _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      value: '${board.bestStreak}',
                      label: l10n.achievementsStatStreak,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Anel de XP em volta do emblema: trilho apagado e arco dourado.
class _XpRingPainter extends CustomPainter {
  final double progress;

  _XpRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.06;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.white.withValues(alpha: 0.1),
    );
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [AppColors.medalGoldDark, AppColors.gold, AppColors.medalGoldLight],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _XpRingPainter old) => old.progress != progress;
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s10),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppSizes.s16),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: AppSizes.s18, color: AppColors.gold),
                  const SizedBox(width: AppSizes.s4),
                  Text(value, style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20)),
                ],
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.6))
                    .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
}

/// "Quase lá": a próxima conquista mais perto da meta.
class _AlmostThereCard extends StatelessWidget {
  final AchievementEntry entry;

  const _AlmostThereCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final achievement = entry.achievement;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, 0),
      child: Material(
        color: AppColors.trophySurface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          onTap: () => showAchievementDetails(context, entry),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.s14),
            child: Row(
              children: [
                MedalBadge(
                  tier: achievement.tier,
                  icon: achievement.icon,
                  unlocked: false,
                  progress: entry.progress,
                  size: AppSizes.s64,
                ),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.achievementsAlmostThere,
                        style: AppTypography.label(color: AppColors.gold)
                            .copyWith(fontSize: AppSizes.s12, letterSpacing: 1.4, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        achievement.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                      ),
                      const SizedBox(height: AppSizes.s6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.s6),
                        child: LinearProgressIndicator(
                          value: entry.progress,
                          minHeight: AppSizes.s8,
                          color: AppColors.primary,
                          backgroundColor: AppColors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(height: AppSizes.s4),
                      Text(
                        l10n.achievementsProgress(entry.current.clamp(0, achievement.goal), achievement.goal),
                        style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.65))
                            .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.white.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Prateleira de uma categoria: título, "ganhas/total", "Ver todas" e a faixa
/// de medalhas (entrando em sequência).
class _CategoryShelf extends StatelessWidget {
  final AchievementCategory category;
  final List<AchievementEntry> entries;
  final Animation<double> reveal;

  /// Posição da prateleira (atrasa a entrada das de baixo).
  final int order;

  const _CategoryShelf({required this.category, required this.entries, required this.reveal, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = achievementCategoryLabel(l10n, category);
    final unlocked = entries.where((e) => e.unlocked).length;

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.s20, right: AppSizes.s8),
            child: Row(
              children: [
                Text(title, style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18)),
                const SizedBox(width: AppSizes.s8),
                Text(
                  '$unlocked/${entries.length}',
                  style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.5))
                      .copyWith(fontSize: AppSizes.s14),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => _CategoryGridPage(title: title, entries: entries),
                  )),
                  child: Text(
                    l10n.achievementsSeeAll,
                    style: AppTypography.label(color: AppColors.gold).copyWith(fontSize: AppSizes.s14),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: AppSizes.s150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s8),
              itemBuilder: (context, index) {
                final start = (0.25 + order * 0.08 + index * 0.05).clamp(0.0, 0.85);
                final appear = CurvedAnimation(
                  parent: reveal,
                  curve: Interval(start, (start + 0.3).clamp(0.0, 1.0), curve: Curves.easeOutBack),
                );
                return AnimatedBuilder(
                  animation: appear,
                  builder: (context, child) => Opacity(
                    opacity: appear.value.clamp(0.0, 1.0),
                    child: Transform.scale(scale: 0.6 + 0.4 * appear.value, child: child),
                  ),
                  child: _ShelfMedal(entry: entries[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Medalha com o nome embaixo (ganha em branco; bloqueada apagada).
class _ShelfMedal extends StatelessWidget {
  final AchievementEntry entry;

  const _ShelfMedal({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final achievement = entry.achievement;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.s16),
      onTap: () => showAchievementDetails(context, entry),
      child: SizedBox(
        width: AppSizes.s100,
        child: Column(
          children: [
            const SizedBox(height: AppSizes.s6),
            MedalBadge(
              tier: achievement.tier,
              icon: achievement.icon,
              unlocked: entry.unlocked,
              progress: entry.progress,
              hidden: entry.hidden,
              size: AppSizes.s80,
            ),
            const SizedBox(height: AppSizes.s6),
            Text(
              entry.hidden ? l10n.achievementsSecret : achievement.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(
                color: entry.unlocked ? AppColors.white : AppColors.white.withValues(alpha: 0.45),
              ).copyWith(fontSize: AppSizes.s12, height: 1.15),
            ),
          ],
        ),
      ),
    );
  }
}

/// Todas as conquistas de uma categoria em grade.
class _CategoryGridPage extends StatelessWidget {
  final String title;
  final List<AchievementEntry> entries;

  const _CategoryGridPage({required this.title, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.trophyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.trophyBackground,
        surfaceTintColor: AppColors.transparent,
        foregroundColor: AppColors.white,
        title: Text(title, style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSizes.s16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppSizes.s8,
          crossAxisSpacing: AppSizes.s8,
          childAspectRatio: 0.72,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) => Center(child: _ShelfMedal(entry: entries[index])),
      ),
    );
  }
}
