import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_board.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/domain/suggested_achievements.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/save_achievement_usecase.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/achievement_form_cubit.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';

const _voter = AchievementDTO(id: 'v1', title: 'Primeiro voto', metric: AchievementMetric.votes, points: 10);
const _jury = AchievementDTO(
  id: 'v10',
  title: 'Jurado',
  metric: AchievementMetric.votes,
  goal: 10,
  points: 40,
  tier: AchievementTier.silver,
  order: 1,
);
const _sharer = AchievementDTO(
  id: 's1',
  title: 'Espalha',
  metric: AchievementMetric.shares,
  category: AchievementCategory.sharing,
  points: 100,
  tier: AchievementTier.gold,
  order: 2,
);
const _inactive = AchievementDTO(id: 'x', title: 'Off', metric: AchievementMetric.votes, active: false);

AchievementProgressDTO _progress(Map<AchievementMetric, int> counters, {int streak = 0, DateTime? last}) =>
    AchievementProgressDTO(counters: counters, streak: streak, lastVisit: last);

class _Save implements SaveAchievementUseCase {
  AchievementDTO? saved;

  @override
  Future<Either<Failure, void>> call(AchievementDTO achievement) async {
    saved = achievement;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('nível pelo XP e o progresso até o próximo', () {
    expect(FanLevel.of(0), FanLevel.fan);
    expect(FanLevel.of(99), FanLevel.fan);
    expect(FanLevel.of(300), FanLevel.roots);
    expect(FanLevel.of(5000), FanLevel.legend);
    expect(FanLevel.loyal.progressOf(200), 0.5);
    expect(FanLevel.legend.progressOf(9999), 1);
  });

  test('quadro: só ativas, desbloqueia pela meta ou pelo servidor, XP e categoria', () {
    final board = AchievementBoard.of(
      catalog: const [_sharer, _jury, _voter, _inactive],
      progress: _progress({AchievementMetric.votes: 3}),
      unlocks: {'s1': AchievementUnlockDTO(achievementId: 's1', unlockedAt: DateTime(2026, 10, 1))},
    );
    expect(board.entries.map((e) => e.achievement.id), ['v1', 'v10', 's1']);
    expect(board.unlocked.map((e) => e.achievement.id), ['v1', 's1']);
    expect(board.entries[1].progress, closeTo(0.3, 0.001));
    expect(board.xp, 110);
    expect(board.level, FanLevel.loyal);
    expect(board.ofCategory(AchievementCategory.sharing).single.achievement.id, 's1');
    expect(board.recent().single.achievement.id, 's1');
    expect(board.best(limit: 1).single.achievement.id, 's1');
  });

  test('"quase lá" e prateleira: ignora secreta e ganha; ganhas primeiro, bloqueadas por progresso', () {
    const secret = AchievementDTO(id: 'z', title: 'Z', metric: AchievementMetric.votes, goal: 4, secret: true);
    const fifty = AchievementDTO(id: 'v50', title: 'V50', metric: AchievementMetric.votes, goal: 50, order: 3);
    final board = AchievementBoard.of(
      catalog: const [_voter, _jury, fifty, secret],
      progress: _progress({AchievementMetric.votes: 3, AchievementMetric.bestStreak: 6}),
    );
    // Secreta tem 75%, mas não aparece; Jurado (30%) ganha de V50 (6%).
    expect(board.almostThere()?.achievement.id, 'v10');
    expect(board.shelfOf(AchievementCategory.fan).map((e) => e.achievement.id), ['v1', 'z', 'v10', 'v50']);
    expect(board.bestStreak, 6);
    expect(AchievementBoard.of(catalog: const [_jury], progress: _progress({})).almostThere(), isNull);
  });

  test('números do app entram no lugar dos do servidor enquanto ele não grava', () {
    final progress = _progress({AchievementMetric.athleteGoals: 2}).withDerived({
      AchievementMetric.athleteGoals: 5,
      AchievementMetric.favoriteTeam: 1,
    });
    expect(progress.valueOf(AchievementMetric.athleteGoals), 5);
    expect(progress.valueOf(AchievementMetric.favoriteTeam), 1);
  });

  test('dia de uso: novo dia soma; seguido aumenta a sequência; pulou volta a 1; mesmo dia nada', () {
    final now = DateTime.utc(2026, 10, 22, 15);
    final first = DailyVisit.next(const AchievementProgressDTO(), now)!;
    expect([first.activeDays, first.streak, first.bestStreak], [1, 1, 1]);

    final yesterday = _progress(
      {AchievementMetric.activeDays: 4, AchievementMetric.bestStreak: 6},
      streak: 4,
      last: DateTime.utc(2026, 10, 21, 20),
    );
    final next = DailyVisit.next(yesterday, now)!;
    expect([next.activeDays, next.streak, next.bestStreak], [5, 5, 6]);

    final gap = _progress({AchievementMetric.activeDays: 4}, streak: 4, last: DateTime.utc(2026, 10, 19, 20));
    expect(DailyVisit.next(gap, now)!.streak, 1);

    // 01h UTC do dia 22 ainda é dia 21 em Brasília: mesmo dia de 21/10 20h UTC.
    expect(DailyVisit.next(yesterday, DateTime.utc(2026, 10, 22, 1)), isNull);
    expect(DailyVisit.next(_progress({}, last: DateTime.utc(2026, 10, 22, 10)), now), isNull);
  });

  test('DTO vai e volta; métrica desconhecida fica nula', () {
    final dto = AchievementDTO.fromMap('a', _jury.toMap());
    expect(dto, _jury.copyWith(id: 'a'));
    expect(AchievementDTO.fromMap('b', const {'titulo': 'X', 'metrica': 'nova_metrica'}).metric, isNull);
  });

  test('sugeridas: métricas válidas e metas positivas', () {
    final list = suggestedAchievements();
    expect(list.length, greaterThan(15));
    expect(list.every((a) => a.metric != null && a.goal >= 1 && a.points > 0), isTrue);
    expect(list.map((a) => a.order).toSet().length, list.length);
  });

  test('formulário: título obrigatório; métrica de sim/não força meta 1', () async {
    final save = _Save();
    final cubit = AchievementFormCubit(save, order: 7);
    await cubit.save();
    expect(cubit.state.missingTitle, isTrue);
    expect(save.saved, isNull);

    cubit
      ..edit((d) => d.copyWith(title: '  Fiel  ', goal: 20))
      ..edit((d) => d.copyWith(metric: AchievementMetric.favoriteTeam));
    expect(cubit.state.draft.goal, 1);
    await cubit.save();
    expect(save.saved?.title, 'Fiel');
    expect(save.saved?.order, 7);
    expect(cubit.state.saved, isTrue);
    await cubit.close();
  });

  testWidgets('medalha secreta bloqueada mostra "?"', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MedalBadge(tier: AchievementTier.gold, icon: 'trophy', unlocked: false, hidden: true, progress: 0.4),
      ),
    ));
    expect(find.text('?'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);
  });
}
