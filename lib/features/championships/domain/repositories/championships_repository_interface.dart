import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_table_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

abstract class IChampionshipsRepository {
  Stream<Either<Failure, List<ChampionshipDTO>>> watchChampionships({String? region});

  Stream<Either<Failure, List<GroupDTO>>> watchGroups({required String region, String? season});

  Stream<Either<Failure, GroupTableDTO?>> watchGroupTable({required String groupId, String? season});

  Future<Either<Failure, void>> requestTablesRecompute(String championshipDocId);

  Stream<Either<Failure, List<StandingDTO>>> watchStandings({
    required String region,
    required String group,
    String? season,
  });

  Future<Either<Failure, ChampionshipDTO>> createChampionship(ChampionshipDTO championship);

  Future<Either<Failure, ChampionshipDTO>> updateChampionship(ChampionshipDTO championship);

  Future<Either<Failure, void>> deleteChampionship(String id);

  /// Competições da temporada, de todas as regiões.
  Future<Either<Failure, List<ChampionshipDTO>>> getSeasonChampionships(String season);

  /// Inscreve ou tira o time do campeonato.
  Future<Either<Failure, ChampionshipDTO>> setTeamEnrollment({
    required String championshipDocId,
    required TeamDTO team,
    required bool enrolled,
  });

  Future<Either<Failure, ChampionshipDTO?>> getChampionshipForRegion({required String region, required String season});

  Future<Either<Failure, List<ChampionshipDTO>>> getRegionChampionships({
    required String region,
    required String season,
  });

  /// Cache local dos campeonatos da [region] na [season]. Nunca falha: sem
  /// cache = `Right(null)`.
  Future<Either<Failure, CachedValue<List<ChampionshipDTO>>?>> getCachedRegionChampionships({
    required String region,
    required String season,
  });

  Future<Either<Failure, void>> saveRegionChampionshipsCache(
    List<ChampionshipDTO> championships, {
    required String region,
    required String season,
  });

  /// Cache local do campeonato da região (`data` nulo = não há).
  Future<Either<Failure, CachedValue<ChampionshipDTO?>?>> getCachedRegionChampionship({
    required String region,
    required String season,
  });

  Future<Either<Failure, void>> saveRegionChampionshipCache(
    ChampionshipDTO? championship, {
    required String region,
    required String season,
  });

  /// Apaga todo o cache de campeonatos (listas e avulsos).
  Future<void> deleteChampionshipsCache();
}
