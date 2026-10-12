import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// Pedidos aguardando resposta (contador no menu do admin).
class WatchPendingPlayerRequestsCountUseCase {
  final IPlayerRequestsRepository _repository;

  WatchPendingPlayerRequestsCountUseCase(this._repository);

  Stream<Either<Failure, int>> call() => _repository.watchPendingCount();
}
