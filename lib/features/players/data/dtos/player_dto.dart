import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

/// Documento das coleções `jogadores` / `jogadores{ano}`.
///
/// O atleta pode jogar por times diferentes em competições diferentes:
/// [enrollments] (`inscricoes`) diz o time e os números em cada competição.
/// [team]/[teamId] é o time principal (o que os apps antigos e o ranking geral
/// usam) e [goals]/[assists] o total da temporada.
class PlayerDTO extends Equatable {
  /// Campos de gols/assistências no Firestore (ranking ordena por eles).
  static const String goalsField = 'nGols';
  static const String assistsField = 'nAssistencias';

  /// Ids dos times das inscrições (consulta do elenco e regras).
  static const String teamIdsField = 'idsTimes';

  final String id;
  final String name;

  /// Nome do time principal (cópia para exibir; o vínculo é [teamId]).
  final String team;

  /// `idTime`: id do time principal (doc de `times{ano}`). Vazio em jogadores
  /// antigos (antes da migração) e em quem está sem time: aí vale o nome.
  final String teamId;
  final String imageUrl;

  /// Totais da temporada (todas as competições + o que veio de antes delas).
  final int goals;
  final int assists;

  /// Conta vinculada (jogador aprovado pelo "Sou jogador"); vazio nos demais.
  final String userId;

  /// Chave de `PlayerPosition` (goleiro, zagueiro...); vazio se não informada.
  final String position;

  /// Inscrições por competição; vazio em atletas antigos (ver [playsIn]).
  final List<PlayerEnrollment> enrollments;

  /// O doc tem o campo `inscricoes` (mesmo vazio): vale só o que está nele.
  /// Sem o campo = atleta antigo, que conta em toda competição do time.
  final bool hasEnrollmentField;

  /// Atleta antigo: sem o campo `inscricoes`.
  bool get isLegacy => !hasEnrollmentField && enrollments.isEmpty;

  const PlayerDTO({
    this.id = '',
    required this.name,
    required this.team,
    this.teamId = '',
    this.imageUrl = '',
    this.goals = 0,
    this.assists = 0,
    this.userId = '',
    this.position = '',
    this.enrollments = const [],
    this.hasEnrollmentField = false,
  });

  factory PlayerDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return PlayerDTO(
      // O id do documento é a fonte da verdade: é nele que as edições gravam.
      id: doc.id,
      name: data['nome']?.toString() ?? '',
      team: data['time']?.toString() ?? '',
      teamId: data['idTime']?.toString() ?? '',
      imageUrl: data['urlImagem']?.toString() ?? '',
      goals: (data[goalsField] as num?)?.toInt() ?? 0,
      assists: (data[assistsField] as num?)?.toInt() ?? 0,
      userId: data['idUsuario']?.toString() ?? '',
      position: data['posicao']?.toString() ?? '',
      enrollments: PlayerEnrollment.listFrom(data[PlayerEnrollment.field]),
      hasEnrollmentField: data.containsKey(PlayerEnrollment.field),
    );
  }

  /// Cache local (ver `CacheStore`).
  factory PlayerDTO.fromCache(Map<String, dynamic> json) {
    return PlayerDTO(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      team: json['team']?.toString() ?? '',
      teamId: json['teamId']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      userId: json['userId']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      enrollments: PlayerEnrollment.listFrom(json['enrollments']),
      hasEnrollmentField: json.containsKey('enrollments'),
    );
  }

  Map<String, dynamic> toCache() => {
        'id': id,
        'name': name,
        'team': team,
        'teamId': teamId,
        'imageUrl': imageUrl,
        'goals': goals,
        'assists': assists,
        'userId': userId,
        'position': position,
        if (!isLegacy) 'enrollments': PlayerEnrollment.mapOf(enrollments),
      };

  Map<String, dynamic> toMap() => {
        'idJogador': id,
        'nome': name,
        'time': team,
        'idTime': teamId,
        'urlImagem': imageUrl,
        goalsField: goals,
        assistsField: assists,
        // Opcionais: só gravados quando existem (jogadores antigos não têm).
        if (userId.isNotEmpty) 'idUsuario': userId,
        if (position.isNotEmpty) 'posicao': position,
        if (!isLegacy) PlayerEnrollment.field: PlayerEnrollment.mapOf(enrollments),
        if (!isLegacy) teamIdsField: teamIds,
      };

  /// Valor do quesito [field] ([goalsField] ou [assistsField]).
  int statOf(String field) => field == goalsField ? goals : assists;

  /// Valor do quesito na competição [championshipId] (nulo = total).
  int statIn(String field, int? championshipId) {
    if (championshipId == null) return statOf(field);
    final enrollment = enrollmentIn(championshipId);
    if (enrollment == null) return 0;
    return field == goalsField ? enrollment.goals : enrollment.assists;
  }

  /// Ids dos times em que o atleta joga: o principal e os das inscrições.
  List<String> get teamIds => {
        if (teamId.isNotEmpty) teamId,
        for (final e in enrollments)
          if (e.teamId.isNotEmpty) e.teamId,
      }.toList();

  /// Times em que o atleta joga, sem repetir (para "Jogador do A e do B").
  List<String> get teamNames {
    final names = <String>[];
    void add(String name) {
      if (name.trim().isNotEmpty && !names.any((n) => sameTeam(nameA: n, nameB: name))) names.add(name);
    }

    add(team);
    for (final e in enrollments) {
      add(e.team);
    }
    return names;
  }

  PlayerEnrollment? enrollmentIn(int championshipId) {
    for (final e in enrollments) {
      if (e.championshipId == championshipId) return e;
    }
    return null;
  }

  /// É do time (elenco geral)? Pelo time principal ou por alguma inscrição;
  /// sem competição nenhuma, o principal continua valendo.
  bool playsFor({String teamId = '', String teamName = ''}) {
    bool same(String id, String name) => sameTeam(idA: id, nameA: name, idB: teamId, nameB: teamName);
    return same(this.teamId, team) || enrollments.any((e) => same(e.teamId, e.team));
  }

  /// Joga pelo time na competição [championshipId]? Atleta antigo (sem o
  /// campo `inscricoes`) conta como inscrito em toda competição do principal.
  bool playsIn(int championshipId, {String teamId = '', String teamName = ''}) {
    if (isLegacy) return playsFor(teamId: teamId, teamName: teamName);
    final enrollment = enrollmentIn(championshipId);
    return enrollment != null && sameTeam(idA: enrollment.teamId, nameA: enrollment.team, idB: teamId, nameB: teamName);
  }

  PlayerDTO copyWith({
    String? id,
    String? name,
    String? team,
    String? teamId,
    String? imageUrl,
    int? goals,
    int? assists,
    String? userId,
    String? position,
    List<PlayerEnrollment>? enrollments,
    bool? hasEnrollmentField,
  }) {
    return PlayerDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      team: team ?? this.team,
      teamId: teamId ?? this.teamId,
      imageUrl: imageUrl ?? this.imageUrl,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      userId: userId ?? this.userId,
      position: position ?? this.position,
      enrollments: enrollments ?? this.enrollments,
      hasEnrollmentField: hasEnrollmentField ?? (enrollments != null || this.hasEnrollmentField),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, team, teamId, imageUrl, goals, assists, userId, position, enrollments, isLegacy];
}
