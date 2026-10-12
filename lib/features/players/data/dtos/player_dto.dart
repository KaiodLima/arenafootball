import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Documento das coleções `jogadores` / `jogadores{ano}`.
class PlayerDTO extends Equatable {
  final String id;
  final String name;

  /// Nome do time (o vínculo com o time é pelo nome, não pelo id).
  final String team;
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
      imageUrl: data['urlImagem']?.toString() ?? '',
      goals: (data['nGols'] as num?)?.toInt() ?? 0,
      assists: (data['nAssistencias'] as num?)?.toInt() ?? 0,
      userId: data['idUsuario']?.toString() ?? '',
      position: data['posicao']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'idJogador': id,
        'nome': name,
        'time': team,
        'urlImagem': imageUrl,
        'nGols': goals,
        'nAssistencias': assists,
        // Opcionais: só gravados quando existem (jogadores antigos não têm).
        if (userId.isNotEmpty) 'idUsuario': userId,
        if (position.isNotEmpty) 'posicao': position,
      };

  PlayerDTO copyWith({
    String? id,
    String? name,
    String? team,
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
      imageUrl: imageUrl ?? this.imageUrl,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      userId: userId ?? this.userId,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [id, name, team, imageUrl, goals, assists, userId, position];
}
