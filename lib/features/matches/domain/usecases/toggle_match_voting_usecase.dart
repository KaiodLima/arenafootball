import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Abre a votação de melhor jogador se estiver fechada, e fecha se estiver
/// aberta (admin).
class ToggleMatchVotingUseCase {
  final IMatchesRepository _repository;

  ToggleMatchVotingUseCase(this._repository);

  Future<Either<Failure, MatchDTO>> call({required MatchDTO match, String? season}) async {
    final updated = match.copyWith(isVotingOpen: !match.isVotingOpen);
    final response = await _repository.setVotingOpen(
      matchId: match.id,
      isOpen: updated.isVotingOpen,
      season: season,
    );
    return response.map((_) => updated);
  }
}
