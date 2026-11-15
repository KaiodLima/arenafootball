import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/qr_codes/domain/qr_target.dart';
import 'package:arena_soccer/features/qr_codes/presentation/widgets/qr_poster.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/presentation/art_exporter.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_controls.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// QR code da partida: o da votação do craque (aberta) ou o da partida.
Future<void> openMatchQr(
  BuildContext context, {
  required MatchDTO match,
  String? season,
  String? homeCrest,
  String? awayCrest,
}) =>
    openQrPoster(
      context,
      QrTarget.forMatch(
        match,
        season: season ?? SeasonCollection.currentSeason,
        home: ArtTeam(name: match.homeTeam, crestUrl: homeCrest ?? ''),
        away: ArtTeam(name: match.awayTeam, crestUrl: awayCrest ?? ''),
      ),
    );

/// Abre o cartaz do QR code de [target].
Future<void> openQrPoster(BuildContext context, QrTarget target) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => QrPosterPage(target: target)));

/// Cartaz do QR code: prévia fiel, formato (Story/Feed/Quadrado/Paisagem),
/// cores, Salvar, Compartilhar (imagem + link) e Copiar link. Só escolhas de
/// tela: nada é lido nem gravado.
class QrPosterPage extends StatefulWidget {
  final QrTarget target;

  const QrPosterPage({super.key, required this.target});

  @override
  State<QrPosterPage> createState() => _QrPosterPageState();
}

class _QrPosterPageState extends State<QrPosterPage> {
  final _artKey = GlobalKey();
  ArtFormat _format = ArtFormat.story;
  ArtPalette _palette = ArtPalette.arena;
  bool _busy = false;

  String get _shareText => AppLocalizations.of(context).qrShareText(widget.target.title, widget.target.link);

  Future<void> _export(Future<void> Function(Uint8List png, String name) action) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final png = await ArtExporter.capture(_artKey, _format);
      if (png == null) throw StateError('cartaz sem tamanho');
      await action(png, 'arena_qr_${widget.target.kind.name}_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      AppLogger.e('qr poster export', name: 'QrPosterPage', error: e);
      if (mounted) showSnackBar(context: context, message: l10n.shareArtError, isSuccess: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _save() => _export((png, name) async {
        final l10n = AppLocalizations.of(context);
        final ok = await ShareService.saveImage(png, name: name);
        if (mounted) {
          showSnackBar(context: context, message: ok ? l10n.shareArtSaved : l10n.shareArtSaveError, isSuccess: ok);
        }
      });

  void _share() => _export((png, name) => ShareService.shareImage(png, text: _shareText, fileName: '$name.png'));

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.target.link));
    if (mounted) showSnackBar(context: context, message: AppLocalizations.of(context).qrLinkCopied);
  }

  String _formatLabel(AppLocalizations l10n, ArtFormat format) => switch (format) {
        ArtFormat.feed => l10n.shareArtFormatFeed,
        ArtFormat.story => l10n.shareArtFormatStory,
        ArtFormat.square => l10n.shareArtFormatSquare,
        ArtFormat.landscape => l10n.shareArtFormatLandscape,
      };

  String _paletteLabel(AppLocalizations l10n, ArtPalette palette) => switch (palette) {
        ArtPalette.teams => l10n.shareArtPaletteTeams,
        ArtPalette.arena => l10n.shareArtPaletteArena,
        ArtPalette.night => l10n.shareArtPaletteNight,
        ArtPalette.crimson => l10n.shareArtPaletteCrimson,
        ArtPalette.ocean => l10n.shareArtPaletteOcean,
        ArtPalette.graphite => l10n.shareArtPaletteGraphite,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        title: Text(l10n.qrPosterTitle,
            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.s16),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.2), blurRadius: AppSizes.s20)],
                    ),
                    child: RepaintBoundary(
                      key: _artKey,
                      child: QrPoster(target: widget.target, format: _format, colors: _palette.resolve(qrArtTheme)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ArtControlsPanel(
            children: [
              ArtChipRow(
                label: l10n.shareArtColors,
                children: [
                  for (final p in qrPalettes)
                    ArtPaletteDot(
                      palette: p,
                      theme: qrArtTheme,
                      label: _paletteLabel(l10n, p),
                      selected: _palette == p,
                      onTap: () => setState(() => _palette = p),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.s8),
              ArtChipRow(
                label: l10n.shareArtFormat,
                children: [
                  for (final f in ArtFormat.values)
                    ArenaChoiceChip(
                      label: _formatLabel(l10n, f),
                      selected: _format == f,
                      onTap: () => setState(() => _format = f),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.s8),
              Row(
                children: [
                  ArtShareAction(
                    icon: Icons.download_rounded,
                    label: l10n.shareArtSave,
                    color: AppColors.primaryDark,
                    onTap: _busy ? null : _save,
                  ),
                  ArtShareAction(
                    icon: Icons.share_rounded,
                    label: l10n.shareMoreOptions,
                    color: AppColors.textSecondary,
                    onTap: _busy ? null : _share,
                  ),
                  ArtShareAction(
                    key: const ValueKey('qr-copy'),
                    icon: Icons.link_rounded,
                    label: l10n.qrCopyLink,
                    color: AppColors.teamBlue,
                    onTap: _copy,
                  ),
                ],
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: AppSizes.s6),
                  child: LinearProgressIndicator(minHeight: 2, color: AppColors.primary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
