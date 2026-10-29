import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_visuals.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Figurinha colada (estilo Panini): borda branca de papel, foto cobrindo,
/// gradiente embaixo com o nome, o número num selo no canto e, no escudo, o
/// brilho holográfico ("foil"). [count] > 1 mostra "×N".
class StickerCard extends StatelessWidget {
  final StickerDTO sticker;

  /// Cor do time (selo do número e faixa do nome).
  final Color accent;
  final int count;
  final VoidCallback? onTap;

  /// Tag do Hero (ampliar); nula = sem Hero.
  final Object? heroTag;

  /// Reflexo guiado pela inclinação (-1 a 1, tela de detalhe); nulo = o
  /// brilho em loop (só no escudo).
  final double? sheen;

  const StickerCard({
    super.key,
    required this.sticker,
    required this.accent,
    this.count = 1,
    this.onTap,
    this.heroTag,
    this.sheen,
  });

  bool get _foil => sticker.kind == StickerKind.crest;

  @override
  Widget build(BuildContext context) {
    Widget card = AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.s4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.s10),
          boxShadow: [
            BoxShadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.s6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accent.withValues(alpha: 0.35), darken(accent, 0.2)],
                  ),
                ),
              ),
              _Photo(sticker: sticker, accent: accent),
              // Faixa do nome.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s6, AppSizes.s16, AppSizes.s6, AppSizes.s4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.transparent, AppColors.black.withValues(alpha: 0.75)],
                    ),
                  ),
                  child: Text(
                    sticker.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.label(color: AppColors.white).copyWith(
                      fontSize: AppSizes.s10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              // Número.
              Positioned(
                top: AppSizes.s4,
                left: AppSizes.s4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s2),
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(AppSizes.s6)),
                  child: Text(
                    '${sticker.number}',
                    style: AppTypography.label(color: AppColors.white)
                        .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final sheen = this.sheen;
    if (sheen != null) {
      card = Stack(
        fit: StackFit.passthrough,
        children: [
          card,
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.s10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.6 + sheen * 1.6, -1),
                      end: Alignment(0.4 + sheen * 1.6, 1),
                      colors: _foil
                          ? [
                              AppColors.transparent,
                              AppColors.teamPink.withValues(alpha: 0.3),
                              AppColors.googleYellow.withValues(alpha: 0.35),
                              AppColors.teamBlue.withValues(alpha: 0.3),
                              AppColors.transparent,
                            ]
                          : [AppColors.transparent, AppColors.white.withValues(alpha: 0.35), AppColors.transparent],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_foil) {
      card = Shimmer(holographic: true, child: card);
    }
    if (heroTag != null) card = Hero(tag: heroTag!, child: card);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          if (count > 1)
            Positioned(
              top: -AppSizes.s6,
              right: -AppSizes.s6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s2),
                decoration: BoxDecoration(
                  color: AppColors.googleYellow,
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                  border: Border.all(color: AppColors.white, width: AppSizes.s2),
                ),
                child: Text(
                  '×$count',
                  style: AppTypography.label(color: AppColors.black)
                      .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  final StickerDTO sticker;
  final Color accent;

  const _Photo({required this.sticker, required this.accent});

  @override
  Widget build(BuildContext context) {
    final crest = sticker.kind == StickerKind.crest;
    final placeholder = Icon(
      crest ? Icons.shield_rounded : Icons.person_rounded,
      color: AppColors.white.withValues(alpha: 0.6),
      size: AppSizes.s40,
    );
    if (sticker.imageUrl.isEmpty) return Center(child: placeholder);
    return Padding(
      padding:
          crest ? const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s20, AppSizes.s12, AppSizes.s24) : EdgeInsets.zero,
      child: CachedNetworkImage(
        imageUrl: sticker.imageUrl,
        fit: crest ? BoxFit.contain : BoxFit.cover,
        alignment: Alignment.topCenter,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, __) => Center(child: placeholder),
        errorWidget: (_, __, ___) => Center(child: placeholder),
      ),
    );
  }
}

/// Espaço vazio (estilo Panini) sobre o fundo escuro da página: moldura
/// tracejada, número grande e o nome de quem falta.
class EmptySlot extends StatelessWidget {
  final StickerDTO sticker;

  const EmptySlot({super.key, required this.sticker});

  @override
  Widget build(BuildContext context) {
    final crest = sticker.kind == StickerKind.crest;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: AppColors.white.withValues(alpha: 0.45)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.s10),
          ),
          padding: const EdgeInsets.all(AppSizes.s6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                crest ? Icons.shield_outlined : Icons.person_outline_rounded,
                color: AppColors.white.withValues(alpha: 0.35),
                size: AppSizes.s24,
              ),
              Text(
                '${sticker.number}',
                style: AppTypography.display(color: AppColors.white.withValues(alpha: 0.85))
                    .copyWith(fontSize: AppSizes.s28),
              ),
              Text(
                sticker.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style:
                    AppTypography.label(color: AppColors.white.withValues(alpha: 0.6)).copyWith(fontSize: AppSizes.s10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(AppSizes.s10)));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
