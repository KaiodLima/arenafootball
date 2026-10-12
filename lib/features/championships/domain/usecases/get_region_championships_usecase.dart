import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Campeonatos da região na temporada (pode haver vários ao mesmo tempo).
class GetRegionChampionshipsUseCase {
  final IChampionshipsRepository _repository;

  GetRegionChampionshipsUseCase(this._repository);

  Future<Either<Failure, List<ChampionshipDTO>>> call({required String region, required String season}) =>
      _repository.getRegionChampionships(region: region, season: season);
}
