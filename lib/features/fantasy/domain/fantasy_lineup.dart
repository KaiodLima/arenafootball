import 'package:equatable/equatable.dart';

/// Vagas da escalação do Arena Fantasy e as posições do cadastro aceitas em
/// cada uma (iguais às regras do Firestore): lateral joga de zagueiro, volante
/// de meio-campista (decisão D2); a livre aceita qualquer posição.
enum FantasySlot {
  goalkeeper('gol', ['goleiro']),
  defender('zag', ['zagueiro', 'lateral']),
  midfielder('mei', ['volante', 'meia']),
  forward('ata', ['atacante']),
  flex('livre', ['goleiro', 'zagueiro', 'lateral', 'volante', 'meia', 'atacante']);

  /// Chave em `atletas` da escalação.
  final String key;
  final List<String> positions;

  const FantasySlot(this.key, this.positions);

  bool accepts(String position) => positions.contains(position.trim().toLowerCase());

  static FantasySlot? fromKey(String key) => values.where((s) => s.key == key).firstOrNull;
}

/// Posição do Fantasy (a vaga fixa) do atleta com a [position] do cadastro;
/// nula = sem posição (não entra no Fantasy).
FantasySlot? fantasySlotOf(String position) {
  final value = position.trim().toLowerCase();
  for (final slot in FantasySlot.values) {
    if (slot != FantasySlot.flex && slot.accepts(value)) return slot;
  }
  return null;
}

/// Problema da escalação.
enum FantasyLineupError { incomplete, duplicate, noCaptain, position }

/// Escalação em edição: vaga → idJogador e o capitão (um dos 5).
class FantasyLineup extends Equatable {
  final Map<FantasySlot, String> athletes;
  final String captainId;

  const FantasyLineup({this.athletes = const {}, this.captainId = ''});

  String? idAt(FantasySlot slot) => athletes[slot];

  bool contains(String athleteId) => athletes.values.contains(athleteId);

  /// Os 5 ids na ordem das vagas (gol, zag, mei, ata, livre).
  List<String> get ids => [for (final slot in FantasySlot.values) athletes[slot] ?? ''];

  /// Põe o atleta na vaga; se ele estava em outra vaga, sai de lá. Capitão
  /// que saiu da escalação deixa de ser capitão.
  FantasyLineup place(FantasySlot slot, String athleteId) {
    final next = {
      for (final entry in athletes.entries)
        if (entry.value != athleteId) entry.key: entry.value,
      slot: athleteId,
    };
    return FantasyLineup(athletes: next, captainId: next.values.contains(captainId) ? captainId : '');
  }

  FantasyLineup remove(FantasySlot slot) {
    final removed = athletes[slot];
    final next = {...athletes}..remove(slot);
    return FantasyLineup(athletes: next, captainId: removed == captainId ? '' : captainId);
  }

  FantasyLineup withCaptain(String athleteId) =>
      contains(athleteId) ? FantasyLineup(athletes: athletes, captainId: athleteId) : this;

  /// [positionOf]: posição do cadastro de cada atleta (para conferir a vaga).
  FantasyLineupError? validate(String Function(String athleteId) positionOf) {
    final values = FantasySlot.values.map((s) => athletes[s] ?? '').toList();
    if (values.any((id) => id.isEmpty)) return FantasyLineupError.incomplete;
    if (values.toSet().length != values.length) return FantasyLineupError.duplicate;
    for (final slot in FantasySlot.values) {
      if (!slot.accepts(positionOf(athletes[slot]!))) return FantasyLineupError.position;
    }
    if (captainId.isEmpty || !values.contains(captainId)) return FantasyLineupError.noCaptain;
    return null;
  }

  @override
  List<Object?> get props => [athletes, captainId];
}
