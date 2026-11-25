import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Competições da temporada (todas as regiões).
class GetSeasonChampionshipsUseCase {
  final IChampionshipsRepository _repository;

  GetSeasonChampionshipsUseCase(this._repository);

  Future<Either<Failure, List<ChampionshipDTO>>> call(String season) => _repository.getSeasonChampionships(season);

  /// Em quais o [team] pode jogar: as municipais da região dele e todas as
  /// intermunicipais, só as não encerradas.
  static List<ChampionshipDTO> eligibleFor(List<ChampionshipDTO> championships, TeamDTO team) => championships
      .where((c) => c.isOpen)
      .where((c) => c.isIntermunicipal || c.region.trim().toLowerCase() == team.region.trim().toLowerCase())
      .toList();
}

/// Competições da temporada do cache local (nunca falha: sem cache =
/// `Right(null)`).
class GetCachedSeasonChampionshipsUseCase {
  final IChampionshipsRepository _repository;

  GetCachedSeasonChampionshipsUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<ChampionshipDTO>>?>> call(String season) =>
      _repository.getCachedSeasonChampionships(season);
}

class SaveSeasonChampionshipsCacheUseCase {
  final IChampionshipsRepository _repository;

  SaveSeasonChampionshipsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(List<ChampionshipDTO> championships, String season) =>
      _repository.saveSeasonChampionshipsCache(championships, season);
}

/// Competições da temporada pelo fluxo [cacheFirst] (validade
/// [CacheTtl.championships]). Gravar um campeonato apaga (no repositório,
/// junto com os outros caches de campeonatos).
class GetSeasonChampionshipsCacheFirstUseCase {
  final GetSeasonChampionshipsUseCase _getChampionships;
  final GetCachedSeasonChampionshipsUseCase _getCached;
  final SaveSeasonChampionshipsCacheUseCase _saveCache;

  GetSeasonChampionshipsCacheFirstUseCase(this._getChampionships, this._getCached, this._saveCache);

  Stream<Either<Failure, List<ChampionshipDTO>>> call(String season, {bool force = false}) =>
      cacheFirst<List<ChampionshipDTO>>(
        readCache: () => _getCached(season),
        fetchRemote: () => _getChampionships(season),
        saveCache: (championships) => _saveCache(championships, season),
        ttl: CacheTtl.championships,
        force: force,
        logName: 'GetSeasonChampionshipsCacheFirstUseCase',
      );

  /// O valor mais novo numa leitura só.
  Future<Either<Failure, List<ChampionshipDTO>>> latest(String season, {bool force = false}) =>
      call(season, force: force).last;
}
