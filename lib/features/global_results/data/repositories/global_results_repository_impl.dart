import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/datasources/global_results_datasource.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';

class GlobalResultsRepositoryImpl implements IGlobalResultsRepository {
  final GlobalResultsDataSource _dataSource;

  GlobalResultsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ScrapedMatchDTO>>> getMatches(ResultsDay day) => _dataSource.getMatches(day);
}
