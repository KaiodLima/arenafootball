import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_report_sheet.dart';
import 'package:arena_soccer/features/matches/domain/usecases/export_match_report_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/export/match_report_pdf.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';

/// Situação da partida no documento.
String matchReportStatusLabel(AppLocalizations l10n, MatchDTO match, DateTime now) {
  final status = MatchCardStatus.of(match, now);
  if (status.finished) return l10n.reportFinished;
  if (status.halfTime) return l10n.reportHalfTime;
  if (status.live) return l10n.reportLive;
  return l10n.reportNotStarted;
}

Future<Uint8List?> _download(String url) async {
  if (!url.startsWith('http')) return null;
  try {
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 6));
    return response.statusCode == 200 ? response.bodyBytes : null;
  } catch (_) {
    return null;
  }
}

/// Roboto (com Unicode), baixada uma vez e guardada em cache pelo `printing`;
/// sem rede, nula (o PDF usa a Helvetica padrão).
Future<({pw.Font regular, pw.Font bold})?> _fonts() async {
  try {
    final regular = await PdfGoogleFonts.robotoRegular().timeout(const Duration(seconds: 8));
    final bold = await PdfGoogleFonts.robotoBold().timeout(const Duration(seconds: 8));
    return (regular: regular, bold: bold);
  } catch (e) {
    AppLogger.e('fonte do PDF indisponível (usa a padrão)', name: 'MatchReportExport', error: e);
    return null;
  }
}

/// Gera o PDF da súmula de [match] e abre a prévia (imprimir/compartilhar).
/// [draft]: súmula com alterações ainda não salvas (faixa "RASCUNHO").
Future<void> showMatchReportExport(BuildContext context, {required MatchDTO match, String? season, bool draft = false}) async {
  final l10n = AppLocalizations.of(context);
  final selectedSeason = season == null || season.isEmpty ? SeasonCollection.currentSeason : season;
  try {
    final info = await sl<ExportMatchReportUseCase>()(match: match, season: selectedSeason);
    final images = await Future.wait([
      rootBundle.load(AppImages.logo).then((data) => data.buffer.asUint8List()).catchError((_) => Uint8List(0)),
      _download(info.homeCrest).then((b) => b ?? Uint8List(0)),
      _download(info.awayCrest).then((b) => b ?? Uint8List(0)),
    ]);
    Uint8List? orNull(Uint8List bytes) => bytes.isEmpty ? null : bytes;
    final fonts = await _fonts();
    final now = DateTime.now();
    final bytes = await buildMatchReportPdf(
      sheet: MatchReportSheet.of(match),
      texts: MatchReportPdfTexts.of(l10n),
      championship: match.championshipId > 0
          ? (info.championship.isEmpty ? l10n.pdfChampionship : info.championship)
          : l10n.resultCardFriendly,
      season: selectedSeason,
      statusLabel: matchReportStatusLabel(l10n, match, now),
      generatedAt: DateFormat('dd/MM/yyyy HH:mm').format(now),
      draft: draft,
      logo: orNull(images[0]),
      homeCrest: orNull(images[1]),
      awayCrest: orNull(images[2]),
      font: fonts?.regular,
      fontBold: fonts?.bold,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: MatchReportSheet.fileName(match));
  } catch (e) {
    AppLogger.e('showMatchReportExport id=${match.id}', name: 'MatchReportExport', error: e);
    if (context.mounted) showSnackBar(context: context, message: l10n.matchReportExportError, isSuccess: false);
  }
}
