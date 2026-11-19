import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/predictions/presentation/widgets/hub_widgets.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Foto do participante; sem foto, a inicial colorida (a do bolão).
class FantasyAvatar extends StatelessWidget {
  final String name;
  final String photoUrl;
  final double size;
  final Color? ring;

  const FantasyAvatar({super.key, required this.name, required this.photoUrl, required this.size, this.ring});

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isEmpty) return HubInitial(name: name, size: size, ring: ring);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: ring == null ? null : Border.all(color: ring!, width: size * 0.07),
        image: DecorationImage(image: CachedNetworkImageProvider(photoUrl), fit: BoxFit.cover),
      ),
    );
  }
}

/// Pódio do Fantasy: 2º · 1º · 3º com medalha, coroa no 1º e os pontos.
class FantasyPodium extends StatelessWidget {
  final List<FantasyRankingEntry> entries;
  final List<int> positions;
  final String uid;

  const FantasyPodium({super.key, required this.entries, required this.positions, required this.uid});

  @override
  Widget build(BuildContext context) {
    final order = [if (entries.length > 1) 1, 0, if (entries.length > 2) 2];
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: ArenaHeroBackground(
        watermarkFactor: 0.7,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s16, AppSizes.s8, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final index in order)
                Expanded(
                  child: Builder(builder: (context) {
                    final entry = entries[index];
                    final position = positions[index];
                    final first = index == 0;
                    final medal =
                        switch (position) { 1 => AppColors.gold, 2 => AppColors.silver, _ => AppColors.bronze };
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (first)
                            const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: AppSizes.s32),
                          FantasyAvatar(
                            name: entry.name,
                            photoUrl: entry.photoUrl,
                            size: first ? AppSizes.s64 : AppSizes.s52,
                            ring: medal,
                          ),
                          const SizedBox(height: AppSizes.s6),
                          Text(
                            entry.name,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(color: entry.uid == uid ? AppColors.gold : AppColors.white)
                                .copyWith(fontSize: AppSizes.s12),
                          ),
                          Text(fantasyPointsLabel(entry.points),
                              style: hubDisplay(first ? AppSizes.s28 : AppSizes.s22, medal)),
                          const SizedBox(height: AppSizes.s8),
                          Container(
                            height: switch (position) { 1 => AppSizes.s64, 2 => AppSizes.s44, _ => AppSizes.s32 },
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [medal, Color.lerp(medal, AppColors.black, 0.4)!],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.s10)),
                            ),
                            child: Text('$positionº',
                                style: hubDisplay(AppSizes.s22, AppColors.black.withValues(alpha: 0.7))),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha do 4º em diante; a da conta destacada.
class FantasyRankingRow extends StatelessWidget {
  final FantasyRankingEntry entry;
  final int position;
  final bool mine;

  const FantasyRankingRow({super.key, required this.entry, required this.position, required this.mine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
      decoration: BoxDecoration(
        color: mine ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: mine ? AppColors.primary : AppColors.greyLight),
      ),
      child: Row(
        children: [
          SizedBox(
              width: AppSizes.s36, child: Text('$positionº', style: hubDisplay(AppSizes.s18, AppColors.textSecondary))),
          FantasyAvatar(name: entry.name, photoUrl: entry.photoUrl, size: AppSizes.s36),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: AppColors.textPrimary),
            ),
          ),
          Text(fantasyPointsLabel(entry.points), style: hubDisplay(AppSizes.s22, AppColors.primaryDark)),
          const SizedBox(width: AppSizes.s4),
          Text('pts', style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10)),
        ],
      ),
    );
  }
}

/// Cartão "Sua posição" (fixo embaixo da lista).
class FantasyMyPositionCard extends StatelessWidget {
  final double? points;
  final int? position;
  final String emptyText;

  const FantasyMyPositionCard({super.key, required this.points, required this.position, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const ValueKey('fantasy-my-position'),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.cardRadius)),
      ),
      child: SafeArea(
        top: false,
        child: points == null
            ? Text(emptyText, style: AppTypography.label(color: AppColors.white))
            : Row(
                children: [
                  Text(l10n.fantasyMyPosition, style: AppTypography.label(color: AppColors.whiteSoft)),
                  const Spacer(),
                  if (position != null) Text('$positionº', style: hubDisplay(AppSizes.s22, AppColors.gold)),
                  const SizedBox(width: AppSizes.s16),
                  Text(fantasyPointsLabel(points!), style: hubDisplay(AppSizes.s22, AppColors.white)),
                  const SizedBox(width: AppSizes.s4),
                  Text('pts',
                      style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s10)),
                ],
              ),
      ),
    );
  }
}

/// Faixa dourada "Campeão do Arena Fantasy" (empate = todos os nomes).
class FantasyChampionBanner extends StatelessWidget {
  final List<FantasyChampionDTO> champions;

  const FantasyChampionBanner({super.key, required this.champions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const ValueKey('fantasy-champion-banner'),
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.gold, AppColors.medalGoldDark]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.primaryDark, size: AppSizes.s36),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  champions.length > 1 ? l10n.fantasyChampionsTitle : l10n.fantasyChampionTitle,
                  style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                ),
                Text(
                  champions.map((c) => c.name).join(' · '),
                  style: AppTypography.title(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s18),
                ),
                Text(
                  l10n.fantasyPointsValue(fantasyPointsLabel(champions.first.points)),
                  style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão de uma rodada do histórico: total, posição, os 5 atletas com os
/// pontos de cada um e o capitão marcado.
class FantasyHistoryCard extends StatelessWidget {
  final FantasyHistoryItem item;
  final Map<String, FantasyAthleteDTO> athletes;

  /// Toque no atleta (pontuação detalhada); nulo = só leitura.
  final void Function(String athleteId, bool captain)? onAthleteTap;

  const FantasyHistoryCard({super.key, required this.item, required this.athletes, this.onAthleteTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lineup = item.lineup;
    final points = lineup.points;
    return Container(
      key: ValueKey('fantasy-history-${item.round.number}'),
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
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
              Expanded(
                child: Text(
                  l10n.fantasyRoundTitle(item.round.number),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title().copyWith(fontSize: AppSizes.s16),
                ),
              ),
              if (points == null)
                Flexible(
                  child: Text(
                    l10n.fantasyAwaitingScore,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                )
              else ...[
                if (item.position != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.s12),
                    child: Text('${item.position}º', style: hubDisplay(AppSizes.s18, AppColors.textSecondary)),
                  ),
                Text(fantasyPointsLabel(points), style: hubDisplay(AppSizes.s22, AppColors.primaryDark)),
                const SizedBox(width: AppSizes.s4),
                Text('pts', style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10)),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          for (final slot in FantasySlot.values)
            if (lineup.lineup.idAt(slot) != null)
              Builder(builder: (context) {
                final id = lineup.lineup.idAt(slot)!;
                final captain = id == lineup.lineup.captainId;
                final athletePoints = lineup.athletePoints[id];
                return InkWell(
                  key: ValueKey('fantasy-history-athlete-${item.round.number}-$id'),
                  onTap: onAthleteTap == null ? null : () => onAthleteTap!(id, captain),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.s6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: AppSizes.s44,
                          child: Text(
                            fantasySlotLabel(l10n, slot),
                            style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s10),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            athletes[id]?.name ?? l10n.fantasyUnknownAthlete,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                          ),
                        ),
                        if (captain)
                          Container(
                            key: ValueKey('fantasy-history-captain-$id'),
                            margin: const EdgeInsets.only(right: AppSizes.s8),
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6),
                            decoration:
                                BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppSizes.s6)),
                            child: Text(
                              l10n.fantasyCaptainShort,
                              style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                            ),
                          ),
                        Text(
                          athletePoints == null ? '–' : fantasyPointsLabel(athletePoints),
                          style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s14),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
