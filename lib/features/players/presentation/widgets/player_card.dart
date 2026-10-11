import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Avatar do jogador: a foto ou as iniciais do nome.
class PlayerAvatar extends StatelessWidget {
  final PlayerDTO player;
  final double size;

  const PlayerAvatar({super.key, required this.player, this.size = AppSizes.s52});

  String get _initials {
    final parts = player.name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: player.imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: player.imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => Center(child: _InitialsText(initials: _initials, size: size)),
              errorWidget: (_, __, ___) => Center(child: _InitialsText(initials: _initials, size: size)),
            )
          : _InitialsText(initials: _initials, size: size),
    );
  }
}

class _InitialsText extends StatelessWidget {
  final String initials;
  final double size;

  const _InitialsText({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(initials, style: AppTypography.title(color: AppColors.primaryDark).copyWith(fontSize: size * 0.36));
  }
}

/// Card do jogador na lista do elenco: avatar, nome, selos de gols e
/// assistências e a coroa do artilheiro do time.
class PlayerCard extends StatelessWidget {
  final PlayerDTO player;
  final bool isTopScorer;
  final VoidCallback onTap;

  const PlayerCard({super.key, required this.player, required this.isTopScorer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s10),
      padding: const EdgeInsets.all(AppSizes.s12),
      onTap: onTap,
      child: Row(
        children: [
          PlayerAvatar(player: player),
          const SizedBox(width: AppSizes.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
                      ),
                    ),
                    if (isTopScorer) ...[
                      const SizedBox(width: AppSizes.s6),
                      Tooltip(
                        message: l10n.playersTopScorer,
                        child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s18),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSizes.s6),
                Row(
                  children: [
                    StatPill(icon: Icons.sports_soccer_rounded, value: player.goals),
                    const SizedBox(width: AppSizes.s6),
                    StatPill(icon: Icons.assistant_rounded, value: player.assists),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Selo pequeno "ícone + número" (gols, assistências).
class StatPill extends StatelessWidget {
  final IconData icon;
  final int value;

  const StatPill({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s14, color: AppColors.primaryDark),
          const SizedBox(width: AppSizes.s4),
          Text('$value', style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
