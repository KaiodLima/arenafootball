import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Ajuste do admin nos números de uma competição: soma [goals]/[assists]
/// (podem ser negativos) na inscrição e no total, sem deixar nenhum dos dois
/// abaixo de zero (atômico, como o registro de um gol).
class AdjustPlayerStatsUseCase {
  final IPlayersRepository _repository;

  AdjustPlayerStatsUseCase(this._repository);

  /// Quanto dá para somar sem ficar negativo (0 = nada a fazer).
  static int clampDelta(int delta, {required int inChampionship, required int total}) {
    if (delta >= 0) return delta;
    final floor = -(inChampionship < total ? inChampionship : total);
    return delta < floor ? floor : delta;
  }

  Future<Either<Failure, void>> call(
    PlayerDTO player,
    PlayerEnrollment enrollment, {
    int goals = 0,
    int assists = 0,
    String? season,
  }) {
    final goalsDelta = clampDelta(goals, inChampionship: enrollment.goals, total: player.goals);
    final assistsDelta = clampDelta(assists, inChampionship: enrollment.assists, total: player.assists);
    return _repository.incrementStats(
      playerId: player.id,
      goals: goalsDelta,
      assists: assistsDelta,
      enrollment: enrollment,
      season: season,
    );
  }

  /// Ajuste nos amistosos (contagem à parte, fora do Geral).
  Future<Either<Failure, void>> friendly(PlayerDTO player, {int goals = 0, int assists = 0, String? season}) =>
      _repository.incrementStats(playerId: player.id, goals: goals, assists: assists, friendly: true, season: season);
}
