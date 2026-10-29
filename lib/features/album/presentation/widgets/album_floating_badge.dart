import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/album/domain/album_pack_id.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_event_cubit.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_visuals.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Selo flutuante do álbum na home (evento visível + conta logada): o mini
/// pacotinho laminado, igual ao da abertura. Com o pacote do dia disponível,
/// chama atenção (halo dourado, flutua, chacoalha de tempos em tempos, "1" e
/// "Abrir!"); sem, fica discreto com a contagem até o próximo. Arrastável:
/// ao soltar, gruda na borda mais próxima. O toque abre o álbum.
class AlbumFloatingBadge extends StatefulWidget {
  const AlbumFloatingBadge({super.key});

  @override
  State<AlbumFloatingBadge> createState() => _AlbumFloatingBadgeState();
}

class _AlbumFloatingBadgeState extends State<AlbumFloatingBadge> with TickerProviderStateMixin {
  static const double _width = AppSizes.s72;
  static const double _height = AppSizes.s100;
  static const double _margin = AppSizes.s8;

  /// Flutuar + halo (contínuo) e o chacoalhar (a cada ~4 s).
  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  /// Mola ao soltar: de [_from] até a borda.
  late final AnimationController _snap = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;

  /// Posição (canto superior esquerdo) na área da home; nula = embaixo à
  /// esquerda.
  Offset? _position;
  bool _dragging = false;

  Timer? _shakeTimer;
  Timer? _clockTimer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
    _snap.addListener(() {
      final t = Curves.easeOutBack.transform(_snap.value);
      setState(() => _position = Offset.lerp(_from, _to, t));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = !MediaQuery.of(context).disableAnimations;
    if (animate && !_idle.isAnimating) _idle.repeat(reverse: true);
    _shakeTimer ??= animate
        ? Timer.periodic(const Duration(seconds: 4), (_) {
            if (mounted && BlocProvider.of<AlbumEventCubit>(context).state.packAvailable) _shake.forward(from: 0);
          })
        : null;
  }

  void _tick() {
    if (mounted) setState(() => _left = AlbumPackId.untilNext(DateTime.now()));
  }

  @override
  void dispose() {
    _shakeTimer?.cancel();
    _clockTimer?.cancel();
    _idle.dispose();
    _shake.dispose();
    _snap.dispose();
    super.dispose();
  }

  /// Gruda na borda (esquerda/direita) mais próxima.
  void _release(Offset current, Offset max) {
    _dragging = false;
    _from = current;
    _to = Offset(current.dx + _width / 2 < (max.dx + _width) / 2 ? _margin : max.dx - _margin, current.dy);
    _snap.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AlbumEventCubit, AlbumEventState>(
      builder: (context, state) {
        if (!state.visible) return const SizedBox.shrink();
        final available = state.packAvailable;
        return LayoutBuilder(
          builder: (context, constraints) {
            final max = Offset(constraints.maxWidth - _width, constraints.maxHeight - _height - AppSizes.s16);
            Offset clamp(Offset o) => Offset(o.dx.clamp(0, max.dx), o.dy.clamp(0, max.dy));
            final position = clamp(_position ?? Offset(_margin, max.dy - AppSizes.s16));

            return Stack(
              children: [
                Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: GestureDetector(
                    onPanStart: (_) {
                      _snap.stop();
                      _dragging = true;
                    },
                    onPanUpdate: (details) => setState(() => _position = clamp(position + details.delta)),
                    onPanEnd: (_) => _release(position, max),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.albumPage),
                    child: Semantics(
                      button: true,
                      label: l10n.albumTitle,
                      child: SizedBox(
                        width: _width,
                        height: _height,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_idle, _shake]),
                          builder: (context, _) {
                            final idle = available && !_dragging ? _idle.value : 0.0;
                            final shake = available ? math.sin(_shake.value * math.pi * 6) * (1 - _shake.value) * 0.18 : 0.0;
                            return Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topCenter,
                              children: [
                                // Halo dourado.
                                if (available)
                                  Positioned(
                                    top: AppSizes.s6,
                                    child: Container(
                                      width: AppSizes.s56,
                                      height: AppSizes.s64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.googleYellow.withValues(alpha: 0.35 + idle * 0.3),
                                            blurRadius: AppSizes.s20 + idle * AppSizes.s10,
                                            spreadRadius: AppSizes.s2 + idle * AppSizes.s4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: AppSizes.s4 - idle * AppSizes.s4,
                                  child: Transform.rotate(
                                    angle: -0.14 + shake,
                                    child: AnimatedScale(
                                      scale: available ? 1 : 0.88,
                                      duration: const Duration(milliseconds: 250),
                                      child: _MiniPack(dim: !available),
                                    ),
                                  ),
                                ),
                                if (available)
                                  const Positioned(top: 0, right: AppSizes.s4, child: _Dot()),
                                Positioned(
                                  bottom: 0,
                                  child: _Pill(
                                    available: available,
                                    label: available ? l10n.albumBadgeOpen : AlbumPackId.shortLabel(_left),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// O pacotinho em miniatura: amarelo→laranja, listras, bordas serrilhadas
/// com a faixa prateada e o logo (com o brilho correndo quando disponível).
class _MiniPack extends StatelessWidget {
  final bool dim;

  const _MiniPack({required this.dim});

  @override
  Widget build(BuildContext context) {
    final crimp = Container(
      height: AppSizes.s6,
      color: AppColors.white.withValues(alpha: 0.45),
    );
    Widget pack = ClipPath(
      clipper: const ZigzagClipper(tooth: 5),
      child: SizedBox(
        width: AppSizes.s52,
        height: AppSizes.s72,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dim
                      ? [darken(AppColors.googleYellow, 0.08), darken(AppColors.teamOrange, 0.12)]
                      : const [AppColors.googleYellow, AppColors.teamOrange],
                ),
              ),
            ),
            CustomPaint(painter: StripesPainter(color: AppColors.white.withValues(alpha: 0.14), width: 5, diagonal: true)),
            Column(
              children: [
                crimp,
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.s4),
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: Image.asset('lib/assets/images/ic_logo.png', width: AppSizes.s24),
                    ),
                  ),
                ),
                crimp,
              ],
            ),
          ],
        ),
      ),
    );
    if (!dim) pack = Shimmer(child: pack);
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: AppSizes.s8, offset: const Offset(0, 4))
        ],
      ),
      child: pack,
    );
  }
}

/// Bolinha vermelha "1" (há pacote para abrir).
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s20,
      height: AppSizes.s20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.danger,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: AppSizes.s2),
      ),
      child: Text(
        '1',
        style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

/// Pílula embaixo: "Abrir!" (branca) ou a contagem com o relógio (escura).
class _Pill extends StatelessWidget {
  final bool available;
  final String label;

  const _Pill({required this.available, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.primaryDark : AppColors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(
        color: available ? AppColors.white : AppColors.primaryDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSizes.s10),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.2), blurRadius: AppSizes.s4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!available) ...[
            Icon(Icons.schedule_rounded, size: AppSizes.s12, color: color),
            const SizedBox(width: AppSizes.s2),
          ],
          Text(
            label,
            style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
