import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Carteirinha que inclina em 3D seguindo o dedo (até 12°, volta com mola),
/// balança de leve parada e vira com o toque. As faces recebem o reflexo
/// (`sheen`, -1 a 1) pela inclinação. Mesmo comportamento da carta do álbum
/// (`StickerDetailPage`), no formato paisagem.
class FanCardTilt extends StatefulWidget {
  final Widget Function(double sheen) front;
  final Widget Function(double sheen) back;

  const FanCardTilt({super.key, required this.front, required this.back});

  @override
  State<FanCardTilt> createState() => _FanCardTiltState();
}

class _FanCardTiltState extends State<FanCardTilt> with TickerProviderStateMixin {
  static const double _maxAngle = 12 * math.pi / 180;

  late final AnimationController _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  late final AnimationController _spring =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(seconds: 7));

  Offset _touch = Offset.zero;
  Offset _released = Offset.zero;
  bool _touching = false;
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.of(context).disableAnimations;
    if (!_still && !_idle.isAnimating) _idle.repeat();
    if (_still) _idle.stop();
  }

  @override
  void dispose() {
    _flip.dispose();
    _spring.dispose();
    _idle.dispose();
    super.dispose();
  }

  void _follow(Offset local, Size size) {
    if (_still) return;
    _spring.stop();
    setState(() {
      _touching = true;
      _touch = Offset(
        ((local.dx / size.width) * 2 - 1).clamp(-1.0, 1.0),
        ((local.dy / size.height) * 2 - 1).clamp(-1.0, 1.0),
      );
    });
  }

  void _release() {
    if (!_touching) return;
    _touching = false;
    _released = _touch;
    _spring.forward(from: 0);
  }

  void _toggleFlip() {
    HapticFeedback.lightImpact();
    if (_still) {
      _flip.value = _flip.value > 0.5 ? 0 : 1;
      return;
    }
    _flip.isCompleted || _flip.velocity > 0 ? _flip.reverse() : _flip.forward();
  }

  Offset get _tilt {
    if (_touching) return _touch;
    if (_still) return Offset.zero;
    final back = Offset.lerp(_released, Offset.zero, Curves.elasticOut.transform(_spring.value))!;
    final t = _idle.value * math.pi * 2;
    return back + Offset(math.sin(t) * 0.16, math.cos(t) * 0.08);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxWidth / 1.586);
        return Listener(
          onPointerDown: (e) => _follow(e.localPosition, size),
          onPointerMove: (e) => _follow(e.localPosition, size),
          onPointerUp: (_) => _release(),
          onPointerCancel: (_) => _release(),
          child: GestureDetector(
            onTap: _toggleFlip,
            child: AnimatedBuilder(
              animation: Listenable.merge([_flip, _spring, _idle]),
              builder: (context, _) {
                final tilt = _tilt;
                final flip = Curves.easeInOutCubic.transform(_flip.value) * math.pi;
                final showBack = flip > math.pi / 2;
                final face = showBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: KeyedSubtree(key: const ValueKey('fan-card-back'), child: widget.back(-tilt.dx)),
                      )
                    : KeyedSubtree(key: const ValueKey('fan-card-front'), child: widget.front(tilt.dx));
                final matrix = Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(-tilt.dy * _maxAngle)
                  ..rotateY(tilt.dx * _maxAngle + flip);
                return SizedBox.fromSize(
                  size: size,
                  child: Transform(alignment: Alignment.center, transform: matrix, child: face),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
