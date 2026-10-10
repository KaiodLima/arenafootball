import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';

abstract class IRegionsRepository {
  Future<Either<Failure, List<String>>> getRegions();

  Future<String?> getSavedRegion();

  Future<void> saveRegion(String region);

  Future<String?> getSavedSeason();

  Future<void> saveSeason(String season);
}
