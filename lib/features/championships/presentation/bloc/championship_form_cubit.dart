import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/championship_rules_file.dart';
import 'package:arena_soccer/features/championships/domain/usecases/save_championship_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Cadastro/edição de campeonato (admin): dados, times participantes da
/// região, banner, regulamento em PDF e premiação.
class ChampionshipFormCubit extends Cubit<ChampionshipFormState> {
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  final SaveChampionshipUseCase saveChampionshipUseCase;

  ChampionshipFormCubit(this.getRegionsUseCase, this.getTeamsUseCase, this.saveChampionshipUseCase)
      : super(const LoadingChampionshipFormState(ChampionshipFormData(base: ChampionshipDTO(id: ''))));

  ChampionshipFormData get _form => state.form;

  /// [initial] = campeonato a editar; sem ele, um novo na região [initialRegion].
  Future<void> load({ChampionshipDTO? initial, required String initialRegion}) async {
    final base = initial ?? ChampionshipDTO(id: '', region: initialRegion, season: SeasonCollection.currentSeason);
    final seasons = {...SeasonCollection.seasons, if (base.season.isNotEmpty) base.season}.toList()..sort();
    final form = ChampionshipFormData(base: base, seasons: seasons, selectedTeams: [...base.teams]);
    emit(LoadingChampionshipFormState(form));

    final regions = await getRegionsUseCase();
    if (isClosed) return;
    if (regions.isLeft || regions.right.isEmpty) {
      emit(LoadErrorChampionshipFormState(form));
      return;
    }
    final list = regions.right;
    final region = list.contains(base.region) ? base.region : list.first;
    emit(EditingChampionshipFormState(form.copyWith(regions: list, base: base.copyWith(region: region))));
    await _loadTeams();
  }

  Future<void> retry({ChampionshipDTO? initial, required String initialRegion}) =>
      load(initial: initial, initialRegion: initialRegion);

  void _edit(ChampionshipFormData form) => emit(EditingChampionshipFormState(form.copyWith(dirty: true)));

  Future<void> _loadTeams() async {
    final region = _form.base.region;
    final season = _form.base.season;
    emit(EditingChampionshipFormState(_form.copyWith(loadingTeams: true)));
    final response = await getTeamsUseCase(region: region, season: season);
    // Só aplica se região/temporada não mudaram enquanto carregava.
    if (isClosed || _form.base.region != region || _form.base.season != season) return;
    response.fold(
      (failure) => emit(ErrorChampionshipFormState(
        _form.copyWith(teams: const [], loadingTeams: false),
        errorMessage: failure.toString(),
      )),
      (teams) {
        final sorted = [...teams]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        emit(EditingChampionshipFormState(_form.copyWith(teams: sorted, loadingTeams: false)));
      },
    );
  }

  Future<void> selectRegion(String region) async {
    if (region == _form.base.region) return;
    // Outra região, outros times: a seleção anterior não vale mais.
    _edit(_form.copyWith(base: _form.base.copyWith(region: region), selectedTeams: const []));
    await _loadTeams();
  }

  Future<void> selectSeason(String season) async {
    if (season == _form.base.season) return;
    _edit(_form.copyWith(base: _form.base.copyWith(season: season)));
    await _loadTeams();
  }

  void changeTitle(String value) => _edit(_form.copyWith(base: _form.base.copyWith(title: value)));

  void changeDescription(String value) => _edit(_form.copyWith(base: _form.base.copyWith(description: value)));

  void changeRulesSummary(String value) => _edit(_form.copyWith(base: _form.base.copyWith(rules: value)));

  void changePrizes({String? first, String? second, String? third, String? topScorer, String? goalkeeper}) {
    _edit(_form.copyWith(
      base: _form.base.copyWith(
        firstPrize: first,
        secondPrize: second,
        thirdPrize: third,
        topScorerPrize: topScorer,
        goalkeeperPrize: goalkeeper,
      ),
    ));
  }

  void toggleTeam(String team) {
    final selected = [..._form.selectedTeams];
    selected.contains(team) ? selected.remove(team) : selected.add(team);
    _edit(_form.copyWith(selectedTeams: selected));
  }

  void selectAllTeams() => _edit(_form.copyWith(
        selectedTeams: [
          ..._form.selectedTeams,
          for (final team in _form.teams)
            if (!_form.selectedTeams.contains(team.name)) team.name,
        ],
      ));

  void clearTeams() => _edit(_form.copyWith(selectedTeams: const []));

  void setBanner(File file) => _edit(_form.copyWith(banner: () => file));

  void setRulesFile(ChampionshipRulesFile file) => _edit(_form.copyWith(rulesFile: () => file));

  /// Tira o regulamento (o novo escolhido e o que já estava gravado).
  void removeRules() => _edit(_form.copyWith(
        rulesFile: () => null,
        base: _form.base.copyWith(rulesUrl: '', rulesFileName: ''),
      ));

  Future<void> submit() async {
    final form = _form;
    if (form.error != null || state is SubmittingChampionshipFormState) return;
    emit(SubmittingChampionshipFormState(form));
    // Ids dos participantes (vínculo) na mesma ordem dos nomes.
    final directory = TeamDirectory(form.teams);
    final response = await saveChampionshipUseCase(
      form.base.copyWith(
        teams: form.selectedTeams,
        // Alinhado com os nomes ('' = time não achado na lista).
        teamIds: [for (final name in form.selectedTeams) directory.idOf(name: name)],
      ),
      banner: form.banner,
      rules: form.rulesFile,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorChampionshipFormState(form, errorMessage: failure.toString())),
      (saved) => emit(SavedChampionshipFormState(form.copyWith(base: saved, dirty: false), created: !form.isEditing)),
    );
  }
}
