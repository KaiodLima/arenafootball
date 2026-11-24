import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';

/// Rodadas ao vivo, a mais recente primeiro (painel do admin).
class WatchFantasyRoundsUseCase {
  final IFantasyRepository _repository;

  WatchFantasyRoundsUseCase(this._repository);

  Stream<Either<Failure, List<FantasyRoundDTO>>> call(String fantasyId) => _repository.watchRounds(fantasyId);
}

/// Participantes paginados (do mais recente ao mais antigo).
class GetFantasyParticipantsUseCase {
  final IFantasyRepository _repository;

  GetFantasyParticipantsUseCase(this._repository);

  Future<Either<Failure, List<FantasyParticipantDTO>>> call(String fantasyId, {DateTime? before}) =>
      _repository.getParticipants(fantasyId, before: before);
}

/// "Zerar pontuações (testes)" (admin): as functions zeram os pontos do Fantasy.
class RequestFantasyResetUseCase {
  final IFantasyRepository _repository;

  RequestFantasyResetUseCase(this._repository);

  Future<Either<Failure, void>> call(String fantasyId) => _repository.requestReset(fantasyId);
}

/// "Fechar agora" / "Reabrir" a rodada (admin): as functions aplicam.
class RequestFantasyRoundActionUseCase {
  final IFantasyRepository _repository;

  RequestFantasyRoundActionUseCase(this._repository);

  Future<Either<Failure, void>> call(String fantasyId, int round, {required bool open, DateTime? deadline}) =>
      _repository.requestRoundAction(fantasyId, round, open: open, deadline: deadline);
}

/// "Zerar pontos de times" (admin): os atletas dos times perdem os pontos do Fantasy.
class RequestFantasyTeamsResetUseCase {
  final IFantasyRepository _repository;

  RequestFantasyTeamsResetUseCase(this._repository);

  Future<Either<Failure, void>> call(String fantasyId, List<String> teamIds) =>
      _repository.requestTeamsReset(fantasyId, teamIds);
}

/// "Reapurar rodadas" (admin).
class RequestFantasyRescoreUseCase {
  final IFantasyRepository _repository;

  RequestFantasyRescoreUseCase(this._repository);

  Future<Either<Failure, void>> call(String fantasyId) => _repository.requestRescore(fantasyId);
}
