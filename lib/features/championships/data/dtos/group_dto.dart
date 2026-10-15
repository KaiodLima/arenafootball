import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';

/// Documento das coleções `grupos` / `grupos{ano}`. Cada grupo tem até quatro
/// times, gravados como `time1`..`time4` (nomes, cópia para exibir) e
/// `idTime1`..`idTime4` (ids; vazios em grupos antigos, quando vale o nome).
class GroupDTO extends Equatable {
  final String id;

  /// Nome do grupo ("A", "B"...). É o valor de `fk_grupo` na classificação.
  final String description;
  final String region;
  final List<String> teams;

  /// Ids dos times, na mesma ordem de [teams] ('' = sem id).
  final List<String> teamIds;

  /// `fk_campeonato` (`id_campeonato`); 0 = grupo antigo, sem campeonato.
  final int championshipId;

  static const int maxTeams = 4;

  const GroupDTO({
    required this.id,
    required this.description,
    this.region = '',
    this.teams = const [],
    this.teamIds = const [],
    this.championshipId = 0,
  });

  /// Id do time na posição [index] ('' se não houver).
  String teamIdAt(int index) => index < teamIds.length ? teamIds[index] : '';

  /// Grupos do campeonato [id]: os marcados com ele; se nenhum estiver
  /// marcado, os antigos (sem campeonato). [id] nulo = todos.
  static List<GroupDTO> forChampionship(List<GroupDTO> groups, int? id) {
    if (id == null) return groups;
    final tagged = groups.where((g) => g.championshipId == id).toList();
    return tagged.isNotEmpty ? tagged : groups.where((g) => g.championshipId == 0).toList();
  }

  factory GroupDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return GroupDTO(
      id: doc.id,
      description: data['descricao']?.toString() ?? '',
      region: RegionRegistry.nameFromDoc(data),
      championshipId: (data['fk_campeonato'] as num?)?.toInt() ?? 0,
      teams: [
        for (var i = 1; i <= maxTeams; i++) data['time$i']?.toString() ?? '',
      ],
      teamIds: [
        for (var i = 1; i <= maxTeams; i++) data['idTime$i']?.toString() ?? '',
      ],
    );
  }

  Map<String, dynamic> toMap() => {
        'descricao': description,
        ...RegionRegistry.fieldsFor(region),
        if (championshipId > 0) 'fk_campeonato': championshipId,
        for (var i = 0; i < maxTeams; i++) 'time${i + 1}': i < teams.length ? teams[i] : '',
        for (var i = 0; i < maxTeams; i++) 'idTime${i + 1}': teamIdAt(i),
      };

  GroupDTO copyWith({String? id, String? description, String? region, List<String>? teams, List<String>? teamIds}) {
    return GroupDTO(
      id: id ?? this.id,
      description: description ?? this.description,
      region: region ?? this.region,
      teams: teams ?? this.teams,
      teamIds: teamIds ?? this.teamIds,
      championshipId: championshipId,
    );
  }

  @override
  List<Object?> get props => [id, description, region, teams, teamIds, championshipId];
}
