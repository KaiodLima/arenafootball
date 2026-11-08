import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/editorial_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/face_off_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/poster_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/vibrant_art.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// A arte é uma superfície de tamanho fixo (o tamanho lógico do formato,
// exportado a ×3): medidas e fontes são proporcionais a ela, não ao tema do
// app; as fontes são as das artes (`ArtFonts`).

/// Modelos do card de resultado.
enum ResultArtTemplate { vibrant, poster, faceOff, editorial }

/// O card de resultado no [template] e no [format] pedidos.
class ResultArt extends StatelessWidget {
  final ResultArtData data;
  final ResultArtTemplate template;
  final ArtFormat format;
  final bool showQr;

  const ResultArt({super.key, required this.data, required this.template, required this.format, this.showQr = false});

  @override
  Widget build(BuildContext context) {
    final size = format.logicalSize;
    final args = ResultArtArgs(
      data: data,
      format: format,
      theme: ArtTheme.of(data.home, data.away),
      qr: showQr && data.link.isNotEmpty ? data.link : null,
      texts: ResultArtTexts.of(AppLocalizations.of(context), data),
    );
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRect(
        child: switch (template) {
          ResultArtTemplate.vibrant => VibrantArt(args),
          ResultArtTemplate.poster => PosterArt(args),
          ResultArtTemplate.faceOff => FaceOffArt(args),
          ResultArtTemplate.editorial => EditorialArt(args),
        },
      ),
    );
  }
}

/// O que os modelos recebem.
class ResultArtArgs {
  final ResultArtData data;
  final ArtFormat format;
  final ArtTheme theme;
  final String? qr;
  final ResultArtTexts texts;

  const ResultArtArgs({
    required this.data,
    required this.format,
    required this.theme,
    required this.qr,
    required this.texts,
  });

  Size get size => format.logicalSize;
  bool get story => format == ArtFormat.story;
  bool get square => format == ArtFormat.square;
  bool get wide => format == ArtFormat.landscape;
  String get logoUrl => data.championshipLogoUrl;
}

/// Textos prontos da arte (idioma do app).
class ResultArtTexts {
  /// "FIM DE JOGO" / "AO VIVO" / "INTERVALO" / "NÃO INICIADO".
  final String status;

  /// "COPA SOL" / "AMISTOSO".
  final String championship;

  /// "10/12/2026 · 16:00 · ARENA ORLANDÃO" (só o que existe).
  final String info;
  final String noScorer;
  final String goals;
  final String callToAction;
  final String? halfTime;

  const ResultArtTexts({
    required this.status,
    required this.championship,
    required this.info,
    required this.noScorer,
    required this.goals,
    required this.callToAction,
    this.halfTime,
  });

  factory ResultArtTexts.of(AppLocalizations l10n, ResultArtData data) {
    final half = data.halfTimeScore;
    return ResultArtTexts(
      status: switch (data.status) {
        ArtMatchStatus.finished => l10n.liveFullTime,
        ArtMatchStatus.live => l10n.liveLabel,
        ArtMatchStatus.halfTime => l10n.reportHalfTime,
        ArtMatchStatus.notStarted => l10n.reportNotStarted,
      }
          .toUpperCase(),
      championship: (data.championship.isEmpty ? l10n.resultCardFriendly : data.championship).toUpperCase(),
      info: [data.date, data.time, data.venue].where((s) => s.isNotEmpty).join('  ·  ').toUpperCase(),
      noScorer: l10n.reportGoalNoScorer,
      goals: l10n.pdfGoals.toUpperCase(),
      callToAction: l10n.shareArtCallToAction,
      halfTime: half == null ? null : l10n.shareArtHalfTime('${half.$1} × ${half.$2}').toUpperCase(),
    );
  }
}
