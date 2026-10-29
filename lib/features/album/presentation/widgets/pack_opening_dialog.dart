import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_visuals.dart';
import 'package:arena_soccer/features/album/presentation/widgets/sticker_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/celebration_painters.dart' show ConfettiPainter;
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Abertura do pacotinho em tela cheia (no molde da abertura de pacote do
/// EA FC e do Panini Digital), em três fases: o pacote laminado que se rasga
/// no toque ou no arrasto, as figurinhas uma a uma (saem do pacote de costas
/// e viram; nova = selo dourado, raios e confete) e o resumo com as cinco.
Future<void> showPackOpening(
  BuildContext context, {
  required AlbumPackDTO pack,
  required StickerDTO? Function(String id) stickerOf,
  required StickerStyle Function(StickerDTO sticker) frameOf,
  String eventTitle = '',
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.transparent,
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, _, __) =>
        _PackOpening(pack: pack, stickerOf: stickerOf, frameOf: frameOf, eventTitle: eventTitle),
  );
}

enum _Stage { pack, reveal, summary }

class _PackOpening extends StatefulWidget {
  final AlbumPackDTO pack;
  final StickerDTO? Function(String id) stickerOf;
  final StickerStyle Function(StickerDTO sticker) frameOf;
  final String eventTitle;

  const _PackOpening({required this.pack, required this.stickerOf, required this.frameOf, required this.eventTitle});

  @override
  State<_PackOpening> createState() => _PackOpeningState();
}

class _PackOpeningState extends State<_PackOpening> with TickerProviderStateMixin {
  /// Raios do fundo girando e o pacote flutuando.
  late final AnimationController _ambient = AnimationController(vsync: this, duration: const Duration(seconds: 24));
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(seconds: 3));

  /// Rasgar o pacote (tira voando, clarão, pacote descendo).
  late final AnimationController _tear = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  /// Figurinha saindo do pacote e virando.
  late final AnimationController _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  late final AnimationController _confetti = AnimationController(vsync: this, duration: const Duration(seconds: 2));

  /// Entrada em cascata do resumo.
  late final AnimationController _summary =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  _Stage _stage = _Stage.pack;
  int _current = 0;

  List<String> get _ids => widget.pack.stickers;

  /// Nova só na primeira vez que o id aparece no pacote.
  bool _isNew(int i) => widget.pack.newOnes.contains(_ids[i]) && _ids.indexOf(_ids[i]) == i;

  int get _newCount => [for (var i = 0; i < _ids.length; i++) _isNew(i)].where((n) => n).length;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.of(context).disableAnimations) {
      if (!_ambient.isAnimating) _ambient.repeat();
      if (!_float.isAnimating) _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ambient.dispose();
    _float.dispose();
    _tear.dispose();
    _flip.dispose();
    _confetti.dispose();
    _summary.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_stage != _Stage.pack || _tear.isAnimating) return;
    HapticFeedback.heavyImpact();
    await _tear.forward();
    if (!mounted) return;
    if (_ids.isEmpty) return _toSummary();
    setState(() => _stage = _Stage.reveal);
    _reveal(0);
  }

  Future<void> _reveal(int i) async {
    setState(() => _current = i);
    HapticFeedback.selectionClick();
    await _flip.forward(from: 0);
    if (!mounted || _stage != _Stage.reveal || _current != i) return;
    if (_isNew(i)) {
      HapticFeedback.heavyImpact();
      _confetti.forward(from: 0);
    }
  }

  void _next() {
    if (_flip.isAnimating) {
      _flip.value = 1;
      if (_isNew(_current)) _confetti.forward(from: 0);
      return;
    }
    if (_current + 1 < _ids.length) {
      _reveal(_current + 1);
    } else {
      _toSummary();
    }
  }

  void _toSummary() {
    _tear.value = 1;
    _flip.value = 1;
    setState(() => _stage = _Stage.summary);
    if (_newCount > 0) {
      HapticFeedback.mediumImpact();
      _confetti.forward(from: 0);
    }
    _summary.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sticker = _stage == _Stage.reveal && _ids.isNotEmpty ? widget.stickerOf(_ids[_current]) : null;
    final accent = sticker == null ? null : widget.frameOf(sticker).accent;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Backdrop(rays: _ambient, glow: accent, strongGlow: _stage == _Stage.reveal && _isNew(_current)),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  counter: _stage == _Stage.reveal ? l10n.albumPackCounter(_current + 1, _ids.length) : '',
                  onSkip: _stage == _Stage.summary ? null : _toSummary,
                ),
                Expanded(
                  child: switch (_stage) {
                    _Stage.pack => _PackStage(
                        float: _float,
                        tear: _tear,
                        eventTitle: widget.eventTitle,
                        count: _ids.length,
                        onOpen: _open,
                      ),
                    _Stage.reveal => _RevealStage(
                        flip: _flip,
                        rays: _ambient,
                        index: _current,
                        sticker: sticker,
                        style: sticker == null ? null : widget.frameOf(sticker),
                        isNew: _isNew(_current),
                        slots: [for (var i = 0; i < _ids.length; i++) i < _current ? (_isNew(i) ? 2 : 1) : 0],
                        eventTitle: widget.eventTitle,
                        onNext: _next,
                      ),
                    _Stage.summary => _SummaryStage(
                        animation: _summary,
                        stickers: [for (final id in _ids) widget.stickerOf(id)],
                        isNew: [for (var i = 0; i < _ids.length; i++) _isNew(i)],
                        frameOf: widget.frameOf,
                        newCount: _newCount,
                      ),
                  },
                ),
              ],
            ),
          ),
          // Clarão do rasgo.
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _tear,
              builder: (context, _) {
                final t = _tear.value;
                final flash = _stage == _Stage.pack ? (1 - ((t - 0.35).abs() / 0.35)).clamp(0.0, 1.0) * 0.75 : 0.0;
                return flash == 0 ? const SizedBox.shrink() : ColoredBox(color: AppColors.white.withValues(alpha: flash));
              },
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (context, _) => CustomPaint(painter: ConfettiPainter(progress: _confetti.value)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fundo da capa (verde-escuro com listras) com raios girando devagar; na
/// revelação, o brilho na cor do time atrás da figurinha.
class _Backdrop extends StatelessWidget {
  final Animation<double> rays;
  final Color? glow;
  final bool strongGlow;

  const _Backdrop({required this.rays, required this.glow, required this.strongGlow});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primaryMedium],
            ),
          ),
        ),
        CustomPaint(painter: StripesPainter(color: AppColors.white.withValues(alpha: 0.04), diagonal: true)),
        AnimatedBuilder(
          animation: rays,
          builder: (context, child) => Transform.rotate(angle: rays.value * math.pi * 2, child: child),
          child: Transform.scale(
            scale: 1.6,
            child: CustomPaint(painter: RaysPainter(color: AppColors.white.withValues(alpha: 0.035), rays: 20)),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: DecoratedBox(
            key: ValueKey('$glow$strongGlow'),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.15),
                radius: 0.8,
                colors: [
                  (glow ?? AppColors.googleYellow).withValues(alpha: glow == null ? 0.18 : (strongGlow ? 0.6 : 0.4)),
                  AppColors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final String counter;
  final VoidCallback? onSkip;

  const _TopBar({required this.counter, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: AppSizes.s56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
        child: Row(
          children: [
            Text(counter, style: AppTypography.label(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s14)),
            const Spacer(),
            if (onSkip != null)
              TextButton(
                onPressed: onSkip,
                child: Text(
                  l10n.albumPackSkipAll,
                  style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Fase 1: o pacote flutuando; toque ou arrasto rasga.
class _PackStage extends StatelessWidget {
  final Animation<double> float;
  final Animation<double> tear;
  final String eventTitle;
  final int count;
  final VoidCallback onOpen;

  const _PackStage({
    required this.float,
    required this.tear,
    required this.eventTitle,
    required this.count,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = math.min(MediaQuery.of(context).size.width * 0.58, AppSizes.s250);
    final pack = _FoilPack(width: width, eventTitle: eventTitle, count: count);
    const strip = 0.16;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      onPanEnd: (_) => onOpen(),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([float, tear]),
                builder: (context, _) {
                  final t = tear.value;
                  final bob = math.sin(float.value * math.pi) * AppSizes.s8;
                  final sway = (float.value - 0.5) * 0.06 * (1 - t);
                  final fall = Curves.easeIn.transform(((t - 0.4) / 0.6).clamp(0.0, 1.0));
                  final fly = Curves.easeOut.transform((t / 0.6).clamp(0.0, 1.0));
                  return Transform.translate(
                    offset: Offset(0, -bob),
                    child: Transform.rotate(
                      angle: sway,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tira de cima: sai voando e girando.
                          Opacity(
                            opacity: 1 - fly,
                            child: Transform.translate(
                              offset: Offset(fly * AppSizes.s60, -fly * AppSizes.s120),
                              child: Transform.rotate(
                                angle: fly * 0.7,
                                child: ClipRect(
                                  child: Align(alignment: Alignment.topCenter, heightFactor: strip, child: pack),
                                ),
                              ),
                            ),
                          ),
                          // Corpo: desce e some.
                          Opacity(
                            opacity: 1 - fall,
                            child: Transform.translate(
                              offset: Offset(0, fall * AppSizes.s200),
                              child: ClipRect(
                                child: Align(alignment: Alignment.bottomCenter, heightFactor: 1 - strip, child: pack),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.s40),
            child: AnimatedBuilder(
              animation: Listenable.merge([float, tear]),
              builder: (context, child) =>
                  Opacity(opacity: (1 - tear.value * 3).clamp(0.0, 1.0) * (0.6 + float.value * 0.4), child: child),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swipe_rounded, color: AppColors.white, size: AppSizes.s20),
                  const SizedBox(width: AppSizes.s8),
                  Text(
                    l10n.albumPackTapToOpen,
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// O pacote laminado (igual ao da capa, grande): amarelo→laranja, bordas
/// serrilhadas com a faixa prateada, logo, o álbum e a quantidade.
class _FoilPack extends StatelessWidget {
  final double width;
  final String eventTitle;
  final int count;

  const _FoilPack({required this.width, required this.eventTitle, required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final height = width * 1.45;
    final crimp = height * 0.08;
    Widget crimpBand() => Container(
          height: crimp,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.white.withValues(alpha: 0.55),
                AppColors.white.withValues(alpha: 0.2),
                AppColors.white.withValues(alpha: 0.55),
              ],
            ),
          ),
        );

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Brilho em volta (fora do recorte).
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.s16),
              boxShadow: [BoxShadow(color: AppColors.googleYellow.withValues(alpha: 0.45), blurRadius: AppSizes.s40)],
            ),
          ),
          ClipPath(
            clipper: const ZigzagClipper(),
            child: Shimmer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.googleYellow, AppColors.teamOrange],
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: StripesPainter(color: AppColors.white.withValues(alpha: 0.12), width: 10, diagonal: true),
                  ),
                  Column(
                    children: [
                      crimpBand(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (eventTitle.isNotEmpty)
                                Text(
                                  eventTitle.toUpperCase(),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.label(color: AppColors.black.withValues(alpha: 0.7))
                                      .copyWith(fontSize: AppSizes.s12, letterSpacing: 1.2),
                                ),
                              const SizedBox(height: AppSizes.s12),
                              Container(
                                padding: const EdgeInsets.all(AppSizes.s12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: AppColors.black.withValues(alpha: 0.2), blurRadius: AppSizes.s12)
                                  ],
                                ),
                                child: Image.asset('lib/assets/images/ic_logo.png', width: width * 0.3),
                              ),
                              const SizedBox(height: AppSizes.s12),
                              Text(
                                l10n.albumPackLabel.replaceAll('\n', ' ').toUpperCase(),
                                textAlign: TextAlign.center,
                                style: AppTypography.display(color: AppColors.white)
                                    .copyWith(fontSize: AppSizes.s20, height: 1.1, shadows: [
                                  Shadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: AppSizes.s6)
                                ]),
                              ),
                              const SizedBox(height: AppSizes.s10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(AppSizes.s20),
                                ),
                                child: Text(
                                  l10n.albumPackStickers(count),
                                  style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      crimpBand(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fase 2: uma figurinha por vez, saindo do pacote de costas e virando.
class _RevealStage extends StatelessWidget {
  final Animation<double> flip;
  final Animation<double> rays;
  final int index;
  final StickerDTO? sticker;
  final StickerStyle? style;
  final bool isNew;

  /// Por posição: 0 = ainda não, 1 = repetida, 2 = nova.
  final List<int> slots;
  final String eventTitle;
  final VoidCallback onNext;

  const _RevealStage({
    required this.flip,
    required this.rays,
    required this.index,
    required this.sticker,
    required this.style,
    required this.isNew,
    required this.slots,
    required this.eventTitle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = math.min(MediaQuery.of(context).size.width * 0.62, AppSizes.s300);
    final sticker = this.sticker;
    final style = this.style;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onNext,
      child: AnimatedBuilder(
        animation: flip,
        builder: (context, _) {
          final v = flip.value;
          final enter = Curves.easeOutBack.transform((v / 0.4).clamp(0.0, 1.0));
          final turn = Curves.easeInOutCubic.transform(((v - 0.35) / 0.65).clamp(0.0, 1.0));
          final front = turn >= 0.5;
          final revealed = v >= 1;

          final face = front && sticker != null && style != null
              ? StickerCard(sticker: sticker, style: style)
              : _CardBack(eventTitle: eventTitle);

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Explosão dourada atrás da nova.
                      if (isNew && front)
                        IgnorePointer(
                          child: AnimatedBuilder(
                            animation: rays,
                            builder: (context, child) =>
                                Transform.rotate(angle: -rays.value * math.pi * 4, child: child),
                            child: SizedBox.square(
                              dimension: width * 1.9,
                              child: CustomPaint(
                                painter: RaysPainter(color: AppColors.googleYellow.withValues(alpha: 0.22), rays: 14),
                              ),
                            ),
                          ),
                        ),
                      Opacity(
                        opacity: enter.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, (1 - enter) * AppSizes.s120),
                          child: Transform.scale(
                            scale: 0.7 + 0.3 * enter,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0012)
                                ..rotateY(math.pi * (1 - turn)),
                              child: SizedBox(
                                width: width,
                                child: front
                                    ? face
                                    : Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.rotationY(math.pi),
                                        child: face,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Selo NOVA!/Repetida.
                      if (revealed)
                        Positioned(
                          top: -AppSizes.s16,
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey(index),
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.elasticOut,
                            builder: (context, s, child) => Transform.scale(scale: s, child: child),
                            child: _Badge(isNew: isNew, large: true),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: revealed ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Column(
                  children: [
                    Text(
                      sticker?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(color: AppColors.white),
                    ),
                    if (sticker != null)
                      Text(
                        l10n.albumStickerCaption(sticker.number, sticker.team),
                        style: AppTypography.subtitle(color: AppColors.whiteSoft),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.s20),
              _Slots(slots: slots, current: index),
              const SizedBox(height: AppSizes.s16),
              Text(l10n.albumPackTapNext, style: AppTypography.subtitle(color: AppColors.whiteSoft)),
              const SizedBox(height: AppSizes.s32),
            ],
          );
        },
      ),
    );
  }
}

/// Verso padrão do álbum (a figurinha ainda fechada).
class _CardBack extends StatelessWidget {
  final String eventTitle;

  const _CardBack({required this.eventTitle});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: LayoutBuilder(
        builder: (context, box) {
          final k = box.maxWidth / 100;
          return Container(
            padding: EdgeInsets.all(AppSizes.s2 + AppSizes.s2 * k),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.s8 * k),
              boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.35), blurRadius: AppSizes.s20)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.s6 * k),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryMedium, AppColors.primaryDark],
                      ),
                    ),
                  ),
                  CustomPaint(painter: RaysPainter(color: AppColors.white.withValues(alpha: 0.06))),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSizes.s6 * k),
                        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                        child: Image.asset('lib/assets/images/ic_logo.png', width: AppSizes.s30 * k),
                      ),
                      SizedBox(height: AppSizes.s6 * k),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.s8 * k),
                        child: Text(
                          eventTitle.toUpperCase(),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: AppTypography.label(color: AppColors.googleYellow)
                              .copyWith(fontSize: AppSizes.s8 * k, letterSpacing: AppSizes.s1 * k),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Selo dourado "NOVA!" ou o discreto "Repetida".
class _Badge extends StatelessWidget {
  final bool isNew;
  final bool large;

  const _Badge({required this.isNew, this.large = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppSizes.s16 : AppSizes.s8,
        vertical: large ? AppSizes.s6 : AppSizes.s2,
      ),
      decoration: BoxDecoration(
        gradient: isNew ? const LinearGradient(colors: [AppColors.googleYellow, AppColors.teamOrange]) : null,
        color: isNew ? null : AppColors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSizes.s20),
        border: Border.all(color: AppColors.white, width: large ? AppSizes.s2 : AppSizes.s1),
        boxShadow: [
          if (isNew) BoxShadow(color: AppColors.googleYellow.withValues(alpha: 0.6), blurRadius: AppSizes.s16),
        ],
      ),
      child: Text(
        isNew ? l10n.albumStickerNew : l10n.albumStickerRepeated,
        style: AppTypography.label(color: isNew ? AppColors.black : AppColors.white).copyWith(
          fontSize: large ? AppSizes.s16 : AppSizes.s10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Os espaços do pacote se preenchendo (dourado = nova, branco = repetida).
class _Slots extends StatelessWidget {
  final List<int> slots;
  final int current;

  const _Slots({required this.slots, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < slots.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
            width: AppSizes.s18,
            height: AppSizes.s24,
            decoration: BoxDecoration(
              color: switch (slots[i]) {
                2 => AppColors.googleYellow,
                1 => AppColors.white,
                _ => AppColors.white.withValues(alpha: 0.1),
              },
              borderRadius: BorderRadius.circular(AppSizes.s4),
              border: Border.all(
                color: i == current ? AppColors.white : AppColors.white.withValues(alpha: 0.3),
                width: i == current ? AppSizes.s2 : AppSizes.s1,
              ),
            ),
          ),
      ],
    );
  }
}

/// Fase 3: o resumo com as figurinhas do pacote e o "Colar no álbum".
class _SummaryStage extends StatelessWidget {
  final Animation<double> animation;
  final List<StickerDTO?> stickers;
  final List<bool> isNew;
  final StickerStyle Function(StickerDTO sticker) frameOf;
  final int newCount;

  const _SummaryStage({
    required this.animation,
    required this.stickers,
    required this.isNew,
    required this.frameOf,
    required this.newCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repeated = stickers.length - newCount;
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - AppSizes.s20 * 2 - AppSizes.s16 * 2) / 3;

    return Column(
      children: [
        Text(
          l10n.albumPackResult(newCount),
          textAlign: TextAlign.center,
          style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s24),
        ),
        const SizedBox(height: AppSizes.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (newCount > 0) _SummaryChip(label: l10n.albumPackNewCount(newCount), gold: true),
            if (newCount > 0 && repeated > 0) const SizedBox(width: AppSizes.s8),
            if (repeated > 0) _SummaryChip(label: l10n.albumPackRepeatedCount(repeated), gold: false),
          ],
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20, vertical: AppSizes.s24),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSizes.s16,
                runSpacing: AppSizes.s28,
                children: [
                  for (var i = 0; i < stickers.length; i++)
                    if (stickers[i] != null)
                      AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final start = (i * 0.12).clamp(0.0, 0.5);
                          final t = Curves.easeOutBack.transform(((animation.value - start) / 0.5).clamp(0.0, 1.0));
                          return Opacity(
                            opacity: t.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, (1 - t) * AppSizes.s40),
                              child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: cardWidth,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              Opacity(
                                opacity: isNew[i] ? 1 : 0.7,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppSizes.s10),
                                    boxShadow: [
                                      if (isNew[i])
                                        BoxShadow(
                                          color: AppColors.googleYellow.withValues(alpha: 0.55),
                                          blurRadius: AppSizes.s16,
                                        ),
                                    ],
                                  ),
                                  child: StickerCard(sticker: stickers[i]!, style: frameOf(stickers[i]!)),
                                ),
                              ),
                              Positioned(top: -AppSizes.s10, child: _Badge(isNew: isNew[i])),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(AppSizes.s12, 0, AppSizes.s12, AppSizes.s12),
          padding: const EdgeInsets.all(AppSizes.s16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: ArenaButton.primary(title: l10n.albumPackStick, function: () => Navigator.pop(context)),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final bool gold;

  const _SummaryChip({required this.label, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
      decoration: BoxDecoration(
        color: gold ? AppColors.googleYellow : AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Text(
        label,
        style: AppTypography.label(color: gold ? AppColors.black : AppColors.white).copyWith(fontSize: AppSizes.s12),
      ),
    );
  }
}
