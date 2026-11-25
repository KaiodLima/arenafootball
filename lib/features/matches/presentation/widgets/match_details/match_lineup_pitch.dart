import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_pitch.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/booking_icon.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_details/match_details_sections.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/pitch_painter.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// "Escalações" no detalhe da partida: o campo inteiro na vertical com quem
/// está em campo agora (titulares + quem entrou − quem saiu − expulsos), o
/// visitante na metade de cima e o mandante na de baixo, cada um com a faixa
/// do time (escudo, nome e formação) na borda do seu lado. Cada jogador: a
/// foto (ou as iniciais) com o anel na cor do time, o número da camisa, o
/// nome curto e os selos de gol, cartão e "entrou". Toque abre o perfil.
/// Só aparece com as escalações confirmadas na súmula ([MatchPitch.visible]).
class MatchLineupPitchCard extends StatelessWidget {
  final MatchDTO match;

  /// Elencos carregados do detalhe (foto e posição); quem não está neles
  /// aparece com o nome da escalação e as iniciais.
  final List<PlayerDTO> homeSquad;
  final List<PlayerDTO> awaySquad;
  final String? homeCrest;
  final String? awayCrest;

  /// Cores dos times (nulas = sem cor cadastrada).
  final Color? homeColor;
  final Color? awayColor;
  final void Function(PitchSpot spot, PlayerDTO? player) onPlayerTap;

  const MatchLineupPitchCard({
    super.key,
    required this.match,
    required this.homeSquad,
    required this.awaySquad,
    this.homeCrest,
    this.awayCrest,
    this.homeColor,
    this.awayColor,
    required this.onPlayerTap,
  });

  /// Largura/altura do gramado.
  static const double pitchAspect = 0.52;

  /// Com 5 fileiras num lado (formação de 4 linhas, como 4-2-3-1), mais alto.
  static const double tallPitchAspect = 0.45;

  /// Cor da faixa e do número: a do time, escurecida se for clara (texto branco).
  static Color stripColor(Color? color) =>
      color == null || isLightColor(color) ? AppColors.primaryDark : Color.lerp(color, AppColors.black, 0.2)!;

  @override
  Widget build(BuildContext context) {
    // Sem as escalações confirmadas (ou sem titular num dos times), nada.
    if (!MatchPitch.visible(match)) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final players = {for (final p in [...homeSquad, ...awaySquad]) p.id: p};
    final positions = {for (final p in players.values) p.id: p.position};
    final home = MatchPitch.side(match, MatchSide.home, positions);
    final away = MatchPitch.side(match, MatchSide.away, positions);
    return ArenaCard(
      padding: const EdgeInsets.all(AppSizes.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.s4, top: AppSizes.s4),
            child: MatchDetailsSectionTitle(icon: Icons.stadium_rounded, title: l10n.matchPitchTitle),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.s16),
            child: Column(
              children: [
                _TeamStrip(
                  name: match.awayTeam,
                  crest: awayCrest,
                  color: stripColor(awayColor),
                  formation: match.formations[MatchSide.away] ?? MatchPitch.formation(away),
                ),
                LayoutBuilder(
                  builder: (context, box) {
                    final width = box.maxWidth;
                    final rows = [MatchPitch.rowsOf(home), MatchPitch.rowsOf(away)].reduce((a, b) => a > b ? a : b);
                    final height = width / (rows >= 5 ? tallPitchAspect : pitchAspect);
                    return SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [AppColors.primaryMedium, AppColors.primaryDark, AppColors.primaryMedium],
                                ),
                              ),
                            ),
                          ),
                          const Positioned.fill(child: CustomPaint(painter: PitchPainter())),
                          for (final (spots, color) in [(away, awayColor), (home, homeColor)])
                            for (final spot in spots)
                              _positioned(
                                spot: spot,
                                width: width,
                                height: height,
                                lineCount: spot.rowSize,
                                child: _PitchPlayer(
                                  key: ValueKey('pitch-${spot.side.key}-${spot.playerId}'),
                                  spot: spot,
                                  player: players[spot.playerId],
                                  ring: color ?? AppColors.white,
                                  badge: stripColor(color),
                                  avatar: (width * 0.1).clamp(AppSizes.s28, AppSizes.s36).toDouble(),
                                  onTap: () => onPlayerTap(spot, players[spot.playerId]),
                                ),
                              ),
                        ],
                      ),
                    );
                  },
                ),
                _TeamStrip(
                  name: match.homeTeam,
                  crest: homeCrest,
                  color: stripColor(homeColor),
                  formation: match.formations[MatchSide.home] ?? MatchPitch.formation(home),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// O jogador centrado no lugar dele; a largura do nome cabe entre os
  /// vizinhos da linha (no zigue-zague, entre os da mesma fileira).
  Widget _positioned({
    required PitchSpot spot,
    required double width,
    required double height,
    required int lineCount,
    required Widget child,
  }) {
    final gap = width * 0.92 / lineCount * (lineCount > MatchPitch.maxPerRow ? 2 : 1);
    final tokenWidth = (gap - AppSizes.s4).clamp(AppSizes.s40, AppSizes.s72).toDouble();
    return Positioned(
      left: spot.x * width - tokenWidth / 2,
      top: spot.y * height - _PitchPlayer.heightFor(width) / 2,
      width: tokenWidth,
      child: child,
    );
  }
}

/// Faixa do time na borda do campo: escudo, nome e a formação.
class _TeamStrip extends StatelessWidget {
  final String name;
  final String? crest;
  final Color color;
  final String formation;

  const _TeamStrip({required this.name, required this.crest, required this.color, required this.formation});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s6),
      child: Row(
        children: [
          TeamCrest(imageUrl: crest, size: AppSizes.s24),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
            ),
          ),
          if (formation.isNotEmpty) ...[
            const SizedBox(width: AppSizes.s8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              child: Text(
                formation,
                style: AppTypography.label(color: AppColors.white)
                    .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Um jogador no gramado: foto com anel, número, nome curto e os selos.
class _PitchPlayer extends StatelessWidget {
  final PitchSpot spot;
  final PlayerDTO? player;
  final Color ring;
  final Color badge;
  final double avatar;
  final VoidCallback onTap;

  const _PitchPlayer({
    super.key,
    required this.spot,
    required this.player,
    required this.ring,
    required this.badge,
    required this.avatar,
    required this.onTap,
  });

  static const double _ringWidth = 2.5;
  static const double _nameHeight = AppSizes.s14;

  /// Altura do jogador (foto com anel + nome) para centrar no lugar.
  static double heightFor(double pitchWidth) =>
      (pitchWidth * 0.1).clamp(AppSizes.s28, AppSizes.s36) + 2 * _ringWidth + AppSizes.s2 + _nameHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = spot.entry;
    final person = player ?? PlayerDTO(id: entry.playerId, name: entry.playerName, team: '');
    final name = MatchPitch.shortName(person.name.isNotEmpty ? person.name : entry.playerName);
    final size = avatar + 2 * _ringWidth;
    const badgeSize = AppSizes.s16;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Semantics(
        button: true,
        label: [
          if (entry.number != null) '${entry.number}',
          person.name,
          if (spot.subbedIn) l10n.matchPitchSubbedIn,
        ].join(' '),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: size,
                    height: size,
                    padding: const EdgeInsets.all(_ringWidth),
                    decoration: BoxDecoration(
                      color: ring,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1),
                      boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s4)],
                    ),
                    // Fundo branco sob a foto/iniciais (o anel do time não tinge).
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: PlayerAvatar(player: person, size: avatar),
                    ),
                  ),
                  if (entry.number != null)
                    Positioned(
                      left: -AppSizes.s6,
                      top: -AppSizes.s4,
                      child: _Badge(
                        key: const ValueKey('pitch-number'),
                        color: badge,
                        size: badgeSize,
                        child: Text(
                          '${entry.number}',
                          maxLines: 1,
                          style: AppTypography.label(color: AppColors.white)
                              .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900, height: 1),
                        ),
                      ),
                    ),
                  if (spot.booking != null)
                    Positioned(
                      right: -AppSizes.s4,
                      top: -AppSizes.s2,
                      child: DecoratedBox(
                        key: ValueKey('pitch-card-${spot.booking!.key}'),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.white, width: 1),
                          borderRadius: BorderRadius.circular(AppSizes.s2),
                        ),
                        child: BookingIcon(type: spot.booking!, size: AppSizes.s14),
                      ),
                    ),
                  if (spot.goals > 0)
                    Positioned(
                      right: -AppSizes.s8,
                      bottom: -AppSizes.s2,
                      child: _Badge(
                        key: const ValueKey('pitch-goals'),
                        color: AppColors.white,
                        size: badgeSize,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sports_soccer_rounded, size: AppSizes.s12, color: AppColors.textPrimary),
                            if (spot.goals > 1)
                              Text(
                                '${spot.goals}',
                                style: AppTypography.label(color: AppColors.textPrimary)
                                    .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900, height: 1),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (spot.subbedIn)
                    Positioned(
                      left: -AppSizes.s6,
                      bottom: -AppSizes.s2,
                      child: const _Badge(
                        key: ValueKey('pitch-subbed-in'),
                        color: AppColors.primary,
                        size: badgeSize,
                        child: Icon(Icons.arrow_upward_rounded, size: AppSizes.s12, color: AppColors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.s2),
            Container(
              height: _nameHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppSizes.s4),
              ),
              alignment: Alignment.center,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.label(color: AppColors.white)
                    .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w700, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selinho redondo (ou pílula) com borda branca.
class _Badge extends StatelessWidget {
  final Color color;
  final double size;
  final Widget child;

  const _Badge({super.key, required this.color, required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: AppColors.white, width: 1),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s2)],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
