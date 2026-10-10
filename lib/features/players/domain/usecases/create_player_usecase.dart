import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Cadastra um jogador. Como no app antigo, sempre na temporada corrente
/// (coleção `jogadores` sem sufixo) e sem foto (a foto é enviada depois,
/// pela tela do elenco).
class CreatePlayerUseCase {
  final IPlayersRepository _repository;

  CreatePlayerUseCase(this._repository);

  Future<Either<Failure, void>> call(PlayerDTO player) =>
      _repository.createPlayer(player.copyWith(name: player.name.trim(), imageUrl: ''));
}
