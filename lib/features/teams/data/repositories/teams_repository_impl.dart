import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/datasources/teams_datasource.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

class TeamsRepositoryImpl implements ITeamsRepository {
  final TeamsDataSource _dataSource;

  TeamsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season}) =>
      _dataSource.getTeams(region: region, season: season);

  @override
  Future<Either<Failure, TeamDTO?>> getTeamByName(String name) => _dataSource.getTeamByName(name);

  @override
  Stream<Either<Failure, List<TeamDTO>>> watchTeams({String? region, String? season}) =>
      _dataSource.watchTeams(region: region, season: season);

  @override
  Future<Either<Failure, int>> countTeams({String? season}) => _dataSource.countTeams(season: season);

  @override
  Future<Either<Failure, void>> createTeam(TeamDTO team, {String? season}) =>
      _dataSource.createTeam(team, season: season);

  @override
  Future<Either<Failure, TeamDTO?>> getTeam({required String id, String? season}) =>
      _dataSource.getTeam(id: id, season: season);

  @override
  Future<Either<Failure, void>> updateTeamDetails({
    required String id,
    required String description,
    required String imageUrl,
    String primaryColor = '',
    String secondaryColor = '',
    String? season,
  }) =>
      _dataSource.updateTeamDetails(
        id: id,
        description: description,
        imageUrl: imageUrl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        season: season,
      );

  @override
  Future<Either<Failure, void>> deleteTeam(TeamDTO team, {String? season}) =>
      _dataSource.deleteTeam(team, season: season);
}
