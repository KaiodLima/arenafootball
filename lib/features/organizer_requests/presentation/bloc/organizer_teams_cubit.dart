import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/domain/usecases/set_team_championships_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_by_ids_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Times de cada campeonato do organizador (aba Times do modo organizador).
class OrganizerTeamsState extends Equatable {
  final bool loading;
  final bool error;

  /// Por campeonato (doc id), os participantes na ordem cadastrada.
  final Map<String, List<TeamDTO>> teamsByChampionship;

  const OrganizerTeamsState({this.loading = true, this.error = false, this.teamsByChampionship = const {}});

  @override
  List<Object?> get props => [loading, error, teamsByChampionship];
}

/// Uma leitura por temporada com todos os ids (e nomes dos sem id) dos
/// campeonatos dela; cada campeonato resolve os seus pelo [TeamDirectory].
/// Time não encontrado aparece só com o nome.
class OrganizerTeamsCubit extends Cubit<OrganizerTeamsState> {
  final GetTeamsByIdsUseCase getTeamsByIdsUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final SetTeamChampionshipsUseCase setTeamChampionshipsUseCase;

  OrganizerTeamsCubit(this.getTeamsByIdsUseCase, this.getTeamsCacheFirstUseCase, this.setTeamChampionshipsUseCase)
      : super(const OrganizerTeamsState());

  /// Times que podem entrar no [championship]: os da sede (municipal) ou de
  /// todas as regiões (intermunicipal), da temporada dele, menos os inscritos.
  Future<Either<Failure, List<TeamDTO>>> candidates(ChampionshipDTO championship) async {
    final municipal = championship.scope != ChampionshipScope.intermunicipal;
    final response = await getTeamsCacheFirstUseCase(
      region: municipal ? championship.region : null,
      season: championship.season.isEmpty ? null : championship.season,
    ).last;
    return response.map((teams) => [
          for (final team in teams)
            if (!championship.hasTeam(id: team.id, name: team.name)) team,
        ]);
  }

  /// Inscreve ([enrolled]) ou tira o [team] do [championship]. A lista volta
  /// atualizada pelo campeonato ao vivo (a aba recarrega).
  Future<Either<Failure, void>> setEnrollment(ChampionshipDTO championship, TeamDTO team, {required bool enrolled}) =>
      setTeamChampionshipsUseCase(
        team: team,
        championships: [championship],
        selected: {if (enrolled) championship.championshipId},
      );

  Future<void> load(List<ChampionshipDTO> championships) async {
    // Recarga (time inscrito/tirado): mantém a lista na tela até chegar a nova.
    if (state.teamsByChampionship.isEmpty) emit(const OrganizerTeamsState());
    final bySeason = <String, List<ChampionshipDTO>>{};
    for (final c in championships) {
      bySeason.putIfAbsent(c.season, () => []).add(c);
    }
    final result = <String, List<TeamDTO>>{};
    // Erro só quando nenhuma leitura deu certo (o resto mostra os nomes).
    var anyOk = championships.isEmpty;
    for (final entry in bySeason.entries) {
      final ids = <String>[];
      final names = <String>[];
      for (final c in entry.value) {
        for (var i = 0; i < c.teams.length; i++) {
          final id = i < c.teamIds.length ? c.teamIds[i] : '';
          id.isNotEmpty ? ids.add(id) : names.add(c.teams[i]);
        }
      }
      final response = await getTeamsByIdsUseCase(
        ids: ids,
        names: names,
        season: entry.key.isEmpty ? null : entry.key,
      );
      if (isClosed) return;
      final directory = TeamDirectory(response.isRight ? response.right : const <TeamDTO>[]);
      anyOk = anyOk || response.isRight;
      for (final c in entry.value) {
        result[c.id] = participantsOf(c, directory);
      }
    }
    emit(OrganizerTeamsState(loading: false, error: !anyOk, teamsByChampionship: result));
  }
}

/// Participantes de [championship] na ordem cadastrada: pelo id, senão pelo nome.
List<TeamDTO> participantsOf(ChampionshipDTO championship, TeamDirectory directory) => [
      for (var i = 0; i < championship.teams.length; i++)
        directory.resolve(
              id: i < championship.teamIds.length ? championship.teamIds[i] : '',
              name: championship.teams[i],
            ) ??
            TeamDTO(id: '', name: championship.teams[i]),
    ];
