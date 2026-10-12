import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_state.dart';

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
}
