import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';

/// Admin inicia a temporada seguinte à atual. Com [copyTeams], os times da
/// atual entram na nova (classificação zerada). Aplica a nova config em
/// [SeasonCollection] para os cadastros seguintes já irem para ela.
class StartSeasonUseCase {
  final ISeasonsRepository _repository;

  StartSeasonUseCase(this._repository);

  Future<Either<Failure, SeasonsConfigDTO>> call({required bool copyTeams}) async {
    final current = SeasonCollection.currentSeason;
    final response = await _repository.startSeason(
      season: SeasonsConfigDTO.nextSeason(current),
      seasons: SeasonCollection.seasons,
      copyTeamsFrom: copyTeams ? current : null,
    );
    return response.map((config) {
      SeasonCollection.configure(current: config.current, seasons: config.seasons);
      return config;
    });
  }
}
