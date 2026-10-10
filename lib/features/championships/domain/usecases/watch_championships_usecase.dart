import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

class WatchChampionshipsUseCase {
  final IChampionshipsRepository _repository;

  WatchChampionshipsUseCase(this._repository);

  Stream<Either<Failure, List<ChampionshipDTO>>> call({String? region}) =>
      _repository.watchChampionships(region: region);
}
