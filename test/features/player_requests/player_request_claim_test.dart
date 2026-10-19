import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/cancel_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/submit_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_my_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_state.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_requests_panel_state.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

const _dudu = PlayerDTO(id: 'p1', name: 'Dudu', team: 'Lava Jato', teamId: '1', goals: 3, position: 'meia');
const _linked = PlayerDTO(id: 'p2', name: 'Kaio', team: 'Lava Jato', teamId: '1', userId: 'outra');
const _ana = PlayerDTO(id: 'p3', name: 'ana', team: 'Lava Jato', teamId: '1');

class _WatchMine implements WatchMyPlayerRequestUseCase {
  @override
  Stream<Either<Failure, PlayerRequestDTO?>> call(String userId) => Stream.value(const Right(null));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Submit implements SubmitPlayerRequestUseCase {
  PlayerRequestDTO? sent;

  @override
  Future<Either<Failure, void>> call(PlayerRequestDTO request, {File? photo}) async {
    sent = request;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cancel implements CancelPlayerRequestUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Regions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta']);
}

class _Teams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.value(const Right([
        TeamDTO(id: '1', name: 'Lava Jato', region: 'Floresta'),
        TeamDTO(id: '2', name: 'Volta', region: 'Floresta'),
      ]));
}

class _Squad implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(Right(teamName == 'Lava Jato' ? const [_dudu, _linked, _ana] : const []));
}

class _Championships implements GetRegionChampionshipsCacheFirstUseCase {
  final List<ChampionshipDTO> championships;

  _Championships([this.championships = const []]);

  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> call(
          {required String region, required String season, bool force = false}) =>
      Stream.value(Right(championships));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PlayerRequestForm', () {
    test('vínculo: dispensa o nome digitado (vale o do atleta)', () {
      const form = PlayerRequestForm(selectedTeam: 'Lava Jato', position: PlayerPosition.midfielder);
      expect(form.error, PlayerRequestFormError.name);
      expect(form.copyWith(claimedPlayer: () => _dudu).error, isNull);
    });
  });

  test('DTO: idJogadorVinculo só vai quando há vínculo', () {
    const request = PlayerRequestDTO(userId: 'u1', name: 'Dudu', team: 'Lava Jato', region: '', season: '2026');
    expect(request.toSubmitMap().containsKey('idJogadorVinculo'), isFalse);
    expect(request.copyWith(claimedPlayerId: 'p1').toSubmitMap()['idJogadorVinculo'], 'p1');
    expect(request.copyWith(claimedPlayerId: 'p1').isClaim, isTrue);
  });

  test('painel: pedido de vínculo não acusa nome duplicado', () {
    const request = PlayerRequestDTO(
      userId: 'u1',
      name: 'Dudu',
      team: 'Lava Jato',
      teamId: '1',
      region: '',
      season: '2026',
    );
    const state = PlayerRequestsPanelState(players: [_dudu]);
    expect(state.duplicateOf(request)?.id, 'p1');
    expect(state.duplicateOf(request.copyWith(claimedPlayerId: 'p1')), isNull);
  });

  group('PlayerRequestCubit', () {
    late _Submit submit;
    late PlayerRequestCubit cubit;

    setUp(() async {
      submit = _Submit();
      cubit = PlayerRequestCubit(_WatchMine(), submit, _Cancel(), _Regions(), _Teams(), _Squad(), _Championships());
      await cubit.start(userId: 'u1', userName: 'Eduardo', email: 'e@x.com', initialRegion: 'Floresta');
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() => cubit.close());

    test('escolher o time lista só os atletas sem conta, em ordem', () async {
      await cubit.selectTeam('Lava Jato');
      expect(cubit.state.form.unlinkedPlayers.map((p) => p.id), ['p3', 'p1']);
      expect(cubit.state.form.loadingPlayers, isFalse);
    });

    test('"sou eu" usa o nome do atleta; tocar de novo desmarca; outro time limpa', () async {
      await cubit.selectTeam('Lava Jato');
      cubit.claimPlayer(_dudu);
      expect(cubit.state.form.name, 'Dudu');
      expect(cubit.state.form.position, PlayerPosition.midfielder);
      cubit.claimPlayer(_dudu);
      expect(cubit.state.form.claimedPlayer, isNull);
      expect(cubit.state.form.name, 'Eduardo');

      cubit.claimPlayer(_dudu);
      await cubit.selectTeam('Volta');
      expect(cubit.state.form.claimedPlayer, isNull);
      expect(cubit.state.form.unlinkedPlayers, isEmpty);
    });

    test('enviar o vínculo leva o id do atleta', () async {
      await cubit.selectTeam('Lava Jato');
      cubit.claimPlayer(_dudu);
      await cubit.submit();
      expect(submit.sent?.claimedPlayerId, 'p1');
      expect(submit.sent?.name, 'Dudu');
      expect(submit.sent?.teamId, '1');
    });
  });

  test('com competições na região: escolhe a competição, os times são os dela e o pedido leva a competição', () async {
    final submit = _Submit();
    final cubit = PlayerRequestCubit(
        _WatchMine(),
        submit,
        _Cancel(),
        _Regions(),
        _Teams(),
        _Squad(),
        _Championships(const [
          ChampionshipDTO(id: 'a', championshipId: 7, title: 'Copa', teams: ['Lava Jato'], teamIds: ['1']),
          ChampionshipDTO(
              id: 'b', championshipId: 9, title: 'Liga', teams: ['Lava Jato', 'Volta'], teamIds: ['1', '2']),
        ]));
    await cubit.start(userId: 'u1', userName: 'Eduardo', email: 'e@x.com', initialRegion: 'Floresta');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.form.error, PlayerRequestFormError.championship);
    await cubit.selectChampionship(7);
    expect(cubit.state.form.selectableTeams.map((t) => t.name), ['Lava Jato']);

    await cubit.selectTeam('Lava Jato');
    cubit.selectPosition(PlayerPosition.forward);
    await cubit.submit();
    expect(submit.sent?.championshipId, 7);
    expect(submit.sent?.championship, 'Copa');

    // Trocar para a Liga mantém o time (ele joga as duas).
    await cubit.selectChampionship(9);
    expect(cubit.state.form.selectedTeam, 'Lava Jato');
    await cubit.close();
  });

  test('"sou eu" da competição: atleta inscrito em outra competição não aparece', () async {
    const copaOnly = PlayerDTO(id: 'p9', name: 'Zeca', team: 'Lava Jato', teamId: '1', enrollments: [
      PlayerEnrollment(championshipId: 7, teamId: '1', team: 'Lava Jato'),
    ]);
    final cubit = PlayerRequestCubit(
        _WatchMine(),
        _Submit(),
        _Cancel(),
        _Regions(),
        _Teams(),
        _SquadWith(copaOnly),
        _Championships(const [
          ChampionshipDTO(id: 'a', championshipId: 7, title: 'Copa', teams: ['Lava Jato'], teamIds: ['1']),
          ChampionshipDTO(id: 'b', championshipId: 9, title: 'Liga', teams: ['Lava Jato'], teamIds: ['1']),
        ]));
    await cubit.start(userId: 'u1', userName: 'Eduardo', email: 'e@x.com', initialRegion: 'Floresta');
    await Future<void>.delayed(Duration.zero);
    await cubit.selectChampionship(9);
    await cubit.selectTeam('Lava Jato');
    expect(cubit.state.form.unlinkedPlayers.map((p) => p.id), isNot(contains('p9')));
    await cubit.selectChampionship(7);
    expect(cubit.state.form.unlinkedPlayers.map((p) => p.id), contains('p9'));
    await cubit.close();
  });
}

class _SquadWith implements WatchTeamPlayersUseCase {
  final PlayerDTO extra;

  _SquadWith(this.extra);

  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(Right(teamName == 'Lava Jato' ? [_dudu, _linked, _ana, extra] : const []));
}
