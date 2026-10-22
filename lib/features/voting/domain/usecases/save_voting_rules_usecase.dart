import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

/// Admin grava as regras da votação (mínimo de votos e porcentagem).
class SaveVotingRulesUseCase {
  final IVotingRepository _repository;

  SaveVotingRulesUseCase(this._repository);

  Future<Either<Failure, void>> call(VotingRulesDTO rules) => _repository.saveRules(rules);
}
