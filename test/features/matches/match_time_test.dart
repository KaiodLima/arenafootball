import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_clock.dart';
import 'package:arena_soccer/features/matches/domain/match_time.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';

void main() {
  // Partida de 01/11 às 17:55 (Brasília); o aparelho pode estar em qualquer fuso.
  const match = MatchDTO(homeTeam: 'Casa', awayTeam: 'Fora', date: '01/11', time: '17:55');

  test('hoje em Brasília perto da meia-noite UTC ainda é o dia anterior', () {
    expect(MatchTime.today(DateTime.utc(2026, 11, 2, 1, 0)), DateTime(2026, 11, 1));
    expect(MatchTime.today(DateTime.utc(2026, 11, 2, 3, 0)), DateTime(2026, 11, 2));
  });

  test('horário de Brasília vira o instante UTC + 3 h', () {
    expect(MatchTime.instant(2026, 11, 1, 17, 55), DateTime.utc(2026, 11, 1, 20, 55));
    expect(MatchClock.kickoffOf(match, DateTime.utc(2026, 11, 1, 12)), DateTime.utc(2026, 11, 1, 20, 55));
  });

  test('status do card segue o horário de Brasília, não o fuso do aparelho', () {
    // 17:00 em Brasília (20:00 UTC): ainda vai começar.
    final before = MatchCardStatus.of(match, DateTime.utc(2026, 11, 1, 20, 0));
    expect(before.upcoming, isTrue);
    expect(before.dayOffset, 0);
    // 18:30 em Brasília: em andamento.
    expect(MatchCardStatus.of(match, DateTime.utc(2026, 11, 1, 21, 30)).live, isTrue);
    // 20:00 em Brasília: passou de 17:55 + 90 min.
    expect(MatchCardStatus.of(match, DateTime.utc(2026, 11, 1, 23, 0)).finished, isTrue);
  });

  test('faixa de horário não muda com o fuso', () {
    expect(MatchCardStatus.timeRange(match), '17:55 – 19:25');
  });
}
