import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/art_exporter.dart';
import 'package:arena_soccer/features/share_art/presentation/bloc/share_art_cubit.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/result_art.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Gerar arte" do resultado da partida: modelo, formato e QR, prévia fiel
/// (a mesma arte, só reduzida) e as ações salvar/compartilhar. A imagem sai
/// no tamanho exato do formato ([ArtExporter]).
class ShareArtPage extends StatefulWidget {
  const ShareArtPage({super.key});

  @override
  State<ShareArtPage> createState() => _ShareArtPageState();
}

class _ShareArtPageState extends State<ShareArtPage> {
  final _artKey = GlobalKey();

  /// Escudos já carregados (antes disso, exportar sairia sem eles).
  bool _imagesReady = false;
  bool _precacheStarted = false;

  /// Pré-carrega os escudos (com tempo limite): o que falhar vira o
  /// substituto e a arte segue.
  Future<void> _precache(ResultArtData data) async {
    if (_precacheStarted) return;
    _precacheStarted = true;
    final urls = [data.home.crestUrl, data.away.crestUrl, data.championshipLogoUrl].where((u) => u.isNotEmpty);
    await Future.wait([
      for (final url in urls)
        precacheImage(CachedNetworkImageProvider(url), context, onError: (_, __) {})
            .timeout(const Duration(seconds: 6), onTimeout: () {}),
    ]);
    if (mounted) setState(() => _imagesReady = true);
  }

  Future<void> _export(Future<void> Function(Uint8List png, String name) action) async {
    final cubit = BlocProvider.of<ShareArtCubit>(context);
    final l10n = AppLocalizations.of(context);
    final state = cubit.state;
    if (state.busy || !_imagesReady) return;
    cubit.setBusy(true);
    try {
      // Espera o quadro atual terminar (a arte desenhada por inteiro).
      await WidgetsBinding.instance.endOfFrame;
      final png = await ArtExporter.capture(_artKey, state.format);
      if (png == null) throw StateError('arte sem tamanho');
      await action(png, 'arena_${state.template.name}_${state.format.name}_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      AppLogger.e('share art export', name: 'ShareArtPage', error: e);
      if (mounted) showSnackBar(context: context, message: l10n.shareArtError, isSuccess: false);
    } finally {
      if (!cubit.isClosed) cubit.setBusy(false);
    }
  }

  void _save() => _export((png, name) async {
        final l10n = AppLocalizations.of(context);
        final ok = await ShareService.saveImage(png, name: name);
        if (mounted) {
          showSnackBar(context: context, message: ok ? l10n.shareArtSaved : l10n.shareArtSaveError, isSuccess: ok);
        }
      });

  void _share() => _export((png, name) async {
        final data = BlocProvider.of<ShareArtCubit>(context).state.data!;
        final l10n = AppLocalizations.of(context);
        await ShareService.shareImage(
          png,
          text: l10n.shareArtShareText(data.home.name, data.away.name, data.link),
          fileName: '$name.png',
        );
      });

  String _formatLabel(AppLocalizations l10n, ArtFormat format) => switch (format) {
        ArtFormat.feed => l10n.shareArtFormatFeed,
        ArtFormat.story => l10n.shareArtFormatStory,
        ArtFormat.square => l10n.shareArtFormatSquare,
        ArtFormat.landscape => l10n.shareArtFormatLandscape,
      };

  String _templateLabel(AppLocalizations l10n, ResultArtTemplate template) => switch (template) {
        ResultArtTemplate.vibrant => l10n.shareArtTemplateVibrant,
        ResultArtTemplate.poster => l10n.shareArtTemplatePoster,
        ResultArtTemplate.faceOff => l10n.shareArtTemplateFaceOff,
        ResultArtTemplate.editorial => l10n.shareArtTemplateEditorial,
      };

  String _missingLabel(AppLocalizations l10n, ResultArtData data) {
    final names = [
      for (final m in data.missing)
        switch (m) {
          ArtMissing.homeCrest => l10n.shareArtMissingCrest(data.home.name),
          ArtMissing.awayCrest => l10n.shareArtMissingCrest(data.away.name),
          ArtMissing.venue => l10n.shareArtMissingVenue,
          ArtMissing.date => l10n.shareArtMissingDate,
        },
    ];
    return l10n.shareArtMissing(names.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ShareArtCubit, ShareArtState>(
      builder: (context, state) {
        final cubit = BlocProvider.of<ShareArtCubit>(context);
        final data = state.data;
        if (data != null) unawaited(_precache(data));
        final ready = data != null && _imagesReady && !state.busy;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            title: Text(l10n.shareArtTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18)),
          ),
          body: data == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : Column(
                  children: [
                    // Prévia fiel: a mesma arte no tamanho lógico, só reduzida.
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.s16),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: AppColors.black.withValues(alpha: 0.2), blurRadius: AppSizes.s20)
                                ],
                              ),
                              child: RepaintBoundary(
                                key: _artKey,
                                child: ResultArt(
                                  data: data,
                                  template: state.template,
                                  format: state.format,
                                  showQr: state.showQr,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _Controls(
                      children: [
                        if (data.missing.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.s8),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    size: AppSizes.s16, color: AppColors.textSecondary),
                                const SizedBox(width: AppSizes.s6),
                                Expanded(
                                  child: Text(
                                    _missingLabel(l10n, data),
                                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _ChipRow(
                          label: l10n.shareArtTemplate,
                          children: [
                            for (final t in ResultArtTemplate.values)
                              ArenaChoiceChip(
                                label: _templateLabel(l10n, t),
                                selected: state.template == t,
                                onTap: () => cubit.selectTemplate(t),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.s8),
                        _ChipRow(
                          label: l10n.shareArtFormat,
                          children: [
                            for (final f in ArtFormat.values)
                              ArenaChoiceChip(
                                label: _formatLabel(l10n, f),
                                selected: state.format == f,
                                onTap: () => cubit.selectFormat(f),
                              ),
                          ],
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          value: state.showQr,
                          onChanged: cubit.toggleQr,
                          title: Text(l10n.shareArtQr, style: AppTypography.label(color: AppColors.textPrimary)),
                        ),
                        Row(
                          children: [
                            _Action(
                              icon: Icons.download_rounded,
                              label: l10n.shareArtSave,
                              color: AppColors.primaryDark,
                              onTap: ready ? _save : null,
                            ),
                            _Action(
                              icon: Icons.camera_alt_rounded,
                              label: l10n.shareArtInstagram,
                              color: AppColors.instagramStart,
                              onTap: ready ? _share : null,
                            ),
                            _Action(
                              icon: Icons.chat_rounded,
                              label: l10n.shareWhatsApp,
                              color: AppColors.whatsapp,
                              onTap: ready ? _share : null,
                            ),
                            _Action(
                              icon: Icons.share_rounded,
                              label: l10n.shareMoreOptions,
                              color: AppColors.textSecondary,
                              onTap: ready ? _share : null,
                            ),
                          ],
                        ),
                        if (!ready)
                          const Padding(
                            padding: EdgeInsets.only(top: AppSizes.s6),
                            child: LinearProgressIndicator(minHeight: 2, color: AppColors.primary),
                          ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  final List<Widget> children;

  const _Controls({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s14)],
        ),
        child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, children: children)),
      );
}

class _ChipRow extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _ChipRow({required this.label, required this.children});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: AppSizes.s72,
            child: Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final child in children)
                    Padding(padding: const EdgeInsets.only(right: AppSizes.s6), child: child),
                ],
              ),
            ),
          ),
        ],
      );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _Action({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.s12),
          onTap: onTap,
          child: Opacity(
            opacity: onTap == null ? 0.4 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s6),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: AppSizes.s20,
                    backgroundColor: color,
                    child: Icon(icon, color: AppColors.white, size: AppSizes.s20),
                  ),
                  const SizedBox(height: AppSizes.s4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
