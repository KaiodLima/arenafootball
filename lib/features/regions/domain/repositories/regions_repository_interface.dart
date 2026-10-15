import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/regions/domain/region_usage.dart';

abstract class IRegionsRepository {
  Future<Either<Failure, List<String>>> getRegions();

  Future<Either<Failure, void>> createRegion(String name);

  Future<Either<Failure, void>> renameRegion({required String id, required String name});

  Future<Either<Failure, void>> deleteRegion(String id);

  Future<Either<Failure, RegionUsage>> regionUsage({required String id, required String name});

  Future<Either<Failure, RegionLinkReport>> linkRegions();

  Future<String?> getSavedRegion();

  Future<void> saveRegion(String region);

  Future<String?> getSavedSeason();

  Future<void> saveSeason(String season);
}
