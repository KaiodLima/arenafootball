import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/team_links.dart';

abstract class ISeasonsRepository {
  Future<Either<Failure, SeasonsConfigDTO?>> getConfig();

  Future<Either<Failure, SeasonsConfigDTO>> startSeason({
    required String season,
    required List<String> seasons,
    String? copyTeamsFrom,
  });

  Future<Either<Failure, TeamLinkReport>> linkTeams(String season);
}
