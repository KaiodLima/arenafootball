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
