import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_table_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_group_table_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_groups_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Grupos da região na temporada, em tempo real, com os escudos dos times
/// (o grupo só guarda os nomes; os escudos vêm da coleção de times) e a
/// tabela automática de cada grupo de campeonato (a mini-classificação do card).
class GroupsCubit extends Cubit<GroupsState> {
  final WatchGroupsUseCase watchGroupsUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final WatchGroupTableUseCase watchGroupTableUseCase;
  StreamSubscription<Either<Failure, List<GroupDTO>>>? _subscription;

  /// Uma assinatura por grupo de campeonato (id do grupo → tabela).
  final Map<String, StreamSubscription<Either<Failure, GroupTableDTO?>>> _tableSubscriptions = {};
  String? _season;

  GroupsCubit(this.watchGroupsUseCase, this.getTeamsCacheFirstUseCase, this.watchGroupTableUseCase)
      : super(const LoadingGroupsState());

  /// Mesmo tipo de estado, com o que mudou.
  void _emitWith({List<GroupDTO>? groups, Map<String, String>? crests, Map<String, GroupTableDTO>? tables}) {
    if (isClosed) return;
    final s = state;
    final g = groups ?? s.groups;
    final c = crests ?? s.crests;
    final t = tables ?? s.tables;
    if (s is LoadingGroupsState) {
      emit(LoadingGroupsState(groups: g, crests: c, tables: t));
    } else if (s is ErrorGroupsState) {
      emit(ErrorGroupsState(errorMessage: s.errorMessage, groups: g, crests: c, tables: t));
    } else {
      emit(SuccessGroupsState(groups: g, crests: c, tables: t));
    }
  }

  /// [championshipId] mostra só os grupos desse campeonato (ver
  /// [GroupDTO.forChampionship]); nulo = todos da região.
  void watch({required String region, required String season, int? championshipId}) {
    _subscription?.cancel();
    _cancelTables();
    _season = season;
    emit(LoadingGroupsState(groups: state.groups, crests: state.crests));
    _loadCrests(region: region, season: season);
    _subscription = watchGroupsUseCase(region: region, season: season).listen((response) {
      response.fold(
        (failure) => emit(
          ErrorGroupsState(
            errorMessage: failure.toString(),
            groups: state.groups,
            crests: state.crests,
            tables: state.tables,
          ),
        ),
        (groups) {
          final shown = GroupDTO.forChampionship(groups, championshipId);
          emit(SuccessGroupsState(groups: shown, crests: state.crests, tables: state.tables));
          _syncTables(shown);
        },
      );
    });
  }

  /// Escuta a tabela de cada grupo de campeonato da lista (e larga as dos
  /// grupos que saíram). Grupo antigo, sem campeonato, não tem tabela.
  void _syncTables(List<GroupDTO> groups) {
    final wanted = {
      for (final g in groups)
        if (g.championshipId > 0 && g.id.isNotEmpty) g.id,
    };
    for (final id in _tableSubscriptions.keys.toList()) {
      if (!wanted.contains(id)) _tableSubscriptions.remove(id)?.cancel();
    }
    for (final id in wanted) {
      if (_tableSubscriptions.containsKey(id)) continue;
      _tableSubscriptions[id] = watchGroupTableUseCase(groupId: id, season: _season).listen((response) {
        // A tabela é só complemento: se falhar, o card mostra os times sem números.
        response.fold((_) => null, (table) {
          final tables = Map<String, GroupTableDTO>.of(state.tables);
          if (table == null) {
            tables.remove(id);
          } else {
            tables[id] = table;
          }
          _emitWith(tables: tables);
        });
      });
    }
  }

  void _cancelTables() {
    for (final sub in _tableSubscriptions.values) {
      sub.cancel();
    }
    _tableSubscriptions.clear();
  }

  /// Escudos são só decoração: se falhar, os cards mostram o ícone padrão.
  Future<void> _loadCrests({required String region, required String season}) async {
    await for (final response in getTeamsCacheFirstUseCase(region: region, season: season)) {
      if (isClosed) return;
      response.fold((_) => null, (teams) {
        _emitWith(crests: {
          for (final team in teams)
            if (team.imageUrl.isNotEmpty) normalizeTeamName(team.name): team.imageUrl,
        });
      });
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _cancelTables();
    return super.close();
  }
}
