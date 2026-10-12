import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';

/// Pedidos de time aguardando resposta (contador no menu do admin).
class WatchPendingTeamRequestsCountUseCase {
  final ITeamRequestsRepository _repository;

  WatchPendingTeamRequestsCountUseCase(this._repository);

  Stream<Either<Failure, int>> call() => _repository.watchPendingCount();
}
