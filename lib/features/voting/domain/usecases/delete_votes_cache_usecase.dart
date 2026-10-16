import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

/// Apaga os votos guardados da partida (votar já faz isso no repositório).
class DeleteVotesCacheUseCase {
  final IVotingRepository _repository;

  DeleteVotesCacheUseCase(this._repository);

  Future<void> call(MatchVoteRef ref) => _repository.deleteVotesCache(ref: ref);
}
