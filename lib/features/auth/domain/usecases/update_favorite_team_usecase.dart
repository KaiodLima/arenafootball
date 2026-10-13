import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class UpdateFavoriteTeamUseCase {
  final IAuthRepository _repository;

  UpdateFavoriteTeamUseCase(this._repository);

  /// Grava o nome (cópia) e o id do time (vínculo).
  Future<Either<Failure, void>> call({required String userId, required String team, required String teamId}) =>
      _repository.updateFavoriteTeam(userId: userId, team: team, teamId: teamId);
}
