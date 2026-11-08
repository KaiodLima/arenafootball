import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/publish_goal_cards_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/save_match_report_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_goals_usecase.dart';

MatchBooking _yellow(String id, String player, {int? minute}) => MatchBooking(
    id: id, side: MatchSide.home, type: BookingType.yellow, playerId: player, playerName: player, minute: minute);

class _Goals implements UpdateMatchGoalsUseCase {
  int calls = 0;

  @override
  Future<Either<Failure, MatchDTO>> call({
    required MatchDTO match,
    required List<MatchGoal> before,
    required List<MatchGoal> after,
    String? season,
  }) async {
    calls++;
    return Right(match.copyWith(
      goals: after,
      homeGoals: after.where((g) => g.side == MatchSide.home).length,
      awayGoals: after.where((g) => g.side == MatchSide.away).length,
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cards implements PublishGoalCardsUseCase {
  int calls = 0;

  @override
  Future<Either<Failure, int>> call({
    required MatchDTO match,
    required List<MatchGoal> before,
    required List<MatchGoal> after,
    String? season,
  }) async {
    calls++;
    return const Right(1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Matches implements IMatchesRepository {
  MatchDTO? saved;

  @override
  Future<Either<Failure, void>> updateReport(MatchDTO match, {String? season}) async {
    saved = match;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('linha do tempo em ordem de minuto; sem minuto no fim; gol antes do cartão', () {
    final events = MatchReport.timeline(
      const [
        MatchGoal(id: 'g1', side: MatchSide.home, minute: 30),
        MatchGoal(id: 'g2', side: MatchSide.away),
        MatchGoal(id: 'g3', side: MatchSide.away, minute: 12),
      ],
      [_yellow('c1', 'ana', minute: 30), _yellow('c2', 'bia', minute: 5)],
    );
    expect(events.map((e) => e.id), ['c2', 'g3', 'g1', 'c1', 'g2']);
  });

  test('2º amarelo lança o vermelho; tirar o amarelo tira o vermelho junto', () {
    var list = MatchReport.addBooking(const [], _yellow('c1', 'ana', minute: 10));
    expect(list, hasLength(1));
    list = MatchReport.addBooking(list, _yellow('c2', 'ana', minute: 60), newId: () => 'r1');
    expect(list.map((b) => (b.id, b.type, b.secondYellow)), [
      ('c1', BookingType.yellow, false),
      ('c2', BookingType.yellow, false),
      ('r1', BookingType.red, true),
    ]);
    expect(list.last.minute, 60);
    // Terceiro amarelo (já expulso): não lança outro vermelho.
    expect(MatchReport.addBooking(list, _yellow('c3', 'ana')).where((b) => b.type == BookingType.red), hasLength(1));
    expect(MatchReport.removeBooking(list, 'c2').map((b) => b.id), ['c1']);
  });

  test('minuto sugerido só com o jogo em andamento', () {
    final now = DateTime(2026, 11, 1, 16, 30);
    final live = MatchDTO(
      homeTeam: 'A',
      awayTeam: 'B',
      manualStatus: MatchManualStatus.live,
      startedAt: now.subtract(const Duration(minutes: 23)),
    );
    // 23 minutos completos = jogando o 24º (como o relógio do card).
    expect(MatchReport.suggestedMinute(live, now), 24);
    expect(MatchReport.suggestedMinute(live.copyWith(manualStatus: MatchManualStatus.finished), now), isNull);
  });

  test('cartões e escalação vão e voltam do Firestore', () {
    const booking = MatchBooking(
      id: 'c1',
      side: MatchSide.away,
      type: BookingType.red,
      playerId: 'p1',
      playerName: 'Ana',
      minute: 77,
      secondYellow: true,
    );
    expect(MatchBooking.fromMap(booking.toMap()), booking);
    const lineup = MatchLineup(
      home: [LineupEntry(playerId: 'p1', playerName: 'Ana', number: 10)],
      away: [LineupEntry(playerId: 'p2', playerName: 'Bia', starter: false)],
    );
    expect(MatchLineup.fromMap(lineup.toMap()), lineup);
    expect(MatchReport.lineupCount(lineup.home), (starters: 1, subs: 0));
    const goal = MatchGoal(id: 'g1', side: MatchSide.home, minute: 12);
    expect(MatchGoal.fromMap(goal.toMap()).minute, 12);
  });

  test('salvar súmula: gols só pelo caminho dos números, uma vez; resto numa gravação', () async {
    const original = MatchDTO(id: 'm1', homeTeam: 'A', awayTeam: 'B');
    const before = [MatchGoal(id: 'g1', side: MatchSide.home)];
    final goals = _Goals();
    final cards = _Cards();
    final matches = _Matches();
    final save = SaveMatchReportUseCase(goals, cards, matches);

    // Só a escalação e o árbitro mudaram: os gols não passam pelos números.
    final edited = original.copyWith(goals: before, referee: 'Zé');
    final result = await save(original: original, goalsBefore: before, edited: edited);
    expect(goals.calls, 0);
    expect(cards.calls, 0);
    expect(matches.saved?.referee, 'Zé');
    expect(result.right.publishedCards, 0);

    // Gol novo: números uma vez e o card.
    final withGoal = edited.copyWith(goals: [...before, const MatchGoal(id: 'g2', side: MatchSide.away, minute: 40)]);
    final second = await save(original: original, goalsBefore: before, edited: withGoal);
    expect(goals.calls, 1);
    expect(cards.calls, 1);
    expect((second.right.match.homeGoals, second.right.match.awayGoals), (1, 1));
    expect(second.right.publishedCards, 1);
  });

  test('cartões do atleta nas partidas', () {
    final matches = [
      MatchDTO(homeTeam: 'A', awayTeam: 'B', bookings: [_yellow('c1', 'p1'), _yellow('c2', 'p2')]),
      const MatchDTO(homeTeam: 'A', awayTeam: 'C', bookings: [
        MatchBooking(id: 'c3', side: MatchSide.home, type: BookingType.red, playerId: 'p1'),
      ]),
    ];
    expect(MatchReport.bookingsOf(matches, 'p1'), (yellow: 1, red: 1));
  });
}
