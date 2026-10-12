import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// Cria o jogador vinculado à conta e marca o pedido como aprovado.
/// Devolve o id do jogador.
class ApprovePlayerRequestUseCase {
  final IPlayerRequestsRepository _repository;

  ApprovePlayerRequestUseCase(this._repository);

  Future<Either<Failure, String>> call(PlayerRequestDTO request) => _repository.approve(request);
}
