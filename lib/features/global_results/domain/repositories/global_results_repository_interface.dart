import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_row_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';

abstract class IGlobalResultsRepository {
  Future<Either<Failure, List<ScrapedRowDTO>>> getRows(ResultsDay day);
}
