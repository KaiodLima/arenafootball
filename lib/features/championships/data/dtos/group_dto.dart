import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_rules.dart';

/// Documento das coleções `grupos` / `grupos{ano}`. Os times vão nas listas
/// `times` (nomes, cópia para exibir) e `idsTimes` (ids; '' = sem id), de
/// qualquer tamanho (até [teamLimit]). Os 4 primeiros também vão em
/// `time1`..`time4` / `idTime1`..`idTime4` (o app antigo e os grupos antigos,
/// sem as listas, usam só esses).
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

  /// `idCampeonatoDoc`: id do doc do campeonato (grupos formados pelo app; as
  /// regras conferem por ele o organizador). Vazio nos grupos antigos.
  final String championshipDocId;

  /// Regras do grupo (`regras`; sem o campo, os padrões: 2 classificados).
  final GroupRules rules;

  static const String championshipDocField = 'idCampeonatoDoc';

  /// Campos fixos do formato antigo (`time1`..`time4`).
  static const int legacySlots = 4;

  /// Teto de segurança por grupo (as regras conferem o mesmo).
  static const int teamLimit = 20;

  const GroupDTO({
    required this.id,
    required this.description,
    this.region = '',
    this.teams = const [],
    this.teamIds = const [],
    this.championshipId = 0,
    this.championshipDocId = '',
    this.rules = GroupRules.standard,
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
      championshipDocId: data[championshipDocField]?.toString() ?? '',
      rules: GroupRules.fromMap(data['regras']),
      // Listas novas quando existem; senão, os campos antigos.
      teams: data['times'] is List
          ? [for (final t in data['times'] as List) t?.toString() ?? '']
          : [for (var i = 1; i <= legacySlots; i++) data['time$i']?.toString() ?? ''],
      teamIds: data['idsTimes'] is List
          ? [for (final t in data['idsTimes'] as List) t?.toString() ?? '']
          : [for (var i = 1; i <= legacySlots; i++) data['idTime$i']?.toString() ?? ''],
    );
  }

  Map<String, dynamic> toMap() => {
        'descricao': description,
        ...RegionRegistry.fieldsFor(region),
        if (championshipId > 0) 'fk_campeonato': championshipId,
        if (championshipDocId.isNotEmpty) championshipDocField: championshipDocId,
        'regras': rules.toMap(),
        'times': [for (var i = 0; i < teams.length; i++) teams[i]],
        'idsTimes': [for (var i = 0; i < teams.length; i++) teamIdAt(i)],
        for (var i = 0; i < legacySlots; i++) 'time${i + 1}': i < teams.length ? teams[i] : '',
        for (var i = 0; i < legacySlots; i++) 'idTime${i + 1}': teamIdAt(i),
      };

  GroupDTO copyWith({
    String? id,
    String? description,
    String? region,
    List<String>? teams,
    List<String>? teamIds,
    GroupRules? rules,
  }) {
    return GroupDTO(
      id: id ?? this.id,
      description: description ?? this.description,
      region: region ?? this.region,
      teams: teams ?? this.teams,
      teamIds: teamIds ?? this.teamIds,
      championshipId: championshipId,
      championshipDocId: championshipDocId,
      rules: rules ?? this.rules,
    );
  }

  @override
  List<Object?> get props => [id, description, region, teams, teamIds, championshipId, championshipDocId, rules];
}
