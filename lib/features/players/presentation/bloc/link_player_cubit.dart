import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/player_link.dart';
import 'package:arena_soccer/features/players/domain/usecases/link_player_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Vincular atleta (admin): os atletas que podem entrar no time (da região e
/// os sem time), os times da região e as competições da temporada.
class LinkPlayerState extends Equatable {
  final bool loading;
  final List<PlayerDTO> candidates;
  final List<TeamDTO> teams;
  final List<ChampionshipDTO> championships;
  final bool saving;
  final String? errorMessage;

  const LinkPlayerState({
    this.loading = true,
    this.candidates = const [],
    this.teams = const [],
    this.championships = const [],
    this.saving = false,
    this.errorMessage,
  });

  LinkPlayerState copyWith({
    bool? loading,
    List<PlayerDTO>? candidates,
    List<TeamDTO>? teams,
    List<ChampionshipDTO>? championships,
    bool? saving,
    String? Function()? errorMessage,
  }) =>
      LinkPlayerState(
        loading: loading ?? this.loading,
        candidates: candidates ?? this.candidates,
        teams: teams ?? this.teams,
        championships: championships ?? this.championships,
        saving: saving ?? this.saving,
        errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      );

  @override
  List<Object?> get props => [loading, candidates, teams, championships, saving, errorMessage];
}

class LinkPlayerCubit extends Cubit<LinkPlayerState> {
  final LinkPlayerUseCase linkPlayerUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final GetSeasonChampionshipsUseCase getSeasonChampionshipsUseCase;

  LinkPlayerCubit(this.linkPlayerUseCase, this.getTeamsCacheFirstUseCase, this.getSeasonChampionshipsUseCase)
      : super(const LinkPlayerState());

  String? _season;

  /// Carrega os times da região e as competições da temporada; com
  /// [withCandidates], também os atletas que podem ser vinculados.
  Future<void> load({required String region, required String season, bool withCandidates = true}) async {
    _season = season;
    emit(const LinkPlayerState());
    final teams = (await getTeamsCacheFirstUseCase(region: region, season: season).first)
        .fold((_) => const <TeamDTO>[], (t) => t);
    final championships =
        (await getSeasonChampionshipsUseCase(season)).fold((_) => const <ChampionshipDTO>[], (c) => c);
    var candidates = const <PlayerDTO>[];
    String? error;
    if (withCandidates) {
      final response = await linkPlayerUseCase.candidates(teamIds: [for (final t in teams) t.id], season: season);
      response.fold((failure) => error = failure.toString(), (list) => candidates = list);
    }
    if (isClosed) return;
    emit(LinkPlayerState(
      loading: false,
      candidates: candidates,
      teams: teams,
      championships: championships,
      errorMessage: error,
    ));
  }

  /// Competições da temporada em que o [teamId]/[team] está inscrito.
  List<ChampionshipDTO> championshipsOf({required String teamId, required String team}) => [
        for (final c in state.championships)
          if (c.isOpen && _hasTeam(c, teamId, team)) c,
      ];

  static bool _hasTeam(ChampionshipDTO c, String teamId, String team) {
    for (var i = 0; i < c.teams.length; i++) {
      final id = i < c.teamIds.length ? c.teamIds[i] : '';
      if (sameTeam(idA: id, nameA: c.teams[i], idB: teamId, nameB: team)) return true;
    }
    return teamId.isNotEmpty && c.teamIds.contains(teamId);
  }

  /// Vincula e devolve o erro (nulo = deu certo).
  Future<String?> link(
    PlayerDTO player, {
    required String teamId,
    required String team,
    required Set<int> selected,
    Set<int> transfers = const {},
    bool makeMain = false,
  }) async {
    if (state.saving) return null;
    emit(state.copyWith(saving: true));
    final plan = PlayerLinkPlan.of(
      player,
      teamId: teamId,
      team: team,
      selected: selected,
      transfers: transfers,
      makeMain: makeMain,
      // Atleta antigo: as competições do time principal dele viram inscrições reais.
      legacyChampionships: player.isLegacy
          ? [for (final c in championshipsOf(teamId: player.teamId, team: player.team)) c.championshipId]
          : const [],
    );
    final response = await linkPlayerUseCase.link(player, plan, teamId: teamId, team: team, season: _season);
    if (isClosed) return null;
    emit(state.copyWith(saving: false));
    return response.fold((failure) => failure.toString(), (_) => null);
  }
}
