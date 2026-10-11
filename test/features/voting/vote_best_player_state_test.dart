import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_state.dart';

const _home = [
  PlayerDTO(id: '1', name: 'João Pedro', team: 'Lava Jato'),
  PlayerDTO(id: '2', name: 'Dudu', team: 'Lava Jato'),
];
const _away = [PlayerDTO(id: '3', name: 'Cassin', team: 'Volta')];

void main() {
  test('visiblePlayers mostra o elenco do time escolhido', () {
    expect(const VoteBestPlayerState(homePlayers: _home, awayPlayers: _away).visiblePlayers, _home);
    expect(const VoteBestPlayerState(homePlayers: _home, awayPlayers: _away, showAway: true).visiblePlayers, _away);
  });

  test('busca sem diferenciar acento e caixa', () {
    const state = VoteBestPlayerState(homePlayers: _home, query: ' JOAO ');
    expect(state.visiblePlayers.map((p) => p.id), ['1']);
    expect(state.currentSquad, _home);
  });

  test('isMyVote compara nome e time do voto gravado', () {
    const state = VoteBestPlayerState(
      homePlayers: _home,
      myVote: VoteDTO(voterId: 'u', playerName: 'Dudu', team: 'Lava Jato'),
      selected: PlayerDTO(id: '2', name: 'Dudu', team: 'Lava Jato'),
    );
    expect(state.isMyVote(_home[1]), isTrue);
    expect(state.isMyVote(_home[0]), isFalse);
    expect(state.isMyVote(const PlayerDTO(name: 'Dudu', team: 'Volta')), isFalse);
    expect(state.selectedIsMyVote, isTrue);
  });

  test('sem voto gravado nada é "meu voto"', () {
    const state = VoteBestPlayerState(homePlayers: _home, selected: PlayerDTO(id: '1', name: 'João Pedro', team: 'Lava Jato'));
    expect(state.isMyVote(_home[0]), isFalse);
    expect(state.selectedIsMyVote, isFalse);
  });
}
