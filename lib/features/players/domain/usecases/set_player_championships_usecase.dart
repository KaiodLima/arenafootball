import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Em quais competições do time o atleta joga por ele (marcar/desmarcar no
/// "Elenco geral"). As de outro time não mudam.
class SetPlayerChampionshipsUseCase {
  final IPlayersRepository _repository;

  SetPlayerChampionshipsUseCase(this._repository);

  Future<Either<Failure, void>> call(
    PlayerDTO player, {
    required String teamId,
    required String team,
    required Set<int> selected,
    required List<int> teamChampionships,
    String? season,
  }) =>
      _repository.setChampionships(
        player,
        teamId: teamId,
        team: team,
        selected: selected,
        teamChampionships: teamChampionships,
        season: season,
      );
}
