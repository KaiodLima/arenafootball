import 'package:equatable/equatable.dart';

/// Inscrição do atleta numa competição (`jogadores{ano}.inscricoes.c<id>`):
/// por qual time ele joga ali e os números dele naquela competição. O mesmo
/// atleta pode jogar pelo time A na competição X e pelo B na Y.
class PlayerEnrollment extends Equatable {
  /// Campo do mapa no Firestore.
  static const String field = 'inscricoes';

  /// `id_campeonato` da competição (o mesmo das partidas).
  final int championshipId;
  final String teamId;

  /// Nome do time (cópia para exibir; o vínculo é [teamId]).
  final String team;
  final int goals;
  final int assists;

  const PlayerEnrollment({
    required this.championshipId,
    required this.teamId,
    required this.team,
    this.goals = 0,
    this.assists = 0,
  });

  /// Chave no mapa: `c` + id (campo que não começa com dígito).
  static String keyOf(int championshipId) => 'c$championshipId';

  /// Id da competição a partir da chave (`c7` → 7); nulo se não for chave.
  static int? idOfKey(String key) => key.startsWith('c') ? int.tryParse(key.substring(1)) : null;

  factory PlayerEnrollment.fromMap(int championshipId, Map<String, dynamic> data) {
    return PlayerEnrollment(
      championshipId: championshipId,
      teamId: data['idTime']?.toString() ?? '',
      team: data['time']?.toString() ?? '',
      goals: (data['nGols'] as num?)?.toInt() ?? 0,
      assists: (data['nAssistencias'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'idTime': teamId, 'time': team, 'nGols': goals, 'nAssistencias': assists};

  /// Mapa `inscricoes` do Firestore (ou do cache) → lista em ordem de competição.
  static List<PlayerEnrollment> listFrom(Object? raw) {
    if (raw is! Map) return const [];
    final list = <PlayerEnrollment>[];
    for (final entry in raw.entries) {
      final id = idOfKey(entry.key.toString());
      if (id == null || entry.value is! Map) continue;
      list.add(PlayerEnrollment.fromMap(id, Map<String, dynamic>.from(entry.value as Map)));
    }
    return list..sort((a, b) => a.championshipId.compareTo(b.championshipId));
  }

  static Map<String, dynamic> mapOf(List<PlayerEnrollment> enrollments) =>
      {for (final e in enrollments) keyOf(e.championshipId): e.toMap()};

  PlayerEnrollment copyWith({String? teamId, String? team, int? goals, int? assists}) {
    return PlayerEnrollment(
      championshipId: championshipId,
      teamId: teamId ?? this.teamId,
      team: team ?? this.team,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
    );
  }

  @override
  List<Object?> get props => [championshipId, teamId, team, goals, assists];
}
