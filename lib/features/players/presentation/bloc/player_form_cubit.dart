import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Cadastro de jogador (admin). O elenco atual do time escolhido alimenta a
/// lista da tela e o aviso de nome duplicado.
class PlayerFormCubit extends Cubit<PlayerFormState> {
  final CreatePlayerUseCase createPlayerUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;

  PlayerFormCubit(
    this.createPlayerUseCase,
    this.getRegionsUseCase,
    this.getTeamsCacheFirstUseCase,
    this.watchTeamPlayersUseCase,
  ) : super(const EditingPlayerFormState());

  void _edit(PlayerFormData form) {
    if (!isClosed) emit(EditingPlayerFormState(form: form));
  }

  Future<void> load({required String initialRegion}) async {
    _edit(PlayerFormData(regions: [initialRegion], selectedRegion: initialRegion));
    final loadTeams = _loadTeams(initialRegion);

    final response = await getRegionsUseCase();
    if (isClosed) return;
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isNotEmpty) {
      final current = state.form.selectedRegion ?? initialRegion;
      _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
    }
    await loadTeams;
  }

  /// Times da região na temporada corrente (coleção `times` sem sufixo),
  /// onde o jogador novo é gravado; já carrega o elenco do primeiro.
  Future<void> _loadTeams(String region) async {
    // Cache-first: fica com a última emissão (o remoto quando revalidou).
    final response = await getTeamsCacheFirstUseCase(region: region).last;
    if (isClosed || state.form.selectedRegion != region) return;
    if (response.isLeft) {
      emit(ErrorPlayerFormState(form: state.form.withTeams(const []), errorMessage: response.left.toString()));
      return;
    }
    _edit(state.form.withTeams(response.right));
    await _loadSquad();
  }

  /// Elenco do time escolhido. Falhar só esconde a lista e o aviso.
  Future<void> _loadSquad() async {
    final team = state.form.selectedTeam;
    _edit(state.form.copyWith(squad: const []));
    if (team == null) return;
    final response = await watchTeamPlayersUseCase(teamId: state.form.selectedTeamId, teamName: team).first;
    if (isClosed || state.form.selectedTeam != team) return;
    _edit(state.form.copyWith(squad: response.fold((_) => const <PlayerDTO>[], (list) => list)));
  }

  Future<void> selectRegion(String region) async {
    if (region == state.form.selectedRegion) return;
    _edit(state.form.copyWith(selectedRegion: region, squad: const []).withTeams(const []));
    await _loadTeams(region);
  }

  Future<void> selectTeam(String team) async {
    if (team == state.form.selectedTeam) return;
    _edit(state.form.copyWith(selectedTeam: team));
    await _loadSquad();
  }

  void changeName(String value) => _edit(state.form.copyWith(name: value));

  void incrementGoals() => _setCounts(goals: state.form.goals + 1);

  void decrementGoals() => _setCounts(goals: state.form.goals - 1);

  void incrementAssists() => _setCounts(assists: state.form.assists + 1);

  void decrementAssists() => _setCounts(assists: state.form.assists - 1);

  void _setCounts({int? goals, int? assists}) => _edit(state.form.copyWith(
        goals: goals?.clamp(0, PlayerFormData.maxCount),
        assists: assists?.clamp(0, PlayerFormData.maxCount),
      ));

  void setPhoto(File file) => _edit(state.form.copyWith(photo: file));

  void clearPhoto() => _edit(state.form.copyWith(clearPhoto: true));

  Future<void> submit() async {
    final form = state.form;
    if (form.error != null || state is SubmittingPlayerFormState) return;
    emit(SubmittingPlayerFormState(form: form));

    final response = await createPlayerUseCase(form.toPlayer(), photo: form.photo);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerFormState(form: form, errorMessage: failure.toString())),
      // Como no app antigo, continua na tela para cadastrar o próximo; o
      // jogador novo entra no elenco mostrado.
      (created) => emit(SuccessPlayerFormState(form: form.cleared().copyWith(squad: [...form.squad, created]))),
    );
  }
}
