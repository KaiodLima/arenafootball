import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';

DateTime? _dateOf(Object? value) => value is Timestamp ? value.toDate() : (value is DateTime ? value : null);

/// Rodada do Fantasy (`fantasy/{id}/rodadas/{n}`, só as functions gravam).
class FantasyRoundDTO extends Equatable {
  final int number;
  final List<String> matchIds;
  final DateTime? closesAt;

  /// `aberta`, `fechada` ou `vazia` (sem partidas).
  final String status;

  /// Já teve apuração (alguma partida terminada processada).
  final bool scored;

  /// Todas as partidas da rodada terminaram e foram apuradas.
  final bool finished;

  /// Apuração (painel do admin): partidas terminadas, escalações apuradas e
  /// quando; e os parâmetros congelados ao fechar (nulos = ainda aberta).
  final int matchesFinished;
  final int lineups;
  final DateTime? processedAt;
  final ({int minMinutes, int minDefenseMinutes, double captain})? params;

  /// Prazo escolhido pelo admin ("Reabrir") / fechada pelo admin ("Fechar agora").
  final bool manualDeadline;
  final bool manualClosed;

  const FantasyRoundDTO({
    required this.number,
    this.matchIds = const [],
    this.closesAt,
    this.status = '',
    this.scored = false,
    this.finished = false,
    this.matchesFinished = 0,
    this.lineups = 0,
    this.processedAt,
    this.params,
    this.manualDeadline = false,
    this.manualClosed = false,
  });

  bool get closed => status == 'fechada';

  factory FantasyRoundDTO.fromMap(String id, Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};
    return FantasyRoundDTO(
      number: (map['numero'] as num?)?.toInt() ?? int.tryParse(id) ?? 0,
      matchIds: (map['idsPartidas'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      closesAt: _dateOf(map['fechaEm']),
      status: map['status']?.toString() ?? '',
      scored: map['apuracao'] is Map,
      finished: map['finalizada'] == true,
      matchesFinished: ((map['apuracao'] as Map?)?['encerradas'] as num?)?.toInt() ?? 0,
      lineups: ((map['apuracao'] as Map?)?['escalacoes'] as num?)?.toInt() ?? 0,
      processedAt: _dateOf((map['apuracao'] as Map?)?['processadoEm']),
      manualDeadline: map['prazoManual'] == true,
      manualClosed: map['fechadaManual'] == true,
      params: map['parametros'] is Map
          ? (
              minMinutes: ((map['parametros'] as Map)['minMinutos'] as num?)?.toInt() ?? 20,
              minDefenseMinutes: ((map['parametros'] as Map)['minMinutosDefesa'] as num?)?.toInt() ?? 45,
              captain: ((map['parametros'] as Map)['capitao'] as num?)?.toDouble() ?? 1.5,
            )
          : null,
    );
  }

  /// Versão da apuração (`apuracao.processadoEm`, em ms; 0 = sem apuração):
  /// muda a cada apuração/reapuração, o que vence o cache da rodada.
  int get scoringVersion => processedAt?.millisecondsSinceEpoch ?? 0;

  Map<String, dynamic> toCache() => {
        'number': number,
        'matchIds': matchIds,
        'closesAt': closesAt?.millisecondsSinceEpoch,
        'status': status,
        'scored': scored,
        'finished': finished,
        'matchesFinished': matchesFinished,
        'lineups': lineups,
        'processedAt': processedAt?.millisecondsSinceEpoch,
        'params': params == null
            ? null
            : {
                'minMinutes': params!.minMinutes,
                'minDefenseMinutes': params!.minDefenseMinutes,
                'captain': params!.captain,
              },
        'manualDeadline': manualDeadline,
        'manualClosed': manualClosed,
      };

  factory FantasyRoundDTO.fromCache(Map<String, dynamic> json) {
    DateTime? date(Object? value) => value is num ? DateTime.fromMillisecondsSinceEpoch(value.toInt()) : null;
    final params = json['params'] as Map?;
    return FantasyRoundDTO(
      number: (json['number'] as num?)?.toInt() ?? 0,
      matchIds: [for (final id in (json['matchIds'] as List?) ?? const []) id.toString()],
      closesAt: date(json['closesAt']),
      status: json['status']?.toString() ?? '',
      scored: json['scored'] == true,
      finished: json['finished'] == true,
      matchesFinished: (json['matchesFinished'] as num?)?.toInt() ?? 0,
      lineups: (json['lineups'] as num?)?.toInt() ?? 0,
      processedAt: date(json['processedAt']),
      params: params == null
          ? null
          : (
              minMinutes: (params['minMinutes'] as num?)?.toInt() ?? 20,
              minDefenseMinutes: (params['minDefenseMinutes'] as num?)?.toInt() ?? 45,
              captain: (params['captain'] as num?)?.toDouble() ?? 1.5,
            ),
      manualDeadline: json['manualDeadline'] == true,
      manualClosed: json['manualClosed'] == true,
    );
  }

  /// Ainda dá para montar/trocar a escalação.
  bool isOpenAt(DateTime now) => status == 'aberta' && closesAt != null && now.isBefore(closesAt!);

  /// Em andamento (mercado fechado): o 1º jogo já começou e nem todas as
  /// partidas terminaram/foram apuradas. A próxima rodada só abre depois.
  bool inProgressAt(DateTime now) =>
      (status == 'aberta' || status == 'fechada') &&
      matchIds.isNotEmpty &&
      closesAt != null &&
      !now.isBefore(closesAt!) &&
      !finished;

  @override
  List<Object?> get props => [
        number,
        matchIds,
        closesAt,
        status,
        scored,
        finished,
        matchesFinished,
        lineups,
        processedAt,
        params,
        manualDeadline,
        manualClosed
      ];
}

/// Participante do Fantasy (`fantasy/{id}/participantes/{uid}`).
class FantasyParticipantDTO extends Equatable {
  final String uid;
  final String name;
  final String photoUrl;
  final int firstRound;

  /// Pontos acumulados (só as functions gravam).
  final double points;
  final DateTime? joinedAt;

  const FantasyParticipantDTO({
    required this.uid,
    this.name = '',
    this.photoUrl = '',
    this.firstRound = 0,
    this.points = 0,
    this.joinedAt,
  });

  factory FantasyParticipantDTO.fromMap(String id, Map<String, dynamic> data) => FantasyParticipantDTO(
        uid: id,
        name: data['nome']?.toString() ?? '',
        photoUrl: data['urlImagem']?.toString() ?? '',
        firstRound: (data['rodadaInicial'] as num?)?.toInt() ?? 0,
        points: (data['pontos'] as num?)?.toDouble() ?? 0,
        joinedAt: _dateOf(data['entrouEm']),
      );

  @override
  List<Object?> get props => [uid, name, photoUrl, firstRound, points, joinedAt];
}

/// Escalação do participante na rodada (`rodadas/{n}/escalacoes/{uid}`).
class FantasyLineupDTO extends Equatable {
  final String uid;
  final String name;
  final String photoUrl;
  final FantasyLineup lineup;

  /// Cópia automática da rodada anterior (o dono troca até o prazo).
  final bool copied;

  /// Pontos da rodada (nulo = ainda sem apuração) e os de cada atleta, com o
  /// capitão já multiplicado (só as functions gravam).
  final double? points;
  final Map<String, double> athletePoints;

  /// Atletas da escalação que já jogaram na rodada (`atletasJogaram`): só
  /// eles mostram os pontos ("fez 0" ≠ "ainda não jogou").
  final List<String> playedIds;

  const FantasyLineupDTO({
    required this.uid,
    this.name = '',
    this.photoUrl = '',
    this.lineup = const FantasyLineup(),
    this.copied = false,
    this.points,
    this.athletePoints = const {},
    this.playedIds = const [],
  });

  /// Pontos dos que já jogaram (id → pontos, capitão multiplicado).
  Map<String, double> get playedPoints => {
        for (final id in playedIds)
          if (athletePoints.containsKey(id)) id: athletePoints[id]!,
      };

  factory FantasyLineupDTO.fromMap(String id, Map<String, dynamic> data) {
    final raw = (data['atletas'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? const {};
    final athletes = <FantasySlot, String>{
      for (final entry in raw.entries)
        if (FantasySlot.fromKey(entry.key) != null && entry.value.isNotEmpty)
          FantasySlot.fromKey(entry.key)!: entry.value,
    };
    return FantasyLineupDTO(
      uid: id,
      name: data['nome']?.toString() ?? '',
      photoUrl: data['urlImagem']?.toString() ?? '',
      lineup: FantasyLineup(athletes: athletes, captainId: data['capitao']?.toString() ?? ''),
      copied: data['copiada'] == true,
      points: (data['pontos'] as num?)?.toDouble(),
      athletePoints: {
        for (final entry in ((data['pontosAtletas'] as Map?) ?? const {}).entries)
          if (entry.value is num) entry.key.toString(): (entry.value as num).toDouble(),
      },
      playedIds: [for (final id in (data['atletasJogaram'] as List?) ?? const []) id.toString()],
    );
  }

  /// O que o dono grava (sem `atualizadoEm`, posto pelo data source). Salvar
  /// tira a marca de cópia.
  Map<String, dynamic> toOwnerMap() => {
        'uid': uid,
        'nome': name,
        'urlImagem': photoUrl,
        'atletas': {for (final slot in FantasySlot.values) slot.key: lineup.idAt(slot) ?? ''},
        'idsAtletas': lineup.ids,
        'capitao': lineup.captainId,
        'copiada': false,
      };

  /// No formato do Firestore (o [FantasyLineupDTO.fromCache] reaproveita o
  /// `fromMap`).
  Map<String, dynamic> toCache() => {
        'uid': uid,
        'nome': name,
        'urlImagem': photoUrl,
        'atletas': {for (final slot in FantasySlot.values) slot.key: lineup.idAt(slot) ?? ''},
        'capitao': lineup.captainId,
        'copiada': copied,
        'pontos': points,
        'pontosAtletas': athletePoints,
        'atletasJogaram': playedIds,
      };

  factory FantasyLineupDTO.fromCache(Map<String, dynamic> json) =>
      FantasyLineupDTO.fromMap(json['uid']?.toString() ?? '', json);

  @override
  List<Object?> get props => [uid, name, photoUrl, lineup, copied, points, athletePoints, playedIds];
}
