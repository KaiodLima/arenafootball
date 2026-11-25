import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/formation.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// Profundidade da posição no campo (0 = área do ataque, 1 = o próprio gol).
/// Base do campinho das escalações ([MatchPitch]) e da arte "Escalação".
double lineupDepth(String positionKey) => switch (PlayerPosition.fromKey(positionKey)) {
      PlayerPosition.forward => 0.18,
      PlayerPosition.midfielder => 0.4,
      PlayerPosition.defensiveMidfielder => 0.52,
      PlayerPosition.fullBack || PlayerPosition.defender => 0.7,
      PlayerPosition.goalkeeper => 0.88,
      null => 0.45,
    };

/// Linha do time no campinho.
enum PitchLine {
  goalkeeper,
  defense,
  midfield,
  attack;

  /// Profundidade da linha ([lineupDepth]): o meio fica entre o volante e o meia.
  double get depth => switch (this) {
        PitchLine.goalkeeper => lineupDepth(PlayerPosition.goalkeeper.key),
        PitchLine.defense => lineupDepth(PlayerPosition.defender.key),
        PitchLine.midfield =>
          (lineupDepth(PlayerPosition.defensiveMidfielder.key) + lineupDepth(PlayerPosition.midfielder.key)) / 2,
        PitchLine.attack => lineupDepth(PlayerPosition.forward.key),
      };

  /// Linha da posição cadastrada (nula = sem posição).
  static PitchLine? of(PlayerPosition? position) => switch (position) {
        PlayerPosition.goalkeeper => PitchLine.goalkeeper,
        PlayerPosition.defender || PlayerPosition.fullBack => PitchLine.defense,
        PlayerPosition.defensiveMidfielder || PlayerPosition.midfielder => PitchLine.midfield,
        PlayerPosition.forward => PitchLine.attack,
        null => null,
      };
}

/// Um jogador em campo no campinho: a entrada da escalação (nome e número),
/// a linha, o lugar no campo inteiro ([x] da esquerda para a direita e [y]
/// de cima para baixo, de 0 a 1, como o torcedor vê) e os selos da partida.
class PitchSpot {
  final MatchSide side;
  final LineupEntry entry;
  final PitchLine line;
  final double x;
  final double y;
  final int goals;

  /// Cartão mais grave do jogador na partida (nulo = sem cartão).
  final BookingType? booking;

  /// Entrou no lugar de alguém (substituição).
  final bool subbedIn;

  /// Fileira no campo (0 = goleiro) e quantos cabem nela (a largura do nome).
  final int row;
  final int rowSize;

  /// Vaga da formação (nula = layout automático, sem formação).
  final int? slot;

  const PitchSpot({
    required this.side,
    required this.entry,
    required this.line,
    required this.x,
    required this.y,
    this.goals = 0,
    this.booking,
    this.subbedIn = false,
    this.row = 0,
    this.rowSize = 1,
    this.slot,
  });

  String get playerId => entry.playerId;
}

/// Campinho das escalações confirmadas no detalhe da partida (funções puras):
/// quem está em campo de cada lado ([MatchReport.onField]) em linhas
/// GOL · DEF · MEI · ATA, o mandante na metade de baixo e o visitante na de
/// cima, espelhado. Com a formação da súmula ([MatchDTO.formations]) e as
/// vagas completas, cada um fica na vaga dele ([Formation.slotPlace]).
class MatchPitch {
  const MatchPitch._();

  /// Jogadores por linha a partir dos quais a linha vira zigue-zague.
  static const int maxPerRow = 5;

  /// Faixa de cada metade ocupada pelos centros (fração da metade): do meio
  /// de campo (ataque) até perto do gol (goleiro).
  static const double _nearCenter = 0.12;
  static const double _nearGoal = 0.885;

  /// Margem lateral dos centros (fração da largura).
  static const double _sideMargin = 0.04;

  /// Deslocamento da fileira de trás no zigue-zague (fração da metade).
  static const double _stagger = 0.11;

  /// O campinho aparece: escalações confirmadas e com titular nos dois times.
  static bool visible(MatchDTO match) => MatchReport.lineupConfirmedValid(match);

  /// Os jogadores em campo dos dois lados.
  static List<PitchSpot> of(MatchDTO match, Map<String, String> positions) => [
        ...side(match, MatchSide.home, positions),
        ...side(match, MatchSide.away, positions),
      ];

  /// Os jogadores em campo do [side] com o lugar no campo. [positions]:
  /// id do atleta → chave da posição (`posicao` do elenco).
  static List<PitchSpot> side(MatchDTO match, MatchSide side, Map<String, String> positions) {
    final lineup = match.lineup.of(side);
    final onField = MatchReport.onField(
      lineup: lineup,
      substitutions: match.substitutions,
      bookings: match.bookings,
      side: side,
    );
    if (onField == null || onField.isEmpty) return const [];
    final byId = {for (final e in lineup) e.playerId: e};
    final entries = <LineupEntry>[
      for (final e in lineup)
        if (onField.contains(e.playerId)) e,
      // Quem entrou e não está na escalação (súmula antiga): o nome da substituição.
      for (final s in match.substitutions)
        if (s.side == side && onField.contains(s.inId) && !byId.containsKey(s.inId))
          LineupEntry(playerId: s.inId, playerName: s.inName),
    ];
    final seen = <String>{};
    entries.retainWhere((e) => seen.add(e.playerId));

    PitchSpot spot(LineupEntry entry, PitchLine line, ({double x, double y}) at,
            {required int row, required int rowSize, int? slot}) =>
        PitchSpot(
          side: side,
          entry: entry,
          line: line,
          x: at.x,
          y: at.y,
          goals: match.goals.where((g) => g.side == side && g.scorerId == entry.playerId).length,
          booking: _bookingOf(match.bookings, side, entry.playerId),
          subbedIn: match.substitutions.any((s) => s.side == side && s.inId == entry.playerId),
          row: row,
          rowSize: rowSize,
          slot: slot,
        );

    // Formação da súmula: cada um na vaga (o expulso deixa a vaga vazia).
    final formation = Formation.parse(match.formations[side]);
    final slots = formation == null ? null : slotsOnField(match, side, formation, entries);
    if (formation != null && slots != null) {
      return [
        for (final entry in entries)
          spot(
            entry,
            formation.pitchLineOf(slots[entry.playerId]!),
            formation.slotPlace(slots[entry.playerId]!, side),
            row: formation.seatOf(slots[entry.playerId]!)!.row,
            rowSize: formation.seatOf(slots[entry.playerId]!)!.count,
            slot: slots[entry.playerId],
          ),
      ];
    }

    final lines = assignLines(entries, positions);
    final spots = <PitchSpot>[];
    for (final line in PitchLine.values) {
      final group = orderInLine(lines[line]!, line, positions);
      for (var i = 0; i < group.length; i++) {
        spots.add(spot(group[i], line, place(line, i, group.length, side),
            row: line.index, rowSize: group.length));
      }
    }
    return spots;
  }

  /// Vaga de cada um em campo do [side] na [formation]: a dos titulares e,
  /// nas substituições (em ordem de minuto), quem entra herda a de quem saiu.
  /// Nulo quando falta vaga para alguém em campo (ou há vaga repetida): o
  /// campinho volta ao layout automático.
  static Map<String, int>? slotsOnField(
    MatchDTO match,
    MatchSide side,
    Formation formation,
    List<LineupEntry> onField,
  ) {
    final slotOf = <String, int>{};
    for (final e in match.lineup.of(side)) {
      final slot = e.slot;
      if (!e.starter || slot == null) continue;
      if (formation.seatOf(slot) == null || slotOf.containsValue(slot)) return null;
      slotOf[e.playerId] = slot;
    }
    final subs = [...match.substitutions.where((s) => s.side == side)]
      ..sort((a, b) => (a.minute ?? 999).compareTo(b.minute ?? 999));
    for (final sub in subs) {
      final slot = slotOf.remove(sub.outId);
      if (slot != null) slotOf[sub.inId] = slot;
    }
    final result = <String, int>{};
    for (final e in onField) {
      final slot = slotOf[e.playerId];
      if (slot == null) return null;
      result[e.playerId] = slot;
    }
    return result;
  }

  /// Linha de cada jogador: a da posição; o 2º goleiro em diante vai para a
  /// defesa; sem posição, a linha de linha (não o gol) com menos gente, o
  /// meio no empate.
  static Map<PitchLine, List<LineupEntry>> assignLines(List<LineupEntry> entries, Map<String, String> positions) {
    final lines = {for (final line in PitchLine.values) line: <LineupEntry>[]};
    final unknown = <LineupEntry>[];
    for (final entry in entries) {
      final line = PitchLine.of(PlayerPosition.fromKey(positions[entry.playerId]));
      if (line == null) {
        unknown.add(entry);
      } else if (line == PitchLine.goalkeeper && lines[PitchLine.goalkeeper]!.isNotEmpty) {
        lines[PitchLine.defense]!.add(entry);
      } else {
        lines[line]!.add(entry);
      }
    }
    // Ordem do desempate: meio, defesa, ataque.
    const order = [PitchLine.midfield, PitchLine.defense, PitchLine.attack];
    for (final entry in unknown) {
      var best = order.first;
      for (final line in order) {
        if (lines[line]!.length < lines[best]!.length) best = line;
      }
      lines[best]!.add(entry);
    }
    return lines;
  }

  /// Ordem da esquerda para a direita (visão do próprio time) dentro da
  /// linha: na defesa, os laterais nas pontas e o resto no meio; nas outras,
  /// pelo número da camisa (sem número no fim), mantendo a ordem da escalação.
  static List<LineupEntry> orderInLine(List<LineupEntry> group, PitchLine line, Map<String, String> positions) {
    final byNumber = [...group];
    final index = {for (var i = 0; i < group.length; i++) group[i].playerId: i};
    byNumber.sort((a, b) {
      final byNum = (a.number ?? 1000).compareTo(b.number ?? 1000);
      return byNum != 0 ? byNum : index[a.playerId]!.compareTo(index[b.playerId]!);
    });
    if (line != PitchLine.defense) return byNumber;
    bool isFullBack(LineupEntry e) => PlayerPosition.fromKey(positions[e.playerId]) == PlayerPosition.fullBack;
    final fullBacks = byNumber.where(isFullBack).toList();
    final middle = byNumber.where((e) => !isFullBack(e)).toList();
    final left = fullBacks.take((fullBacks.length + 1) ~/ 2).toList();
    final right = fullBacks.skip(left.length).toList();
    return [...left, ...middle, ...right];
  }

  /// Lugar do [index]-ésimo de [count] jogadores da [line] do [side] no campo
  /// inteiro. O mandante ataca para cima (metade de baixo); o visitante é o
  /// espelho (metade de cima, esquerda e direita trocadas).
  static ({double x, double y}) place(PitchLine line, int index, int count, MatchSide side) =>
      placeAt(depthOf(line), index, count, side, stagger: true);

  /// Profundidade da linha na escala do campinho (1 = o gol, 0 = o ataque).
  static double depthOf(PitchLine line) =>
      (line.depth - PitchLine.attack.depth) / (PitchLine.goalkeeper.depth - PitchLine.attack.depth);

  /// Lugar do [index]-ésimo de [count] numa fileira de profundidade [t]
  /// ([depthOf]); com [stagger], a fileira cheia vira zigue-zague.
  static ({double x, double y}) placeAt(double t, int index, int count, MatchSide side, {bool stagger = false}) {
    final x = _sideMargin + (1 - 2 * _sideMargin) * (index + 0.5) / count;
    var half = _nearCenter + (_nearGoal - _nearCenter) * t;
    // Linha cheia: os ímpares um pouco atrás (zigue-zague), sem passar do gol.
    if (stagger && count > maxPerRow && index.isOdd) half = (half + _stagger).clamp(0.0, _nearGoal);
    final y = 0.5 + half / 2;
    return side == MatchSide.home ? (x: x, y: y) : (x: 1 - x, y: 1 - y);
  }

  /// Fileiras do lado (goleiro + linhas): o campinho fica mais alto com 5.
  static int rowsOf(List<PitchSpot> spots) => spots.fold(0, (rows, s) => s.row + 1 > rows ? s.row + 1 : rows);

  /// Formação do lado pelas linhas de linha ("4-3-3"); sem ninguém fora do
  /// gol, vazia. Linha vazia não entra ("4-4" sem atacante).
  static String formation(List<PitchSpot> spots) => [
        for (final line in [PitchLine.defense, PitchLine.midfield, PitchLine.attack])
          spots.where((s) => s.line == line).length,
      ].where((count) => count > 0).join('-');

  static BookingType? _bookingOf(List<MatchBooking> bookings, MatchSide side, String playerId) {
    final mine = bookings.where((b) => b.side == side && b.playerId == playerId);
    if (mine.any((b) => b.type == BookingType.red)) return BookingType.red;
    if (mine.any((b) => b.type == BookingType.yellow)) return BookingType.yellow;
    return null;
  }

  static const _suffixes = {'jr', 'jr.', 'junior', 'júnior', 'filho', 'neto', 'sobrinho', 'segundo'};

  /// Nome curto no campinho: o apelido (nome de uma palavra) ou o
  /// sobrenome; "Júnior"/"Filho"/"Neto" levam o nome de antes junto.
  static String shortName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;
    final last = parts.last;
    if (_suffixes.contains(last.toLowerCase()) && parts.length > 2) return '${parts[parts.length - 2]} $last';
    if (_suffixes.contains(last.toLowerCase())) return parts.first;
    return last;
  }
}
