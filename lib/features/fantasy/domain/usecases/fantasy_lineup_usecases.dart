import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';

/// Rodada [round] do Fantasy (nula = ainda não existe).
class WatchFantasyRoundUseCase {
  final IFantasyRepository _repository;

  WatchFantasyRoundUseCase(this._repository);

  Stream<Either<Failure, FantasyRoundDTO?>> call(String fantasyId, int round) =>
      _repository.watchRound(fantasyId, round);
}

/// Participação da conta no Fantasy (nula = ainda não entrou).
class WatchFantasyParticipantUseCase {
  final IFantasyRepository _repository;

  WatchFantasyParticipantUseCase(this._repository);

  Stream<Either<Failure, FantasyParticipantDTO?>> call(String fantasyId, String uid) =>
      _repository.watchParticipant(fantasyId, uid);
}

/// Entra no Fantasy a partir da rodada atual (sem pontos retroativos).
class JoinFantasyUseCase {
  final IFantasyRepository _repository;

  JoinFantasyUseCase(this._repository);

  Future<Either<Failure, void>> call(
    FantasyConfigDTO config, {
    required String uid,
    required String name,
    String photoUrl = '',
  }) =>
      _repository.join(
        config.championshipDocId,
        uid: uid,
        name: name.trim().isEmpty ? 'Torcedor' : name.trim(),
        photoUrl: photoUrl,
        currentRound: config.currentRound,
      );
}

/// Escalação da conta na rodada (nula = ainda não montou).
class WatchFantasyLineupUseCase {
  final IFantasyRepository _repository;

  WatchFantasyLineupUseCase(this._repository);

  Stream<Either<Failure, FantasyLineupDTO?>> call(String fantasyId, int round, String uid) =>
      _repository.watchLineup(fantasyId, round, uid);
}

/// Grava a escalação da rodada.
class SaveFantasyLineupUseCase {
  final IFantasyRepository _repository;

  SaveFantasyLineupUseCase(this._repository);

  Future<Either<Failure, void>> call(String fantasyId, int round, FantasyLineupDTO lineup) =>
      _repository.saveLineup(fantasyId, round, lineup);
}

/// Atletas elegíveis pelo fluxo [cacheFirst] (validade [CacheTtl.fantasyAthletes]).
class GetFantasyAthletesCacheFirstUseCase {
  final IFantasyRepository _repository;

  GetFantasyAthletesCacheFirstUseCase(this._repository);

  Stream<Either<Failure, List<FantasyAthleteDTO>>> call(FantasyConfigDTO config, {bool force = false}) =>
      cacheFirst<List<FantasyAthleteDTO>>(
        readCache: () => _repository.getCachedAthletes(config),
        fetchRemote: () => _repository.getEligibleAthletes(config),
        saveCache: (athletes) => _repository.saveAthletesCache(config, athletes),
        ttl: CacheTtl.fantasyAthletes,
        force: force,
        logName: 'GetFantasyAthletesCacheFirstUseCase',
      );
}
