import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Campeonato cadastrado da região na temporada (nulo se não houver).
class GetRegionChampionshipUseCase {
  final IChampionshipsRepository _repository;

  GetRegionChampionshipUseCase(this._repository);

  Future<Either<Failure, ChampionshipDTO?>> call({required String region, required String season}) =>
      _repository.getChampionshipForRegion(region: region, season: season);
}
