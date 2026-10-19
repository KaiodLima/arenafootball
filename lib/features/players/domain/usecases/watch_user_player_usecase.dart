import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Atleta da conta logada em tempo real (`idUsuario`), para o menu e a
/// carteirinha mostrarem por quais times ela joga.
class WatchUserPlayerUseCase {
  final IPlayersRepository _repository;

  WatchUserPlayerUseCase(this._repository);

  Stream<Either<Failure, PlayerDTO?>> call({required String userId, String? season}) =>
      _repository.watchPlayerOfUser(userId: userId, season: season);
}
