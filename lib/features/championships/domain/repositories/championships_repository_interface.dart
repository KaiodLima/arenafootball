import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';

abstract class IChampionshipsRepository {
  Stream<Either<Failure, List<ChampionshipDTO>>> watchChampionships({String? region});

  Stream<Either<Failure, List<GroupDTO>>> watchGroups({required String region, String? season});

  Stream<Either<Failure, List<StandingDTO>>> watchStandings({
    required String region,
    required String group,
    String? season,
  });
}
