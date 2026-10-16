import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_cached_votes_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_votes_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/save_votes_cache_usecase.dart';

/// Votos da partida pelo fluxo [cacheFirst] (validade curta,
/// [CacheTtl.votes]). Só para o resultado (tela do eleito, aberta com a
/// votação encerrada); a votação aberta não usa cache.
class GetVotesCacheFirstUseCase {
  final GetVotesUseCase _getVotes;
  final GetCachedVotesUseCase _getCached;
  final SaveVotesCacheUseCase _saveCache;

  GetVotesCacheFirstUseCase(this._getVotes, this._getCached, this._saveCache);

  Stream<Either<Failure, List<VoteDTO>>> call(MatchVoteRef ref, {bool force = false}) => cacheFirst<List<VoteDTO>>(
        readCache: () => _getCached(ref),
        fetchRemote: () => _getVotes(ref),
        saveCache: (votes) => _saveCache(ref, votes),
        ttl: CacheTtl.votes,
        force: force,
        logName: 'GetVotesCacheFirstUseCase',
      );
}
