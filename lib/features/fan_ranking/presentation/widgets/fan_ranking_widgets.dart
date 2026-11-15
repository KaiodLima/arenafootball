import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';
import 'package:arena_soccer/features/fan_ranking/domain/fan_ranking_view.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

const String _display = 'Anton';

TextStyle fanDisplay(double size, Color color) =>
    TextStyle(fontFamily: _display, fontSize: size, color: color, height: 1.05, letterSpacing: 0.3);

/// Cores do time (verde do app quando o time não tem cor).
TeamPalette fanPalette(FanRankingEntry entry) => TeamPalette.orDefault(entry.primaryColor, entry.secondaryColor);

/// Cor do time em barras e faixas (o tom escuro quando a principal é clara).
Color fanColor(FanRankingEntry entry) => fanPalette(entry).ring;

/// Escudo num círculo branco.
class FanCrest extends StatelessWidget {
  final FanRankingEntry entry;
  final double size;

  const FanCrest({super.key, required this.entry, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.06),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.2), blurRadius: size * 0.15)],
      ),
      child: TeamCrest(imageUrl: entry.imageUrl, size: size),
    );
  }
}

/// Herói do líder: degradê nas cores do 1º, o escudo gigante apagado, a
/// coroa, "MAIOR TORCIDA DE …", o nome e os torcedores em Anton e o % da
/// torcida. Empate no topo: os escudos lado a lado.
class FanLeaderHero extends StatelessWidget {
  final List<FanRankingEntry> leaders;
  final int total;

  /// "Floresta" (região) ou vazio (Geral).
  final String region;

  const FanLeaderHero({super.key, required this.leaders, required this.total, required this.region});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final first = leaders.first;
    final palette = fanPalette(first);
    final ink = palette.onAccent;
    final tie = leaders.length > 1;
    final shown = leaders.take(3).toList();
    final title = tie
        ? l10n.fanRankingTopTie
        : region.isEmpty
            ? l10n.fanRankingBiggestOverall
            : l10n.fanRankingBiggestIn(region);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Container(
        key: const ValueKey('fan-leader'),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.accent, palette.accentDark, Color.lerp(palette.accentDark, AppColors.black, 0.35)!],
          ),
        ),
        child: Stack(
          children: [
            if (first.imageUrl.isNotEmpty)
              Positioned(
                right: -AppSizes.s40,
                top: -AppSizes.s20,
                child: Opacity(
                  opacity: 0.13,
                  child: CachedNetworkImage(
                    imageUrl: first.imageUrl,
                    width: AppSizes.s200,
                    height: AppSizes.s200,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s18, AppSizes.s20, AppSizes.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: double.infinity),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.medalGoldLight, AppColors.gold, AppColors.medalGoldDark],
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.s20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, size: AppSizes.s16, color: AppColors.black),
                        const SizedBox(width: AppSizes.s4),
                        Flexible(
                          child: Text(
                            title.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(color: AppColors.black).copyWith(
                              fontSize: AppSizes.s12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.s14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < shown.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSizes.s12),
                        FanCrest(entry: shown[i], size: tie ? AppSizes.s64 : AppSizes.s80),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSizes.s12),
                  Text(
                    shown.map((e) => e.name).join('  ·  ').toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: fanDisplay(tie ? AppSizes.s22 : AppSizes.s28, ink).copyWith(
                      shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.3), offset: const Offset(0, 2))],
                    ),
                  ),
                  const SizedBox(height: AppSizes.s8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${first.fans}', style: fanDisplay(AppSizes.s48, AppColors.gold)),
                      const SizedBox(width: AppSizes.s8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.s8),
                        child: Text(
                          l10n.fanRankingFansLabel(first.fans).toUpperCase(),
                          style: AppTypography.label(color: ink).copyWith(letterSpacing: 1.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.s6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s4),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppSizes.s20),
                    ),
                    child: Text(
                      l10n.fanRankingShareOf(FanRankingView.percent(first.fans, total)),
                      style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Divisão das torcidas": uma barra só, dividida nas cores dos times (os
/// maiores e "Outros"), e a legenda com os percentuais.
class FanSplitBar extends StatelessWidget {
  final List<FanSlice> slices;

  const FanSplitBar({super.key, required this.slices});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color colorOf(FanSlice s) => s.isOthers ? AppColors.greyLight : fanColor(s.entry!);
    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded, size: AppSizes.s18, color: AppColors.primary),
              const SizedBox(width: AppSizes.s6),
              Expanded(child: Text(l10n.fanRankingSplit, style: AppTypography.label(color: AppColors.textPrimary))),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.s10),
            child: SizedBox(
              height: AppSizes.s20,
              child: Row(
                children: [
                  for (var i = 0; i < slices.length; i++)
                    Expanded(
                      flex: (slices[i].share * 1000).round().clamp(1, 1000),
                      child: Container(
                        margin: EdgeInsets.only(right: i == slices.length - 1 ? 0 : 2),
                        color: colorOf(slices[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.s12),
          Wrap(
            spacing: AppSizes.s12,
            runSpacing: AppSizes.s6,
            children: [
              for (final slice in slices)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSizes.s10,
                      height: AppSizes.s10,
                      decoration: BoxDecoration(color: colorOf(slice), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppSizes.s4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: AppSizes.s120),
                      child: Text(
                        slice.isOthers ? l10n.fanRankingOthers : slice.entry!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s4),
                    Text(
                      '${(slice.share * 100).round()}%',
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Sua torcida": posição, torcedores e %, quem está acima (ou "lidera") e
/// o botão "Convocar a torcida".
class FanMyCrowdCard extends StatelessWidget {
  final FanRankingEntry entry;
  final int position;
  final int total;
  final ({FanRankingEntry team, int gap})? next;
  final VoidCallback onRally;

  const FanMyCrowdCard({
    super.key,
    required this.entry,
    required this.position,
    required this.total,
    required this.next,
    required this.onRally,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = fanPalette(entry);
    final ink = palette.onAccent;
    final next = this.next;
    return Container(
      key: const ValueKey('fan-mine'),
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [palette.accent, palette.accentDark]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
              color: palette.accentDark.withValues(alpha: 0.35), blurRadius: AppSizes.s12, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FanCrest(entry: entry, size: AppSizes.s48),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.fanRankingYourFans.toUpperCase(),
                      style: AppTypography.label(color: ink.withValues(alpha: 0.85)).copyWith(
                        fontSize: AppSizes.s10,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(entry.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: fanDisplay(AppSizes.s22, ink)),
                    Text(
                      '${l10n.fanRankingFans(entry.fans)} · ${FanRankingView.percent(entry.fans, total)}%',
                      style: AppTypography.label(color: ink.withValues(alpha: 0.9)).copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
              ),
              Text('$positionº', style: fanDisplay(AppSizes.s48, ink)),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          Container(
            padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s8, AppSizes.s12, AppSizes.s10),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.s12),
            ),
            child: next == null
                ? Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s18),
                      const SizedBox(width: AppSizes.s8),
                      Text(l10n.fanRankingYouLead, style: AppTypography.label(color: AppColors.white)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trending_up_rounded, color: AppColors.gold, size: AppSizes.s18),
                          const SizedBox(width: AppSizes.s6),
                          Expanded(
                            child: Text(
                              l10n.fanRankingGap(next.gap, next.team.name),
                              maxLines: 2,
                              style: AppTypography.label(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.s6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.s6),
                        child: LinearProgressIndicator(
                          value: next.team.fans == 0 ? 0 : (entry.fans / next.team.fans).clamp(0.0, 1.0),
                          minHeight: AppSizes.s6,
                          backgroundColor: AppColors.white.withValues(alpha: 0.2),
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSizes.s12),
          FilledButton.icon(
            key: const ValueKey('fan-rally'),
            onPressed: onRally,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: palette.accentDark,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
            ),
            icon: const Icon(Icons.campaign_rounded),
            label: Text(l10n.fanRankingRally, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

/// Sem time do coração: chamada para escolher e entrar na disputa.
class FanChooseTeamCard extends StatelessWidget {
  final VoidCallback onChoose;

  const FanChooseTeamCard({super.key, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: AppColors.gold, size: AppSizes.s40),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.fanRankingChooseTitle, style: fanDisplay(AppSizes.s20, AppColors.white)),
                const SizedBox(height: AppSizes.s2),
                Text(l10n.fanRankingChooseText,
                    style: AppTypography.body(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12)),
                const SizedBox(height: AppSizes.s8),
                FilledButton(
                  key: const ValueKey('fan-choose'),
                  onPressed: onChoose,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.black,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(l10n.drawerChooseTeam),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 2º ou 3º lugar: card com a medalha (prata/bronze), escudo, nome,
/// torcedores e %.
class FanRunnerUpCard extends StatelessWidget {
  final FanRankingEntry entry;
  final int position;
  final int total;
  final bool mine;
  final bool showRegion;

  const FanRunnerUpCard({
    super.key,
    required this.entry,
    required this.position,
    required this.total,
    required this.mine,
    this.showRegion = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final medal = switch (position) { 1 => AppColors.gold, 2 => AppColors.silver, _ => AppColors.bronze };
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s12, AppSizes.s12, AppSizes.s14),
      decoration: BoxDecoration(
        color: mine ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: mine ? AppColors.primary : AppColors.greyLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.s32,
                height: AppSizes.s32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [medal, Color.lerp(medal, AppColors.black, 0.35)!],
                  ),
                ),
                child: Text('$position', style: fanDisplay(AppSizes.s18, AppColors.white)),
              ),
              const Spacer(),
              Text(
                '${FanRankingView.percent(entry.fans, total)}%',
                style: fanDisplay(AppSizes.s18, fanColor(entry)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          FanCrest(entry: entry, size: AppSizes.s52),
          const SizedBox(height: AppSizes.s8),
          Text(
            entry.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(color: AppColors.textPrimary),
          ),
          if (showRegion && entry.region.isNotEmpty)
            Text(
              entry.region,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10),
            ),
          const SizedBox(height: AppSizes.s2),
          Text('${entry.fans}', style: fanDisplay(AppSizes.s28, AppColors.textPrimary)),
          Text(
            l10n.fanRankingFansLabel(entry.fans),
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10),
          ),
        ],
      ),
    );
  }
}

/// Do 4º em diante: posição, faixa e escudo, nome (região no Geral), barra
/// na cor do time proporcional ao líder, torcedores e %.
class FanRankRow extends StatelessWidget {
  final FanRankingEntry entry;
  final int position;
  final int leaderFans;
  final int total;
  final bool mine;
  final bool showRegion;

  const FanRankRow({
    super.key,
    required this.entry,
    required this.position,
    required this.leaderFans,
    required this.total,
    required this.mine,
    this.showRegion = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = fanColor(entry);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      decoration: BoxDecoration(
        color: mine ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: mine ? AppColors.primary : AppColors.greyLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: AppSizes.s6, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s10, AppSizes.s10, AppSizes.s12, AppSizes.s10),
                child: Row(
                  children: [
                    SizedBox(
                      width: AppSizes.s32,
                      child: Text('$positionº', style: fanDisplay(AppSizes.s18, AppColors.textSecondary)),
                    ),
                    TeamCrest(imageUrl: entry.imageUrl, size: AppSizes.s36),
                    const SizedBox(width: AppSizes.s10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  entry.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.label(color: AppColors.textPrimary),
                                ),
                              ),
                              if (mine) ...[
                                const SizedBox(width: AppSizes.s6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(AppSizes.s20),
                                  ),
                                  child: Text(
                                    l10n.fanRankingYourFans,
                                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (showRegion && entry.region.isNotEmpty)
                            Text(
                              entry.region,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10),
                            ),
                          const SizedBox(height: AppSizes.s4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.s4),
                            child: LinearProgressIndicator(
                              value: leaderFans == 0 ? 0 : (entry.fans / leaderFans).clamp(0.0, 1.0),
                              minHeight: AppSizes.s6,
                              backgroundColor: AppColors.greyLight,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.s10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${entry.fans}', style: fanDisplay(AppSizes.s20, AppColors.textPrimary)),
                        Text(
                          '${FanRankingView.percent(entry.fans, total)}%',
                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
