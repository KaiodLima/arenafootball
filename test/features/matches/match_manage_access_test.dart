import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_manage_access.dart';

void main() {
  const copa = MatchDTO(homeTeam: 'Leões', awayTeam: 'Tigres', championshipId: 11);
  const other = MatchDTO(homeTeam: 'Leões', awayTeam: 'Tigres', championshipId: 12);
  const friendly = MatchDTO(homeTeam: 'Leões', awayTeam: 'Tigres');

  test('admin gerencia qualquer partida', () {
    for (final match in [copa, other, friendly]) {
      expect(canManageMatch(match, isAdmin: true, organizerChampionshipIds: const []), isTrue);
    }
  });

  test('organizador só as partidas das competições dele (amistoso não)', () {
    expect(canManageMatch(copa, isAdmin: false, organizerChampionshipIds: const [11]), isTrue);
    expect(canManageMatch(other, isAdmin: false, organizerChampionshipIds: const [11]), isFalse);
    expect(canManageMatch(friendly, isAdmin: false, organizerChampionshipIds: const [0, 11]), isFalse);
    expect(canManageMatch(copa, isAdmin: false, organizerChampionshipIds: const []), isFalse);
  });
}
