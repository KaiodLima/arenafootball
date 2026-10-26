import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/celebration_painters.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Destaque do eleito: foto com anel dourado e troféu, nome, time, gols e
/// assistências na temporada e os votos recebidos.
///
/// Ao abrir, uma revelação de ~2,4 s: o cartão sobe, raios dourados giram atrás
/// da foto, a foto entra com mola enquanto o anel dourado se desenha, o troféu
/// cai quicando, explode um confete dourado/verde, nome e time sobem em
/// sequência e os votos/porcentagem contam do zero. Com "remover animações"
/// do sistema, aparece direto no estado final.
class ElectedPlayerCard extends StatefulWidget {
  final ElectedPlayer elected;

  /// Fração dos votos (0–1) que o eleito recebeu.
  final double share;

  const ElectedPlayerCard({super.key, required this.elected, required this.share});

  @override
  State<ElectedPlayerCard> createState() => _ElectedPlayerCardState();
}

class _ElectedPlayerCardState extends State<ElectedPlayerCard> with TickerProviderStateMixin {
  static const Duration _revealDuration = Duration(milliseconds: 2400);

  /// Raios girando sem parar atrás da foto (volta a cada 24 s).
  late final AnimationController _rays = AnimationController(vsync: this, duration: const Duration(seconds: 24));
  late final AnimationController _reveal = AnimationController(vsync: this, duration: _revealDuration);

  Animation<double> _interval(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _reveal, curve: Interval(begin, end, curve: curve));

  late final Animation<double> _card = _interval(0, 0.18);
  late final Animation<double> _raysIn = _interval(0.08, 0.4);
  late final Animation<double> _avatar = _interval(0.1, 0.45, Curves.elasticOut);
  late final Animation<double> _ring = _interval(0.15, 0.5, Curves.easeInOutCubic);
  late final Animation<double> _trophy = _interval(0.42, 0.62, Curves.bounceOut);
  late final Animation<double> _confetti = _interval(0.45, 1, Curves.linear);
  late final Animation<double> _name = _interval(0.5, 0.68);
  late final Animation<double> _team = _interval(0.58, 0.76);
  late final Animation<double> _votes = _interval(0.62, 0.92);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _reveal.value = 1;
      _rays.stop();
    } else if (!_reveal.isAnimating && _reveal.value == 0) {
      _reveal.forward();
      _rays.repeat();
    }
  }

  @override
  void dispose() {
    _rays.dispose();
    _reveal.dispose();
    super.dispose();
  }

  /// Sobe [offset] px e aparece conforme [animation].
  Widget _rise(Animation<double> animation, Widget child, {double offset = AppSizes.s16}) => AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) => Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, (1 - animation.value) * offset), child: child),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final elected = widget.elected;
    final player = PlayerDTO(name: elected.playerName, team: elected.team, imageUrl: elected.playerImageUrl);
    final hasStats = elected.goals > 0 || elected.assists > 0;
    final percent = (widget.share * 100).round();
    const avatarSize = AppSizes.s120;
    // Foto + anel (4) + folga (4) de cada lado.
    const ringSize = avatarSize + AppSizes.s16;
    const raysSize = AppSizes.s250;

    return _rise(
      _card,
      offset: AppSizes.s40,
      ArenaCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s24, AppSizes.s20, AppSizes.s20),
        child: Column(
          children: [
            Text(
              l10n.votingElectedTitle.toUpperCase(),
              style: AppTypography.label(color: AppColors.textSecondary).copyWith(
                fontSize: AppSizes.s12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSizes.s16),
            SizedBox(
              height: ringSize + AppSizes.s14,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Raios dourados girando atrás da foto.
                  Positioned(
                    top: (ringSize - raysSize) / 2,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_rays, _raysIn]),
                      builder: (context, _) => Opacity(
                        opacity: _raysIn.value,
                        child: Transform.rotate(
                          angle: _rays.value * 2 * math.pi,
                          child: Transform.scale(
                            scale: 0.6 + 0.4 * _raysIn.value,
                            child: const CustomPaint(size: Size.square(raysSize), painter: RaysPainter()),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Foto com mola e o anel dourado se desenhando em volta.
                  AnimatedBuilder(
                    animation: Listenable.merge([_avatar, _ring]),
                    builder: (context, child) => Transform.scale(
                      scale: 0.4 + 0.6 * _avatar.value,
                      child: Opacity(
                        opacity: _avatar.value.clamp(0.0, 1.0),
                        child: CustomPaint(
                          foregroundPainter: _RingPainter(progress: _ring.value),
                          child: child,
                        ),
                      ),
                    ),
                    child: Container(
                      width: ringSize,
                      height: ringSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: AppSizes.s24)],
                      ),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                        child: PlayerAvatar(player: player, size: avatarSize),
                      ),
                    ),
                  ),
                  // Confete saindo do centro da foto.
                  Positioned(
                    top: ringSize / 2,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _confetti,
                        builder: (context, _) => CustomPaint(painter: ConfettiPainter(progress: _confetti.value)),
                      ),
                    ),
                  ),
                  // Troféu caindo e quicando no pé do anel.
                  Positioned(
                    top: ringSize - AppSizes.s22,
                    child: AnimatedBuilder(
                      animation: _trophy,
                      builder: (context, child) => Opacity(
                        opacity: (_trophy.value * 3).clamp(0.0, 1.0),
                        child:
                            Transform.translate(offset: Offset(0, (1 - _trophy.value) * -AppSizes.s40), child: child),
                      ),
                      child: Container(
                        width: AppSizes.s36,
                        height: AppSizes.s36,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: AppSizes.s4),
                        ),
                        child: const Icon(Icons.emoji_events_rounded, color: AppColors.primaryDark, size: AppSizes.s18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.s10),
            _rise(
              _name,
              Text(
                elected.playerName,
                textAlign: TextAlign.center,
                style: AppTypography.display().copyWith(fontSize: AppSizes.s24),
              ),
            ),
            if (elected.team.isNotEmpty) ...[
              const SizedBox(height: AppSizes.s6),
              _rise(
                _team,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TeamCrest(imageUrl: elected.teamImageUrl, size: AppSizes.s22),
                    const SizedBox(width: AppSizes.s6),
                    Flexible(
                      child: Text(
                        elected.team,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (hasStats) ...[
              const SizedBox(height: AppSizes.s12),
              _rise(
                _team,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatPill(icon: Icons.sports_soccer_rounded, value: elected.goals),
                    const SizedBox(width: AppSizes.s8),
                    StatPill(icon: Icons.assistant_rounded, value: elected.assists),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSizes.s16),
            _rise(
              _votes,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSizes.s20),
                ),
                // Votos e porcentagem contam do zero.
                child: AnimatedBuilder(
                  animation: _votes,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.how_to_vote_rounded, size: AppSizes.s18, color: AppColors.textPrimary),
                      const SizedBox(width: AppSizes.s6),
                      Text(
                        l10n.votingVotes((elected.votes * _votes.value).round()),
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(
                          fontSize: AppSizes.s14,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        '  ·  ${l10n.votingShareOfVotes((percent * _votes.value).round())}',
                        style: AppTypography.subtitle(color: AppColors.textPrimary).copyWith(
                          fontSize: AppSizes.s14,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
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

/// Anel dourado desenhado do topo, no sentido horário, até fechar.
class _RingPainter extends CustomPainter {
  final double progress;

  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    const stroke = AppSizes.s4;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress.clamp(0.0, 1.0), false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}
