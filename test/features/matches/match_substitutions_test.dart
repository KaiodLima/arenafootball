import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_report/player_grid_sheet.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

PlayerDTO _p(String id, {String position = ''}) => PlayerDTO(id: id, name: id, team: 'Leões', position: position);

void main() {
  const lineup = [
    LineupEntry(playerId: 'a', playerName: 'a', number: 9),
    LineupEntry(playerId: 'b', playerName: 'b', number: 1),
    LineupEntry(playerId: 'c', playerName: 'c', number: 4),
    LineupEntry(playerId: 'r', playerName: 'r', starter: false),
  ];

  test('em campo: titulares, + quem entrou, − quem saiu, − expulsos', () {
    final onField = MatchReport.onField(
      lineup: lineup,
      substitutions: const [
        MatchSubstitution(id: 's1', side: MatchSide.home, outId: 'a', outName: 'a', inId: 'r', inName: 'r', minute: 60),
      ],
      bookings: const [MatchBooking(id: 'k', side: MatchSide.home, type: BookingType.red, playerId: 'c')],
      side: MatchSide.home,
    );
    expect(onField, {'b', 'r'});
  });

  test('sem escalação: nulo (o modal mostra o elenco todo)', () {
    expect(
      MatchReport.onField(lineup: const [], substitutions: const [], bookings: const [], side: MatchSide.home),
      isNull,
    );
  });

  test('modal agrupado por posição, camisa e nome', () {
    final sections = groupedForPicking([
      _p('a', position: 'atacante'),
      _p('b', position: 'goleiro'),
      _p('c', position: 'zagueiro'),
      _p('z'),
      _p('x', position: 'atacante'),
    ], lineup);
    expect(sections.map((s) => s.position), [
      PlayerPosition.goalkeeper,
      PlayerPosition.defender,
      PlayerPosition.forward,
      null,
    ]);
    // Atacantes: o de camisa 9 antes do sem número.
    expect(sections[2].items.map((i) => i.player.id), ['a', 'x']);
  });

  test('linha do tempo com a substituição na ordem do minuto', () {
    final events = MatchReport.timeline(
      const [MatchGoal(id: 'g', side: MatchSide.home, minute: 70)],
      const [],
      const [MatchSubstitution(id: 's', side: MatchSide.home, outId: 'a', outName: 'a', inId: 'r', inName: 'r', minute: 60)],
    );
    expect(events.map((e) => e.id), ['s', 'g']);
    expect(events.first.isSubstitution, isTrue);
  });

  test('substituição grava e lê no mesmo formato', () {
    const sub = MatchSubstitution(id: 's', side: MatchSide.away, outId: 'a', outName: 'Ana', inId: 'r', inName: 'Rui', minute: 61);
    expect(MatchSubstitution.fromMap(sub.toMap()), sub);
    expect(sub.toMap()['idEntra'], 'r');
    expect(MatchReport.substitutedOut([sub], MatchSide.away), {'a'});
  });
}
