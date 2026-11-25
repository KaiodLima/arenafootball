import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/features/share_art/domain/fantasy_round_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/art_exporter.dart';
import 'package:arena_soccer/features/share_art/presentation/bloc/fantasy_round_art_cubit.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/event_result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/fantasy/fantasy_round_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_controls.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Texto que acompanha a arte: a rodada, o campeonato, os craques com os
/// pontos e o convite com o link do Fantasy.
String fantasyRoundShareText(AppLocalizations l10n, FantasyRoundArtData data) {
  final podium = [
    for (final a in data.athletes)
      '${a.rank}º ${a.name} (${l10n.fantasyArtPoints(FantasyRoundArtData.pointsText(a.points))})',
  ].join(', ');
  return l10n.fantasyArtShareText(data.round, data.championship, podium, data.link);
}

/// "Compartilhar" do card "Craques da rodada": modelo, cores, formato e QR
/// (link do Fantasy do campeonato), prévia fiel e salvar/compartilhar (mesma
/// estrutura das outras artes).
class FantasyRoundArtPage extends StatefulWidget {
  const FantasyRoundArtPage({super.key});

  @override
  State<FantasyRoundArtPage> createState() => _FantasyRoundArtPageState();
}

class _FantasyRoundArtPageState extends State<FantasyRoundArtPage> {
  final _artKey = GlobalKey();
  bool _imagesReady = false;
  bool _precacheStarted = false;

  /// Pré-carrega as fotos dos atletas (com tempo limite): a que falhar vira
  /// as iniciais e a arte segue.
  Future<void> _precache(FantasyRoundArtData data) async {
    if (_precacheStarted) return;
    _precacheStarted = true;
    final urls = data.athletes.map((a) => a.photoUrl).where((u) => u.isNotEmpty);
    await Future.wait([
      for (final url in urls)
        precacheImage(EventArtPhoto.providerFor(url), context, onError: (_, __) {})
            .timeout(const Duration(seconds: 6), onTimeout: () {}),
    ]);
    if (mounted) setState(() => _imagesReady = true);
  }

  Future<void> _export(Future<void> Function(Uint8List png, String name) action) async {
    final cubit = BlocProvider.of<FantasyRoundArtCubit>(context);
    final l10n = AppLocalizations.of(context);
    final state = cubit.state;
    if (state.busy || !_imagesReady) return;
    cubit.setBusy(true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final png = await ArtExporter.capture(_artKey, state.format);
      if (png == null) throw StateError('arte sem tamanho');
      await action(
          png, 'arena_fantasy_${state.template.name}_${state.format.name}_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      AppLogger.e('fantasy art export', name: 'FantasyRoundArtPage', error: e);
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
        final data = BlocProvider.of<FantasyRoundArtCubit>(context).state.data;
        await ShareService.shareImage(
          png,
          text: fantasyRoundShareText(AppLocalizations.of(context), data),
          fileName: '$name.png',
        );
      });

  String _formatLabel(AppLocalizations l10n, ArtFormat format) => switch (format) {
        ArtFormat.feed => l10n.shareArtFormatFeed,
        ArtFormat.story => l10n.shareArtFormatStory,
        ArtFormat.square => l10n.shareArtFormatSquare,
        ArtFormat.landscape => l10n.shareArtFormatLandscape,
      };

  String _templateLabel(AppLocalizations l10n, FantasyRoundArtTemplate template) => switch (template) {
        FantasyRoundArtTemplate.podium => l10n.eventArtTemplatePodium,
        FantasyRoundArtTemplate.mvp => l10n.fantasyArtTemplateMvp,
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
    // As paletas fixas não dependem de time: o tema só completa a assinatura.
    const theme = ArtTheme(
      brandDark: AppColors.primaryDark,
      brand: AppColors.primary,
      accent: AppColors.gold,
      home: AppColors.primary,
      away: AppColors.primaryDark,
    );
    return BlocBuilder<FantasyRoundArtCubit, FantasyRoundArtState>(
      builder: (context, state) {
        final cubit = BlocProvider.of<FantasyRoundArtCubit>(context);
        unawaited(_precache(state.data));
        final ready = _imagesReady && !state.busy;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            title: Text(l10n.fantasyArtTitle,
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
                          boxShadow: [
                            BoxShadow(color: AppColors.black.withValues(alpha: 0.2), blurRadius: AppSizes.s20)
                          ],
                        ),
                        child: RepaintBoundary(
                          key: _artKey,
                          child: FantasyRoundArt(
                            data: state.data,
                            template: state.template,
                            format: state.format,
                            colors: state.palette.resolve(theme),
                            showQr: state.showQr,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ArtControlsPanel(
                children: [
                  ArtChipRow(
                    label: l10n.shareArtTemplate,
                    children: [
                      for (final t in FantasyRoundArtTemplate.values)
                        ArenaChoiceChip(
                          label: _templateLabel(l10n, t),
                          selected: state.template == t,
                          onTap: () => cubit.selectTemplate(t),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.s8),
                  ArtChipRow(
                    label: l10n.shareArtColors,
                    children: [
                      for (final p in fantasyArtPalettes)
                        ArtPaletteDot(
                          palette: p,
                          theme: theme,
                          label: _paletteLabel(l10n, p),
                          selected: state.palette == p,
                          onTap: () => cubit.selectPalette(p),
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
                      ArtShareAction(
                        icon: Icons.download_rounded,
                        label: l10n.shareArtSave,
                        color: AppColors.primaryDark,
                        onTap: ready ? _save : null,
                      ),
                      ArtShareAction(
                        icon: Icons.camera_alt_rounded,
                        label: l10n.shareArtInstagram,
                        color: AppColors.instagramStart,
                        onTap: ready ? _share : null,
                      ),
                      ArtShareAction(
                        icon: Icons.chat_rounded,
                        label: l10n.shareWhatsApp,
                        color: AppColors.whatsapp,
                        onTap: ready ? _share : null,
                      ),
                      ArtShareAction(
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
