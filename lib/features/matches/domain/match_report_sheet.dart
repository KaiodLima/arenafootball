import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';

/// Atleta na escalação do documento: número, nome, titular/reserva e se
/// entrou/saiu (com o minuto).
class SheetLineupRow {
  final int? number;
  final String name;
  final bool starter;
  final int? inMinute;
  final int? outMinute;
  final bool cameIn;
  final bool wentOut;

  const SheetLineupRow({
    required this.number,
    required this.name,
    required this.starter,
    this.cameIn = false,
    this.wentOut = false,
    this.inMinute,
    this.outMinute,
  });
}

class SheetGoalRow {
  final int? minute;
  final bool home;
  final String scorer;
  final String assistant;

  const SheetGoalRow({required this.minute, required this.home, required this.scorer, required this.assistant});
}

class SheetBookingRow {
  final int? minute;
  final bool home;
  final String player;
  final BookingType type;
  final bool secondYellow;

  const SheetBookingRow({
    required this.minute,
    required this.home,
    required this.player,
    required this.type,
    required this.secondYellow,
  });
}

class SheetSubstitutionRow {
  final int? minute;
  final bool home;
  final String playerIn;
  final String playerOut;

  const SheetSubstitutionRow(
      {required this.minute, required this.home, required this.playerIn, required this.playerOut});
}

/// Conteúdo do documento da súmula (PDF), montado da partida: escalações
/// (titulares e reservas, por número, com quem entrou/saiu), gols, cartões e
/// substituições em ordem de minuto (sem minuto no fim) e o placar pela lista
/// de gols. Puro: o PDF só desenha.
class MatchReportSheet {
  final MatchDTO match;
  final int homeGoals;
  final int awayGoals;
  final List<SheetLineupRow> homeLineup;
  final List<SheetLineupRow> awayLineup;
  final List<SheetGoalRow> goals;
  final List<SheetBookingRow> bookings;
  final List<SheetSubstitutionRow> substitutions;

  const MatchReportSheet._({
    required this.match,
    required this.homeGoals,
    required this.awayGoals,
    required this.homeLineup,
    required this.awayLineup,
    required this.goals,
    required this.bookings,
    required this.substitutions,
  });

  static int _byMinute(int? a, int? b) => (a ?? 1 << 20).compareTo(b ?? 1 << 20);

  static List<SheetLineupRow> _lineup(MatchDTO match, MatchSide side) {
    final subs = match.substitutions.where((s) => s.side == side).toList();
    SheetLineupRow row(LineupEntry e) {
      final inSub = subs.where((s) => s.inId == e.playerId).firstOrNull;
      final outSub = subs.where((s) => s.outId == e.playerId).firstOrNull;
      return SheetLineupRow(
        number: e.number,
        name: e.playerName,
        starter: e.starter,
        cameIn: inSub != null,
        wentOut: outSub != null,
        inMinute: inSub?.minute,
        outMinute: outSub?.minute,
      );
    }

    int byNumber(LineupEntry a, LineupEntry b) {
      final n = (a.number ?? 999).compareTo(b.number ?? 999);
      return n != 0 ? n : a.playerName.toLowerCase().compareTo(b.playerName.toLowerCase());
    }

    final entries = match.lineup.of(side);
    return [
      for (final e in entries.where((e) => e.starter).toList()..sort(byNumber)) row(e),
      for (final e in entries.where((e) => !e.starter).toList()..sort(byNumber)) row(e),
    ];
  }

  factory MatchReportSheet.of(MatchDTO match) {
    final goals = [...match.goals]..sort((a, b) => _byMinute(a.minute, b.minute));
    final bookings = [...match.bookings]..sort((a, b) => _byMinute(a.minute, b.minute));
    final subs = [...match.substitutions]..sort((a, b) => _byMinute(a.minute, b.minute));
    return MatchReportSheet._(
      match: match,
      homeGoals: match.goals.isEmpty ? match.homeGoals : match.goals.where((g) => g.side == MatchSide.home).length,
      awayGoals: match.goals.isEmpty ? match.awayGoals : match.goals.where((g) => g.side == MatchSide.away).length,
      homeLineup: _lineup(match, MatchSide.home),
      awayLineup: _lineup(match, MatchSide.away),
      goals: [
        for (final g in goals)
          SheetGoalRow(
            minute: g.minute,
            home: g.side == MatchSide.home,
            scorer: g.hasScorer ? g.scorerName : '',
            assistant: g.hasAssistant ? g.assistantName : '',
          ),
      ],
      bookings: [
        for (final b in bookings)
          SheetBookingRow(
            minute: b.minute,
            home: b.side == MatchSide.home,
            player: b.playerName,
            type: b.type,
            secondYellow: b.secondYellow,
          ),
      ],
      substitutions: [
        for (final s in subs)
          SheetSubstitutionRow(
              minute: s.minute, home: s.side == MatchSide.home, playerIn: s.inName, playerOut: s.outName),
      ],
    );
  }

  /// "sumula_leoes_x_tigres_10-12-2026.pdf" (sem acento nem espaço).
  static String fileName(MatchDTO match) {
    String slug(String text) =>
        foldForSearch(text).replaceAll(RegExp('[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
    final date = match.date.replaceAll('/', '-').replaceAll(RegExp('[^0-9-]'), '');
    final name = [
      'sumula',
      slug(match.homeTeam),
      'x',
      slug(match.awayTeam),
      if (date.isNotEmpty) date,
    ].where((p) => p.isNotEmpty).join('_');
    return '$name.pdf';
  }
}
