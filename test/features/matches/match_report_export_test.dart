import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_report_sheet.dart';
import 'package:arena_soccer/features/matches/presentation/export/match_report_pdf.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Leões da Colônia',
  awayTeam: 'Tigres',
  date: '10/12/2026',
  time: '16:00',
  venue: 'Arena Orlandão',
  region: 'Floresta',
  referee: 'José',
  notes: 'Jogo tranquilo.',
  lineup: MatchLineup(home: [
    LineupEntry(playerId: 'p2', playerName: 'Beto', number: 10),
    LineupEntry(playerId: 'p1', playerName: 'Ana', number: 1),
    LineupEntry(playerId: 'p3', playerName: 'Rui', starter: false, number: 14),
  ]),
  substitutions: [
    MatchSubstitution(id: 's', side: MatchSide.home, outId: 'p2', outName: 'Beto', inId: 'p3', inName: 'Rui', minute: 60),
  ],
  goals: [
    MatchGoal(id: 'g2', side: MatchSide.away, scorerId: 'x', scorerName: 'Zé', minute: 70),
    MatchGoal(id: 'g1', side: MatchSide.home, scorerId: 'p2', scorerName: 'Beto', assistantId: 'p1', assistantName: 'Ana', minute: 12),
  ],
  bookings: [
    MatchBooking(id: 'c', side: MatchSide.away, type: BookingType.red, playerId: 'x', playerName: 'Zé', minute: 80, secondYellow: true),
  ],
);

void main() {
  test('documento: escalação por número com entrou/saiu, lances em ordem e placar', () {
    final sheet = MatchReportSheet.of(_match);
    expect(sheet.homeGoals, 1);
    expect(sheet.awayGoals, 1);
    expect(sheet.homeLineup.map((r) => r.name), ['Ana', 'Beto', 'Rui']);
    expect(sheet.homeLineup[1].wentOut, isTrue);
    expect(sheet.homeLineup[1].outMinute, 60);
    expect(sheet.homeLineup[2].cameIn, isTrue);
    expect(sheet.goals.map((g) => g.minute), [12, 70]);
    expect(sheet.goals.first.assistant, 'Ana');
    expect(sheet.bookings.single.secondYellow, isTrue);
    expect(sheet.awayLineup, isEmpty);
  });

  test('nome do arquivo sem acento nem espaço', () {
    expect(MatchReportSheet.fileName(_match), 'sumula_leoes_da_colonia_x_tigres_10-12-2026.pdf');
  });

  test('gera o PDF (súmula completa e vazia, sem escudos)', () async {
    final l10n = lookupAppLocalizations(const Locale('pt'));
    final texts = MatchReportPdfTexts.of(l10n);
    for (final match in [_match, const MatchDTO(homeTeam: 'A', awayTeam: 'B')]) {
      final bytes = await buildMatchReportPdf(
        sheet: MatchReportSheet.of(match),
        texts: texts,
        championship: 'Copa Sol',
        season: '2026',
        statusLabel: l10n.reportFinished,
        generatedAt: '07/11/2026 15:30',
        draft: match == _match,
      );
      expect(ascii.decode(bytes.sublist(0, 4)), '%PDF');
      expect(bytes.length, greaterThan(1000));
    }
  });
}
