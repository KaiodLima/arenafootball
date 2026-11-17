import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_podium.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Admin/organizador: encerra a competição com o campeão (e o vice).
class CloseChampionshipUseCase {
  final IChampionshipsRepository _repository;

  CloseChampionshipUseCase(this._repository);

  Future<Either<Failure, void>> call(
    String id, {
    required ChampionshipPodiumTeam champion,
    ChampionshipPodiumTeam? runnerUp,
  }) =>
      _repository.closeChampionship(id, champion: champion, runnerUp: runnerUp);
}

/// Admin/organizador: reabre a competição encerrada.
class ReopenChampionshipUseCase {
  final IChampionshipsRepository _repository;

  ReopenChampionshipUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) => _repository.reopenChampionship(id);
}
