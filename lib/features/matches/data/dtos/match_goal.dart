import 'dart:math';

import 'package:equatable/equatable.dart';

/// Lado do gol na partida.
enum MatchSide {
  home('casa'),
  away('fora');

  final String key;

  const MatchSide(this.key);

  static MatchSide fromKey(String? key) => key == away.key ? away : home;
}

/// Um gol guardado na partida (`partidas{ano}.gols[]`): lado, autor e
/// assistência (opcionais; sem autor, o gol só conta no placar). O [id] diz
/// quais gols entraram ou saíram ao salvar.
class MatchGoal extends Equatable {
  final String id;
  final MatchSide side;
  final String scorerId;
  final String scorerName;
  final String assistantId;
  final String assistantName;

  const MatchGoal({
    required this.id,
    required this.side,
    this.scorerId = '',
    this.scorerName = '',
    this.assistantId = '',
    this.assistantName = '',
  });

  static final Random _random = Random();

  /// Id novo de gol (único na partida).
  static String newId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_random.nextInt(1 << 20).toRadixString(36)}';

  bool get hasScorer => scorerId.isNotEmpty;

  /// Assistência que vale (outro atleta que não o autor).
  bool get hasAssistant => assistantId.isNotEmpty && assistantId != scorerId;

  factory MatchGoal.fromMap(Map<String, dynamic> data) {
    String text(String key) => data[key]?.toString() ?? '';
    return MatchGoal(
      id: text('id'),
      side: MatchSide.fromKey(text('lado')),
      scorerId: text('idJogador'),
      scorerName: text('jogador'),
      assistantId: text('idAssistencia'),
      assistantName: text('assistencia'),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'lado': side.key,
        'idJogador': scorerId,
        'jogador': scorerName,
        'idAssistencia': hasAssistant ? assistantId : '',
        'assistencia': hasAssistant ? assistantName : '',
      };

  static List<MatchGoal> listFrom(Object? raw) => raw is List
      ? [
          for (final item in raw)
            if (item is Map) MatchGoal.fromMap(Map<String, dynamic>.from(item)),
        ]
      : const [];

  /// Gols para editar: os guardados e, em partida antiga (placar sem a lista
  /// completa), um "gol sem autor" para cada gol do placar que faltar.
  static List<MatchGoal> forEditing({
    required List<MatchGoal> saved,
    required int homeGoals,
    required int awayGoals,
    required String Function() newId,
  }) {
    final list = [...saved];
    int count(MatchSide side) => list.where((g) => g.side == side).length;
    for (var i = count(MatchSide.home); i < homeGoals; i++) {
      list.add(MatchGoal(id: newId(), side: MatchSide.home));
    }
    for (var i = count(MatchSide.away); i < awayGoals; i++) {
      list.add(MatchGoal(id: newId(), side: MatchSide.away));
    }
    return list;
  }

  /// O que muda nos números dos atletas entre a lista [before] e a [after]
  /// (pelo id do gol; autor trocado = sai um, entra outro): atleta →
  /// (gols, assistências, lado). Gol sem autor não mexe em ninguém.
  static Map<String, ({int goals, int assists, MatchSide side})> statsDelta(
    List<MatchGoal> before,
    List<MatchGoal> after,
  ) {
    final delta = <String, ({int goals, int assists, MatchSide side})>{};
    void bump(String playerId, MatchSide side, {int goals = 0, int assists = 0}) {
      if (playerId.isEmpty) return;
      final current = delta[playerId];
      delta[playerId] = (
        goals: (current?.goals ?? 0) + goals,
        assists: (current?.assists ?? 0) + assists,
        side: side,
      );
    }

    void apply(MatchGoal goal, int sign) {
      bump(goal.scorerId, goal.side, goals: sign);
      if (goal.hasAssistant) bump(goal.assistantId, goal.side, assists: sign);
    }

    final beforeById = {for (final g in before) g.id: g};
    final afterById = {for (final g in after) g.id: g};
    for (final goal in before) {
      final now = afterById[goal.id];
      if (now == goal) continue;
      apply(goal, -1);
    }
    for (final goal in after) {
      final was = beforeById[goal.id];
      if (was == goal) continue;
      apply(goal, 1);
    }
    delta.removeWhere((_, d) => d.goals == 0 && d.assists == 0);
    return delta;
  }

  /// Gols do [side] com autor, juntando os do mesmo autor (na ordem do
  /// primeiro gol dele) e as assistências de cada um. Sem autor não entra.
  static List<({String scorer, int count, List<String> assists})> summaryOf(List<MatchGoal> goals, MatchSide side) {
    final order = <String>[];
    final names = <String, String>{};
    final counts = <String, int>{};
    final assists = <String, List<String>>{};
    for (final goal in goals) {
      if (goal.side != side || !goal.hasScorer) continue;
      final key = goal.scorerId;
      if (!counts.containsKey(key)) order.add(key);
      names[key] = goal.scorerName;
      counts[key] = (counts[key] ?? 0) + 1;
      if (goal.hasAssistant) assists.putIfAbsent(key, () => []).add(goal.assistantName);
    }
    return [for (final key in order) (scorer: names[key]!, count: counts[key]!, assists: assists[key] ?? const [])];
  }

  MatchGoal copyWith({String? scorerId, String? scorerName, String? assistantId, String? assistantName}) {
    return MatchGoal(
      id: id,
      side: side,
      scorerId: scorerId ?? this.scorerId,
      scorerName: scorerName ?? this.scorerName,
      assistantId: assistantId ?? this.assistantId,
      assistantName: assistantName ?? this.assistantName,
    );
  }

  @override
  List<Object?> get props => [id, side, scorerId, scorerName, assistantId, assistantName];
}
