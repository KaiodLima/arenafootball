import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Times participantes do campeonato, na ordem cadastrada, com os dados da
/// coleção de times (escudo e link para o elenco). Time não encontrado (ex.:
/// renomeado) aparece só com o nome.
class ChampionshipDetailsCubit extends Cubit<List<TeamDTO>> {
  final GetTeamsUseCase getTeamsUseCase;

  ChampionshipDetailsCubit(this.getTeamsUseCase) : super(const []);

  Future<void> load(ChampionshipDTO championship) async {
    if (championship.teams.isEmpty) return;
    final fallback = [for (final name in championship.teams) TeamDTO(id: '', name: name)];
    emit(fallback);
    final season = championship.season.isEmpty ? null : championship.season;
    final response = await getTeamsUseCase(region: championship.region, season: season);
    if (isClosed) return;
    response.fold((_) => null, (teams) {
      final byName = {for (final team in teams) team.name: team};
      emit([for (final team in fallback) byName[team.name] ?? team]);
    });
  }
}
