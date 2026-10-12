import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';

void main() {
  tearDown(SeasonCollection.reset);

  test('2023 sem sufixo, as outras com o ano', () {
    expect(SeasonCollection.name('times', '2023'), 'times');
    expect(SeasonCollection.name('times', '2022'), 'times2022');
    expect(SeasonCollection.name('times', '2024'), 'times2024');
  });

  test('sem temporada = a atual (padrão 2023, depois a configurada)', () {
    expect(SeasonCollection.name('partidas', null), 'partidas');
    SeasonCollection.configure(current: '2024', seasons: ['2022', '2023']);
    expect(SeasonCollection.currentSeason, '2024');
    expect(SeasonCollection.name('partidas', null), 'partidas2024');
    expect(SeasonCollection.name('partidas', ''), 'partidas2024');
    // A atual sempre entra na lista, em ordem.
    expect(SeasonCollection.seasons, ['2022', '2023', '2024']);
  });

  test('config vazia não muda nada', () {
    SeasonCollection.configure(current: '', seasons: ['2030']);
    expect(SeasonCollection.currentSeason, '2023');
  });

  test('próxima temporada', () {
    expect(SeasonsConfigDTO.nextSeason('2023'), '2024');
    expect(SeasonsConfigDTO.nextSeason('2029'), '2030');
  });
}
