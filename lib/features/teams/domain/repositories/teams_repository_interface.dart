import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

abstract class ITeamsRepository {
  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season});

  Future<Either<Failure, TeamDTO?>> getTeamByName(String name);

  Stream<Either<Failure, List<TeamDTO>>> watchTeams({String? region, String? season});

  Future<Either<Failure, int>> countTeams({String? season});

  Future<Either<Failure, void>> createTeam(TeamDTO team, {String? season});

  Future<Either<Failure, TeamDTO?>> getTeam({required String id, String? season});

  Future<Either<Failure, void>> updateTeamDetails({
    required String id,
    required String description,
    required String imageUrl,
    String primaryColor = '',
    String secondaryColor = '',
    String? season,
  });

  Future<Either<Failure, void>> deleteTeam(TeamDTO team, {String? season});
}
