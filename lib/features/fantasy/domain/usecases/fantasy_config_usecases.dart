import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';

/// Configuração do Fantasy do campeonato (stream; cache do Firestore).
class WatchFantasyConfigUseCase {
  final IFantasyRepository _repository;

  WatchFantasyConfigUseCase(this._repository);

  Stream<Either<Failure, FantasyConfigDTO>> call(ChampionshipDTO championship) => _repository.watchConfig(championship);
}

/// Configuração pelo id do doc do campeonato (link `/fantasy/<id>`; uma leitura).
class GetFantasyConfigUseCase {
  final IFantasyRepository _repository;

  GetFantasyConfigUseCase(this._repository);

  Future<Either<Failure, FantasyConfigDTO?>> call(String championshipDocId) => _repository.getConfig(championshipDocId);
}

/// Admin salva a configuração; parâmetros inválidos não vão ao servidor.
class SaveFantasyConfigUseCase {
  final IFantasyRepository _repository;

  SaveFantasyConfigUseCase(this._repository);

  Future<Either<Failure, void>> call(FantasyConfigDTO config) async {
    final error = FantasySettings.validate(
      minMinutes: config.minMinutes,
      minDefenseMinutes: config.minDefenseMinutes,
      captainMultiplier: config.captainMultiplier,
    );
    if (error != null) return Left(ErrorWithMessage('Parâmetros inválidos.', code: 'invalid-settings'));
    return _repository
        .saveConfig(config.copyWith(captainMultiplier: FantasySettings.roundCaptain(config.captainMultiplier)));
  }
}

/// Fantasy ativos da temporada (selo da home).
class WatchActiveFantasiesUseCase {
  final IFantasyRepository _repository;

  WatchActiveFantasiesUseCase(this._repository);

  Stream<Either<Failure, List<FantasyConfigDTO>>> call(String season) => _repository.watchActive(season);
}
