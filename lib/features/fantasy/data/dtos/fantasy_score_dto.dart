import 'package:equatable/equatable.dart';

/// Linha da pontuação: a regra, quantas vezes e os pontos (já multiplicados).
class FantasyScoreItem extends Equatable {
  final String rule;
  final int qty;
  final double points;
  final String matchId;

  const FantasyScoreItem({required this.rule, this.qty = 1, this.points = 0, this.matchId = ''});

  @override
  List<Object?> get props => [rule, qty, points, matchId];
}

/// Motivo (por que não pontuou / observação), pelo código das functions.
class FantasyScoreReason extends Equatable {
  final String code;
  final String matchId;

  const FantasyScoreReason({required this.code, this.matchId = ''});

  @override
  List<Object?> get props => [code, matchId];
}

/// Partida do atleta na rodada: minutos (estimados ou não) e pontos.
class FantasyScoreMatch extends Equatable {
  final String matchId;
  final int minutes;
  final bool estimated;
  final double points;

  const FantasyScoreMatch({required this.matchId, this.minutes = 0, this.estimated = false, this.points = 0});

  @override
  List<Object?> get props => [matchId, minutes, estimated, points];
}

/// Pontuação auditada do atleta na rodada (`rodadas/{n}/atletas/{id}`, só as
/// functions gravam).
class FantasyAthleteScoreDTO extends Equatable {
  final String athleteId;
  final String name;
  final String photoUrl;
  final String team;
  final double total;
  final int minutes;

  /// `gol`/`zag`/`mei`/`ata` (nula = sem posição).
  final String? position;
  final List<FantasyScoreMatch> matches;
  final List<FantasyScoreItem> items;
  final List<FantasyScoreReason> reasons;
  final int minMinutes;
  final int minDefenseMinutes;
  final double captain;

  const FantasyAthleteScoreDTO({
    required this.athleteId,
    this.name = '',
    this.photoUrl = '',
    this.team = '',
    this.total = 0,
    this.minutes = 0,
    this.position,
    this.matches = const [],
    this.items = const [],
    this.reasons = const [],
    this.minMinutes = 20,
    this.minDefenseMinutes = 45,
    this.captain = 1.5,
  });

  static List<Map<String, dynamic>> _maps(Object? value) => [
        for (final item in (value as List?) ?? const [])
          if (item is Map) Map<String, dynamic>.from(item),
      ];

  factory FantasyAthleteScoreDTO.fromMap(String id, Map<String, dynamic> data) {
    final params = (data['parametros'] as Map?) ?? const {};
    double number(Object? v) => (v as num?)?.toDouble() ?? 0;
    return FantasyAthleteScoreDTO(
      athleteId: id,
      name: data['nome']?.toString() ?? '',
      photoUrl: data['urlImagem']?.toString() ?? '',
      team: data['time']?.toString() ?? '',
      total: number(data['total']),
      minutes: (data['minutos'] as num?)?.toInt() ?? 0,
      position: data['posicao']?.toString(),
      matches: [
        for (final m in _maps(data['partidas']))
          FantasyScoreMatch(
            matchId: m['idPartida']?.toString() ?? '',
            minutes: (m['minutos'] as num?)?.toInt() ?? 0,
            estimated: m['minutosEstimados'] == true,
            points: number(m['pontos']),
          ),
      ],
      items: [
        for (final i in _maps(data['itens']))
          FantasyScoreItem(
            rule: i['regra']?.toString() ?? '',
            qty: (i['qtd'] as num?)?.toInt() ?? 1,
            points: number(i['pontos']),
            matchId: i['idPartida']?.toString() ?? '',
          ),
      ],
      reasons: [
        for (final r in _maps(data['motivos']))
          FantasyScoreReason(code: r['codigo']?.toString() ?? '', matchId: r['idPartida']?.toString() ?? ''),
      ],
      minMinutes: (params['minMinutos'] as num?)?.toInt() ?? 20,
      minDefenseMinutes: (params['minMinutosDefesa'] as num?)?.toInt() ?? 45,
      captain: (params['capitao'] as num?)?.toDouble() ?? 1.5,
    );
  }

  /// Os itens da mesma regra somados (várias partidas na rodada).
  List<FantasyScoreItem> get groupedItems {
    final byRule = <String, FantasyScoreItem>{};
    for (final item in items) {
      final current = byRule[item.rule];
      byRule[item.rule] = current == null
          ? item
          : FantasyScoreItem(rule: item.rule, qty: current.qty + item.qty, points: current.points + item.points);
    }
    return byRule.values.toList();
  }

  /// Minutos jogados na partida [matchId] (o total, sem a partida).
  int minutesIn(String matchId) => matches.where((m) => m.matchId == matchId).firstOrNull?.minutes ?? minutes;

  @override
  List<Object?> get props => [
        athleteId,
        name,
        photoUrl,
        team,
        total,
        minutes,
        position,
        matches,
        items,
        reasons,
        minMinutes,
        minDefenseMinutes,
        captain
      ];
}
