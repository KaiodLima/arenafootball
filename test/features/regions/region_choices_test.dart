import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/regions/domain/region_choices.dart';

void main() {
  const regions = ['Floresta', 'Santo Inácio', 'Centro', 'Água Verde'];

  test('busca sem acento e em ordem alfabética', () {
    expect(RegionChoices.search(regions, ''), ['Água Verde', 'Centro', 'Floresta', 'Santo Inácio']);
    expect(RegionChoices.search(regions, 'santo inacio'), ['Santo Inácio']);
    expect(RegionChoices.search(regions, 'AGUA'), ['Água Verde']);
    expect(RegionChoices.search(regions, 'xyz'), isEmpty);
  });

  test('recentes: a última na frente, sem repetir, no máximo 4', () {
    var recent = <String>[];
    for (final r in ['Floresta', 'Centro', 'Floresta', 'Água Verde', 'Santo Inácio', 'Vila']) {
      recent = RegionChoices.push(recent, r);
    }
    expect(recent, ['Vila', 'Santo Inácio', 'Água Verde', 'Floresta']);
  });

  test('recentes na folha: sem a atual, só as que existem, até 3', () {
    final shown = RegionChoices.recentToShow(
      ['Floresta', 'Removida', 'Centro', 'Santo Inácio', 'Água Verde'],
      selected: 'Floresta',
      regions: regions,
    );
    expect(shown, ['Centro', 'Santo Inácio', 'Água Verde']);
  });
}
