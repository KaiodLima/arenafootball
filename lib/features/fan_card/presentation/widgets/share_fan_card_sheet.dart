import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Compartilhar a carteirinha (mesmo molde do card de dica do Relove):
/// título com X, a prévia da imagem que será enviada e os destinos. Cada
/// destino tira o "print" da prévia e abre o compartilhamento do sistema.
Future<void> showShareFanCardSheet(
  BuildContext context, {
  required Widget preview,
  required String shareText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
    ),
    builder: (_) => _ShareSheet(preview: preview, shareText: shareText),
  );
}

class _ShareSheet extends StatefulWidget {
  final Widget preview;
  final String shareText;

  const _ShareSheet({required this.preview, required this.shareText});

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _captureKey = GlobalKey();
  bool _sharing = false;

  /// "Print" da prévia em alta resolução (o FittedBox só reduz a exibição).
  Future<void> _captureAndShare() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) return;
      await ShareService.shareImage(
        bytes.buffer.asUint8List(),
        text: widget.shareText,
        fileName: 'carteirinha_arena_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    } catch (e) {
      AppLogger.e('captureAndShare', name: 'ShareFanCardSheet', error: e);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.s40,
              height: AppSizes.s4,
              margin: const EdgeInsets.only(top: AppSizes.s8, bottom: AppSizes.s4),
              decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(AppSizes.s4)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s8, AppSizes.s8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.fanCardShareTitle,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.greyLight),

            // Prévia inteira: só reduz quando não cabe; o fundo cinza a
            // destaca como "objeto que será compartilhado".
            Flexible(
              child: Container(
                width: double.infinity,
                color: AppColors.background,
                padding: const EdgeInsets.all(AppSizes.s16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RepaintBoundary(key: _captureKey, child: widget.preview),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s16),
              child: Column(
                children: [
                  _ShareActionRow(
                    icon: Icons.camera_alt_rounded,
                    label: l10n.shareInstagramStories,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [AppColors.instagramStart, AppColors.instagramEnd],
                      ),
                    ),
                    busy: _sharing,
                    onTap: _captureAndShare,
                  ),
                  const SizedBox(height: AppSizes.s8),
                  _ShareActionRow(
                    icon: Icons.chat_rounded,
                    label: l10n.shareWhatsApp,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.whatsapp),
                    busy: _sharing,
                    onTap: _captureAndShare,
                  ),
                  const SizedBox(height: AppSizes.s8),
                  _ShareActionRow(
                    icon: Icons.share_rounded,
                    label: l10n.shareMoreOptions,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryDark),
                    busy: _sharing,
                    onTap: _captureAndShare,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha de destino: a cor da rede só no disco do ícone; toque com leve
/// encolhida (0.97/120ms), respeitando animações desativadas.
class _ShareActionRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final BoxDecoration decoration;
  final bool busy;
  final VoidCallback onTap;

  const _ShareActionRow({
    required this.icon,
    required this.label,
    required this.decoration,
    required this.busy,
    required this.onTap,
  });

  @override
  State<_ShareActionRow> createState() => _ShareActionRowState();
}

class _ShareActionRowState extends State<_ShareActionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.busy ? null : widget.onTap,
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
              border: Border.all(color: AppColors.greyLight),
            ),
            child: Row(
              children: [
                Container(
                  width: AppSizes.s40,
                  height: AppSizes.s40,
                  decoration: widget.decoration,
                  child: Icon(widget.icon, color: AppColors.white, size: AppSizes.s22),
                ),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTypography.body().copyWith(fontSize: AppSizes.s16, fontWeight: FontWeight.w600),
                  ),
                ),
                if (widget.busy)
                  const SizedBox.square(
                    dimension: AppSizes.s20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                else
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
