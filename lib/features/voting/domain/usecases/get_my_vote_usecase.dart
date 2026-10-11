import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

/// Voto atual do usuário na partida (`null` se ainda não votou). Convidado
/// ([voterId] vazio) não tem voto: devolve `null` sem ler o Firestore.
class GetMyVoteUseCase {
  final IVotingRepository _repository;

  GetMyVoteUseCase(this._repository);

  Future<Either<Failure, VoteDTO?>> call({
    required String homeTeam,
    required String awayTeam,
    required String voterId,
  }) async {
    if (voterId.isEmpty) return const Right(null);
    return _repository.getVote(homeTeam: homeTeam, awayTeam: awayTeam, voterId: voterId);
  }
}
