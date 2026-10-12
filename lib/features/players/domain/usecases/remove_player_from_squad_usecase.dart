import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Admin tira do elenco um jogador vinculado a uma conta: ele fica sem time,
/// mantém os números e pode pedir outro time ([season] nulo = corrente).
class RemovePlayerFromSquadUseCase {
  final IPlayersRepository _repository;

  RemovePlayerFromSquadUseCase(this._repository);

  Future<Either<Failure, void>> call(PlayerDTO player, {String? season}) =>
      _repository.removeFromSquad(player, season: season);
}
