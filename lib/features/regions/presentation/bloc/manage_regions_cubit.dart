import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/regions/domain/usecases/create_region_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/manage_region_usecases.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/manage_regions_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Painel do admin: lista as regiões (com os times da temporada atual),
/// cria, renomeia, exclui (só vazia) e roda a manutenção "Vincular regiões
/// por id".
class ManageRegionsCubit extends Cubit<ManageRegionsState> {
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final CreateRegionUseCase createRegionUseCase;
  final RenameRegionUseCase renameRegionUseCase;
  final DeleteRegionUseCase deleteRegionUseCase;
  final LinkRegionsByIdUseCase linkRegionsByIdUseCase;

  ManageRegionsCubit(
    this.getRegionsUseCase,
    this.getTeamsCacheFirstUseCase,
    this.createRegionUseCase,
    this.renameRegionUseCase,
    this.deleteRegionUseCase,
    this.linkRegionsByIdUseCase,
  ) : super(const LoadingManageRegionsState());

  void _emit(ManageRegionsState next) {
    if (!isClosed) emit(next);
  }

  ManageRegionsState _busy({bool saving = false, bool working = false}) =>
      SuccessManageRegionsState(regions: state.regions, teamCounts: state.teamCounts, saving: saving, working: working);

  void _fail(Failure failure) => _emit(failure is RegionNameFailure
      ? InvalidNameManageRegionsState(error: failure.error, regions: state.regions, teamCounts: state.teamCounts)
      : failure is LastRegionFailure
          ? LastRegionManageRegionsState(regions: state.regions, teamCounts: state.teamCounts)
          : ErrorManageRegionsState(
              errorMessage: failure.toString(),
              regions: state.regions,
              teamCounts: state.teamCounts,
            ));

  Future<void> load() async {
    _emit(LoadingManageRegionsState(regions: state.regions, teamCounts: state.teamCounts));
    final regions = await getRegionsUseCase();
    if (regions.isLeft) {
      _fail(regions.left);
      return;
    }
    // Uma consulta só (todos os times da temporada), agrupada por região.
    // A contagem decide se a região pode ser excluída: sempre do Firestore
    // (o resultado renova o cache dos times).
    final teams = await getTeamsCacheFirstUseCase(force: true).last;
    final counts = <String, int>{};
    for (final team in teams.isRight ? teams.right : const []) {
      counts[team.region] = (counts[team.region] ?? 0) + 1;
    }
    final sorted = [...regions.right]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _emit(SuccessManageRegionsState(regions: sorted, teamCounts: counts));
  }

  Future<void> create(String name) async {
    if (state.saving) return;
    _emit(_busy(saving: true));
    final response = await createRegionUseCase(name);
    if (response.isLeft) return _fail(response.left);
    await load();
    _emit(CreatedManageRegionsState(name: response.right, regions: state.regions, teamCounts: state.teamCounts));
  }

  Future<void> rename(String current, String name) async {
    if (state.saving) return;
    _emit(_busy(saving: true));
    final response = await renameRegionUseCase(current: current, name: name);
    if (response.isLeft) return _fail(response.left);
    await load();
    _emit(RenamedManageRegionsState(
      previous: current,
      name: response.right,
      regions: state.regions,
      teamCounts: state.teamCounts,
    ));
  }

  /// Confere o conteúdo da região antes de excluir.
  Future<void> checkDelete(String name) async {
    if (state.working) return;
    if (state.regions.length <= 1) {
      return _emit(LastRegionManageRegionsState(regions: state.regions, teamCounts: state.teamCounts));
    }
    _emit(_busy(working: true));
    final response = await deleteRegionUseCase.usage(name);
    if (response.isLeft) return _fail(response.left);
    _emit(DeleteCheckedManageRegionsState(
      name: name,
      usage: response.right,
      regions: state.regions,
      teamCounts: state.teamCounts,
    ));
  }

  Future<void> delete(String name) async {
    if (state.working) return;
    _emit(_busy(working: true));
    final response = await deleteRegionUseCase(name);
    if (response.isLeft) {
      final failure = response.left;
      // Ganhou conteúdo entre a conferência e a exclusão: mostra de novo.
      if (failure is RegionInUseFailure) {
        return _emit(DeleteCheckedManageRegionsState(
          name: name,
          usage: failure.usage,
          regions: state.regions,
          teamCounts: state.teamCounts,
        ));
      }
      return _fail(failure);
    }
    await load();
    _emit(DeletedManageRegionsState(name: name, regions: state.regions, teamCounts: state.teamCounts));
  }

  Future<void> linkRegions() async {
    if (state.working) return;
    _emit(_busy(working: true));
    final response = await linkRegionsByIdUseCase();
    if (response.isLeft) return _fail(response.left);
    await load();
    _emit(LinkedManageRegionsState(report: response.right, regions: state.regions, teamCounts: state.teamCounts));
  }
}
