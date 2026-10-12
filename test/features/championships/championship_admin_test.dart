import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';

void main() {
  test('próximo id_campeonato: maior + 1, ou 1 sem nenhum', () {
    expect(ChampionshipsDataSource.nextChampionshipId([1, 2]), 3);
    expect(ChampionshipsDataSource.nextChampionshipId([5, 2, 0]), 6);
    expect(ChampionshipsDataSource.nextChampionshipId([]), 1);
  });

  test('campeonato da região escolhido pela temporada', () {
    const old = ChampionshipDTO(id: 'a', championshipId: 1, season: '2022');
    const current = ChampionshipDTO(id: 'b', championshipId: 3, season: '2023');
    expect(ChampionshipsDataSource.pickChampionshipForSeason([old, current], '2023'), current);
    expect(ChampionshipsDataSource.pickChampionshipForSeason([old], '2023'), isNull);
  });
}
