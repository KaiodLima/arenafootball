import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/player_link.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Admin: vincula um atleta (com ou sem conta) a um time e às competições dele.
class LinkPlayerUseCase {
  final IPlayersRepository _repository;

  LinkPlayerUseCase(this._repository);

  /// Atletas dos times [teamIds] (da região) e os sem time.
  Future<Either<Failure, List<PlayerDTO>>> candidates({required List<String> teamIds, String? season}) =>
      _repository.getLinkCandidates(teamIds: teamIds, season: season);

  Future<Either<Failure, void>> link(
    PlayerDTO player,
    PlayerLinkPlan plan, {
    required String teamId,
    required String team,
    String? season,
  }) =>
      _repository.linkToTeam(player, plan, teamId: teamId, team: team, season: season);
}
