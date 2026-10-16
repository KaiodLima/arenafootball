import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Documento das coleções `jogadores` / `jogadores{ano}`.
class PlayerDTO extends Equatable {
  /// Campos de gols/assistências no Firestore (ranking ordena por eles).
  static const String goalsField = 'nGols';
  static const String assistsField = 'nAssistencias';

  final String id;
  final String name;

  /// Nome do time (cópia para exibir; o vínculo é [teamId]).
  final String team;

  /// `idTime`: id do time (doc de `times{ano}`). Vazio em jogadores antigos
  /// (antes da migração) e em quem está sem time: aí vale o nome.
  final String teamId;
  final String imageUrl;
  final int goals;
  final int assists;

  /// Conta vinculada (jogador aprovado pelo "Sou jogador"); vazio nos demais.
  final String userId;

  /// Chave de `PlayerPosition` (goleiro, zagueiro...); vazio se não informada.
  final String position;

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
      };

  /// Valor do quesito [field] ([goalsField] ou [assistsField]).
  int statOf(String field) => field == goalsField ? goals : assists;

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
    );
  }

  @override
  List<Object?> get props => [id, name, team, teamId, imageUrl, goals, assists, userId, position];
}
