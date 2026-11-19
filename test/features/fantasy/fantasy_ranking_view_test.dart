import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_ranking_view.dart';

FantasyRankingEntry _e(String uid, double points) =>
    FantasyRankingEntry(uid: uid, name: uid.toUpperCase(), points: points);

void main() {
  final entries = sortFantasyRanking([_e('a', 60), _e('b', 50), _e('c', 50), _e('d', 30), _e('e', 0)]);
  final positions = fantasyPositions(entries);

  test('barra: pontos / pontos do líder, limitada a 0..1; líder sem pontos = 0', () {
    expect(FantasyRankingView.barFraction(entries, 0), 1);
    expect(FantasyRankingView.barFraction(entries, 3), closeTo(0.5, 1e-9));
    expect(FantasyRankingView.barFraction(entries, 4), 0);
    expect(FantasyRankingView.barFraction([_e('x', 0), _e('y', -3)], 1), 0);
    expect(FantasyRankingView.barFraction(const [], 0), 0);
  });

  test('distância para o de cima: 0 no 1º e no empate', () {
    expect(FantasyRankingView.gapToAbove(entries, 0), 0);
    expect(FantasyRankingView.gapToAbove(entries, 1), 10);
    expect(FantasyRankingView.gapToAbove(entries, 2), 0);
    expect(FantasyRankingView.gapToAbove(entries, 3), 20);
  });

  test('empate: as duas linhas com a mesma posição', () {
    expect(positions, [1, 2, 2, 4, 5]);
    expect([for (var i = 0; i < positions.length; i++) FantasyRankingView.isTied(positions, i)],
        [false, true, true, false, false]);
    expect(FantasyRankingView.isTied(positions, 9), isFalse);
  });

  test('quem a conta persegue: o mais perto com mais pontos; líder = nulo', () {
    final chase = FantasyRankingView.chase(entries, 'd', 30)!;
    expect((chase.name, chase.gap), ('C', 20));
    expect(chase.progress, closeTo(0.6, 1e-9));
    // Empatado com quem está acima: persegue o próximo com mais pontos.
    expect(FantasyRankingView.chase(entries, 'c', 50)!.name, 'A');
    expect(FantasyRankingView.chase(entries, 'a', 60), isNull);
    // Fora da lista (além do top): o último com mais pontos.
    expect(FantasyRankingView.chase(entries, 'z', 10)!.name, 'D');
  });

  test('participantes: os carregados; no limite da consulta, o total do campeonato', () {
    expect(FantasyRankingView.participants(entries, total: 99), 5);
    expect(FantasyRankingView.participants(entries, limit: 5, total: 99), 99);
    expect(FantasyRankingView.participants(entries, limit: 5), 5);
  });
}
