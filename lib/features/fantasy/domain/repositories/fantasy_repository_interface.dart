import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';

abstract class IFantasyRepository {
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship);

  Future<Either<Failure, void>> saveConfig(FantasyConfigDTO config);
}
