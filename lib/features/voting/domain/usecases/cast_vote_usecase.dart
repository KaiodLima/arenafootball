import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

/// Registra o voto de melhor jogador. O voto é único por votante (id do
/// documento = uid): votar de novo substitui o voto anterior.
class CastVoteUseCase {
  final IVotingRepository _repository;

  CastVoteUseCase(this._repository);

  static const String loginRequiredCode = 'login-required';
  static const String blankVoteCode = 'blank-vote';

  Future<Either<Failure, void>> call({required MatchVoteRef ref, required VoteDTO vote}) async {
    // Convidado não vota: o voto é identificado pelo uid.
    if (vote.voterId.isEmpty) {
      return Left(ErrorWithMessage('Faça login para votar.', code: loginRequiredCode));
    }
    if (vote.playerName.isEmpty || vote.team.isEmpty) {
      return Left(ErrorWithMessage('Voto em branco! Tente novamente.', code: blankVoteCode));
    }
    return _repository.castVote(ref: ref, vote: vote);
  }
}
