import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/sticker_name.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_visuals.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cores e escudo do time de uma figurinha. Sem [secondary], o card usa um
/// tom mais escuro do [accent].
class StickerStyle {
  final Color accent;
  final Color? secondary;
  final String crestUrl;

  const StickerStyle({required this.accent, this.secondary, this.crestUrl = ''});

  Color get second => secondary ?? darken(accent, 0.25);
}

/// Figurinha colada no estilo Panini: papel branco em volta, fundo nas cores
/// do time com listras e o escudo apagado atrás, o atleta em destaque, o
/// número e o escudo nos cantos, o time na vertical e a placa inclinada com
/// o primeiro nome pequeno, o SOBRENOME grande e a sigla do time. O escudo é
/// a "brilhante" (raios + foil). Tudo escala pela largura (grade ou detalhe).
/// [count] > 1 mostra "×N".
class StickerCard extends StatelessWidget {
  final StickerDTO sticker;
  final StickerStyle style;
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
    required this.style,
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
      child: LayoutBuilder(
        builder: (context, box) {
          // Escala: 1 = card de 100 px de largura (grade de 3 colunas).
          final k = box.maxWidth / 100;
          return Container(
            padding: EdgeInsets.all(AppSizes.s2 + AppSizes.s2 * k),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.s8 * k),
              boxShadow: [
                BoxShadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.s6 * k),
              // Material: estilo de texto certo também no diálogo do
              // pacotinho e no voo do Hero (sem ele, sublinhado amarelo).
              child: Material(
                type: MaterialType.transparency,
                child: _Face(sticker: sticker, style: style, k: k),
              ),
            ),
          );
        },
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

/// Texto legível sobre [color] (preto em cor clara, branco em escura).
Color _onColor(Color color) => color.computeLuminance() > 0.6 ? AppColors.black : AppColors.white;

/// Frente da figurinha (dentro do papel), com as medidas × [k].
class _Face extends StatelessWidget {
  final StickerDTO sticker;
  final StickerStyle style;
  final double k;

  const _Face({required this.sticker, required this.style, required this.k});

  @override
  Widget build(BuildContext context) {
    final crest = sticker.kind == StickerKind.crest;
    final accent = style.accent;
    final second = style.second;
    final deep = darken(accent, 0.22);
    return LayoutBuilder(
      builder: (context, box) {
        final plate = box.maxHeight * 0.25;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Fundo: cor do time, textura e (no escudo) os raios.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.lerp(accent, AppColors.white, 0.12)!, deep],
                ),
              ),
            ),
            if (crest)
              CustomPaint(painter: RaysPainter(color: AppColors.white.withValues(alpha: 0.1)))
            else
              CustomPaint(
                painter: StripesPainter(color: AppColors.white.withValues(alpha: 0.07), width: 6 * k, diagonal: true),
              ),
            // Marca d'água: o escudo grande e apagado atrás do atleta.
            if (!crest && style.crestUrl.isNotEmpty)
              Positioned(
                top: box.maxHeight * 0.08,
                left: -box.maxWidth * 0.1,
                right: -box.maxWidth * 0.1,
                bottom: plate,
                child: Opacity(opacity: 0.14, child: _Image(url: style.crestUrl, contain: true)),
              ),
            // Atleta (ou o escudo grande na brilhante).
            if (crest)
              Positioned(
                top: box.maxHeight * 0.12,
                left: box.maxWidth * 0.14,
                right: box.maxWidth * 0.14,
                bottom: plate + box.maxHeight * 0.04,
                child: _Image(url: sticker.imageUrl, contain: true, icon: Icons.shield_rounded, k: k),
              )
            else
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: plate * 0.55,
                child: _Image(url: sticker.imageUrl, icon: Icons.person_rounded, k: k),
              ),
            // Funde a foto na placa.
            if (!crest)
              Positioned(
                left: 0,
                right: 0,
                bottom: plate * 0.5,
                height: box.maxHeight * 0.2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.transparent, deep.withValues(alpha: 0.85)],
                    ),
                  ),
                ),
              ),
            // Time na vertical, na lateral (como o país nas Panini).
            if (!crest && sticker.team.isNotEmpty)
              Positioned(
                left: AppSizes.s2 * k,
                top: box.maxHeight * 0.24,
                bottom: plate + AppSizes.s4 * k,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      sticker.team.toUpperCase(),
                      maxLines: 1,
                      style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.55)).copyWith(
                        fontSize: AppSizes.s8 * k,
                        fontWeight: FontWeight.w900,
                        letterSpacing: AppSizes.s1 * k,
                      ),
                    ),
                  ),
                ),
              ),
            // Número.
            Positioned(
              top: AppSizes.s4 * k,
              left: AppSizes.s4 * k,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.s4 * k, vertical: AppSizes.s1 * k),
                decoration: BoxDecoration(
                  color: second,
                  borderRadius: BorderRadius.circular(AppSizes.s4 * k),
                  border: Border.all(color: AppColors.white, width: AppSizes.s1 * k),
                ),
                child: Text(
                  '${sticker.number}',
                  style: AppTypography.label(color: _onColor(second))
                      .copyWith(fontSize: AppSizes.s10 * k, fontWeight: FontWeight.w900, height: 1.1),
                ),
              ),
            ),
            // Escudo pequeno no canto.
            if (!crest && style.crestUrl.isNotEmpty)
              Positioned(
                top: AppSizes.s4 * k,
                right: AppSizes.s4 * k,
                child: Container(
                  width: AppSizes.s20 * k,
                  height: AppSizes.s20 * k,
                  padding: EdgeInsets.all(AppSizes.s2 * k),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.25), blurRadius: 3 * k)],
                  ),
                  child: _Image(url: style.crestUrl, contain: true),
                ),
              ),
            // Placa do nome.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: plate,
              child: _NamePlate(sticker: sticker, accent: deep, second: second, k: k),
            ),
          ],
        );
      },
    );
  }
}

/// Placa inclinada: filete da cor secundária, a faixa do time com o primeiro
/// nome pequeno e o SOBRENOME grande, e a aba escura com a sigla.
class _NamePlate extends StatelessWidget {
  final StickerDTO sticker;
  final Color accent;
  final Color second;
  final double k;

  const _NamePlate({required this.sticker, required this.accent, required this.second, required this.k});

  @override
  Widget build(BuildContext context) {
    final crest = sticker.kind == StickerKind.crest;
    final (first, main) = crest
        ? (AppLocalizations.of(context).albumDetailCrest, sticker.team.isEmpty ? sticker.name : sticker.team)
        : StickerName.split(sticker.name);
    final code = StickerName.teamCode(sticker.team);
    final slant = AppSizes.s8 * k;
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(clipper: _SlantClipper(slant: slant), child: ColoredBox(color: second)),
        ClipPath(
          clipper: _SlantClipper(slant: slant, inset: AppSizes.s2 * k),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accent, darken(accent, 0.12)],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(AppSizes.s6 * k, slant * 0.6, AppSizes.s4 * k, AppSizes.s2 * k),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // As duas linhas encolhem juntas para caber na placa (nome
              // longo ou placa baixa).
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (first.isNotEmpty)
                        Text(
                          crest ? first.toUpperCase() : first,
                          maxLines: 1,
                          style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.8)).copyWith(
                            fontSize: AppSizes.s8 * k,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                            letterSpacing: crest ? AppSizes.s1 * k : 0,
                          ),
                        ),
                      Text(
                        main.toUpperCase(),
                        maxLines: 1,
                        style: AppTypography.label(color: AppColors.white).copyWith(
                          fontSize: AppSizes.s12 * k,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: AppSizes.s1 * k * 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (code.isNotEmpty) ...[
                SizedBox(width: AppSizes.s2 * k),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.s2 * k * 1.5, vertical: AppSizes.s1 * k),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppSizes.s2 * k),
                  ),
                  child: Text(
                    code,
                    style: AppTypography.label(color: AppColors.white).copyWith(
                      fontSize: AppSizes.s8 * k,
                      fontWeight: FontWeight.w900,
                      letterSpacing: AppSizes.s1 * k * 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Recorte com a borda de cima inclinada (sobe da esquerda para a direita);
/// [inset] desce a borda (o filete aparece por cima).
class _SlantClipper extends CustomClipper<Path> {
  final double slant;
  final double inset;

  const _SlantClipper({required this.slant, this.inset = 0});

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, slant + inset)
    ..lineTo(size.width, inset)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_SlantClipper old) => old.slant != slant || old.inset != inset;
}

class _Image extends StatelessWidget {
  final String url;
  final bool contain;
  final IconData? icon;
  final double k;

  const _Image({required this.url, this.contain = false, this.icon, this.k = 1});

  @override
  Widget build(BuildContext context) {
    final placeholder = icon == null
        ? const SizedBox.shrink()
        : Center(child: Icon(icon, color: AppColors.white.withValues(alpha: 0.6), size: AppSizes.s40 * k));
    if (url.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: url,
      fit: contain ? BoxFit.contain : BoxFit.cover,
      alignment: contain ? Alignment.center : Alignment.topCenter,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
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
