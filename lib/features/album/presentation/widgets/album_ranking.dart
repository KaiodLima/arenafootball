import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/usecases/album_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cor da medalha da posição (1º ouro, 2º prata, 3º bronze).
Color _medal(int position) => switch (position) {
      1 => AppColors.gold,
      2 => AppColors.silver,
      _ => AppColors.bronze,
    };

/// Aba "Ranking" da capa: pódio dos 3 primeiros e a lista até o 50º, de quem
/// tem mais figurinhas diferentes coladas no álbum ([total] = do álbum).
class AlbumRankingSection extends StatelessWidget {
  final AlbumRankingView? view;
  final bool loading;
  final int total;
  final String userId;
  final VoidCallback onRefresh;

  const AlbumRankingSection({
    super.key,
    required this.view,
    required this.loading,
    required this.total,
    required this.userId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final view = this.view;
    if (view == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.s32),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (view.top.isEmpty) {
      return ArenaEmptyState(message: l10n.albumRankingEmpty, icon: Icons.emoji_events_outlined);
    }
    final podium = view.top.take(3).toList();
    final rest = view.top.skip(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.albumRankingHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12))),
            IconButton(
              tooltip: l10n.albumRankingRefresh,
              onPressed: loading ? null : onRefresh,
              icon: loading
                  ? const SizedBox.square(
                      dimension: AppSizes.s18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.refresh_rounded, color: AppColors.primary),
            ),
          ],
        ),
        _Podium(entries: podium, total: total, userId: userId),
        const SizedBox(height: AppSizes.s12),
        for (var i = 0; i < rest.length; i++)
          _RankingRow(position: i + 4, entry: rest[i], total: total, mine: rest[i].userId == userId),
      ],
    );
  }
}

/// Pódio na ordem visual 2º · 1º · 3º, num cartão escuro (como o herói da capa).
class _Podium extends StatelessWidget {
  final List<AlbumRankingEntryDTO> entries;
  final int total;
  final String userId;

  const _Podium({required this.entries, required this.total, required this.userId});

  @override
  Widget build(BuildContext context) {
    final order = [if (entries.length > 1) 1, 0, if (entries.length > 2) 2];
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s20, AppSizes.s12, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryMedium],
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final i in order)
            Expanded(
              child: _PodiumPlace(
                position: i + 1,
                entry: entries[i],
                total: total,
                mine: entries[i].userId == userId,
              ),
            ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  final int position;
  final AlbumRankingEntryDTO entry;
  final int total;
  final bool mine;

  const _PodiumPlace({required this.position, required this.entry, required this.total, required this.mine});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final medal = _medal(position);
    final first = position == 1;
    final stepHeight = switch (position) { 1 => AppSizes.s72, 2 => AppSizes.s52, _ => AppSizes.s40 };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first) const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: AppSizes.s28),
        _Avatar(entry: entry, size: first ? AppSizes.s64 : AppSizes.s52, ring: medal),
        const SizedBox(height: AppSizes.s6),
        Text(
          mine ? l10n.albumRankingYou : entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
        ),
        Text(
          entry.complete ? l10n.albumRankingComplete : '${entry.collected}/$total',
          style: AppTypography.label(color: entry.complete ? AppColors.gold : AppColors.whiteSoft)
              .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSizes.s6),
        Container(
          height: stepHeight,
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [medal, medal.withValues(alpha: 0.55)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.s10)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$positionº',
            style: AppTypography.display(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s22),
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int position;
  final AlbumRankingEntryDTO entry;
  final int total;
  final bool mine;

  const _RankingRow({required this.position, required this.entry, required this.total, required this.mine});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = total == 0 ? 0.0 : (entry.collected / total).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
      decoration: BoxDecoration(
        color: mine ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: mine ? AppColors.primary : AppColors.transparent),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.s32,
            child: Text(
              '$positionº',
              style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s14),
            ),
          ),
          _Avatar(entry: entry, size: AppSizes.s40),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mine ? l10n.albumRankingYou : entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSizes.s4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.s4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: AppSizes.s6,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    color: entry.complete ? AppColors.gold : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.collected}/$total',
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w800),
              ),
              if (entry.rares > 0)
                Text(
                  '✨ ${entry.rares}',
                  style: AppTypography.subtitle(color: AppColors.gold).copyWith(fontSize: AppSizes.s12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Sua posição" fixa embaixo (mesmo fora do top 50).
class AlbumMyPositionBar extends StatelessWidget {
  final AlbumRankingView view;
  final int total;

  const AlbumMyPositionBar({super.key, required this.view, required this.total});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = view.me;
    return Material(
      color: AppColors.primaryDark,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
          child: me == null
              ? Text(
                  l10n.albumRankingNotYet,
                  style: AppTypography.subtitle(color: AppColors.whiteSoft),
                )
              : Row(
                  children: [
                    _Avatar(entry: me, size: AppSizes.s36, ring: AppColors.gold),
                    const SizedBox(width: AppSizes.s10),
                    Expanded(
                      child: Text(
                        l10n.albumRankingMyPosition,
                        style: AppTypography.label(color: AppColors.white),
                      ),
                    ),
                    Text(
                      view.myPosition == null ? '–' : '${view.myPosition}º',
                      style: AppTypography.display(color: AppColors.gold).copyWith(fontSize: AppSizes.s22),
                    ),
                    const SizedBox(width: AppSizes.s12),
                    Text(
                      '${me.collected}/$total',
                      style: AppTypography.label(color: AppColors.whiteSoft),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Foto da conta (ou a inicial), com anel na cor da medalha.
class _Avatar extends StatelessWidget {
  final AlbumRankingEntryDTO entry;
  final double size;
  final Color? ring;

  const _Avatar({required this.entry, required this.size, this.ring});

  @override
  Widget build(BuildContext context) {
    final initial = entry.name.trim().isEmpty ? '?' : entry.name.trim()[0].toUpperCase();
    final fallback = Center(
      child: Text(
        initial,
        style: AppTypography.title(color: AppColors.primaryDark).copyWith(fontSize: size * 0.4),
      ),
    );
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring == null ? 0 : AppSizes.s2),
      decoration: BoxDecoration(shape: BoxShape.circle, color: ring ?? AppColors.transparent),
      child: ClipOval(
        child: ColoredBox(
          color: AppColors.background,
          child: entry.imageUrl.isEmpty
              ? fallback
              : CachedNetworkImage(
                  imageUrl: entry.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => fallback,
                ),
        ),
      ),
    );
  }
}
