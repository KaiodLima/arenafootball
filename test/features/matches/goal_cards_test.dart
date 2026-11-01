import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/goal_cards.dart';
import 'package:arena_soccer/features/matches/domain/usecases/publish_goal_cards_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

MatchGoal _goal(String id, MatchSide side, {String scorer = '', String assist = ''}) => MatchGoal(
      id: id,
      side: side,
      scorerId: scorer,
      scorerName: scorer.toUpperCase(),
      assistantId: assist,
      assistantName: assist.toUpperCase(),
    );

class _CreateNews implements CreateNewsUseCase {
  final created = <NewsDTO>[];

  @override
  Future<Either<Failure, void>> call({
    required NewsDTO news,
    File? cover,
    List<File> album = const [],
    bool forApproval = false,
  }) async {
    created.add(news);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _News implements INewsRepository {
  final List<NewsDTO> cards;
  final deleted = <String>[];
  final updated = <NewsDTO>[];

  _News(this.cards);

  @override
  Future<Either<Failure, List<NewsDTO>>> getGoalCardsByGoalIds(List<String> goalIds) async =>
      Right(cards.where((c) => goalIds.contains(c.goalId)).toList());

  @override
  Future<Either<Failure, void>> deleteNews(String id) async {
    deleted.add(id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateNews(NewsDTO news) async {
    updated.add(news);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Teams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) => Stream.value(
        const Right([
          TeamDTO(id: 'tA', name: 'Alfa', imageUrl: 'https://alfa', primaryColor: '#FF0000', secondaryColor: '#FFFFFF'),
        ]),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('gols novos com o placar de cada momento; removidos e editados à parte', () {
    final before = [
      _goal('g1', MatchSide.home, scorer: 'ana'),
      _goal('g2', MatchSide.away, scorer: 'bia'),
    ];
    final after = [
      _goal('g1', MatchSide.home, scorer: 'caio'), // autor trocado
      _goal('g3', MatchSide.home, scorer: 'ana'), // novo: 2×0
      _goal('g4', MatchSide.away), // novo sem autor: 2×1
    ];
    final plan = GoalCardsPlan.of(before, after);
    expect(plan.added.map((i) => (i.goal.id, i.homeGoals, i.awayGoals)), [('g3', 2, 0), ('g4', 2, 1)]);
    expect(plan.removed.map((g) => g.id), ['g2']);
    expect(plan.changed.map((g) => g.id), ['g1']);
    expect(GoalCardsPlan.of(before, before).isEmpty, isTrue);
  });

  test('publica os cards novos, apaga o do gol removido e atualiza o editado', () async {
    const match = MatchDTO(
      id: 'm1',
      homeTeam: 'Alfa',
      awayTeam: 'Beta',
      homeTeamId: 'tA',
      awayTeamId: 'tB',
      championshipId: 7,
      region: 'Floresta',
    );
    final news = _News(const [
      NewsDTO(id: 'n1', tag: NewsDTO.goalTag, goalId: 'g1', scorerId: 'ana', scorerName: 'ANA'),
      NewsDTO(id: 'n2', tag: NewsDTO.goalTag, goalId: 'g2', scorerId: 'bia', scorerName: 'BIA'),
    ]);
    final create = _CreateNews();
    final result = await PublishGoalCardsUseCase(create, news, _Teams()).call(
      match: match,
      before: [_goal('g1', MatchSide.home, scorer: 'ana'), _goal('g2', MatchSide.away, scorer: 'bia')],
      after: [_goal('g1', MatchSide.home, scorer: 'caio', assist: 'davi'), _goal('g3', MatchSide.home, scorer: 'ana')],
      season: '2026',
    );
    expect(result.right, 1);
    expect(news.deleted, ['n2']);
    expect(news.updated.single.scorerId, 'caio');
    expect(news.updated.single.assistantId, 'davi');
    final card = create.created.single;
    expect((card.homeGoals, card.awayGoals), ('2', '0'));
    expect(card.goalId, 'g3');
    expect(card.matchId, 'm1');
    expect(card.championshipId, 7);
    expect(card.scoringTeamCrest, 'https://alfa');
    expect(card.scoringTeamPrimaryColor, '#FF0000');
    expect(card.toMap()['id_gol'], 'g3');
  });
}
