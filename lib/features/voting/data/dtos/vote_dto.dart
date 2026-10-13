import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Voto em `partidas{ano}/{idPartida}/votos` (antes: `melhorjogador{timeC}{timeF}`,
/// ainda lido como fallback): um documento por votante, com o id do documento
/// = uid de quem votou (votar de novo sobrescreve o voto).
class VoteDTO extends Equatable {
  final String voterId;
  final String playerName;

  /// Nome do time do jogador votado (cópia para exibir).
  final String team;

  /// `idTime`: id do time do jogador votado; vazio em votos antigos.
  final String teamId;

  const VoteDTO({required this.voterId, required this.playerName, required this.team, this.teamId = ''});

  factory VoteDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return VoteDTO(
      voterId: doc.id,
      playerName: data['nome']?.toString() ?? '',
      team: data['time']?.toString() ?? '',
      teamId: data['idTime']?.toString() ?? '',
    );
  }

  /// O id do votante é o id do documento; não vai nos campos.
  Map<String, dynamic> toMap() => {'nome': playerName, 'time': team, 'idTime': teamId};

  VoteDTO copyWith({String? voterId, String? playerName, String? team, String? teamId}) {
    return VoteDTO(
      voterId: voterId ?? this.voterId,
      playerName: playerName ?? this.playerName,
      team: team ?? this.team,
      teamId: teamId ?? this.teamId,
    );
  }

  @override
  List<Object?> get props => [voterId, playerName, team, teamId];
}
