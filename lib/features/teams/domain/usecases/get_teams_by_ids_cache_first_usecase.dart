import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_by_ids_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Times pelos ids (e pelos nomes, para os sem id) a partir dos times da
/// temporada (todas as regiões) do [GetTeamsCacheFirstUseCase]: com o cache
/// válido não lê; só os que faltarem nele vão ao Firestore pelo
/// [GetTeamsByIdsUseCase]. Falha na lista da temporada = lê todos pelo id.
class GetTeamsByIdsCacheFirstUseCase {
  final GetTeamsByIdsUseCase _getByIds;
  final GetTeamsCacheFirstUseCase _getSeasonTeams;

  GetTeamsByIdsCacheFirstUseCase(this._getByIds, this._getSeasonTeams);

  Future<Either<Failure, List<TeamDTO>>> call({
    required List<String> ids,
    List<String> names = const [],
    String? season,
  }) async {
    final wantedIds = ids.where((id) => id.isNotEmpty).toSet();
    final wantedNames = names.where((name) => name.isNotEmpty).toSet();
    if (wantedIds.isEmpty && wantedNames.isEmpty) return const Right([]);

    final seasonTeams = await _getSeasonTeams(season: season).last;
    final known = seasonTeams.fold((_) => const <TeamDTO>[], (teams) => teams);
    final found = <TeamDTO>[
      for (final team in known)
        if (wantedIds.contains(team.id) || wantedNames.contains(team.name)) team,
    ];
    final missingIds = wantedIds.difference({for (final team in found) team.id});
    final missingNames = wantedNames.difference({for (final team in found) team.name});
    if (missingIds.isEmpty && missingNames.isEmpty) return Right(found);

    final rest = await _getByIds(ids: missingIds.toList(), names: missingNames.toList(), season: season);
    if (rest.isLeft) return found.isEmpty ? rest : Right(found);
    return Right([...found, ...rest.right]);
  }
}
