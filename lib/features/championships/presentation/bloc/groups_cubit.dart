import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_table_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/championship_groups_usecases.dart';
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

  /// Grupos pelo campeonato (qualquer região); nulo = só a busca por região.
  final WatchChampionshipGroupsUseCase? watchChampionshipGroupsUseCase;
  StreamSubscription<Either<Failure, List<GroupDTO>>>? _championshipSubscription;

  /// Últimos resultados das duas buscas (campeonato e região).
  List<GroupDTO>? _byChampionship;
  List<GroupDTO>? _byRegion;

  /// Uma assinatura por grupo de campeonato (id do grupo → tabela).
  final Map<String, StreamSubscription<Either<Failure, GroupTableDTO?>>> _tableSubscriptions = {};
  String? _season;

  GroupsCubit(
    this.watchGroupsUseCase,
    this.getTeamsCacheFirstUseCase,
    this.watchGroupTableUseCase, [
    this.watchChampionshipGroupsUseCase,
  ]) : super(const LoadingGroupsState());

  /// Ordem A, B, C... pelo nome do grupo.
  static List<GroupDTO> sorted(List<GroupDTO> groups) =>
      [...groups]..sort((a, b) => a.description.compareTo(b.description));

  /// Grupos do campeonato: os dele (de qualquer região); sem nenhum, os
  /// antigos da região só se a temporada ali for só de grupos antigos (sem
  /// nenhum ligado a campeonato) — campeonato novo sem grupo fica vazio.
  static List<GroupDTO> resolve({required List<GroupDTO> own, required List<GroupDTO> region}) {
    if (own.isNotEmpty) return sorted(own);
    if (region.any((g) => g.championshipId > 0)) return const [];
    return sorted(region.where((g) => g.championshipId == 0).toList());
  }

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

  void _fail(Failure failure) => emit(
        ErrorGroupsState(
          errorMessage: failure.toString(),
          groups: state.groups,
          crests: state.crests,
          tables: state.tables,
        ),
      );

  void _show(List<GroupDTO> shown) {
    emit(SuccessGroupsState(groups: shown, crests: state.crests, tables: state.tables));
    _syncTables(shown);
  }

  /// Com as duas buscas do campeonato prontas, mostra o resultado.
  void _resolveChampionship() {
    final own = _byChampionship;
    final region = _byRegion;
    if (own == null || region == null) return;
    _show(resolve(own: own, region: region));
  }

  /// [championshipId]: os grupos desse campeonato, buscados por ele (os de
  /// sede em outra região também), ordenados; nulo = todos da região.
  void watch({required String region, required String season, int? championshipId}) {
    _subscription?.cancel();
    _championshipSubscription?.cancel();
    _championshipSubscription = null;
    _byChampionship = null;
    _byRegion = null;
    _cancelTables();
    _season = season;
    emit(LoadingGroupsState(groups: state.groups, crests: state.crests));
    _loadCrests(region: region, season: season);
    final byChampionship = watchChampionshipGroupsUseCase;
    if (championshipId != null && byChampionship != null) {
      _championshipSubscription = byChampionship(championshipId: championshipId, season: season).listen((response) {
        response.fold(_fail, (groups) {
          _byChampionship = groups;
          _resolveChampionship();
        });
      });
      // A da região só decide o legado (grupos antigos, sem campeonato).
      _subscription = watchGroupsUseCase(region: region, season: season).listen((response) {
        response.fold((_) => _byRegion = const [], (groups) => _byRegion = groups);
        _resolveChampionship();
      });
      return;
    }
    _subscription = watchGroupsUseCase(region: region, season: season).listen((response) {
      response.fold(_fail, (groups) => _show(sorted(GroupDTO.forChampionship(groups, championshipId))));
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
    _championshipSubscription?.cancel();
    _cancelTables();
    return super.close();
  }
}
