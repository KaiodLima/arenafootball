import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_state.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

void main() {
  const base = PlayerRequestDTO(
    userId: 'u1',
    name: 'Kaio',
    team: 'Volta',
    region: 'Floresta',
    season: '2023',
    playerId: 'p1',
  );

  test('aprovado: time, atleta e temporada para o menu', () {
    final state = MyPlayerState(request: base.copyWith(status: PlayerRequestStatus.approved));
    expect(state.teamName, 'Volta');
    expect(state.playerId, 'p1');
    expect(state.season, '2023');
  });

  test('pendente, rejeitado, fora do elenco ou sem pedido: não é jogador', () {
    for (final status in [PlayerRequestStatus.pending, PlayerRequestStatus.rejected, PlayerRequestStatus.removed]) {
      final state = MyPlayerState(request: base.copyWith(status: status));
      expect(state.teamName, isNull, reason: status.key);
      expect(state.playerId, isNull, reason: status.key);
    }
    expect(const MyPlayerState().teamName, isNull);
  });

  test('pelo atleta: dois times (um por competição); pedido novo pendente não tira o time', () {
    const player = PlayerDTO(id: 'p1', name: 'Kaio', team: 'Volta', teamId: '2', enrollments: [
      PlayerEnrollment(championshipId: 7, teamId: '2', team: 'Volta'),
      PlayerEnrollment(championshipId: 9, teamId: '1', team: 'Lava Jato'),
    ]);
    final state = MyPlayerState(player: player, request: base.copyWith(status: PlayerRequestStatus.pending));
    expect(state.teamNames, ['Volta', 'Lava Jato']);
    expect(state.teamName, 'Volta e Lava Jato');
    expect(state.playerId, 'p1');
    expect(state.teamId, '2');
  });

  test('atleta sem time (fora do elenco): não é jogador', () {
    const player = PlayerDTO(id: 'p1', name: 'Kaio', team: '');
    expect(const MyPlayerState(player: player).teamName, isNull);
    expect(const MyPlayerState(player: player).playerId, isNull);
  });
}
