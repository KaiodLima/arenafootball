import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/presentation/widgets/sticker_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/celebration_painters.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Abertura do pacotinho: o pacote balança e "rasga", depois as figurinhas
/// viram uma a uma ("NOVA!" ou "Repetida"), com vibração e confete quando
/// vem figurinha nova.
Future<void> showPackOpening(
  BuildContext context, {
  required AlbumPackDTO pack,
  required StickerDTO? Function(String id) stickerOf,
  required StickerStyle Function(StickerDTO sticker) frameOf,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withValues(alpha: 0.85),
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, _, __) => _PackOpening(pack: pack, stickerOf: stickerOf, frameOf: frameOf),
  );
}

class _PackOpening extends StatefulWidget {
  final AlbumPackDTO pack;
  final StickerDTO? Function(String id) stickerOf;
  final StickerStyle Function(StickerDTO sticker) frameOf;

  const _PackOpening({required this.pack, required this.stickerOf, required this.frameOf});

  @override
  State<_PackOpening> createState() => _PackOpeningState();
}

class _PackOpeningState extends State<_PackOpening> with TickerProviderStateMixin {
  /// Pacote balançando e rasgando.
  late final AnimationController _pack = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  late final AnimationController _confetti = AnimationController(vsync: this, duration: const Duration(seconds: 2));

  /// Quantas figurinhas já viraram.
  int _revealed = 0;
  Timer? _timer;

  bool get _done => _revealed >= widget.pack.stickers.length;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _pack.forward().then((_) => _revealNext());
  }

  void _revealNext() {
    if (!mounted || _done) return;
    setState(() => _revealed++);
    final id = widget.pack.stickers[_revealed - 1];
    final isNew = widget.pack.newOnes.contains(id) && widget.pack.stickers.indexOf(id) == _revealed - 1;
    if (isNew) {
      HapticFeedback.heavyImpact();
      _confetti.forward(from: 0);
    } else {
      HapticFeedback.selectionClick();
    }
    if (!_done) _timer = Timer(const Duration(milliseconds: 550), _revealNext);
  }

  /// Toque pula a animação.
  void _skip() {
    _timer?.cancel();
    _pack.value = 1;
    setState(() => _revealed = widget.pack.stickers.length);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pack.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ids = widget.pack.stickers;
    final newCount = widget.pack.newOnes.length;

    return SafeArea(
      child: GestureDetector(
        onTap: _done ? null : _skip,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confetti,
                  builder: (context, _) => CustomPaint(painter: ConfettiPainter(progress: _confetti.value)),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.s20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _done ? l10n.albumPackResult(newCount) : l10n.albumPackOpening,
                      textAlign: TextAlign.center,
                      style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
                    ),
                    const SizedBox(height: AppSizes.s20),
                    if (_revealed == 0)
                      _PackWrapper(animation: _pack)
                    else
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSizes.s10,
                        runSpacing: AppSizes.s14,
                        children: [
                          for (var i = 0; i < ids.length; i++)
                            _RevealCard(
                              key: ValueKey(i),
                              visible: i < _revealed,
                              sticker: widget.stickerOf(ids[i]),
                              isNew: widget.pack.newOnes.contains(ids[i]) && ids.indexOf(ids[i]) == i,
                              frameOf: widget.frameOf,
                            ),
                        ],
                      ),
                    const SizedBox(height: AppSizes.s24),
                    AnimatedOpacity(
                      opacity: _done ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: ArenaButton.primary(
                        title: l10n.albumPackStick,
                        function: _done ? () => Navigator.pop(context) : null,
                      ),
                    ),
                    if (!_done)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.s8),
                        child: Text(l10n.albumPackSkip, style: AppTypography.subtitle(color: AppColors.whiteSoft)),
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

/// O pacote fechado: balança e, no fim, cresce e some ("rasga").
class _PackWrapper extends StatelessWidget {
  final Animation<double> animation;

  const _PackWrapper({required this.animation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final shake = t < 0.7 ? math.sin(t * 40) * 0.08 * (1 - t) : 0.0;
        final burst = t < 0.7 ? 1.0 : 1 + (t - 0.7) * 1.2;
        final opacity = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.rotate(angle: shake, child: Transform.scale(scale: burst, child: child)),
        );
      },
      child: Container(
        width: AppSizes.s150,
        height: AppSizes.s200,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(AppSizes.s16),
          border: Border.all(color: AppColors.googleYellow, width: AppSizes.s4),
          boxShadow: [BoxShadow(color: AppColors.googleYellow.withValues(alpha: 0.4), blurRadius: 24)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/images/ic_logo.png', height: AppSizes.s48),
            const SizedBox(height: AppSizes.s12),
            Text(
              l10n.albumPackLabel,
              textAlign: TextAlign.center,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figurinha virando (de costas para a frente) com o selo NOVA!/Repetida.
class _RevealCard extends StatelessWidget {
  final bool visible;
  final StickerDTO? sticker;
  final bool isNew;
  final StickerStyle Function(StickerDTO sticker) frameOf;

  const _RevealCard(
      {super.key, required this.visible, required this.sticker, required this.isNew, required this.frameOf});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sticker = this.sticker;
    return SizedBox(
      width: AppSizes.s100,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: visible ? 1 : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, t, _) {
          final front = t >= 0.5;
          return Opacity(
            opacity: visible ? 1 : 0.35,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(math.pi * (1 - t.clamp(0.0, 1.0))),
              child: front && sticker != null
                  ? Column(
                      children: [
                        StickerCard(sticker: sticker, style: frameOf(sticker)),
                        const SizedBox(height: AppSizes.s6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                          decoration: BoxDecoration(
                            color: isNew ? AppColors.googleYellow : AppColors.whiteMuted,
                            borderRadius: BorderRadius.circular(AppSizes.s10),
                          ),
                          child: Text(
                            isNew ? l10n.albumStickerNew : l10n.albumStickerRepeated,
                            style: AppTypography.label(color: isNew ? AppColors.black : AppColors.white)
                                .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    )
                  : AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(AppSizes.s10),
                          border: Border.all(color: AppColors.googleYellow, width: AppSizes.s2),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: AppColors.googleYellow),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
