import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

/// Regras da votação no cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedVotingRulesUseCase {
  final IVotingRepository _repository;

  GetCachedVotingRulesUseCase(this._repository);

  Future<Either<Failure, CachedValue<VotingRulesDTO>?>> call() => _repository.getCachedRules();
}
