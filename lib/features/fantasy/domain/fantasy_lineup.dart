import 'package:equatable/equatable.dart';

/// Posições das vagas da escalação do Arena Fantasy e as posições do cadastro
/// aceitas em cada uma (iguais às regras do Firestore): lateral joga de
/// zagueiro, volante de meio-campista (decisão D2); a livre aceita qualquer
/// posição. Quantas vagas de cada o campeonato usa = [FantasyFormation].
enum FantasySlot {
  goalkeeper('gol', ['goleiro'], 1),
  defender('zag', ['zagueiro', 'lateral'], 4),
  midfielder('mei', ['volante', 'meia'], 4),
  forward('ata', ['atacante'], 4),
  flex('livre', ['goleiro', 'zagueiro', 'lateral', 'volante', 'meia', 'atacante'], 3);

  /// Chave em `atletas` da escalação (da 1ª vaga; as outras ganham o número).
  final String key;
  final List<String> positions;

  /// Máximo de vagas desta posição na formação (igual às regras).
  final int maxCount;

  const FantasySlot(this.key, this.positions, this.maxCount);

  bool accepts(String position) => positions.contains(position.trim().toLowerCase());

  static FantasySlot? fromKey(String key) => values.where((s) => s.key == key).firstOrNull;
}

/// Uma vaga da escalação: a posição e qual delas (0 = a 1ª). Chave no
/// Firestore: `zag`, `zag2`, `zag3`...
class FantasySpot extends Equatable {
  final FantasySlot slot;
  final int index;

  const FantasySpot(this.slot, [this.index = 0]);

  String get key => index == 0 ? slot.key : '${slot.key}${index + 1}';

  static final _pattern = RegExp(r'^([a-z]+?)([2-9])?$');

  /// Nula = chave desconhecida.
  static FantasySpot? parse(String key) {
    final match = _pattern.firstMatch(key);
    final slot = match == null ? null : FantasySlot.fromKey(match.group(1)!);
    if (slot == null) return null;
    final index = match!.group(2) == null ? 0 : int.parse(match.group(2)!) - 1;
    return index < slot.maxCount ? FantasySpot(slot, index) : null;
  }

  @override
  List<Object?> get props => [slot, index];
}

/// Quantas vagas de cada posição a escalação tem (`fantasy.vagas`, o admin
/// escolhe por campeonato). Mesmas faixas das regras do Firestore e das
/// functions: GOL 0–1, ZAG/MEI/ATA 0–4, LIVRE 0–3, total de 3 a 7.
class FantasyFormation extends Equatable {
  final Map<FantasySlot, int> counts;

  static const int minTotal = 3;
  static const int maxTotal = 7;

  const FantasyFormation([this.counts = _defaultCounts]);

  static const _defaultCounts = {
    FantasySlot.goalkeeper: 1,
    FantasySlot.defender: 1,
    FantasySlot.midfielder: 1,
    FantasySlot.forward: 1,
    FantasySlot.flex: 1,
  };

  /// O formato de sempre: uma vaga de cada (5 atletas).
  static const defaults = FantasyFormation();

  int countOf(FantasySlot slot) => counts[slot] ?? 0;

  int get total => FantasySlot.values.fold(0, (acc, slot) => acc + countOf(slot));

  bool get isValid =>
      total >= minTotal &&
      total <= maxTotal &&
      FantasySlot.values.every((s) => countOf(s) >= 0 && countOf(s) <= s.maxCount);

  /// As vagas na ordem do formato (gol…, zag…, mei…, ata…, livre…).
  List<FantasySpot> get spots => [
        for (final slot in FantasySlot.values)
          for (var i = 0; i < countOf(slot); i++) FantasySpot(slot, i),
      ];

  /// Troca a quantidade de uma posição (presa à faixa da posição; o total
  /// é conferido pelo [isValid]).
  FantasyFormation withCount(FantasySlot slot, int count) =>
      FantasyFormation({...counts, slot: count.clamp(0, slot.maxCount)});

  /// Lê `vagas` (inválido/sem o campo = o padrão).
  factory FantasyFormation.fromMap(Object? data) {
    if (data is! Map) return defaults;
    final counts = <FantasySlot, int>{};
    for (final slot in FantasySlot.values) {
      final value = data[slot.key];
      if (value is! num || value != value.toInt()) return defaults;
      counts[slot] = value.toInt();
    }
    final formation = FantasyFormation(counts);
    return formation.isValid ? formation : defaults;
  }

  /// O formato de uma escalação gravada pelas chaves dela (`zag2` = 2 ZAG).
  factory FantasyFormation.ofSpots(Iterable<FantasySpot> spots) {
    final counts = {for (final slot in FantasySlot.values) slot: 0};
    for (final spot in spots) {
      if (spot.index + 1 > counts[spot.slot]!) counts[spot.slot] = spot.index + 1;
    }
    return FantasyFormation(counts);
  }

  Map<String, int> toMap() => {for (final slot in FantasySlot.values) slot.key: countOf(slot)};

  @override
  List<Object?> get props => [for (final slot in FantasySlot.values) countOf(slot)];
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

/// Linha do campinho em que uma vaga LIVRE joga: a da posição do atleta
/// escolhido nela ([flexPosition] do cadastro); vazia/sem posição = meio.
FantasySlot fantasyFlexLine(String? flexPosition) =>
    flexPosition == null ? FantasySlot.midfielder : fantasySlotOf(flexPosition) ?? FantasySlot.midfielder;

/// Problema da escalação.
enum FantasyLineupError { incomplete, duplicate, noCaptain, position }

/// Escalação em edição: vaga → idJogador, o capitão (um dos escalados) e o
/// formato ([formation]: as vagas que ela tem).
class FantasyLineup extends Equatable {
  final Map<FantasySpot, String> athletes;
  final String captainId;
  final FantasyFormation formation;

  const FantasyLineup({this.athletes = const {}, this.captainId = '', this.formation = FantasyFormation.defaults});

  String? idAt(FantasySpot spot) => athletes[spot];

  bool contains(String athleteId) => athletes.values.contains(athleteId);

  /// As vagas na ordem do formato.
  List<FantasySpot> get spots => formation.spots;

  /// Vagas preenchidas, na ordem do formato.
  List<FantasySpot> get filledSpots => [
        for (final spot in spots)
          if ((athletes[spot] ?? '').isNotEmpty) spot,
      ];

  /// Os ids na ordem das vagas ('' = vaga vazia).
  List<String> get ids => [for (final spot in spots) athletes[spot] ?? ''];

  /// As vagas da escalação são as do [other] formato.
  bool fitsFormation(FantasyFormation other) => formation == other;

  /// Leva a escalação para o [target] formato: ficam os atletas das vagas que
  /// existem nele; o capitão que saiu deixa de ser capitão.
  FantasyLineup adaptTo(FantasyFormation target) {
    final kept = <FantasySpot, String>{
      for (final spot in target.spots)
        if ((athletes[spot] ?? '').isNotEmpty) spot: athletes[spot]!,
    };
    return FantasyLineup(
      athletes: kept,
      captainId: kept.values.contains(captainId) ? captainId : '',
      formation: target,
    );
  }

  /// Põe o atleta na vaga; se ele estava em outra vaga, sai de lá. Capitão
  /// que saiu da escalação deixa de ser capitão.
  FantasyLineup place(FantasySpot spot, String athleteId) {
    final next = {
      for (final entry in athletes.entries)
        if (entry.value != athleteId) entry.key: entry.value,
      spot: athleteId,
    };
    return FantasyLineup(
      athletes: next,
      captainId: next.values.contains(captainId) ? captainId : '',
      formation: formation,
    );
  }

  FantasyLineup remove(FantasySpot spot) {
    final removed = athletes[spot];
    final next = {...athletes}..remove(spot);
    return FantasyLineup(athletes: next, captainId: removed == captainId ? '' : captainId, formation: formation);
  }

  FantasyLineup withCaptain(String athleteId) =>
      contains(athleteId) ? FantasyLineup(athletes: athletes, captainId: athleteId, formation: formation) : this;

  /// [positionOf]: posição do cadastro de cada atleta (para conferir a vaga).
  FantasyLineupError? validate(String Function(String athleteId) positionOf) {
    final values = ids;
    if (values.any((id) => id.isEmpty)) return FantasyLineupError.incomplete;
    if (values.toSet().length != values.length) return FantasyLineupError.duplicate;
    for (final spot in spots) {
      if (!spot.slot.accepts(positionOf(athletes[spot]!))) return FantasyLineupError.position;
    }
    if (captainId.isEmpty || !values.contains(captainId)) return FantasyLineupError.noCaptain;
    return null;
  }

  /// `atletas` como gravado no Firestore (todas as vagas do formato; '' = vazia).
  Map<String, String> toAthletesMap() => {for (final spot in spots) spot.key: athletes[spot] ?? ''};

  @override
  List<Object?> get props => [athletes, captainId, formation];
}
