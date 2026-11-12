import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/cancel_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/submit_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_my_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_state.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

const _dudu = PlayerDTO(id: 'p1', name: 'Dudu Silva', team: 'Lava Jato', teamId: '1', position: 'meia');

class _WatchMine implements WatchMyPlayerRequestUseCase {
  final controller = StreamController<Either<Failure, PlayerRequestDTO?>>.broadcast();

  @override
  Stream<Either<Failure, PlayerRequestDTO?>> call(String userId) => controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// O envio só termina quando o teste libera ([done]).
class _Submit implements SubmitPlayerRequestUseCase {
  PlayerRequestDTO? sent;
  var calls = 0;
  Completer<Either<Failure, void>> done = Completer();

  @override
  Future<Either<Failure, void>> call(PlayerRequestDTO request, {File? photo}) {
    sent = request;
    calls++;
    return done.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cancel implements CancelPlayerRequestUseCase {
  @override
  Future<Either<Failure, void>> call(String userId) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Regions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta', 'Riacho']);
}

class _Teams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.value(Right(region == 'Floresta'
          ? const [
              TeamDTO(id: '1', name: 'Lava Jato', region: 'Floresta'),
              TeamDTO(id: '2', name: 'Volta', region: 'Floresta'),
            ]
          : const [TeamDTO(id: '3', name: 'Riacho FC', region: 'Riacho')]));
}

class _Squad implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(Right(teamName == 'Lava Jato' ? const [_dudu] : const []));
}

/// Floresta tem a Copa (só o Lava Jato); Riacho falha (sem cache e sem rede).
class _Championships implements GetRegionChampionshipsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> call(
          {required String region, required String season, bool force = false}) =>
      Stream.value(region == 'Floresta'
          ? const Right([
              ChampionshipDTO(id: 'c', championshipId: 7, title: 'Copa', teams: ['Lava Jato'], teamIds: ['1']),
            ])
          : Left(ErrorWithMessage('sem rede')));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _WatchMine mine;
  late _Submit submit;
  late PlayerRequestCubit cubit;

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() async {
    mine = _WatchMine();
    submit = _Submit();
    cubit = PlayerRequestCubit(mine, submit, _Cancel(), _Regions(), _Teams(), _Squad(), _Championships());
    await cubit.start(
      userId: 'u1',
      userName: 'Eduardo Henrique de Albuquerque Cavalcanti Junior',
      email: 'e@x.com',
      initialRegion: 'Floresta',
    );
    mine.controller.add(const Right(null));
    await settle();
  });

  tearDown(() => cubit.close());

  Future<void> fillValid() async {
    await cubit.selectTeam('Lava Jato');
    cubit.changeName('Eduardo Lima');
    cubit.selectPosition(PlayerPosition.forward);
  }

  test('nome da conta longo vem cortado no limite das regras', () {
    expect(cubit.state.form.name.length, lessThanOrEqualTo(PlayerRequestForm.nameMaxLength));
    cubit.changeName('x' * 41);
    expect(cubit.state.form.error, isNot(PlayerRequestFormError.nameTooLong),
        reason: 'antes do time, o primeiro erro é outro');
  });

  test('nome com mais de 40 letras é inválido', () async {
    await fillValid();
    cubit.changeName('Nome Muito Comprido Que Passa Do Limite Das Regras');
    expect(cubit.state.form.error, PlayerRequestFormError.nameTooLong);
  });

  test('o snapshot do envio chega antes do fim: a tela fica no pedido novo', () async {
    await fillValid();
    final sending = cubit.submit();
    await settle();
    mine.controller.add(Right(submit.sent!));
    await settle();
    submit.done.complete(const Right(null));
    await sending;
    expect(cubit.state, isA<SubmittedPlayerRequestState>());
    expect(cubit.state.request, isNotNull, reason: 'não volta para o formulário');
    expect(cubit.state.showForm, isFalse);
  });

  test('atualização durante o envio não reabilita o botão (sem envio duplo)', () async {
    await fillValid();
    unawaited(cubit.submit());
    await settle();
    cubit.selectPosition(PlayerPosition.midfielder);
    expect(cubit.state, isA<SubmittingPlayerRequestState>());
    await cubit.submit();
    expect(submit.calls, 1);
    submit.done.complete(const Right(null));
  });

  test('competições que não carregam bloqueiam o envio; trocar de região limpa as anteriores', () async {
    expect(cubit.state.form.championships.map((c) => c.championshipId), [7]);
    await cubit.selectRegion('Riacho');
    await settle();
    expect(cubit.state.form.championships, isEmpty);
    expect(cubit.state.form.championshipId, isNull);
    expect(cubit.state.form.championshipsFailed, isTrue);
    await cubit.selectTeam('Riacho FC');
    cubit.changeName('Eduardo Lima');
    cubit.selectPosition(PlayerPosition.forward);
    expect(cubit.state.form.error, PlayerRequestFormError.championshipsFailed);
  });

  test('time fora da competição escolhida é inválido', () {
    final form = cubit.state.form.copyWith(
      selectedTeam: () => 'Volta',
      name: 'Eduardo Lima',
      position: PlayerPosition.forward,
    );
    expect(form.championshipId, 7);
    expect(form.error, PlayerRequestFormError.team);
  });

  test('desfazer o "sou eu" trocando o time devolve o nome da conta', () async {
    await cubit.selectTeam('Lava Jato');
    cubit.claimPlayer(_dudu);
    expect(cubit.state.form.name, 'Dudu Silva');
    await cubit.selectTeam('Volta');
    expect(cubit.state.form.isClaim, isFalse);
    expect(cubit.state.form.name, isNot('Dudu Silva'));
  });

  test('vínculo: o nome enviado é o do atleta; curto demais para as regras, o da conta', () async {
    await cubit.selectTeam('Lava Jato');
    cubit.claimPlayer(_dudu);
    expect(cubit.state.form.submitName, 'Dudu Silva');
    const short = PlayerDTO(id: 'z', name: 'Zé', team: 'Lava Jato');
    cubit.claimPlayer(short);
    cubit.selectPosition(PlayerPosition.goalkeeper);
    unawaited(cubit.submit());
    await settle();
    expect(submit.sent?.name.length, greaterThanOrEqualTo(PlayerRequestForm.nameMinLength));
    expect(submit.sent?.claimedPlayerId, 'z');
    submit.done.complete(const Right(null));
  });

  test('corrigir um pedido pendente mantém o "enviado em"; reenviar rejeitado não', () async {
    final sentAt = DateTime(2026, 11, 1);
    final pending = PlayerRequestDTO(
      userId: 'u1',
      name: 'Eduardo Lima',
      team: 'Lava Jato',
      teamId: '1',
      region: 'Floresta',
      season: '2026',
      position: PlayerPosition.forward,
      championshipId: 7,
      championship: 'Copa',
      createdAt: sentAt,
    );
    mine.controller.add(Right(pending));
    await settle();
    cubit.startEditing();
    await settle();
    unawaited(cubit.submit());
    await settle();
    expect(submit.sent?.createdAt, sentAt);
    submit.done.complete(const Right(null));
    await settle();

    submit.done = Completer();
    mine.controller.add(Right(pending.copyWith(status: PlayerRequestStatus.rejected)));
    await settle();
    cubit.startEditing();
    await settle();
    unawaited(cubit.submit());
    await settle();
    expect(submit.sent?.createdAt, isNull);
    submit.done.complete(const Right(null));
  });

  test('cancelar: o formulário volta limpo', () async {
    final pending = PlayerRequestDTO(
      userId: 'u1',
      name: 'Eduardo Lima',
      team: 'Lava Jato',
      teamId: '1',
      region: 'Floresta',
      season: '2026',
      position: PlayerPosition.forward,
      message: 'Jogo de meia',
    );
    mine.controller.add(Right(pending));
    await settle();
    await cubit.cancelRequest();
    mine.controller.add(const Right(null));
    await settle();
    expect(cubit.state.form.selectedTeam, isNull);
    expect(cubit.state.form.message, '');
    expect(cubit.state.showForm, isTrue);
  });
}
