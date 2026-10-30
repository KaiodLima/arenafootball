import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/tour/tour_layout.dart';
import 'package:arena_soccer/utils/components/tour/tour_step.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Retângulo do widget de [key] na tela (nulo = não montado ou sem tamanho).
Rect? tourTargetRect(GlobalKey key) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Spotlight (no molde dos apps grandes): a tela escurece, um recorte
/// destaca o elemento real com um anel pulsando e o cartão explica; o recorte
/// desliza de um passo para o outro. Passos com o alvo fora da tela são
/// pulados. Devolve true se chegou ao fim, false se pulou e nulo se nenhum
/// alvo estava na tela (nada foi mostrado).
Future<bool?> showTourOverlay(BuildContext context, List<TourStep> steps) async {
  final size = MediaQuery.of(context).size;
  final visible = [
    for (final step in steps)
      if (tourTargetRect(step.target) case final rect? when TourLayout.isVisible(rect, size)) step,
  ];
  if (visible.isEmpty) return null;
  final completed = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.transparent,
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, _, __) => _TourOverlay(steps: visible),
  );
  return completed ?? false;
}

class _TourOverlay extends StatefulWidget {
  final List<TourStep> steps;

  const _TourOverlay({required this.steps});

  @override
  State<_TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<_TourOverlay> with TickerProviderStateMixin {
  late final AnimationController _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  int _index = 0;
  Rect _from = Rect.zero;
  Rect _to = Rect.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = !MediaQuery.of(context).disableAnimations;
    if (animate && !_pulse.isAnimating) _pulse.repeat();
    if (_to == Rect.zero) {
      _to = _holeFor(_index);
      _from = _to.deflate(_to.shortestSide / 2);
      animate ? _move.forward(from: 0) : _move.value = 1;
    }
  }

  @override
  void dispose() {
    _move.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Rect _holeFor(int index) {
    final step = widget.steps[index];
    final size = MediaQuery.of(context).size;
    final rect = tourTargetRect(step.target) ?? Rect.fromCenter(center: size.center(Offset.zero), width: 0, height: 0);
    return TourLayout.hole(rect, size, step.padding);
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_index + 1 >= widget.steps.length) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _from = Rect.lerp(_from, _to, _move.value)!;
      _index++;
      _to = _holeFor(_index);
    });
    MediaQuery.of(context).disableAnimations ? _move.value = 1 : _move.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final step = widget.steps[_index];
    final above = TourLayout.cardAbove(_to, size);

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: Listenable.merge([_move, _pulse]),
        builder: (context, _) {
          final hole = Rect.lerp(_from, _to, Curves.easeOutCubic.transform(_move.value))!;
          final radius = step.shape == TourShape.circle ? hole.shortestSide / 2 : AppSizes.s16;
          return Stack(
            children: [
              // Fundo escuro com o recorte (toque fora não faz nada).
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: CustomPaint(
                    painter: _SpotlightPainter(
                      hole: RRect.fromRectAndRadius(hole, Radius.circular(radius)),
                      pulse: _pulse.value,
                    ),
                  ),
                ),
              ),
              // Toque no recorte avança.
              Positioned.fromRect(
                rect: hole,
                child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _next),
              ),
              _Card(
                key: ValueKey(_index),
                step: step,
                index: _index,
                total: widget.steps.length,
                target: _to,
                above: above,
                screen: size,
                onNext: _next,
                onSkip: () => Navigator.pop(context, false),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final RRect hole;
  final double pulse;

  const _SpotlightPainter({required this.hole, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(hole);
    canvas.drawPath(scrim, Paint()..color = AppColors.black.withValues(alpha: 0.74));
    // Anel verde pulsando em volta do recorte.
    final ring = hole.inflate(2 + pulse * 10);
    canvas.drawRRect(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.primary.withValues(alpha: (1 - pulse) * 0.9),
    );
    canvas.drawRRect(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.hole != hole || old.pulse != pulse;
}

/// Cartão do passo: ícone, título, texto, progresso e os botões; a setinha
/// aponta para o recorte.
class _Card extends StatelessWidget {
  final TourStep step;
  final int index;
  final int total;
  final Rect target;
  final bool above;
  final Size screen;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _Card({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.target,
    required this.above,
    required this.screen,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = math.min(screen.width - AppSizes.s32, 420.0);
    final left = (screen.width - width) / 2;
    final arrowX = TourLayout.arrowX(target, cardLeft: left, cardRight: left + width) - left;
    final last = index == total - 1;
    const arrowHeight = AppSizes.s10;

    final card = Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s12, AppSizes.s10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s20),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: AppSizes.s20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.s36,
                height: AppSizes.s36,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(step.icon, color: AppColors.primary, size: AppSizes.s20),
              ),
              const SizedBox(width: AppSizes.s10),
              Expanded(
                child: Text(step.title, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          Text(step.body, style: AppTypography.body(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s14)),
          const SizedBox(height: AppSizes.s8),
          Row(
            children: [
              for (var i = 0; i < total; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: AppSizes.s4),
                  width: i == index ? AppSizes.s16 : AppSizes.s6,
                  height: AppSizes.s6,
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSizes.s4),
                  ),
                ),
              const Spacer(),
              if (!last)
                TextButton(
                  onPressed: onSkip,
                  child: Text(l10n.tourSkip, style: AppTypography.label(color: AppColors.textSecondary)),
                ),
              FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
                ),
                child: Text(
                  last ? l10n.tourDone : l10n.tourNext,
                  style: AppTypography.label(color: AppColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final arrow = CustomPaint(
      size: const Size(AppSizes.s20, arrowHeight),
      painter: _ArrowPainter(up: !above),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!above) Padding(padding: EdgeInsets.only(left: arrowX - AppSizes.s10), child: arrow),
        card,
        if (above) Padding(padding: EdgeInsets.only(left: arrowX - AppSizes.s10), child: arrow),
      ],
    );

    return Positioned(
      left: left,
      top: above ? null : target.bottom + AppSizes.s8,
      bottom: above ? screen.height - target.top + AppSizes.s8 : null,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * (above ? AppSizes.s12 : -AppSizes.s12)), child: child),
        ),
        child: content,
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final bool up;

  const _ArrowPainter({required this.up});

  @override
  void paint(Canvas canvas, Size size) {
    final path = up
        ? (Path()
          ..moveTo(0, size.height)
          ..lineTo(size.width / 2, 0)
          ..lineTo(size.width, size.height))
        : (Path()
          ..moveTo(0, 0)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width, 0));
    canvas.drawPath(path..close(), Paint()..color = AppColors.surface);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.up != up;
}
