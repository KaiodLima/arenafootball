import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Times participantes do campeonato, na ordem cadastrada, com os dados da
/// coleção de times (escudo e link para o elenco). Time não encontrado (ex.:
/// renomeado) aparece só com o nome.
class ChampionshipDetailsCubit extends Cubit<List<TeamDTO>> {
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;

  ChampionshipDetailsCubit(this.getTeamsCacheFirstUseCase) : super(const []);

  Future<void> load(ChampionshipDTO championship) async {
    if (championship.teams.isEmpty) return;
    final fallback = [for (final name in championship.teams) TeamDTO(id: '', name: name)];
    emit(fallback);
    final season = championship.season.isEmpty ? null : championship.season;
    await for (final response in getTeamsCacheFirstUseCase(region: championship.region, season: season)) {
      if (isClosed) return;
      response.fold((_) => null, (teams) {
        // Pelo id quando o campeonato já tem ids; senão, pelo nome.
        final directory = TeamDirectory(teams);
        emit([
          for (var i = 0; i < fallback.length; i++)
            directory.resolve(
                  id: i < championship.teamIds.length ? championship.teamIds[i] : '',
                  name: fallback[i].name,
                ) ??
                fallback[i],
        ]);
      });
    }
  }
}
