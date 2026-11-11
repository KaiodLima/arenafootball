import 'dart:async';
import 'dart:math';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_rules.dart';
import 'package:arena_soccer/features/championships/domain/usecases/championship_groups_usecases.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_teams_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_by_ids_usecase.dart';

class OrganizerGroupsState extends Equatable {
  final bool loading;
  final bool error;
  final List<GroupDTO> groups;

  /// Times inscritos no campeonato (escudo pelo id; sem doc, só o nome).
  final List<TeamDTO> teams;

  /// Gravação em andamento (botões desligados).
  final bool busy;

  const OrganizerGroupsState({
    this.loading = true,
    this.error = false,
    this.groups = const [],
    this.teams = const [],
    this.busy = false,
  });

  /// Inscritos que ainda não estão em nenhum grupo (exceto o [editing]).
  List<TeamDTO> freeTeams({GroupDTO? editing}) {
    // Pelo id e pelo nome (grupo antigo grava só o nome).
    final used = <String>{
      for (final group in groups)
        if (group.id != editing?.id)
          for (var i = 0; i < group.teams.length; i++)
            if (group.teams[i].isNotEmpty) ...[
              teamKey(id: '', name: group.teams[i]),
              if (group.teamIdAt(i).isNotEmpty) teamKey(id: group.teamIdAt(i), name: ''),
            ],
    };
    return [
      for (final team in teams)
        if (!used.contains(teamKey(id: '', name: team.name)) &&
            (team.id.isEmpty || !used.contains(teamKey(id: team.id, name: ''))))
          team,
    ];
  }

  /// Próximo nome livre: A, B, C...
  String nextName() {
    final names = groups.map((g) => g.description.trim().toUpperCase()).toSet();
    var i = 0;
    while (names.contains(groupLetter(i))) {
      i++;
    }
    return groupLetter(i);
  }

  OrganizerGroupsState copyWith(
          {bool? loading, bool? error, List<GroupDTO>? groups, List<TeamDTO>? teams, bool? busy}) =>
      OrganizerGroupsState(
        loading: loading ?? this.loading,
        error: error ?? this.error,
        groups: groups ?? this.groups,
        teams: teams ?? this.teams,
        busy: busy ?? this.busy,
      );

  @override
  List<Object?> get props => [loading, error, groups, teams, busy];
}

/// Chave de comparação do time: o id ou, sem id, o nome normalizado.
String teamKey({required String id, required String name}) =>
    id.isNotEmpty ? 'id:$id' : 'nome:${normalizeTeamName(name)}';

/// Grupos de um campeonato do organizador: lista ao vivo, criar/editar,
/// apagar e sortear.
class OrganizerGroupsCubit extends Cubit<OrganizerGroupsState> {
  final WatchChampionshipGroupsUseCase watchGroupsUseCase;
  final SaveGroupUseCase saveGroupUseCase;
  final DeleteGroupUseCase deleteGroupUseCase;
  final ReplaceGroupsUseCase replaceGroupsUseCase;
  final GetTeamsByIdsUseCase getTeamsByIdsUseCase;

  StreamSubscription<Either<Failure, List<GroupDTO>>>? _subscription;
  late ChampionshipDTO _championship;

  OrganizerGroupsCubit(
    this.watchGroupsUseCase,
    this.saveGroupUseCase,
    this.deleteGroupUseCase,
    this.replaceGroupsUseCase,
    this.getTeamsByIdsUseCase,
  ) : super(const OrganizerGroupsState());

  String? get _season => _championship.season.isEmpty ? null : _championship.season;

  Future<void> start(ChampionshipDTO championship) async {
    _championship = championship;
    _subscription = watchGroupsUseCase(championshipId: championship.championshipId, season: _season).listen((response) {
      if (isClosed) return;
      response.fold(
        (_) => emit(state.copyWith(loading: false, error: true)),
        (groups) => emit(state.copyWith(loading: false, error: false, groups: groups)),
      );
    });
    await loadTeams(championship);
  }

  /// Inscritos do campeonato (de novo quando a inscrição muda).
  Future<void> loadTeams(ChampionshipDTO championship) async {
    _championship = championship;
    final ids = <String>[];
    final names = <String>[];
    for (var i = 0; i < championship.teams.length; i++) {
      final id = i < championship.teamIds.length ? championship.teamIds[i] : '';
      id.isNotEmpty ? ids.add(id) : names.add(championship.teams[i]);
    }
    final response = await getTeamsByIdsUseCase(ids: ids, names: names, season: _season);
    if (isClosed) return;
    final directory = TeamDirectory(response.isRight ? response.right : const <TeamDTO>[]);
    emit(state.copyWith(teams: participantsOf(championship, directory)));
  }

  /// O grupo com os campos do campeonato (sede, número e doc).
  GroupDTO _complete(GroupDTO group) => GroupDTO(
        id: group.id,
        description: group.description.trim(),
        region: _championship.region,
        teams: group.teams,
        teamIds: group.teamIds,
        championshipId: _championship.championshipId,
        championshipDocId: _championship.id,
        rules: group.rules,
      );

  static GroupDTO groupOf(String name, List<TeamDTO> teams, {String id = '', GroupRules rules = GroupRules.standard}) =>
      GroupDTO(
        id: id,
        description: name,
        teams: [for (final t in teams) t.name],
        teamIds: [for (final t in teams) t.id],
        rules: rules,
      );

  /// Grava as [rules] no grupo [group] ou, com [toAll], em todos os grupos.
  Future<Either<Failure, void>> saveRules(GroupDTO group, GroupRules rules, {bool toAll = false}) => _busy(() async {
        final targets = toAll ? state.groups : [group];
        for (final g in targets) {
          final response = await saveGroupUseCase(_complete(g.copyWith(rules: rules)), season: _season);
          if (response.isLeft) return response;
        }
        return const Right(null);
      });

  Future<Either<Failure, void>> save(GroupDTO group) =>
      _busy(() => saveGroupUseCase(_complete(group), season: _season));

  Future<Either<Failure, void>> delete(GroupDTO group) => _busy(() => deleteGroupUseCase(group.id, season: _season));

  /// Sorteia os inscritos em [count] grupos (A, B...) e troca os atuais.
  Future<Either<Failure, void>> draw(int count, {Random? random}) {
    final drawn = drawGroups(state.teams, count, random: random);
    // O sorteio mantém as regras que os grupos já tinham.
    final rules = state.groups.firstOrNull?.rules ?? GroupRules.standard;
    final groups = [
      for (var i = 0; i < drawn.length; i++) _complete(groupOf(groupLetter(i), drawn[i], rules: rules)),
    ];
    return _busy(() => replaceGroupsUseCase(previous: state.groups, groups: groups, season: _season));
  }

  Future<Either<Failure, void>> _busy(Future<Either<Failure, void>> Function() action) async {
    emit(state.copyWith(busy: true));
    final response = await action();
    if (!isClosed) emit(state.copyWith(busy: false));
    return response;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
