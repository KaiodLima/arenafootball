import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Documento das coleções `grupos` / `grupos{ano}`. Cada grupo tem até quatro
/// times, gravados como `time1`..`time4` (nomes dos times).
class GroupDTO extends Equatable {
  final String id;

  /// Nome do grupo ("A", "B"...). É o valor de `fk_grupo` na classificação.
  final String description;
  final String region;
  final List<String> teams;

  static const int maxTeams = 4;

  const GroupDTO({
    required this.id,
    required this.description,
    this.region = '',
    this.teams = const [],
  });

  factory GroupDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return GroupDTO(
      id: doc.id,
      description: data['descricao']?.toString() ?? '',
      region: data['fk_competicao']?.toString() ?? '',
      teams: [
        for (var i = 1; i <= maxTeams; i++) data['time$i']?.toString() ?? '',
      ],
    );
  }

  Map<String, dynamic> toMap() => {
        'descricao': description,
        'fk_competicao': region,
        for (var i = 0; i < maxTeams; i++) 'time${i + 1}': i < teams.length ? teams[i] : '',
      };

  GroupDTO copyWith({String? id, String? description, String? region, List<String>? teams}) {
    return GroupDTO(
      id: id ?? this.id,
      description: description ?? this.description,
      region: region ?? this.region,
      teams: teams ?? this.teams,
    );
  }

  @override
  List<Object?> get props => [id, description, region, teams];
}
