import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Apaga o campeonato (partidas, grupos e classificação ficam).
class DeleteChampionshipUseCase {
  final IChampionshipsRepository _repository;

  DeleteChampionshipUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) => _repository.deleteChampionship(id);
}
