import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_report_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

/// Textos do documento (no idioma do app), separados do `BuildContext` para
/// o PDF ser gerado e testado sem tela.
class MatchReportPdfTexts {
  final String title;
  final String draft;
  final String matchInfo;
  final String date;
  final String time;
  final String venue;
  final String region;
  final String duration;
  final String status;
  final String referee;
  final String lineups;
  final String starters;
  final String reserves;
  final String goals;
  final String bookings;
  final String substitutions;
  final String minute;
  final String team;
  final String player;
  final String scorer;
  final String assist;
  final String type;
  final String playerIn;
  final String playerOut;
  final String yellow;
  final String red;
  final String secondYellow;
  final String bestPlayer;
  final String notes;
  final String signatures;
  final String signReferee;
  final String signOrganizer;
  final String none;
  final String friendly;
  final String championship;
  final String Function(String team) signCaptain;
  final String Function(String date) generatedAt;
  final String Function(int page, int total) page;
  final String Function(int minutes) minutes;
  final String Function(String season) season;
  final String Function(int? minute) cameIn;
  final String Function(int? minute) wentOut;

  const MatchReportPdfTexts({
    required this.title,
    required this.draft,
    required this.matchInfo,
    required this.date,
    required this.time,
    required this.venue,
    required this.region,
    required this.duration,
    required this.status,
    required this.referee,
    required this.lineups,
    required this.starters,
    required this.reserves,
    required this.goals,
    required this.bookings,
    required this.substitutions,
    required this.minute,
    required this.team,
    required this.player,
    required this.scorer,
    required this.assist,
    required this.type,
    required this.playerIn,
    required this.playerOut,
    required this.yellow,
    required this.red,
    required this.secondYellow,
    required this.bestPlayer,
    required this.notes,
    required this.signatures,
    required this.signReferee,
    required this.signOrganizer,
    required this.none,
    required this.friendly,
    required this.championship,
    required this.signCaptain,
    required this.generatedAt,
    required this.page,
    required this.minutes,
    required this.season,
    required this.cameIn,
    required this.wentOut,
  });

  factory MatchReportPdfTexts.of(AppLocalizations l10n) => MatchReportPdfTexts(
        title: l10n.pdfTitle,
        draft: l10n.pdfDraft,
        matchInfo: l10n.pdfMatchInfo,
        date: l10n.pdfDate,
        time: l10n.pdfTime,
        venue: l10n.pdfVenue,
        region: l10n.pdfRegion,
        duration: l10n.pdfDuration,
        status: l10n.pdfStatus,
        referee: l10n.matchReportReferee,
        lineups: l10n.pdfLineups,
        starters: l10n.pdfStarters,
        reserves: l10n.pdfReserves,
        goals: l10n.pdfGoals,
        bookings: l10n.pdfBookings,
        substitutions: l10n.pdfSubstitutions,
        minute: l10n.pdfMinute,
        team: l10n.pdfTeam,
        player: l10n.pdfPlayer,
        scorer: l10n.pdfScorer,
        assist: l10n.pdfAssist,
        type: l10n.pdfType,
        playerIn: l10n.pdfIn,
        playerOut: l10n.pdfOut,
        yellow: l10n.pdfYellow,
        red: l10n.pdfRed,
        secondYellow: l10n.matchReportSecondYellow,
        bestPlayer: l10n.pdfBestPlayer,
        notes: l10n.pdfNotes,
        signatures: l10n.pdfSignatures,
        signReferee: l10n.pdfSignReferee,
        signOrganizer: l10n.pdfSignOrganizer,
        none: l10n.pdfNone,
        friendly: l10n.resultCardFriendly,
        championship: l10n.pdfChampionship,
        signCaptain: l10n.pdfSignCaptain,
        generatedAt: l10n.pdfGeneratedAt,
        page: l10n.pdfPage,
        minutes: l10n.pdfMinutes,
        season: l10n.homeSeasonChip,
        cameIn: (m) => l10n.pdfCameIn(m == null ? '' : " $m'"),
        wentOut: (m) => l10n.pdfWentOut(m == null ? '' : " $m'"),
      );
}

const _green = PdfColor.fromInt(0xFF1B431C);
const _greenSoft = PdfColor.fromInt(0xFFE8F1E8);
const _grey = PdfColor.fromInt(0xFF6B7280);
const _line = PdfColor.fromInt(0xFFD1D5DB);
const _danger = PdfColor.fromInt(0xFFD32F2F);

/// Gera o PDF (A4) da súmula: cabeçalho, dados do jogo, placar, escalações,
/// gols, cartões, substituições, craque, observações e assinaturas.
Future<Uint8List> buildMatchReportPdf({
  required MatchReportSheet sheet,
  required MatchReportPdfTexts texts,
  required String championship,
  required String season,
  required String statusLabel,
  required String generatedAt,
  bool draft = false,
  Uint8List? logo,
  Uint8List? homeCrest,
  Uint8List? awayCrest,
  pw.Font? font,
  pw.Font? fontBold,
}) async {
  final match = sheet.match;
  // Com a fonte (Roboto, com Unicode), acentos e símbolos de nomes saem
  // certos; sem ela, a Helvetica padrão (só Latin-1).
  final theme = font == null ? null : pw.ThemeData.withFont(base: font, bold: fontBold ?? font);
  final doc = pw.Document(
    title: '${texts.title} · ${match.homeTeam} x ${match.awayTeam}',
    author: 'Arena Football',
    theme: theme,
  );
  final small = pw.TextStyle(fontSize: 8, color: _grey);
  final body = const pw.TextStyle(fontSize: 9);
  final bold = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);
  String minute(int? m) => m == null ? '-' : "$m'";
  String teamOf(bool home) => home ? match.homeTeam : match.awayTeam;

  pw.Widget sectionTitle(String text) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 12, bottom: 6),
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration:
            const pw.BoxDecoration(color: _greenSoft, border: pw.Border(left: pw.BorderSide(color: _green, width: 3))),
        child: pw.Text(text.toUpperCase(),
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _green)),
      );

  pw.Widget none() => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Text(texts.none, style: small),
      );

  pw.Widget table(List<String> headers, List<List<String>> rows, Map<int, pw.TableColumnWidth> widths) {
    if (rows.isEmpty) return none();
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      columnWidths: widths,
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _green),
      cellStyle: body,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF6F7F6)),
      border: pw.TableBorder.all(color: _line, width: 0.5),
    );
  }

  pw.Widget infoCell(String label, String value) => pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label.toUpperCase(), style: pw.TextStyle(fontSize: 7, color: _grey)),
              pw.Text(value.trim().isEmpty ? '-' : value, style: bold),
            ],
          ),
        ),
      );

  pw.Widget crest(Uint8List? bytes) => pw.Container(
        width: 46,
        height: 46,
        decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(color: _line)),
        padding: const pw.EdgeInsets.all(4),
        child:
            bytes == null ? pw.SizedBox() : pw.ClipOval(child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain)),
      );

  pw.Widget lineupColumn(String team, List<SheetLineupRow> rows) {
    pw.Widget block(String label, List<SheetLineupRow> list) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
              child: pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _grey)),
            ),
            if (list.isEmpty)
              pw.Text('-', style: small)
            else
              for (final r in list)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 18,
                        child: pw.Text(r.number?.toString() ?? '', style: bold, textAlign: pw.TextAlign.right),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Expanded(child: pw.Text(r.name, style: body)),
                      if (r.cameIn) pw.Text(texts.cameIn(r.inMinute), style: pw.TextStyle(fontSize: 7, color: _green)),
                      if (r.wentOut)
                        pw.Text(texts.wentOut(r.outMinute), style: const pw.TextStyle(fontSize: 7, color: _danger)),
                    ],
                  ),
                ),
          ],
        );
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: _line, width: 0.5)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(team, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _green)),
            if (rows.isEmpty)
              pw.Padding(padding: const pw.EdgeInsets.only(top: 4), child: pw.Text(texts.none, style: small))
            else ...[
              block(texts.starters, rows.where((r) => r.starter).toList()),
              block(texts.reserves, rows.where((r) => !r.starter).toList()),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget signature(String label) => pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Column(
            children: [
              pw.SizedBox(height: 28),
              pw.Container(height: 0.7, color: PdfColors.black),
              pw.SizedBox(height: 3),
              pw.Text(label, style: small, textAlign: pw.TextAlign.center),
            ],
          ),
        ),
      );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 28),
      header: (context) => pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logo != null) pw.Image(pw.MemoryImage(logo), width: 34, height: 34),
              if (logo != null) pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(texts.title,
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _green)),
                    pw.Text(
                      [championship, if (season.isNotEmpty) texts.season(season)].join('  ·  '),
                      style: const pw.TextStyle(fontSize: 9, color: _grey),
                    ),
                  ],
                ),
              ),
              pw.Text('Arena Football',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _green)),
            ],
          ),
          if (draft)
            pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(top: 6),
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              color: const PdfColor.fromInt(0xFFFFF3CD),
              child: pw.Text(texts.draft,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _danger)),
            ),
          pw.Divider(color: _green, thickness: 1.2),
        ],
      ),
      footer: (context) => pw.Row(
        children: [
          pw.Expanded(child: pw.Text(texts.generatedAt(generatedAt), style: small)),
          pw.Text(texts.page(context.pageNumber, context.pagesCount), style: small),
        ],
      ),
      build: (context) => [
        sectionTitle(texts.matchInfo),
        pw.Row(children: [
          infoCell(texts.date, match.date),
          infoCell(texts.time, match.time),
          infoCell(texts.duration, texts.minutes(match.durationMinutes)),
          infoCell(texts.status, statusLabel),
        ]),
        pw.Row(children: [
          infoCell(texts.venue, match.venue),
          infoCell(texts.region, match.region),
          infoCell(texts.referee, match.referee),
        ]),
        // Placar.
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 10),
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _green, width: 1), borderRadius: pw.BorderRadius.circular(6)),
          child: pw.Row(
            children: [
              crest(homeCrest),
              pw.SizedBox(width: 8),
              pw.Expanded(
                  child: pw.Text(match.homeTeam, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
              pw.Text('${sheet.homeGoals}  x  ${sheet.awayGoals}',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _green)),
              pw.Expanded(
                child: pw.Text(match.awayTeam,
                    textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(width: 8),
              crest(awayCrest),
            ],
          ),
        ),
        sectionTitle(texts.lineups),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            lineupColumn(match.homeTeam, sheet.homeLineup),
            pw.SizedBox(width: 8),
            lineupColumn(match.awayTeam, sheet.awayLineup),
          ],
        ),
        sectionTitle(texts.goals),
        table(
          [texts.minute, texts.team, texts.scorer, texts.assist],
          [
            for (final g in sheet.goals)
              [minute(g.minute), teamOf(g.home), g.scorer.isEmpty ? '-' : g.scorer, g.assistant]
          ],
          const {
            0: pw.FixedColumnWidth(36),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(3),
            3: pw.FlexColumnWidth(3)
          },
        ),
        sectionTitle(texts.bookings),
        table(
          [texts.minute, texts.team, texts.player, texts.type],
          [
            for (final b in sheet.bookings)
              [
                minute(b.minute),
                teamOf(b.home),
                b.player,
                b.type == BookingType.yellow
                    ? texts.yellow
                    : (b.secondYellow ? '${texts.red} (${texts.secondYellow})' : texts.red),
              ],
          ],
          const {
            0: pw.FixedColumnWidth(36),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(3),
            3: pw.FlexColumnWidth(2)
          },
        ),
        sectionTitle(texts.substitutions),
        table(
          [texts.minute, texts.team, texts.playerIn, texts.playerOut],
          [
            for (final s in sheet.substitutions) [minute(s.minute), teamOf(s.home), s.playerIn, s.playerOut]
          ],
          const {
            0: pw.FixedColumnWidth(36),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(3),
            3: pw.FlexColumnWidth(3)
          },
        ),
        if (match.electedPlayerName.isNotEmpty) ...[
          sectionTitle(texts.bestPlayer),
          pw.Text(match.electedPlayerName, style: bold),
        ],
        sectionTitle(texts.notes),
        match.notes.trim().isEmpty ? none() : pw.Text(match.notes.trim(), style: body),
        sectionTitle(texts.signatures),
        pw.Row(children: [
          signature(texts.signReferee),
          signature(texts.signCaptain(match.homeTeam)),
          signature(texts.signCaptain(match.awayTeam)),
          signature(texts.signOrganizer),
        ]),
      ],
    ),
  );
  return doc.save();
}
