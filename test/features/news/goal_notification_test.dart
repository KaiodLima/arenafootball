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
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

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
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season}) => Stream.value(const Right([
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

class _FakeTeams implements GetTeamsUseCase {
  @override
  Future<Either<Failure, List<TeamDTO>>> call({String? region, String? season}) async => const Right([
        TeamDTO(id: '1', name: 'Lava Jato', imageUrl: 'https://img/lj.png'),
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

    setUp(() async {
      matches = _FakeMatchesRepository();
      createNews = _FakeCreateNews();
      cubit = GoalNotificationCubit(
        createNews,
        _FakeRegions(),
        _FakeTeams(),
        _TodayMatches(matches),
        UpdateMatchScoreUseCase(matches),
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
      );
      await fromCard.load(
        initialRegion: 'Floresta',
        initial: const NewsDTO(tag: NewsDTO.goalTag, homeTeam: 'Volta', awayTeam: 'Lava Jato', homeGoals: '2', awayGoals: '1'),
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
  });
}
