import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_cached_voting_rules_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_voting_rules_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/save_voting_rules_cache_usecase.dart';

/// Regras da votação pelo fluxo [cacheFirst] ([CacheTtl.votingRules]).
class GetVotingRulesCacheFirstUseCase {
  final GetVotingRulesUseCase _getRules;
  final GetCachedVotingRulesUseCase _getCached;
  final SaveVotingRulesCacheUseCase _saveCache;

  GetVotingRulesCacheFirstUseCase(this._getRules, this._getCached, this._saveCache);

  Stream<Either<Failure, VotingRulesDTO>> call({bool force = false}) => cacheFirst<VotingRulesDTO>(
        readCache: _getCached.call,
        fetchRemote: _getRules.call,
        saveCache: _saveCache.call,
        ttl: CacheTtl.votingRules,
        force: force,
        logName: 'GetVotingRulesCacheFirstUseCase',
      );
}
