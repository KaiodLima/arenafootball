import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

/// Regras da votação no Firestore (`config/votacao`).
class GetVotingRulesUseCase {
  final IVotingRepository _repository;

  GetVotingRulesUseCase(this._repository);

  Future<Either<Failure, VotingRulesDTO>> call() => _repository.getRules();
}
