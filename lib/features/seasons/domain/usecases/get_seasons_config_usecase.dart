import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';

/// Lê a config de temporadas e aplica em [SeasonCollection]. Sem config (ou
/// sem rede), fica no padrão do código: o app nunca trava por isso.
class GetSeasonsConfigUseCase {
  final ISeasonsRepository _repository;

  GetSeasonsConfigUseCase(this._repository);

  Future<SeasonsConfigDTO> call() async {
    final response = await _repository.getConfig();
    final config = response.fold((_) => null, (config) => config);
    if (config != null && config.current.isNotEmpty) {
      SeasonCollection.configure(current: config.current, seasons: config.seasons);
    }
    return SeasonsConfigDTO(current: SeasonCollection.currentSeason, seasons: SeasonCollection.seasons);
  }
}
