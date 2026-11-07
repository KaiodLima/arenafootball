import 'dart:math';

import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_clock.dart';

/// Um lance da linha do tempo da súmula: gol, cartão ou substituição.
class ReportEvent {
  final MatchSide side;
  final int? minute;
  final MatchGoal? goal;
  final MatchBooking? booking;
  final MatchSubstitution? substitution;

  ReportEvent.goal(MatchGoal this.goal)
      : side = goal.side,
        minute = goal.minute,
        booking = null,
        substitution = null;

  ReportEvent.booking(MatchBooking this.booking)
      : side = booking.side,
        minute = booking.minute,
        goal = null,
        substitution = null;

  ReportEvent.substitution(MatchSubstitution this.substitution)
      : side = substitution.side,
        minute = substitution.minute,
        goal = null,
        booking = null;

  bool get isGoal => goal != null;

  bool get isSubstitution => substitution != null;

  String get id => goal?.id ?? booking?.id ?? substitution!.id;
}

/// Regras da súmula (funções puras).
class MatchReport {
  const MatchReport._();

  static final Random _random = Random();

  /// Id de documento novo (20 letras/números), para o atleta do cadastro
  /// rápido já entrar na escalação antes de gravar.
  static String newDocId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(List.generate(20, (_) => chars.codeUnitAt(_random.nextInt(chars.length))));
  }

  /// Gols, cartões e substituições em ordem de minuto; sem minuto ficam no
  /// fim, na ordem em que foram lançados. Empate de minuto: gol antes do resto.
  static List<ReportEvent> timeline(
    List<MatchGoal> goals,
    List<MatchBooking> bookings, [
    List<MatchSubstitution> substitutions = const [],
  ]) {
    final events = [
      for (final g in goals) ReportEvent.goal(g),
      for (final b in bookings) ReportEvent.booking(b),
      for (final s in substitutions) ReportEvent.substitution(s),
    ];
    final order = {for (var i = 0; i < events.length; i++) events[i]: i};
    events.sort((a, b) {
      final am = a.minute;
      final bm = b.minute;
      if (am != null && bm != null && am != bm) return am.compareTo(bm);
      if ((am == null) != (bm == null)) return am == null ? 1 : -1;
      if (a.isGoal != b.isGoal) return a.isGoal ? -1 : 1;
      return order[a]!.compareTo(order[b]!);
    });
    return events;
  }

  /// Acrescenta o cartão. 2º amarelo do mesmo atleta (sem vermelho ainda)
  /// lança junto o vermelho ("2º amarelo"), no mesmo minuto.
  static List<MatchBooking> addBooking(List<MatchBooking> current, MatchBooking booking, {String Function()? newId}) {
    final list = [...current, booking];
    if (booking.type != BookingType.yellow || booking.playerId.isEmpty) return list;
    final mine = current.where((b) => b.playerId == booking.playerId && b.side == booking.side);
    final hasYellow = mine.any((b) => b.type == BookingType.yellow);
    final hasRed = mine.any((b) => b.type == BookingType.red);
    if (!hasYellow || hasRed) return list;
    return [
      ...list,
      MatchBooking(
        id: (newId ?? MatchBooking.newId)(),
        side: booking.side,
        type: BookingType.red,
        playerId: booking.playerId,
        playerName: booking.playerName,
        minute: booking.minute,
        secondYellow: true,
      ),
    ];
  }

  /// Tira o cartão [id]; tirar um amarelo também tira o vermelho de 2º
  /// amarelo do atleta (que deixou de ter dois).
  static List<MatchBooking> removeBooking(List<MatchBooking> current, String id) {
    final removed = current.where((b) => b.id == id).firstOrNull;
    final list = current.where((b) => b.id != id).toList();
    if (removed == null || removed.type != BookingType.yellow) return list;
    final yellows = list.where((b) => b.playerId == removed.playerId && b.type == BookingType.yellow).length;
    if (yellows >= 2) return list;
    return list.where((b) => !(b.secondYellow && b.playerId == removed.playerId)).toList();
  }

  /// Minuto sugerido para o lance: o do relógio com o jogo em andamento
  /// (iniciado pelo admin); fora disso, nenhum (digita).
  static int? suggestedMinute(MatchDTO match, DateTime now) {
    if (match.manualStatus != MatchManualStatus.live) return null;
    return MatchClock.of(match, now).minute;
  }

  /// Quem está em campo do [side]: titulares da escalação, mais quem entrou,
  /// menos quem saiu e menos os expulsos (vermelho). Sem escalação daquele
  /// lado, nulo (a súmula usa o elenco todo).
  static Set<String>? onField({
    required List<LineupEntry> lineup,
    required List<MatchSubstitution> substitutions,
    required List<MatchBooking> bookings,
    required MatchSide side,
  }) {
    if (lineup.isEmpty) return null;
    final ids = {for (final e in lineup) if (e.starter) e.playerId};
    final ordered = [...substitutions.where((s) => s.side == side)]
      ..sort((a, b) => (a.minute ?? 999).compareTo(b.minute ?? 999));
    for (final sub in ordered) {
      ids
        ..remove(sub.outId)
        ..add(sub.inId);
    }
    for (final booking in bookings) {
      if (booking.side == side && booking.type == BookingType.red) ids.remove(booking.playerId);
    }
    return ids..remove('');
  }

  /// Quem participou da partida pelo [side] (votação do craque): titulares,
  /// quem entrou nas substituições e quem tem gol, assistência ou cartão.
  /// Reserva que não entrou fica de fora. Sem escalação daquele lado, nulo
  /// (não dá para saber: vale o elenco). Mesma regra das functions
  /// (`participantNames`).
  static Set<String>? participants(MatchDTO match, MatchSide side) {
    final lineup = match.lineup.of(side);
    if (lineup.isEmpty) return null;
    return {
      for (final e in lineup)
        if (e.starter) e.playerId,
      for (final s in match.substitutions)
        if (s.side == side) s.inId,
      for (final g in match.goals)
        if (g.side == side) ...[g.scorerId, g.assistantId],
      for (final b in match.bookings)
        if (b.side == side) b.playerId,
    }..remove('');
  }

  /// O mesmo pelos nomes (o voto grava o nome do atleta), em minúsculas.
  static Set<String>? participantNames(MatchDTO match, MatchSide side) {
    final lineup = match.lineup.of(side);
    if (lineup.isEmpty) return null;
    String key(String name) => name.trim().toLowerCase();
    return {
      for (final e in lineup)
        if (e.starter) key(e.playerName),
      for (final s in match.substitutions)
        if (s.side == side) key(s.inName),
      for (final g in match.goals)
        if (g.side == side) ...[key(g.scorerName), key(g.assistantName)],
      for (final b in match.bookings)
        if (b.side == side) key(b.playerName),
    }..remove('');
  }

  /// Quem já saiu substituído do [side] (não volta a entrar).
  static Set<String> substitutedOut(List<MatchSubstitution> substitutions, MatchSide side) =>
      {for (final s in substitutions) if (s.side == side) s.outId};

  /// Titulares e reservas de um lado.
  static ({int starters, int subs}) lineupCount(List<LineupEntry> entries) =>
      (starters: entries.where((e) => e.starter).length, subs: entries.where((e) => !e.starter).length);

  /// Cartões do atleta [playerId] nas [matches] (perfil do atleta).
  static ({int yellow, int red}) bookingsOf(List<MatchDTO> matches, String playerId) {
    var yellow = 0;
    var red = 0;
    for (final match in matches) {
      for (final b in match.bookings) {
        if (b.playerId != playerId) continue;
        b.type == BookingType.yellow ? yellow++ : red++;
      }
    }
    return (yellow: yellow, red: red);
  }
}
