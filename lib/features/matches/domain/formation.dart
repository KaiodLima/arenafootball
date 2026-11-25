import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_pitch.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// Função da vaga na formação (sigla no editor da súmula).
enum SlotRole { goalkeeper, fullBack, centerBack, defensiveMid, midfielder, forward }

/// Lugar de uma vaga: a fileira (0 = goleiro, 1 = defesa … [Formation.lines]
/// .length = ataque), a posição na fileira (da esquerda para a direita, visão
/// do próprio time) e quantas vagas a fileira tem.
typedef SlotSeat = ({int row, int index, int count});

/// Formação do time na súmula (`partidas{ano}.formacoes.<lado>`): o código
/// ("4-2-3-1") e as linhas de linha, da defesa para o ataque. As vagas são
/// numeradas a partir do goleiro (0) e depois fileira por fileira.
class Formation {
  final String code;
  final List<int> lines;

  const Formation._(this.code, this.lines);

  /// Formações prontas por número de titulares (os outros tamanhos: só Livre).
  static const Map<int, List<String>> presets = {
    11: ['4-4-2', '4-3-3', '3-5-2', '4-2-3-1', '3-4-3', '5-3-2', '4-5-1'],
    7: ['3-2-1', '2-3-1', '3-1-2', '2-2-2'],
    5: ['2-2', '1-2-1', '3-1'],
  };

  /// Jogadores de linha.
  int get outfield => lines.fold(0, (total, n) => total + n);

  /// Vagas (goleiro + linha).
  int get players => 1 + outfield;

  /// Código válido ("4-3-3": de 1 a 6 linhas de 1 a 6 jogadores, até 10 de
  /// linha); nulo para o resto (Livre).
  static Formation? parse(String? code) {
    final text = code?.trim() ?? '';
    if (!RegExp(r'^\d(-\d){0,5}$').hasMatch(text)) return null;
    final lines = text.split('-').map(int.parse).toList();
    if (lines.any((n) => n < 1 || n > 6)) return null;
    final formation = Formation._(text, List.unmodifiable(lines));
    return formation.outfield <= 10 ? formation : null;
  }

  /// As formações da lista para [starters] titulares (vazia = só Livre).
  static List<Formation> forStarters(int starters) =>
      [for (final code in presets[starters] ?? const <String>[]) parse(code)!];

  /// Tamanhos que têm formação pronta (o aviso da súmula).
  static List<int> get sizes => presets.keys.toList();

  /// Fileira e posição da vaga [slot] (nula = fora da formação).
  SlotSeat? seatOf(int slot) {
    if (slot < 0 || slot >= players) return null;
    if (slot == 0) return (row: 0, index: 0, count: 1);
    var first = 1;
    for (var i = 0; i < lines.length; i++) {
      if (slot < first + lines[i]) return (row: i + 1, index: slot - first, count: lines[i]);
      first += lines[i];
    }
    return null;
  }

  /// Função da vaga: goleiro; na defesa com 4 ou mais, as pontas são
  /// laterais e o resto zagueiros; com duas ou mais linhas no meio, a 1ª é de
  /// volantes; a última linha é o ataque.
  SlotRole roleOf(int slot) {
    final seat = seatOf(slot);
    if (seat == null || seat.row == 0) return SlotRole.goalkeeper;
    if (seat.row == 1 && lines.length > 1) {
      final end = seat.index == 0 || seat.index == seat.count - 1;
      return seat.count >= 4 && end ? SlotRole.fullBack : SlotRole.centerBack;
    }
    if (seat.row == lines.length) return SlotRole.forward;
    final middleLines = lines.length - 2;
    return middleLines >= 2 && seat.row == 2 ? SlotRole.defensiveMid : SlotRole.midfielder;
  }

  /// Linha do campinho da vaga (selos e largura do nome).
  PitchLine pitchLineOf(int slot) => switch (roleOf(slot)) {
        SlotRole.goalkeeper => PitchLine.goalkeeper,
        SlotRole.fullBack || SlotRole.centerBack => PitchLine.defense,
        SlotRole.defensiveMid || SlotRole.midfielder => PitchLine.midfield,
        SlotRole.forward => PitchLine.attack,
      };

  /// Fileira desejada para a posição cadastrada (de 0 = gol até o ataque).
  double _targetRow(PlayerPosition? position) {
    final last = lines.length.toDouble();
    return switch (position) {
      PlayerPosition.goalkeeper => 0,
      PlayerPosition.defender || PlayerPosition.fullBack => 1,
      PlayerPosition.defensiveMidfielder => 1 + (last - 1) * 0.4,
      PlayerPosition.midfielder => 1 + (last - 1) * 0.6,
      PlayerPosition.forward => last,
      null => (1 + last) / 2,
    };
  }

  /// Custo de pôr alguém da [position] na vaga [slot] (menor = melhor).
  double _cost(PlayerPosition? position, int slot) {
    final seat = seatOf(slot)!;
    final isKeeper = position == PlayerPosition.goalkeeper;
    // Goleiro só no gol, e no gol só goleiro (a não ser que não sobre outro lugar).
    if ((seat.row == 0) != isKeeper) return 100 + (seat.row - _targetRow(position)).abs();
    var cost = (seat.row - _targetRow(position)).abs();
    final role = roleOf(slot);
    if (position == PlayerPosition.fullBack) cost += role == SlotRole.fullBack ? -0.3 : 0.3;
    if (position == PlayerPosition.defender && role == SlotRole.fullBack) cost += 0.3;
    return cost;
  }

  /// Ordem de quem escolhe a vaga primeiro: goleiros, laterais, zagueiros,
  /// atacantes, volantes, meias e, por fim, quem não tem posição.
  static int _priority(PlayerPosition? position) => switch (position) {
        PlayerPosition.goalkeeper => 0,
        PlayerPosition.fullBack => 1,
        PlayerPosition.defender => 2,
        PlayerPosition.forward => 3,
        PlayerPosition.defensiveMidfielder => 4,
        PlayerPosition.midfielder => 5,
        null => 6,
      };

  /// Vagas dos titulares de [lineup] pela posição cadastrada ([positions]:
  /// id → `posicao`): goleiro no gol, zagueiros e laterais na defesa (laterais
  /// nas pontas), volantes e meias no meio, atacantes no ataque; quem sobra
  /// vai para a vaga livre mais perto da linha dele. Com [keep], quem já está
  /// numa vaga válida (e única) fica onde está. Reservas ficam sem vaga;
  /// titular além das vagas também.
  List<LineupEntry> suggestSlots(List<LineupEntry> lineup, Map<String, String> positions, {bool keep = true}) {
    final taken = <int>{};
    final slotOf = <String, int>{};
    if (keep) {
      for (final e in lineup) {
        final slot = e.slot;
        if (e.starter && slot != null && seatOf(slot) != null && taken.add(slot)) slotOf[e.playerId] = slot;
      }
    }
    final order = {for (var i = 0; i < lineup.length; i++) lineup[i].playerId: i};
    final waiting = [
      for (final e in lineup)
        if (e.starter && !slotOf.containsKey(e.playerId)) e,
    ]..sort((a, b) {
        final pa = _priority(PlayerPosition.fromKey(positions[a.playerId]));
        final pb = _priority(PlayerPosition.fromKey(positions[b.playerId]));
        return pa != pb ? pa.compareTo(pb) : order[a.playerId]!.compareTo(order[b.playerId]!);
      });
    for (final entry in waiting) {
      final position = PlayerPosition.fromKey(positions[entry.playerId]);
      int? best;
      for (var slot = 0; slot < players; slot++) {
        if (taken.contains(slot)) continue;
        if (best == null || _cost(position, slot) < _cost(position, best)) best = slot;
      }
      if (best == null) break;
      taken.add(best);
      slotOf[entry.playerId] = best;
    }
    return [for (final e in lineup) e.copyWith(slot: () => e.starter ? slotOf[e.playerId] : null)];
  }

  /// Põe o titular [playerId] na vaga [slot]: quem estava nela vai para a
  /// vaga antiga dele (troca) ou fica sem vaga, se ele não tinha.
  static List<LineupEntry> swapSlot(List<LineupEntry> lineup, String playerId, int slot) {
    final mover = lineup.where((e) => e.playerId == playerId).firstOrNull;
    if (mover == null || !mover.starter || mover.slot == slot) return lineup;
    final from = mover.slot;
    return [
      for (final e in lineup)
        if (e.playerId == playerId)
          e.copyWith(slot: () => slot)
        else if (e.slot == slot && e.starter)
          e.copyWith(slot: () => from)
        else
          e,
    ];
  }

  /// Vagas sem titular (o aviso da súmula).
  int emptySlots(List<LineupEntry> lineup) {
    final used = {
      for (final e in lineup)
        if (e.starter && e.slot != null && seatOf(e.slot!) != null) e.slot!
    };
    return players - used.length;
  }

  /// Lugar da vaga [slot] no campo inteiro: o goleiro perto do gol e as
  /// linhas igualmente espaçadas da defesa ao ataque; o visitante espelhado.
  ({double x, double y}) slotPlace(int slot, MatchSide side) {
    final seat = seatOf(slot) ?? (row: 0, index: 0, count: 1);
    return MatchPitch.placeAt(rowDepth(seat.row), seat.index, seat.count, side);
  }

  /// Profundidade da fileira (1 = o gol, 0 = o ataque), na escala do
  /// [MatchPitch.placeAt]: a defesa na mesma altura do layout automático.
  double rowDepth(int row) {
    if (row == 0) return 1;
    final defense = MatchPitch.depthOf(PitchLine.defense);
    if (lines.length == 1) return defense / 2;
    return defense * (lines.length - row) / (lines.length - 1);
  }
}
