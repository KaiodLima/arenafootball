import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Voto em `melhorjogador{timeC}{timeF}`: um documento por votante, com o id
/// do documento = uid de quem votou (votar de novo sobrescreve o voto).
class VoteDTO extends Equatable {
  final String voterId;
  final String playerName;

  /// Nome do time do jogador votado.
  final String team;

  const VoteDTO({required this.voterId, required this.playerName, required this.team});

  factory VoteDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return VoteDTO(
      voterId: doc.id,
      playerName: data['nome']?.toString() ?? '',
      team: data['time']?.toString() ?? '',
    );
  }

  /// O id do votante é o id do documento; não vai nos campos.
  Map<String, dynamic> toMap() => {'nome': playerName, 'time': team};

  VoteDTO copyWith({String? voterId, String? playerName, String? team}) {
    return VoteDTO(
      voterId: voterId ?? this.voterId,
      playerName: playerName ?? this.playerName,
      team: team ?? this.team,
    );
  }

  @override
  List<Object?> get props => [voterId, playerName, team];
}
