import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Vínculo com time: o **id** do time (doc de `times{ano}`) é a chave; o nome
/// gravado ao lado é só cópia para exibir. Docs antigos (antes da migração
/// "Vincular times por id") só têm o nome: aí a comparação cai no nome.

/// Nome normalizado (sem espaços nas pontas, minúsculo): chave de fallback.
String normalizeTeamName(String name) => name.trim().toLowerCase();

/// Mesmo time? Pelo id quando os dois lados têm id; senão, pelo nome.
bool sameTeam({String idA = '', String nameA = '', String idB = '', String nameB = ''}) {
  if (idA.isNotEmpty && idB.isNotEmpty) return idA == idB;
  final a = normalizeTeamName(nameA);
  return a.isNotEmpty && a == normalizeTeamName(nameB);
}

/// Times de uma temporada indexados por id e por nome, para resolver vínculos
/// (id quando houver, nome nos docs antigos).
class TeamDirectory {
  final Map<String, TeamDTO> _byId;
  final Map<String, TeamDTO> _byName;

  /// Nomes (normalizados) que aparecem em mais de um time: não dá para
  /// resolver só pelo nome.
  final Set<String> ambiguousNames;

  TeamDirectory._(this._byId, this._byName, this.ambiguousNames);

  factory TeamDirectory(Iterable<TeamDTO> teams) {
    final byId = <String, TeamDTO>{};
    final byName = <String, TeamDTO>{};
    final ambiguous = <String>{};
    for (final team in teams) {
      if (team.id.isNotEmpty) byId[team.id] = team;
      final key = normalizeTeamName(team.name);
      if (key.isEmpty) continue;
      final other = byName[key];
      if (other != null && other.id != team.id) {
        ambiguous.add(key);
      } else {
        byName[key] = team;
      }
    }
    for (final key in ambiguous) {
      byName.remove(key);
    }
    return TeamDirectory._(byId, byName, ambiguous);
  }

  static final empty = TeamDirectory(const []);

  Iterable<TeamDTO> get teams => _byId.values;

  TeamDTO? byId(String id) => id.isEmpty ? null : _byId[id];

  /// Pelo nome (nulo se não existir ou se for ambíguo).
  TeamDTO? byName(String name) => _byName[normalizeTeamName(name)];

  /// Pelo id; sem id (doc antigo) ou id que não está na lista, pelo nome.
  TeamDTO? resolve({String id = '', String name = ''}) => byId(id) ?? byName(name);

  /// Id do time: o informado ou, sem ele, o do time com esse nome ('' se não achar).
  String idOf({String id = '', String name = ''}) => id.isNotEmpty ? id : (byName(name)?.id ?? '');
}
