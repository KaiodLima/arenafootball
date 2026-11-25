import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_ranking_view.dart';
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

/// Cor da vaga (selo GOL/ZAG/MEI/ATA/LIVRE nas listas do ranking).
Color fantasySlotColor(FantasySlot slot) => switch (slot) {
      FantasySlot.goalkeeper => AppColors.teamOrange,
      FantasySlot.defender => AppColors.organizerPrimary,
      FantasySlot.midfielder => AppColors.primaryStrong,
      FantasySlot.forward => AppColors.danger,
      FantasySlot.flex => AppColors.medalGoldDark,
    };

/// Cor da medalha da [position] (ouro, prata, bronze; nula = sem medalha).
Color? fantasyPodiumColor(int position) => switch (position) {
      1 => AppColors.gold,
      2 => AppColors.silver,
      3 => AppColors.bronze,
      _ => null,
    };

/// Cor dos pontos de um atleta: verde positivo, vermelho negativo, 0 neutro.
Color fantasyPointsColor(double points) => points > 0
    ? AppColors.primaryStrong
    : points < 0
        ? AppColors.danger
        : AppColors.textSecondary;

/// Selo colorido da vaga ("ATA").
class FantasySlotBadge extends StatelessWidget {
  final FantasySlot slot;

  /// Largura fixa (alinha as linhas); nula = do texto.
  final double? width;

  const FantasySlotBadge({super.key, required this.slot, this.width});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s2),
      alignment: width == null ? null : Alignment.center,
      decoration: BoxDecoration(color: fantasySlotColor(slot), borderRadius: BorderRadius.circular(AppSizes.s6)),
      child: Text(
        fantasySlotLabel(l10n, slot),
        maxLines: 1,
        style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s10, letterSpacing: 0.5),
      ),
    );
  }
}

/// Selo "VOCÊ" na linha/pódio da conta.
class FantasyYouBadge extends StatelessWidget {
  final bool dark;

  const FantasyYouBadge({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s1),
      decoration: BoxDecoration(
        color: dark ? AppColors.gold : AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.s6),
      ),
      child: Text(
        AppLocalizations.of(context).fantasyYou,
        style: AppTypography.label(color: dark ? AppColors.primaryDark : AppColors.white)
            .copyWith(fontSize: AppSizes.s10, letterSpacing: 0.5),
      ),
    );
  }
}

/// Selo do estado da rodada: FINAL · PARCIAL · AGUARDANDO APURAÇÃO.
class FantasyRoundStatusBadge extends StatelessWidget {
  final FantasyRoundDTO round;

  const FantasyRoundStatusBadge({super.key, required this.round});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (text, background, foreground) = round.finished
        ? (l10n.fantasyStatusFinal, AppColors.primary, AppColors.white)
        : round.scored
            ? (l10n.fantasyStatusPartial, AppColors.gold, AppColors.primaryDark)
            : (l10n.fantasyStatusAwaiting, AppColors.white.withValues(alpha: 0.18), AppColors.white);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppSizes.s20)),
      child: Text(
        text,
        style: AppTypography.label(color: foreground).copyWith(fontSize: AppSizes.s10, letterSpacing: 0.8),
      ),
    );
  }
}

/// Um número do cabeçalho (valor em Anton e a legenda).
class FantasyHeroStat {
  final String value;
  final String label;
  final bool highlight;

  const FantasyHeroStat({required this.value, required this.label, this.highlight = false});
}

/// Cabeçalho escuro da marca, continuação da AppBar: o [top] (seletor da
/// rodada ou título) e, opcionalmente, os números da conta.
class FantasyRankingHero extends StatelessWidget {
  final Widget top;
  final List<FantasyHeroStat> stats;

  const FantasyRankingHero({super.key, required this.top, this.stats = const []});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSizes.s24)),
      child: ArenaHeroBackground(
        watermarkFactor: 0.9,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s4, AppSizes.s8, AppSizes.s12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              top,
              if (stats.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                  child: Row(
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSizes.s8),
                        Expanded(child: _HeroStatTile(stat: stats[i])),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  final FantasyHeroStat stat;

  const _HeroStatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s6, horizontal: AppSizes.s4),
      decoration: BoxDecoration(
        color: stat.highlight ? AppColors.gold : AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.s12),
      ),
      child: Column(
        children: [
          Text(stat.value,
              maxLines: 1, style: hubDisplay(AppSizes.s20, stat.highlight ? AppColors.primaryDark : AppColors.white)),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(color: stat.highlight ? AppColors.primaryDark : AppColors.whiteSoft)
                .copyWith(fontSize: AppSizes.s10),
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s20, AppSizes.s8, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final index in order)
                Expanded(
                  child: _PodiumColumn(
                    entry: entries[index],
                    position: positions[index],
                    first: index == 0,
                    mine: entries[index].uid == uid,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final FantasyRankingEntry entry;
  final int position;
  final bool first;
  final bool mine;

  const _PodiumColumn({required this.entry, required this.position, required this.first, required this.mine});

  @override
  Widget build(BuildContext context) {
    final medal = fantasyPodiumColor(position) ?? AppColors.bronze;
    final avatar = first ? AppSizes.s64 : AppSizes.s52;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (first) const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: AppSizes.s28),
          // Selo "VOCÊ" por cima da foto: não muda a altura da coluna.
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              FantasyAvatar(name: entry.name, photoUrl: entry.photoUrl, size: avatar, ring: medal),
              if (mine) const Positioned(bottom: -AppSizes.s6, child: FantasyYouBadge(dark: true)),
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          // Nome em até 2 linhas numa caixa de altura fixa: as colunas alinham.
          SizedBox(
            height: AppSizes.s32,
            child: Center(
              child: Text(
                entry.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: mine ? AppColors.gold : AppColors.white)
                    .copyWith(fontSize: AppSizes.s12, height: 1.15),
              ),
            ),
          ),
          Text(fantasyPointsLabel(entry.points), style: hubDisplay(first ? AppSizes.s28 : AppSizes.s22, medal)),
          const SizedBox(height: AppSizes.s10),
          Container(
            height: switch (position) { 1 => AppSizes.s56, 2 => AppSizes.s40, _ => AppSizes.s28 },
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
            child: Text('$positionº', style: hubDisplay(AppSizes.s20, AppColors.black.withValues(alpha: 0.7))),
          ),
        ],
      ),
    );
  }
}

/// Posição com a marca de empate ("4º" e "=" embaixo).
class FantasyPositionLabel extends StatelessWidget {
  final int position;
  final bool tied;
  final double size;
  final Color? color;

  const FantasyPositionLabel(
      {super.key, required this.position, this.tied = false, this.size = AppSizes.s18, this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tint = color ?? fantasyPodiumMedalText(position) ?? AppColors.textSecondary;
    // Empate: "4º =" (o "=" lido como "empate" pelo leitor de tela); "10º =" encolhe para caber.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$positionº', style: hubDisplay(size, tint)),
          if (tied)
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.s2),
              child: Semantics(
                label: l10n.fantasyTiedShort,
                excludeSemantics: true,
                child: Text('=', style: hubDisplay(size * 0.75, tint)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Cor de texto da posição do pódio na lista clara (tons escuros, legíveis).
Color? fantasyPodiumMedalText(int position) => switch (position) {
      1 => AppColors.medalGoldDark,
      2 => AppColors.medalSilverDark,
      3 => AppColors.medalBronzeDark,
      _ => null,
    };

/// Linha do ranking (do 4º em diante; no Geral com campeão, do 2º): posição,
/// foto, nome com o selo "VOCÊ", barra relativa ao líder, a distância para o
/// de cima e os pontos alinhados.
class FantasyRankingRow extends StatelessWidget {
  final FantasyRankingEntry entry;
  final int position;
  final bool mine;

  /// 0..1: pontos / pontos do líder.
  final double fraction;

  /// Pontos atrás de quem está acima (0 = sem texto) e a posição dele.
  final double gap;
  final int? abovePosition;
  final bool tied;

  const FantasyRankingRow({
    super.key,
    required this.entry,
    required this.position,
    required this.mine,
    this.fraction = 0,
    this.gap = 0,
    this.abovePosition,
    this.tied = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
      decoration: BoxDecoration(
        color: mine ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: mine ? AppColors.primary : AppColors.greyLight, width: mine ? 1.5 : 1),
      ),
      child: Row(
        children: [
          SizedBox(width: AppSizes.s40, child: FantasyPositionLabel(position: position, tied: tied)),
          FantasyAvatar(name: entry.name, photoUrl: entry.photoUrl, size: AppSizes.s36),
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
                    if (mine) ...[const SizedBox(width: AppSizes.s6), const FantasyYouBadge()],
                  ],
                ),
                const SizedBox(height: AppSizes.s6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.s4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: AppSizes.s4,
                    backgroundColor: AppColors.greyLight,
                    color: mine ? AppColors.primary : AppColors.medalGoldDark,
                  ),
                ),
                if (gap > 0 && abovePosition != null) ...[
                  const SizedBox(height: AppSizes.s2),
                  Text(
                    l10n.fantasyGapBehind(fantasyPointsLabel(gap), abovePosition!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          FantasyPointsColumn(points: entry.points),
        ],
      ),
    );
  }
}

/// Pontos em Anton numa coluna de largura fixa (alinhados entre as linhas).
class FantasyPointsColumn extends StatelessWidget {
  final double points;
  final double size;

  const FantasyPointsColumn({super.key, required this.points, this.size = AppSizes.s22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.s56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(fantasyPointsLabel(points), style: hubDisplay(size, AppColors.primaryDark)),
          ),
          Text('pts', style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10, height: 1)),
        ],
      ),
    );
  }
}

/// Cartão flutuante "Sua posição": medalha com a posição, quanto falta para
/// passar o de cima (ou "Você lidera") e os pontos.
class FantasyMyPositionCard extends StatelessWidget {
  final double? points;
  final int? position;
  final String emptyText;

  /// Quem a conta persegue; nulo com pontos = lidera.
  final FantasyChase? chase;

  const FantasyMyPositionCard({
    super.key,
    required this.points,
    required this.position,
    required this.emptyText,
    this.chase,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final medal = fantasyPodiumColor(position ?? 0);
    return Container(
      key: const ValueKey('fantasy-my-position'),
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s14, AppSizes.s10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryMedium]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s16, offset: Offset(0, AppSizes.s4))],
      ),
      child: points == null
          ? Row(
              children: [
                const Icon(Icons.sports_soccer_rounded, color: AppColors.gold, size: AppSizes.s28),
                const SizedBox(width: AppSizes.s12),
                Expanded(child: Text(emptyText, style: AppTypography.label(color: AppColors.white))),
              ],
            )
          : Row(
              children: [
                Container(
                  width: AppSizes.s44,
                  height: AppSizes.s44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: medal ?? AppColors.white.withValues(alpha: 0.12),
                    border: Border.all(color: medal == null ? AppColors.gold : AppColors.white, width: 2),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                      child: Text(
                        position == null ? '–' : '$positionº',
                        style: hubDisplay(AppSizes.s20, medal == null ? AppColors.gold : AppColors.primaryDark),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.fantasyMyPosition.toUpperCase(),
                        style: AppTypography.label(color: AppColors.whiteSoft)
                            .copyWith(fontSize: AppSizes.s10, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: AppSizes.s2),
                      Row(
                        children: [
                          Icon(chase == null ? Icons.emoji_events_rounded : Icons.trending_up_rounded,
                              color: AppColors.gold, size: AppSizes.s16),
                          const SizedBox(width: AppSizes.s4),
                          Expanded(
                            child: Text(
                              chase == null
                                  ? l10n.fantasyLeading
                                  : l10n.fantasyChase(fantasyPointsLabel(chase!.gap), chase!.name),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                            ),
                          ),
                        ],
                      ),
                      if (chase != null) ...[
                        const SizedBox(height: AppSizes.s6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.s4),
                          child: LinearProgressIndicator(
                            value: chase!.progress,
                            minHeight: AppSizes.s4,
                            backgroundColor: AppColors.white.withValues(alpha: 0.15),
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(fantasyPointsLabel(points!), style: hubDisplay(AppSizes.s24, AppColors.white)),
                    Text('pts',
                        style: AppTypography.subtitle(color: AppColors.whiteSoft)
                            .copyWith(fontSize: AppSizes.s10, height: 1)),
                  ],
                ),
              ],
            ),
    );
  }
}

/// Faixa festiva "Campeão do Arena Fantasy" (empate = todos os nomes).
class FantasyChampionBanner extends StatelessWidget {
  final List<FantasyChampionDTO> champions;

  const FantasyChampionBanner({super.key, required this.champions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const ValueKey('fantasy-champion-banner'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.medalGoldLight, AppColors.gold, AppColors.medalGoldDark],
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: AppSizes.s16)],
      ),
      child: Stack(
        children: [
          // Brilho: troféu gigante apagado e estrelinhas.
          Positioned(
            right: -AppSizes.s24,
            bottom: -AppSizes.s28,
            child:
                Icon(Icons.emoji_events_rounded, size: AppSizes.s150, color: AppColors.white.withValues(alpha: 0.22)),
          ),
          Positioned(
            right: AppSizes.s12,
            top: AppSizes.s8,
            child: Icon(Icons.auto_awesome_rounded, size: AppSizes.s20, color: AppColors.white.withValues(alpha: 0.8)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.s16),
            child: Row(
              children: [
                Container(
                  width: AppSizes.s72,
                  height: AppSizes.s72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryDark,
                    border: Border.all(color: AppColors.white, width: 3),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s44),
                ),
                const SizedBox(width: AppSizes.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        champions.length > 1 ? l10n.fantasyChampionsTitle : l10n.fantasyChampionTitle,
                        style: AppTypography.label(color: AppColors.primaryDark)
                            .copyWith(fontSize: AppSizes.s10, letterSpacing: 1),
                      ),
                      const SizedBox(height: AppSizes.s2),
                      Text(
                        champions.map((c) => c.name).join(' · '),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: hubDisplay(AppSizes.s24, AppColors.primaryDark),
                      ),
                      const SizedBox(height: AppSizes.s6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(AppSizes.s20),
                        ),
                        child: Text(
                          l10n.fantasyPointsValue(fantasyPointsLabel(champions.first.points)),
                          style: hubDisplay(AppSizes.s14, AppColors.gold),
                        ),
                      ),
                    ],
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

/// Selo dourado do capitão ("C ×1,5").
class _CaptainBadge extends StatelessWidget {
  final double? multiplier;

  const _CaptainBadge({super.key, this.multiplier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s1),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(AppSizes.s6),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.5), blurRadius: AppSizes.s4)],
      ),
      child: Text(
        multiplier == null
            ? l10n.fantasyCaptainShort
            : '${l10n.fantasyCaptainShort} ×${fantasyPointsLabel(multiplier!)}',
        style: AppTypography.label(color: AppColors.primaryDark)
            .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

/// Cartão de uma rodada do histórico: pílula da rodada, estado, posição em
/// medalha e o total; os atletas (as vagas da escalação gravada, no formato
/// daquela rodada) com a vaga, o capitão e os pontos de cada
/// um. Sem apuração, só os atletas em fichas.
class FantasyHistoryCard extends StatelessWidget {
  final FantasyHistoryItem item;
  final Map<String, FantasyAthleteDTO> athletes;

  /// Multiplicador do capitão (congelado na rodada ou o do campeonato).
  final double? captainMultiplier;

  /// Toque no atleta (pontuação detalhada); nulo = só leitura.
  final void Function(String athleteId, bool captain)? onAthleteTap;

  const FantasyHistoryCard({
    super.key,
    required this.item,
    required this.athletes,
    this.captainMultiplier,
    this.onAthleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lineup = item.lineup;
    final points = lineup.points;
    final round = item.round;
    final slots = lineup.lineup.filledSpots;
    final medal = fantasyPodiumColor(item.position ?? 0);
    return Container(
      key: ValueKey('fantasy-history-${round.number}'),
      margin: const EdgeInsets.only(bottom: AppSizes.s10),
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s12, AppSizes.s12, AppSizes.s8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(AppSizes.s20),
                ),
                child: Text(l10n.fantasyRoundTitle(round.number).toUpperCase(),
                    style: hubDisplay(AppSizes.s14, AppColors.white)),
              ),
              const SizedBox(width: AppSizes.s6),
              if (points == null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(AppSizes.s20),
                    ),
                    child: Text(
                      l10n.fantasyAwaitingScore,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s10),
                    ),
                  ),
                )
              else if (!round.finished)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppSizes.s20)),
                  child: Text(
                    l10n.fantasyStatusPartial,
                    style: AppTypography.label(color: AppColors.primaryDark)
                        .copyWith(fontSize: AppSizes.s10, letterSpacing: 0.8),
                  ),
                ),
              if (points != null) ...[
                const Spacer(),
                if (item.position != null) ...[
                  Container(
                    constraints: const BoxConstraints(minWidth: AppSizes.s32),
                    height: AppSizes.s32,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: medal ?? AppColors.inputFill,
                      borderRadius: BorderRadius.circular(AppSizes.s16),
                    ),
                    child: Text('${item.position}º',
                        style:
                            hubDisplay(AppSizes.s14, medal == null ? AppColors.textSecondary : AppColors.primaryDark)),
                  ),
                  const SizedBox(width: AppSizes.s10),
                ],
                Text(fantasyPointsLabel(points), style: hubDisplay(AppSizes.s24, AppColors.primaryDark)),
                const SizedBox(width: AppSizes.s2),
                Text('pts', style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10)),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          if (points == null)
            // Sem apuração: só quem foi escalado, em fichas.
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.s4),
              child: Wrap(
                spacing: AppSizes.s6,
                runSpacing: AppSizes.s6,
                children: [
                  for (final slot in slots) _athleteChip(context, slot),
                ],
              ),
            )
          else
            for (final slot in slots) _athleteRow(context, slot),
        ],
      ),
    );
  }

  Widget _athleteChip(BuildContext context, FantasySpot spot) {
    final l10n = AppLocalizations.of(context);
    final id = item.lineup.lineup.idAt(spot)!;
    final captain = id == item.lineup.lineup.captainId;
    return InkWell(
      key: ValueKey('fantasy-history-athlete-${item.round.number}-$id'),
      onTap: onAthleteTap == null ? null : () => onAthleteTap!(id, captain),
      borderRadius: BorderRadius.circular(AppSizes.s20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s4, AppSizes.s8, AppSizes.s4),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppSizes.s20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FantasySlotBadge(slot: spot.slot),
            const SizedBox(width: AppSizes.s6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.s150),
              child: Text(
                athletes[id]?.name ?? l10n.fantasyUnknownAthlete,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
              ),
            ),
            if (captain) ...[
              const SizedBox(width: AppSizes.s4),
              _CaptainBadge(key: ValueKey('fantasy-history-captain-$id'), multiplier: captainMultiplier),
            ],
          ],
        ),
      ),
    );
  }

  Widget _athleteRow(BuildContext context, FantasySpot spot) {
    final l10n = AppLocalizations.of(context);
    final id = item.lineup.lineup.idAt(spot)!;
    final captain = id == item.lineup.lineup.captainId;
    final athlete = athletes[id];
    final name = athlete?.name ?? l10n.fantasyUnknownAthlete;
    final athletePoints = item.lineup.athletePoints[id];
    return InkWell(
      key: ValueKey('fantasy-history-athlete-${item.round.number}-$id'),
      onTap: onAthleteTap == null ? null : () => onAthleteTap!(id, captain),
      borderRadius: BorderRadius.circular(AppSizes.s8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s4),
        child: Row(
          children: [
            FantasySlotBadge(slot: spot.slot, width: AppSizes.s44),
            const SizedBox(width: AppSizes.s8),
            FantasyAvatar(name: name, photoUrl: athlete?.photoUrl ?? '', size: AppSizes.s24),
            const SizedBox(width: AppSizes.s8),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
              ),
            ),
            if (captain) ...[
              _CaptainBadge(key: ValueKey('fantasy-history-captain-$id'), multiplier: captainMultiplier),
              const SizedBox(width: AppSizes.s8),
            ],
            SizedBox(
              width: AppSizes.s40,
              child: Text(
                athletePoints == null ? '–' : fantasyPointsLabel(athletePoints),
                textAlign: TextAlign.right,
                style: AppTypography.label(color: fantasyPointsColor(athletePoints ?? 0))
                    .copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
