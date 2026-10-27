import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Admin atribui os números que estão só no Geral ("Sem competição") a uma
/// competição do atleta ([enrollment]) ou, sem ela, aos amistosos. Nunca mais
/// que a sobra.
class AssignUnassignedStatsUseCase {
  final IPlayersRepository _repository;

  AssignUnassignedStatsUseCase(this._repository);

  Future<Either<Failure, void>> call(
    PlayerDTO player, {
    int goals = 0,
    int assists = 0,
    PlayerEnrollment? enrollment,
    String? season,
  }) {
    return _repository.assignUnassigned(
      playerId: player.id,
      goals: goals.clamp(0, player.unassignedGoals),
      assists: assists.clamp(0, player.unassignedAssists),
      enrollment: enrollment,
      season: season,
    );
  }
}
