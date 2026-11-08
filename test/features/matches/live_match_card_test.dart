import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/live_match_card.dart';
import 'package:arena_soccer/features/news/data/dtos/live_event.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

const _base = MatchDTO(
  id: 'm1',
  homeTeam: 'Leões',
  awayTeam: 'Tigres',
  homeTeamId: 't1',
  awayTeamId: 't2',
  championshipId: 11,
  region: 'Floresta',
);
const _goal = MatchGoal(id: 'g1', side: MatchSide.home, scorerId: 'p1', scorerName: 'Ana', minute: 12);
const _goal2 = MatchGoal(id: 'g2', side: MatchSide.home, scorerId: 'p2', scorerName: 'Bia', minute: 40);
const _red =
    MatchBooking(id: 'c1', side: MatchSide.away, type: BookingType.red, playerId: 'p9', playerName: 'Zé', minute: 30);
const _sub = MatchSubstitution(
    id: 's1', side: MatchSide.away, outId: 'p9', outName: 'Zé', inId: 'p8', inName: 'Rui', minute: 50);

void main() {
  final teams = {
    't1': const TeamDTO(id: 't1', name: 'Leões', imageUrl: 'https://x/l.png', primaryColor: '#FF0000'),
    't2': const TeamDTO(id: 't2', name: 'Tigres'),
  };

  test('1x0 cria o card; 2x0 destaca o lance novo e sobe (mesmo id)', () {
    final first = _base.copyWith(goals: const [_goal]);
    final last1 = LiveMatchCard.newestEvent(_base, first);
    expect(last1?.id, 'g1');
    final card1 = LiveMatchCard.build(first, teams, season: '2026', last: last1);
    expect(card1.id, NewsDTO.liveIdOf('m1'));
    expect(card1.isLive, isTrue);
    expect('${card1.homeGoals} × ${card1.awayGoals}', '1 × 0');

    final second = first.copyWith(goals: const [_goal, _goal2]);
    final last2 = LiveMatchCard.newestEvent(first, second);
    final card2 = LiveMatchCard.build(second, teams, last: last2);
    expect(card2.id, card1.id);
    expect(card2.homeGoals, '2');
    expect(card2.lastEvent?.player, 'Bia');
    // Texto para o app antigo (mostra como notícia).
    expect(card2.title, 'Leões 2 × 0 Tigres · ao vivo');
    expect(card2.description, "⚽ 40' Bia");
  });

  test('cartão e substituição também entram no card, na ordem do minuto', () {
    final before = _base.copyWith(goals: const [_goal]);
    final after = before.copyWith(bookings: const [_red], substitutions: const [_sub]);
    final last = LiveMatchCard.newestEvent(before, after);
    expect(last?.type, LiveEventType.substitution);
    final card = LiveMatchCard.build(after, teams, last: last);
    expect(card.liveEvents.map((e) => e.id), ['g1', 'c1', 's1']);
    expect(card.liveEvents[1].type, LiveEventType.red);
  });

  test('só apagar um lance: sem lance novo (o card não sobe)', () {
    final before = _base.copyWith(goals: const [_goal, _goal2]);
    final after = _base.copyWith(goals: const [_goal]);
    expect(LiveMatchCard.newestEvent(before, after), isNull);
    expect(LiveMatchCard.build(after, teams).lastEvent?.id, 'g1');
  });

  test('vermelho novo vira o card oculto do push', () {
    final before = _base.copyWith(goals: const [_goal]);
    final after = before.copyWith(bookings: const [_red]);
    final reds = LiveMatchCard.newReds(before, after);
    expect(reds.single.id, 'c1');
    final card = LiveMatchCard.redCard(after, reds.single, teams, season: '2026');
    expect(card.tag, NewsDTO.bookingTag);
    expect(card.isVisible, isFalse);
    expect(card.description, "Zé (Tigres) · 30'");
    expect(card.toMap()['id_partida'], 'm1');
  });

  test('card ao vivo grava os lances e o último', () {
    final card = LiveMatchCard.build(_base.copyWith(goals: const [_goal]), teams, last: null);
    final map = card.toMap();
    expect(map['tag'], 'aovivo');
    expect((map['lances'] as List).single['jogador'], 'Ana');
    expect((map['ultimo_lance'] as Map)['tipo'], 'gol');
    expect(LiveEvent.fromMap(Map<String, dynamic>.from(map['ultimo_lance'] as Map)), card.lastEvent);
    expect(map['escudo_casa'], 'https://x/l.png');
  });

  test('fase do card: encerrada, intervalo ou andamento (não volta a "ao vivo")', () {
    final finished = _base.copyWith(goals: const [_goal], manualStatus: MatchManualStatus.finished);
    final card = LiveMatchCard.build(finished, teams);
    expect(card.matchStatus, NewsDTO.matchStatusFinished);
    expect(card.title, 'Leões 1 × 0 Tigres · fim de jogo');
    expect(card.toMap()['status_partida'], 'encerrada');

    final halfTime = _base.copyWith(manualStatus: MatchManualStatus.halfTime);
    expect(LiveMatchCard.statusOf(halfTime, DateTime(2026, 11, 7)), NewsDTO.matchStatusHalfTime);
    expect(LiveMatchCard.statusOf(_base, DateTime(2026, 11, 7)), NewsDTO.matchStatusLive);

    // Sem nada marcado, mas passado o fim esperado (horário + duração): encerrada.
    final old = _base.copyWith(date: '01/11/2026', time: '15:00');
    expect(LiveMatchCard.statusOf(old, DateTime(2026, 11, 7)), NewsDTO.matchStatusFinished);
  });
}
