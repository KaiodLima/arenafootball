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

  const PlayerDTO({
    this.id = '',
    required this.name,
    required this.team,
    this.imageUrl = '',
    this.goals = 0,
    this.assists = 0,
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
    );
  }

  Map<String, dynamic> toMap() => {
        'idJogador': id,
        'nome': name,
        'time': team,
        'urlImagem': imageUrl,
        'nGols': goals,
        'nAssistencias': assists,
      };

  PlayerDTO copyWith({String? id, String? name, String? team, String? imageUrl, int? goals, int? assists}) {
    return PlayerDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      team: team ?? this.team,
      imageUrl: imageUrl ?? this.imageUrl,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
    );
  }

  @override
  List<Object?> get props => [id, name, team, imageUrl, goals, assists];
}
