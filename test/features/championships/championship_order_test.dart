import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/championship_order.dart';

ChampionshipDTO _c(String id, int number, {String season = '2026', bool closed = false, DateTime? closedAt}) =>
    ChampionshipDTO(id: id, championshipId: number, season: season, closed: closed, closedAt: closedAt);

void main() {
  test('em andamento primeiro (a mais recente na frente), encerradas no fim', () {
    final list = [
      _c('copa1', 1, closed: true, closedAt: DateTime(2026, 9, 1)),
      _c('copa2', 2),
      _c('copa3', 3, closed: true, closedAt: DateTime(2026, 10, 1)),
      _c('copa4', 4),
      _c('copa5', 5, closed: true),
      _c('antiga', 9, season: '2025'),
    ];
    expect(featuredChampionships(list, '2026').map((c) => c.id), ['copa4', 'copa2', 'copa3', 'copa1', 'copa5']);
  });

  test('sem nada na temporada: a mais recente; lista vazia = vazia', () {
    final list = [_c('a', 1, season: '2024'), _c('b', 2, season: '2025')];
    expect(featuredChampionships(list, '2026').map((c) => c.id), ['b']);
    expect(featuredChampionships(const [], '2026'), isEmpty);
  });
}
