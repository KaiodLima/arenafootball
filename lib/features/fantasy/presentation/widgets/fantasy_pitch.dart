import 'package:flutter/material.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/presentation/widgets/sticker_card.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_score_sheet.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/pitch_painter.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Campinho da escalação: gramado com as linhas e as vagas do formato (ATA no
/// alto, MEI, ZAG e GOL embaixo; no padrão, MEI e LIVRE lado a lado). Cada
/// vaga é uma figurinha (`StickerCard` do álbum, nas cores do time, com a vaga
/// no selo do canto); vazia = espaço tracejado com "+". Braçadeira "C" (toque
/// escolhe o capitão). A formação acompanha cada LIVRE: ela joga na linha da
/// posição do atleta escolhido, depois das vagas fixas dessa linha (animado);
/// as vagas de uma linha ficam espalhadas por igual.
class FantasyPitch extends StatelessWidget {
  final FantasyLineup lineup;
  final Map<String, FantasyAthleteDTO> athletes;

  /// Times por id (cores e escudo das figurinhas); sem o time, a cor da marca.
  final Map<String, TeamDTO> teams;

  /// Pontos na rodada dos atletas que já jogaram (id → pontos); vazio = sem pílulas.
  final Map<String, double> points;
  final bool editable;
  final ValueChanged<FantasySpot> onSlotTap;
  final ValueChanged<String> onCaptainTap;

  const FantasyPitch({
    super.key,
    required this.lineup,
    required this.athletes,
    this.teams = const {},
    this.points = const {},
    required this.editable,
    required this.onSlotTap,
    required this.onCaptainTap,
  });

  /// Altura de cada linha no campinho.
  static const Map<FantasySlot, double> _lineY = {
    FantasySlot.forward: -0.9,
    FantasySlot.midfielder: -0.25,
    FantasySlot.defender: 0.4,
    FantasySlot.goalkeeper: 0.95,
  };

  /// Linha de cada vaga: a fixa na dela; a LIVRE na de [flexLineOf] (a
  /// posição do atleta escolhido nela).
  static Map<FantasySlot, List<FantasySpot>> rows(
    List<FantasySpot> spots,
    FantasySlot Function(FantasySpot flex) flexLineOf,
  ) {
    final rows = {for (final line in _lineY.keys) line: <FantasySpot>[]};
    for (final spot in spots) {
      if (spot.slot != FantasySlot.flex) rows[spot.slot]!.add(spot);
    }
    for (final spot in spots) {
      if (spot.slot == FantasySlot.flex) rows[flexLineOf(spot)]!.add(spot);
    }
    return rows;
  }

  /// Posição de cada vaga: as de uma linha espalhadas por igual (1 = centro;
  /// 2 = ±0,5, como a fixa e a LIVRE do padrão; 3 = ±0,8; mais = a largura toda).
  static Map<FantasySpot, Alignment> formation(Map<FantasySlot, List<FantasySpot>> rows) {
    final positions = <FantasySpot, Alignment>{};
    for (final entry in rows.entries) {
      final row = entry.value;
      final span = row.length <= 2 ? 0.5 : (row.length == 3 ? 0.8 : 1.0);
      for (var i = 0; i < row.length; i++) {
        final x = row.length == 1 ? 0.0 : -span + 2 * span * i / (row.length - 1);
        positions[row[i]] = Alignment(x, _lineY[entry.key]!);
      }
    }
    return positions;
  }

  /// Largura da figurinha (fração do campinho) para a maior linha [widest].
  static double cardFraction(int widest) => widest <= 3 ? 0.22 : (1 / (widest + 0.2)).clamp(0.1, 0.22);

  static const Duration _move = Duration(milliseconds: 450);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: LayoutBuilder(
          builder: (context, box) {
            // Figurinha proporcional ao campinho (3:4).
            final spots = lineup.spots;
            final lines = rows(spots, (flex) => fantasyFlexLine(athletes[lineup.idAt(flex) ?? '']?.position));
            final widest = lines.values.fold(0, (acc, row) => row.length > acc ? row.length : acc);
            final cardWidth = (box.maxWidth * cardFraction(widest)).clamp(AppSizes.s40, AppSizes.s100).toDouble();
            final positions = formation(lines);
            return Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primaryMedium, AppColors.primaryDark],
                      ),
                    ),
                  ),
                ),
                const Positioned.fill(child: CustomPaint(painter: PitchPainter())),
                for (final spot in spots)
                  AnimatedAlign(
                    key: ValueKey('fantasy-pos-${spot.key}'),
                    alignment: positions[spot]!,
                    duration: _move,
                    curve: Curves.easeOutBack,
                    child: _PitchSlot(
                      spot: spot,
                      width: cardWidth,
                      athlete: athletes[lineup.idAt(spot) ?? ''],
                      team: teams[athletes[lineup.idAt(spot) ?? '']?.teamId ?? ''],
                      athleteId: lineup.idAt(spot),
                      points: points[lineup.idAt(spot) ?? ''],
                      captain: lineup.idAt(spot) != null && lineup.idAt(spot) == lineup.captainId,
                      editable: editable,
                      onTap: () => onSlotTap(spot),
                      onCaptainTap: onCaptainTap,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PitchSlot extends StatelessWidget {
  final FantasySpot spot;
  final double width;
  final FantasyAthleteDTO? athlete;
  final TeamDTO? team;
  final String? athleteId;

  /// Pontos na rodada (nulo = ainda não jogou).
  final double? points;
  final bool captain;
  final bool editable;
  final VoidCallback onTap;
  final ValueChanged<String> onCaptainTap;

  const _PitchSlot({
    required this.spot,
    required this.width,
    required this.athlete,
    required this.team,
    required this.athleteId,
    this.points,
    required this.captain,
    required this.editable,
    required this.onTap,
    required this.onCaptainTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filled = athleteId != null;
    final slot = spot.slot;
    final label = fantasySlotLabel(l10n, slot);
    Widget card;
    if (filled) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.s8),
          boxShadow: captain
              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.9), blurRadius: AppSizes.s12, spreadRadius: 2)]
              : const [],
        ),
        child: StickerCard(
          label: label,
          sticker: StickerDTO(
            name: athlete?.name ?? '',
            teamId: athlete?.teamId ?? '',
            team: athlete?.team ?? '',
            imageUrl: athlete?.photoUrl ?? '',
          ),
          style: StickerStyle(
            accent: colorFromHex(team?.primaryColor ?? '') ?? AppColors.primary,
            secondary: colorFromHex(team?.secondaryColor ?? ''),
            crestUrl: team?.imageUrl ?? '',
          ),
        ),
      );
    } else {
      // Vaga livre vazia: moldura dourada (como a rara do álbum).
      card = EmptySlot(
        label: label,
        icon: editable ? Icons.add_rounded : Icons.person_outline_rounded,
        sticker: StickerDTO(rare: slot == FantasySlot.flex),
      );
    }
    // LIVRE: a figurinha "chega" com um leve aumento a cada atleta novo.
    if (slot == FantasySlot.flex && filled) {
      final arriving = card;
      card = TweenAnimationBuilder<double>(
        key: ValueKey('fantasy-flex-in-$athleteId'),
        tween: Tween(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: arriving,
      );
    }
    return SizedBox(
      width: width,
      child: GestureDetector(
        key: ValueKey('fantasy-slot-${spot.key}'),
        onTap: editable || filled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            card,
            if (filled && points != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: -AppSizes.s8,
                child: Center(child: _PointsPill(key: ValueKey('fantasy-points-${spot.key}'), points: points!)),
              ),
            if (filled)
              Positioned(
                right: -AppSizes.s6,
                top: -AppSizes.s6,
                child: GestureDetector(
                  key: ValueKey('fantasy-captain-${spot.key}'),
                  onTap: editable ? () => onCaptainTap(athleteId!) : null,
                  child: Container(
                    width: AppSizes.s24,
                    height: AppSizes.s24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: captain ? AppColors.gold : AppColors.primaryDark.withValues(alpha: 0.85),
                      border: Border.all(color: AppColors.white, width: 1.5),
                      boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s4)],
                    ),
                    child: Text(
                      l10n.fantasyCaptainShort,
                      style: AppTypography.label(color: captain ? AppColors.primaryDark : AppColors.whiteSoft)
                          .copyWith(fontSize: AppSizes.s12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pílula dos pontos do atleta na rodada: verde (+), vermelha (−) ou cinza (0).
class _PointsPill extends StatelessWidget {
  final double points;

  const _PointsPill({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final color = points > 0
        ? AppColors.primaryStrong
        : points < 0
            ? AppColors.danger
            : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.s10),
        border: Border.all(color: AppColors.white, width: 1.5),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s4)],
      ),
      child: Text(
        fantasySignedPoints(points),
        style:
            AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w900),
      ),
    );
  }
}
