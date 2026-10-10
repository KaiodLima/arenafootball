import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

class ChampionshipsRepositoryImpl implements IChampionshipsRepository {
  final ChampionshipsDataSource _dataSource;

  ChampionshipsRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> watchChampionships({String? region}) =>
      _dataSource.watchChampionships(region: region);

  @override
  Stream<Either<Failure, List<GroupDTO>>> watchGroups({required String region, String? season}) =>
      _dataSource.watchGroups(region: region, season: season);

  @override
  Stream<Either<Failure, List<StandingDTO>>> watchStandings({
    required String region,
    required String group,
    String? season,
  }) =>
      _dataSource.watchStandings(region: region, group: group, season: season);
}
