import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

class SaveVotingRulesCacheUseCase {
  final IVotingRepository _repository;

  SaveVotingRulesCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(VotingRulesDTO rules) => _repository.saveRulesCache(rules);
}
