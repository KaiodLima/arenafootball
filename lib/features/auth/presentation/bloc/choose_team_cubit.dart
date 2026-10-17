import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_favorite_team_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/choose_team_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_cache_first_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Etapa 2 do cadastro. Roda já com o usuário logado: só assim o Firestore
/// libera a leitura de `competicao` e `times`. Regiões e times vêm do cache
/// local quando houver (ver `cacheFirst`).
class ChooseTeamCubit extends Cubit<ChooseTeamState> {
  final GetRegionsCacheFirstUseCase getRegionsCacheFirstUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final UpdateFavoriteTeamUseCase updateFavoriteTeamUseCase;

  ChooseTeamCubit(
    this.getRegionsCacheFirstUseCase,
    this.getTeamsCacheFirstUseCase,
    this.updateFavoriteTeamUseCase,
  ) : super(const LoadingChooseTeamState());

  Future<void> load({required String initialRegion, bool force = false}) async {
    emit(const LoadingChooseTeamState());
    await for (final response in getRegionsCacheFirstUseCase(force: force)) {
      if (isClosed) return;
      // `Left` só vem sem cache: com o cache em tela, a falha é ignorada.
      if (response.isLeft) {
        emit(LoadErrorChooseTeamState(errorMessage: response.left.toString()));
        return;
      }
      final regions = response.right.map((region) => region.name).toList();
      if (regions.isEmpty) {
        emit(const LoadErrorChooseTeamState(errorMessage: ''));
        return;
      }
      if (listEquals(regions, state.regions)) continue;
      final selected = state.selectedRegion;
      // Lista atualizada depois do cache: mantém a região e o time escolhidos.
      if (selected != null && regions.contains(selected) && state is ReadyChooseTeamState) {
        emit(ReadyChooseTeamState(
          regions: regions,
          selectedRegion: selected,
          teams: state.teams,
          selectedTeam: state.selectedTeam,
          selectedTeamId: state.selectedTeamId,
          loadingTeams: state.loadingTeams,
        ));
        continue;
      }
      final region = regions.contains(initialRegion) ? initialRegion : regions.first;
      // Sem esperar: os times da região chegam enquanto o remoto das regiões
      // (cache vencido) ainda está a caminho.
      unawaited(_loadTeams(regions, region, force: force));
    }
  }

  /// Tenta de novo a partir do que já foi carregado (ignora a validade).
  Future<void> retry({required String initialRegion}) async {
    if (state.regions.isEmpty) return load(initialRegion: initialRegion, force: true);
    await _loadTeams(state.regions, state.selectedRegion ?? state.regions.first, force: true);
  }

  Future<void> selectRegion(String region) async {
    if (region == state.selectedRegion) return;
    await _loadTeams(state.regions, region);
  }

  Future<void> _loadTeams(List<String> regions, String region, {bool force = false}) async {
    emit(ReadyChooseTeamState(regions: regions, selectedRegion: region, loadingTeams: true));
    await for (final response in getTeamsCacheFirstUseCase(region: region, force: force)) {
      // Só aplica se o usuário não trocou de região enquanto carregava.
      if (isClosed || state.selectedRegion != region || state is SavingChooseTeamState) return;
      response.fold(
        (failure) => emit(
          LoadErrorChooseTeamState(errorMessage: failure.toString(), regions: state.regions, selectedRegion: region),
        ),
        (teams) {
          // Times atualizados depois do cache: mantém o escolhido se ainda existe.
          final keep = state.selectedTeam != null && teams.any((team) => team.id == state.selectedTeamId);
          emit(ReadyChooseTeamState(
            regions: state.regions,
            selectedRegion: region,
            teams: teams,
            selectedTeam: keep ? state.selectedTeam : null,
            selectedTeamId: keep ? state.selectedTeamId : '',
          ));
        },
      );
    }
  }

  void selectTeam(TeamDTO team) {
    emit(
      ReadyChooseTeamState(
        regions: state.regions,
        selectedRegion: state.selectedRegion,
        teams: state.teams,
        selectedTeam: team.name,
        selectedTeamId: team.id,
      ),
    );
  }

  Future<void> save({required UserDTO user}) async {
    if (!state.canSave || state is SavingChooseTeamState) return;
    final current = state;
    emit(SavingChooseTeamState(current));
    final response = await updateFavoriteTeamUseCase(
      user: user,
      team: current.selectedTeam!,
      teamId: current.selectedTeamId,
    );
    response.fold(
      (failure) => emit(SaveErrorChooseTeamState(current, errorMessage: failure.toString(), failure: failure)),
      (changedAt) => emit(SavedChooseTeamState(
        region: current.selectedRegion!,
        team: current.selectedTeam!,
        teamId: current.selectedTeamId,
        changedAt: changedAt,
      )),
    );
  }
}
