import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Galeria de fotos em tela cheia: deslizar entre as fotos e zoom com pinça
/// ou toque duplo. Visualizador genérico, aberto como um dialog (sem rota
/// nomeada) via [PhotoGalleryPage.open].
class PhotoGalleryPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  /// Tag do Hero da primeira foto aberta (transição a partir da tela de origem).
  final Object? heroTag;

  const PhotoGalleryPage({super.key, required this.images, this.initialIndex = 0, this.heroTag});

  static Future<void> open(BuildContext context, {required List<String> images, int initialIndex = 0, Object? heroTag}) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: AppColors.black,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => PhotoGalleryPage(images: images, initialIndex: initialIndex, heroTag: heroTag),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _current = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _current = index),
              itemBuilder: (context, index) {
                final image = _ZoomableImage(url: widget.images[index]);
                if (index == widget.initialIndex && widget.heroTag != null) {
                  return Hero(tag: widget.heroTag!, child: image);
                }
                return image;
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l10n.galleryClose,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppColors.white),
                    ),
                    const Spacer(),
                    if (widget.images.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s12),
                        child: Text(
                          l10n.galleryCounter(_current + 1, widget.images.length),
                          style: AppTypography.label(color: AppColors.white),
                        ),
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

/// Foto com zoom por pinça (1×–4×) e toque duplo para ampliar/voltar.
class _ZoomableImage extends StatefulWidget {
  final String url;

  const _ZoomableImage({required this.url});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _transform = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (_transform.value != Matrix4.identity()) {
      _transform.value = Matrix4.identity();
      return;
    }
    final position = _doubleTapDetails?.localPosition ?? Offset.zero;
    const scale = 2.5;
    _transform.value = Matrix4.identity()
      ..translateByDouble(-position.dx * (scale - 1), -position.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: widget.url,
            fit: BoxFit.contain,
            placeholder: (_, __) => const CircularProgressIndicator(color: AppColors.white),
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: AppColors.whiteSoft),
          ),
        ),
      ),
    );
  }
}
