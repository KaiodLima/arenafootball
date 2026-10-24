import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

/// Documento das coleções `jogadores` / `jogadores{ano}`.
///
/// O atleta pode jogar por times diferentes em competições diferentes:
/// [enrollments] (`inscricoes`) diz o time e os números em cada competição.
/// [team]/[teamId] é o time principal (o que os apps antigos e o ranking geral
/// usam) e [goals]/[assists] o Geral da temporada: a soma das competições.
/// Gols e assistências em amistosos (partida sem competição) ficam à parte,
/// em [friendlyGoals]/[friendlyAssists], e não entram no Geral.
class PlayerDTO extends Equatable {
  /// Campos de gols/assistências no Firestore (ranking ordena por eles).
  static const String goalsField = 'nGols';
  static const String assistsField = 'nAssistencias';

  /// Números em amistosos (contagem à parte).
  static const String friendlyGoalsField = 'nGolsAmistoso';
  static const String friendlyAssistsField = 'nAssistenciasAmistoso';

  /// "Competição" dos amistosos em [statIn] (chip "Amistosos").
  static const int friendlyId = -1;

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

  /// Geral da temporada: nunca menor que a soma das competições (o gravado
  /// pode ter ficado abaixo por ajuste antigo só no total; ver [repairedTotals]).
  /// Atleta antigo (sem inscrições): o número gravado, o único que existe.
  final int goals;
  final int assists;

  /// Em amistosos (não entram no Geral nem em competição nenhuma).
  final int friendlyGoals;
  final int friendlyAssists;

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
    this.friendlyGoals = 0,
    this.friendlyAssists = 0,
    this.userId = '',
    this.position = '',
    this.enrollments = const [],
    this.hasEnrollmentField = false,
  });

  static int _number(Object? value) => (value as num?)?.toInt() ?? 0;

  /// Geral lido: o gravado, mas nunca abaixo da soma das competições.
  static int _total(int stored, List<PlayerEnrollment> enrollments, int Function(PlayerEnrollment) of) {
    final sum = enrollments.fold(0, (total, e) => total + of(e));
    return stored > sum ? stored : sum;
  }

  factory PlayerDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final enrollments = PlayerEnrollment.listFrom(data[PlayerEnrollment.field]);
    return PlayerDTO(
      // O id do documento é a fonte da verdade: é nele que as edições gravam.
      id: doc.id,
      name: data['nome']?.toString() ?? '',
      team: data['time']?.toString() ?? '',
      teamId: data['idTime']?.toString() ?? '',
      imageUrl: data['urlImagem']?.toString() ?? '',
      goals: _total(_number(data[goalsField]), enrollments, (e) => e.goals),
      assists: _total(_number(data[assistsField]), enrollments, (e) => e.assists),
      friendlyGoals: _number(data[friendlyGoalsField]),
      friendlyAssists: _number(data[friendlyAssistsField]),
      userId: data['idUsuario']?.toString() ?? '',
      position: data['posicao']?.toString() ?? '',
      enrollments: enrollments,
      hasEnrollmentField: data.containsKey(PlayerEnrollment.field),
    );
  }

  /// Cache local (ver `CacheStore`).
  factory PlayerDTO.fromCache(Map<String, dynamic> json) {
    final enrollments = PlayerEnrollment.listFrom(json['enrollments']);
    return PlayerDTO(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      team: json['team']?.toString() ?? '',
      teamId: json['teamId']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      goals: _total(_number(json['goals']), enrollments, (e) => e.goals),
      assists: _total(_number(json['assists']), enrollments, (e) => e.assists),
      friendlyGoals: _number(json['friendlyGoals']),
      friendlyAssists: _number(json['friendlyAssists']),
      userId: json['userId']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      enrollments: enrollments,
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
        'friendlyGoals': friendlyGoals,
        'friendlyAssists': friendlyAssists,
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
        friendlyGoalsField: friendlyGoals,
        friendlyAssistsField: friendlyAssists,
        // Opcionais: só gravados quando existem (jogadores antigos não têm).
        if (userId.isNotEmpty) 'idUsuario': userId,
        if (position.isNotEmpty) 'posicao': position,
        if (!isLegacy) PlayerEnrollment.field: PlayerEnrollment.mapOf(enrollments),
        if (!isLegacy) teamIdsField: teamIds,
      };

  /// Valor do quesito [field] ([goalsField] ou [assistsField]).
  int statOf(String field) => field == goalsField ? goals : assists;

  /// Valor do quesito na competição [championshipId] (nulo = Geral;
  /// [friendlyId] = amistosos).
  int statIn(String field, int? championshipId) {
    if (championshipId == null) return statOf(field);
    if (championshipId == friendlyId) return field == goalsField ? friendlyGoals : friendlyAssists;
    final enrollment = enrollmentIn(championshipId);
    if (enrollment == null) return 0;
    return field == goalsField ? enrollment.goals : enrollment.assists;
  }

  /// Correção dos números gravados (manutenção do admin): o Geral volta a
  /// ser a soma das competições, tirando os amistosos que entraram nele antes
  /// da contagem à parte (sem nunca ficar abaixo da soma), e os amistosos
  /// passam a ser [friendlyGoals]/[friendlyAssists] contados nas partidas.
  /// Campos a gravar; nulo se já está certo. Atleta antigo: só os amistosos.
  Map<String, int>? repairedTotals(
      {required int stored, required int storedAssists, int friendlyGoals = 0, int friendlyAssists = 0}) {
    int fixed(int value, int friendly, int sum) {
      final withoutFriendly = value - friendly;
      return withoutFriendly > sum ? withoutFriendly : sum;
    }

    final goalsSum = enrollments.fold(0, (total, e) => total + e.goals);
    final assistsSum = enrollments.fold(0, (total, e) => total + e.assists);
    final changes = <String, int>{
      if (!isLegacy && fixed(stored, friendlyGoals, goalsSum) != stored)
        goalsField: fixed(stored, friendlyGoals, goalsSum),
      if (!isLegacy && fixed(storedAssists, friendlyAssists, assistsSum) != storedAssists)
        assistsField: fixed(storedAssists, friendlyAssists, assistsSum),
      if (friendlyGoals != this.friendlyGoals) friendlyGoalsField: friendlyGoals,
      if (friendlyAssists != this.friendlyAssists) friendlyAssistsField: friendlyAssists,
    };
    return changes.isEmpty ? null : changes;
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
    int? friendlyGoals,
    int? friendlyAssists,
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
      friendlyGoals: friendlyGoals ?? this.friendlyGoals,
      friendlyAssists: friendlyAssists ?? this.friendlyAssists,
      userId: userId ?? this.userId,
      position: position ?? this.position,
      enrollments: enrollments ?? this.enrollments,
      hasEnrollmentField: hasEnrollmentField ?? (enrollments != null || this.hasEnrollmentField),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        team,
        teamId,
        imageUrl,
        goals,
        assists,
        friendlyGoals,
        friendlyAssists,
        userId,
        position,
        enrollments,
        isLegacy
      ];
}
