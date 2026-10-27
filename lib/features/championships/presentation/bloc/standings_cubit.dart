import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_table_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_group_table_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_standings_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Classificação de um grupo em tempo real. Vale a tabela calculada pelas
/// functions (`tabelas{ano}/{idGrupo}`); sem ela (grupo antigo ou ainda não
/// calculado), a classificação manual antiga. O escudo vem do registro da
/// classificação; quando falta, da coleção de times (mesma fonte dos grupos).
class StandingsCubit extends Cubit<StandingsState> {
  final WatchStandingsUseCase watchStandingsUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final WatchGroupTableUseCase watchGroupTableUseCase;
  StreamSubscription? _tableSubscription;
  StreamSubscription? _legacySubscription;
  Map<String, String> _crests = const {};

  StandingsCubit(this.watchStandingsUseCase, this.getTeamsCacheFirstUseCase, this.watchGroupTableUseCase)
      : super(const LoadingStandingsState());

  void watch({required String region, required String group, required String season, String groupId = ''}) {
    _tableSubscription?.cancel();
    _legacySubscription?.cancel();
    _legacySubscription = null;
    emit(LoadingStandingsState(standings: state.standings));
    _loadCrests(region: region, season: season);
    void legacy() => _watchLegacy(region: region, group: group, season: season);
    if (groupId.isEmpty) {
      legacy();
      return;
    }
    _tableSubscription = watchGroupTableUseCase(groupId: groupId, season: season).listen((response) {
      if (isClosed) return;
      final GroupTableDTO? table = response.fold((_) => null, (table) => table);
      if (table == null || table.rows.isEmpty) {
        if (_legacySubscription == null) legacy();
        return;
      }
      _legacySubscription?.cancel();
      _legacySubscription = null;
      emit(SuccessStandingsState(standings: _withCrests(table.rows), automatic: true, criteria: table.criteria));
    });
  }

  void _watchLegacy({required String region, required String group, required String season}) {
    _legacySubscription = watchStandingsUseCase(region: region, group: group, season: season).listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(ErrorStandingsState(errorMessage: failure.toString(), standings: state.standings)),
        (standings) => emit(SuccessStandingsState(standings: _withCrests(standings))),
      );
    });
  }

  /// Escudos são só decoração: se falhar, a linha mostra o ícone padrão.
  Future<void> _loadCrests({required String region, required String season}) async {
    await for (final response in getTeamsCacheFirstUseCase(region: region, season: season)) {
      if (isClosed) return;
      response.fold((_) => null, (teams) {
        _crests = {
          for (final team in teams)
            if (team.imageUrl.isNotEmpty) normalizeTeamName(team.name): team.imageUrl,
        };
        final s = state;
        final standings = _withCrests(s.standings);
        if (s is SuccessStandingsState) {
          emit(SuccessStandingsState(standings: standings, automatic: s.automatic, criteria: s.criteria));
        }
      });
    }
  }

  List<StandingDTO> _withCrests(List<StandingDTO> standings) => standings
      .map((s) => s.imageUrl.isNotEmpty ? s : s.copyWith(imageUrl: _crests[normalizeTeamName(s.teamName)] ?? ''))
      .toList();

  @override
  Future<void> close() {
    _tableSubscription?.cancel();
    _legacySubscription?.cancel();
    return super.close();
  }
}
