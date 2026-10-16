import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_today_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_score_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_state.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/add_player_stats_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

const _today = MatchDTO(
  id: 'm1',
  homeTeam: 'Lava Jato',
  awayTeam: 'Volta',
  date: '11/10',
  time: '16:45',
  region: 'Floresta',
  homeGoals: 1,
  awayGoals: 0,
);

class _FakeMatchesRepository implements IMatchesRepository {
  bool failUpdate = false;
  int updates = 0;

  @override
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season, String? region}) => Stream.value(const Right([
        MatchDTO(id: 'late', homeTeam: 'A', awayTeam: 'B', date: '11/10', time: '18:00', region: 'Floresta'),
        _today,
        MatchDTO(id: 'other', homeTeam: 'C', awayTeam: 'D', date: '11/10', time: '10:00', region: 'Santo inacio'),
        MatchDTO(id: 'old', homeTeam: 'E', awayTeam: 'F', date: '10/10', time: '10:00', region: 'Floresta'),
      ]));

  @override
  Future<Either<Failure, void>> updateScore({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
    String? season,
  }) async {
    updates++;
    return failUpdate ? Left(ErrorWithMessage('erro')) : const Right(null);
  }

  @override
  Future<Either<Failure, void>> createMatch(MatchDTO match, {String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteMatch({required String matchId, String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> setVotingOpen({required String matchId, required bool isOpen, String? season}) async =>
      const Right(null);
}

class _FakeCreateNews implements CreateNewsUseCase {
  NewsDTO? created;

  @override
  Future<Either<Failure, void>> call({required NewsDTO news, File? cover, List<File> album = const []}) async {
    created = news;
    return const Right(null);
  }
}

class _FakeRegions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta', 'Santo inacio']);
}

class _FakeTeams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.fromFuture(_load(region: region, season: season));

  Future<Either<Failure, List<TeamDTO>>> _load({String? region, String? season}) async => const Right([
        TeamDTO(
          id: '1',
          name: 'Lava Jato',
          imageUrl: 'https://img/lj.png',
          primaryColor: '#C62828',
          secondaryColor: '#FFFFFF',
        ),
        TeamDTO(id: '2', name: 'Volta'),
      ]);
}

/// Hoje = 11/10 para as partidas do fake.
class _TodayMatches extends GetTodayMatchesUseCase {
  _TodayMatches(super.repository);

  @override
  Future<Either<Failure, List<MatchDTO>>> call({required String region, String? season, DateTime? now}) =>
      super.call(region: region, season: season, now: DateTime(2026, 10, 11));
}

const _squads = {
  'Lava Jato': [
    PlayerDTO(id: 'dudu', name: 'Dudu', team: 'Lava Jato', goals: 3),
    PlayerDTO(id: 'cassin', name: 'Cassin', team: 'Lava Jato', assists: 1),
  ],
  'Volta': [PlayerDTO(id: 'gabriel', name: 'Gabriel', team: 'Volta')],
  'Riacho': [PlayerDTO(id: 'rafa', name: 'Rafa', team: 'Riacho')],
};

class _FakePlayersRepository implements IPlayersRepository {
  final increments = <String>[];
  bool fail = false;

  @override
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers(
          {String teamId = '', required String teamName, String? season}) =>
      Stream.value(Right(_squads[teamName] ?? const []));

  @override
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    String? season,
  }) async {
    if (fail) return Left(ErrorWithMessage('erro'));
    increments.add('$playerId:g$goals:a$assists');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  Stream<Either<Failure, PlayerDTO?>> watchPlayer({required String id, String? season}) => const Stream.empty();

  @override
  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season}) async => const Right([]);

  @override
  Future<Either<Failure, List<PlayerDTO>>> getTopPlayers({
    required List<String> teamIds,
    required String field,
    int limit = 50,
    String? season,
  }) async =>
      const Right([]);

  @override
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> deletePlayer(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> removeFromSquad(PlayerDTO player, {String? season}) async => const Right(null);
}

void main() {
  group('GetTodayMatchesUseCase', () {
    test('só os jogos de hoje da região, por horário', () async {
      final result = await GetTodayMatchesUseCase(_FakeMatchesRepository())(
        region: 'Floresta',
        now: DateTime(2026, 10, 11),
      );
      expect(result.right.map((m) => m.id), ['m1', 'late']);
    });
  });

  group('GoalFormData', () {
    test('mesmo time dos dois lados não pode publicar', () {
      const form = GoalFormData(homeTeam: 'A', awayTeam: 'A');
      expect(form.sameTeam, isTrue);
      expect(form.canSubmit, isFalse);
    });

    test('linkedMatch exige mandante e visitante na mesma ordem', () {
      const form = GoalFormData(homeTeam: 'Lava Jato', awayTeam: 'Volta', todayMatches: [_today]);
      expect(form.linkedMatch, _today);
      expect(form.copyWith(homeTeam: 'Volta', awayTeam: 'Lava Jato').linkedMatch, isNull);
    });
  });

  group('GoalNotificationCubit', () {
    late _FakeMatchesRepository matches;
    late _FakeCreateNews createNews;
    late GoalNotificationCubit cubit;
    late _FakePlayersRepository players;

    setUp(() async {
      matches = _FakeMatchesRepository();
      createNews = _FakeCreateNews();
      players = _FakePlayersRepository();
      cubit = GoalNotificationCubit(
        createNews,
        _FakeRegions(),
        _FakeTeams(),
        _TodayMatches(matches),
        UpdateMatchScoreUseCase(matches),
        WatchTeamPlayersUseCase(players),
        AddPlayerStatsUseCase(players),
      );
      await cubit.load(initialRegion: 'Floresta', season: '2023');
    });

    test('carrega times (com escudo), placar 0×0 e jogos de hoje', () {
      final form = cubit.state.form;
      expect([form.homeTeam, form.awayTeam], ['Lava Jato', 'Volta']);
      expect(form.crestOf('Lava Jato'), 'https://img/lj.png');
      expect([form.homeGoals, form.awayGoals], [0, 0]);
      expect(form.todayMatches.map((m) => m.id), ['m1', 'late']);
    });

    test('stepper não fica negativo', () {
      cubit.decrementHome();
      cubit.incrementAway();
      cubit.incrementAway();
      expect([cubit.state.form.homeGoals, cubit.state.form.awayGoals], [0, 2]);
    });

    test('publica o card sem mexer na partida quando desligado', () async {
      cubit.incrementHome();
      await cubit.submit();
      expect(createNews.created!.tag, NewsDTO.goalTag);
      expect([createNews.created!.homeGoals, createNews.created!.awayGoals], ['1', '0']);
      // Sem autor: nenhum campo novo no documento.
      expect(createNews.created!.toMap().keys,
          isNot(anyOf(contains('autor_gol_id'), contains('assistencia_id'), contains('temporada'))));
      expect(matches.updates, 0);
      expect(cubit.state, isA<SuccessGoalNotificationState>());
    });

    test('pelo atalho de hoje, publica e atualiza a partida', () async {
      cubit.pickMatch(_today);
      cubit.incrementHome();
      await cubit.submit();
      expect(matches.updates, 1);
      final state = cubit.state as SuccessGoalNotificationState;
      expect(state.matchUpdated, isTrue);
      expect(state.form.todayMatches.first.homeGoals, 2);
    });

    test('a partir de um card do feed: times na ordem do card e o placar dele', () async {
      final fromCard = GoalNotificationCubit(
        createNews,
        _FakeRegions(),
        _FakeTeams(),
        _TodayMatches(matches),
        UpdateMatchScoreUseCase(matches),
        WatchTeamPlayersUseCase(players),
        AddPlayerStatsUseCase(players),
      );
      await fromCard.load(
        initialRegion: 'Floresta',
        initial: const NewsDTO(
            tag: NewsDTO.goalTag, homeTeam: 'Volta', awayTeam: 'Lava Jato', homeGoals: '2', awayGoals: '1'),
      );
      final form = fromCard.state.form;
      expect([form.homeTeam, form.awayTeam], ['Volta', 'Lava Jato']);
      expect([form.homeGoals, form.awayGoals], [2, 1]);
      expect(form.updateMatch, isFalse);
    });

    test('placar vazio ou inválido no card vira 0', () async {
      final fromCard = GoalNotificationCubit(
        createNews,
        _FakeRegions(),
        _FakeTeams(),
        _TodayMatches(matches),
        UpdateMatchScoreUseCase(matches),
        WatchTeamPlayersUseCase(players),
        AddPlayerStatsUseCase(players),
      );
      await fromCard.load(
        initialRegion: 'Floresta',
        initial: const NewsDTO(tag: NewsDTO.goalTag, homeTeam: 'Volta', awayTeam: 'Lava Jato', awayGoals: 'x'),
      );
      expect([fromCard.state.form.homeGoals, fromCard.state.form.awayGoals], [0, 0]);
    });

    test('a partir de um card de partida (não é de hoje): vinculada e atualizada', () async {
      const old = MatchDTO(
        id: 'antiga',
        homeTeam: 'Volta',
        awayTeam: 'Lava Jato',
        date: '03/06',
        region: 'Floresta',
        homeGoals: 3,
        awayGoals: 0,
      );
      final fromMatch = GoalNotificationCubit(
        createNews,
        _FakeRegions(),
        _FakeTeams(),
        _TodayMatches(matches),
        UpdateMatchScoreUseCase(matches),
        WatchTeamPlayersUseCase(players),
        AddPlayerStatsUseCase(players),
      );
      await fromMatch.load(initialRegion: 'Floresta', season: '2023', initialMatch: old);
      var form = fromMatch.state.form;
      expect([form.homeTeam, form.awayTeam], ['Volta', 'Lava Jato']);
      expect([form.homeGoals, form.awayGoals], [3, 0]);
      expect(form.updateMatch, isTrue);
      expect(form.linkedMatch, old);

      fromMatch.incrementAway();
      await fromMatch.submit();
      expect(matches.updates, 1);
      form = fromMatch.state.form;
      expect(form.pinnedMatch!.awayGoals, 1);

      // Trocar o confronto desfaz o vínculo com a partida de origem
      // (Lava Jato x Volta passaria a apontar para o jogo de hoje).
      fromMatch.selectAwayTeam('Riacho');
      expect(fromMatch.state.form.linkedMatch, isNull);
      fromMatch.selectHomeTeam('Lava Jato');
      fromMatch.selectAwayTeam('Volta');
      expect(fromMatch.state.form.linkedMatch!.id, 'm1');
    });

    test('card publicado mas partida falhou → estado parcial', () async {
      matches.failUpdate = true;
      cubit.pickMatch(_today);
      await cubit.submit();
      expect(createNews.created, isNotNull);
      expect(cubit.state, isA<PartialGoalNotificationState>());
    });

    test('carrega os elencos do confronto; trocar o mandante limpa o autor', () async {
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.form.homeSquad.map((p) => p.id), ['cassin', 'dudu']);
      expect(cubit.state.form.awaySquad.map((p) => p.id), ['gabriel']);

      cubit.setScorer(_squads['Lava Jato']![0], null);
      expect(cubit.state.form.scorer?.id, 'dudu');
      cubit.selectHomeTeam('Riacho');
      expect(cubit.state.form.scorer, isNull);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.form.homeSquad.map((p) => p.id), ['rafa']);
    });

    test('assistência só vale para outro jogador do mesmo time', () async {
      await Future<void>.delayed(Duration.zero);
      final dudu = _squads['Lava Jato']![0];
      cubit.setScorer(dudu, _squads['Lava Jato']![1]);
      expect(cubit.state.form.assistant?.id, 'cassin');
      cubit.setScorer(dudu, _squads['Volta']![0]);
      expect(cubit.state.form.assistant, isNull);
      cubit.setScorer(dudu, dudu);
      expect(cubit.state.form.assistant, isNull);
    });

    test('o − do time do autor desfaz o autor; o do outro time não', () async {
      await Future<void>.delayed(Duration.zero);
      cubit.incrementHome();
      cubit.incrementAway();
      cubit.setScorer(_squads['Lava Jato']![0], _squads['Lava Jato']![1]);
      cubit.decrementAway();
      expect(cubit.state.form.scorer?.id, 'dudu');
      cubit.decrementHome();
      expect(cubit.state.form.scorer, isNull);
      expect(cubit.state.form.assistant, isNull);
    });

    test('publica somando +1 gol no autor e +1 assistência', () async {
      await Future<void>.delayed(Duration.zero);
      cubit.incrementHome();
      cubit.setScorer(_squads['Lava Jato']![0], _squads['Lava Jato']![1]);
      await cubit.submit();

      expect(players.increments, ['dudu:g1:a0', 'cassin:g0:a1']);
      // O card guarda quem marcou/deu o passe e a temporada deles.
      final card = createNews.created!;
      expect([card.scorerId, card.scorerName, card.assistantId, card.assistantName, card.season],
          ['dudu', 'Dudu', 'cassin', 'Cassin', '2023']);
      expect(card.toMap(), containsPair('autor_gol_id', 'dudu'));
      expect(card.toMap(), containsPair('assistencia', 'Cassin'));
      expect(card.toMap(), containsPair('temporada', '2023'));
      final state = cubit.state as SuccessGoalNotificationState;
      expect(state.scorer?.name, 'Dudu');
      expect(state.assistant?.name, 'Cassin');
      // Pronto para o próximo gol, com os números locais atualizados.
      expect(state.form.scorer, isNull);
      expect(state.form.homeSquad.firstWhere((p) => p.id == 'dudu').goals, 4);
      expect(state.form.homeSquad.firstWhere((p) => p.id == 'cassin').assists, 2);
    });

    test('falha ao somar nos jogadores → estado parcial (card já publicado)', () async {
      await Future<void>.delayed(Duration.zero);
      players.fail = true;
      cubit.setScorer(_squads['Lava Jato']![0], null);
      await cubit.submit();
      expect(createNews.created, isNotNull);
      final state = cubit.state as PartialGoalNotificationState;
      expect(state.failure, GoalPartialFailure.stats);
    });

    test('o "+" define o time do gol; o card leva nome e escudo dele', () async {
      cubit.incrementAway();
      expect(cubit.state.form.scoringTeam, 'Volta');
      cubit.incrementHome();
      expect(cubit.state.form.scoringTeam, 'Lava Jato');
      await cubit.submit();
      final map = createNews.created!.toMap();
      expect(map, containsPair('time_marcador', 'Lava Jato'));
      expect(map, containsPair('escudo_marcador', 'https://img/lj.png'));
      // Cores do time que marcou: pintam o fundo do card.
      expect(map, containsPair('cor_marcador', '#C62828'));
      expect(map, containsPair('cor_marcador_secundaria', '#FFFFFF'));
      expect(cubit.state.form.scoringTeam, isNull);
    });

    test('o "−" do time do gol limpa; sem "+" o card não tem time do gol', () async {
      cubit.incrementHome();
      cubit.decrementAway();
      expect(cubit.state.form.scoringTeam, 'Lava Jato');
      cubit.decrementHome();
      expect(cubit.state.form.scoringTeam, isNull);
      await cubit.submit();
      expect(createNews.created!.toMap().keys, isNot(contains('time_marcador')));
    });
  });

  group('AddPlayerStatsUseCase', () {
    const dudu = PlayerDTO(id: 'dudu', name: 'Dudu', team: 'Lava Jato');
    const cassin = PlayerDTO(id: 'cassin', name: 'Cassin', team: 'Lava Jato');

    test('só autor, autor + assistência, mesmo jogador e nenhum', () async {
      final repository = _FakePlayersRepository();
      final useCase = AddPlayerStatsUseCase(repository);

      await useCase(scorer: dudu);
      expect(repository.increments, ['dudu:g1:a0']);

      repository.increments.clear();
      await useCase(scorer: dudu, assistant: cassin);
      expect(repository.increments, ['dudu:g1:a0', 'cassin:g0:a1']);

      repository.increments.clear();
      await useCase(scorer: dudu, assistant: dudu);
      expect(repository.increments, ['dudu:g1:a0']);

      repository.increments.clear();
      await useCase();
      expect(repository.increments, isEmpty);
    });
  });
}
