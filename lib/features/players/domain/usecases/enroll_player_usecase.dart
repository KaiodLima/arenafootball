import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Inscreve um atleta já cadastrado em outra competição (por um time),
/// mantendo as outras inscrições e os números.
class EnrollPlayerUseCase {
  final IPlayersRepository _repository;

  EnrollPlayerUseCase(this._repository);

  Future<Either<Failure, void>> call(PlayerDTO player, PlayerEnrollment enrollment, {String? season}) =>
      _repository.enroll(player, enrollment, season: season);
}
