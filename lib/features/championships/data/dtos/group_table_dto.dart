import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/standings_criterion.dart';

/// Tabela de um grupo calculada pelas Cloud Functions (`tabelas{ano}/{idGrupo}`):
/// as linhas já em ordem e os critérios de desempate usados.
class GroupTableDTO extends Equatable {
  final String groupId;
  final int championshipId;
  final String group;
  final List<StandingsCriterion> criteria;
  final List<StandingDTO> rows;
  final DateTime? updatedAt;

  const GroupTableDTO({
    required this.groupId,
    this.championshipId = 0,
    this.group = '',
    this.criteria = const [],
    this.rows = const [],
    this.updatedAt,
  });

  static int _int(Object? value) => (value as num?)?.toInt() ?? 0;

  factory GroupTableDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final group = data['grupo']?.toString() ?? '';
    final rows = <StandingDTO>[];
    for (final item in (data['linhas'] as List?) ?? const []) {
      if (item is! Map) continue;
      final id = item['idTime']?.toString() ?? '';
      final name = item['nome']?.toString() ?? '';
      rows.add(StandingDTO(
        // Sem id (grupo antigo pelo nome): o nome identifica a linha.
        id: id.isNotEmpty ? id : name,
        teamName: name,
        group: group,
        wins: _int(item['vitorias']),
        draws: _int(item['empates']),
        losses: _int(item['derrotas']),
        goalsFor: _int(item['golsPro']),
        goalsAgainst: _int(item['golsContra']),
        points: _int(item['pontos']),
        storedGoalDifference: _int(item['saldo']),
      ));
    }
    final updatedAt = data['atualizadoEm'];
    return GroupTableDTO(
      groupId: doc.id,
      championshipId: _int(data['idCampeonato']),
      group: group,
      criteria: StandingsCriterion.fromKeys(data['criterios']),
      rows: rows,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }

  @override
  List<Object?> get props => [groupId, championshipId, group, criteria, rows, updatedAt];
}
