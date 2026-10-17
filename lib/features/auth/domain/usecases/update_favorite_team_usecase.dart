import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:arena_soccer/features/auth/domain/team_change_policy.dart';

class UpdateFavoriteTeamUseCase {
  final IAuthRepository _repository;

  UpdateFavoriteTeamUseCase(this._repository);

  /// Grava o nome (cópia) e o id do time (vínculo) da conta [user]. Devolve a
  /// data da troca (nula na primeira escolha ou se o time é o mesmo), ou
  /// [TeamChangeLockedFailure] antes do prazo de [TeamChangePolicy].
  Future<Either<Failure, DateTime?>> call({
    required UserDTO user,
    required String team,
    required String teamId,
    DateTime? now,
  }) async {
    final isChange = TeamChangePolicy.isChange(user, team: team, teamId: teamId);
    final at = now ?? DateTime.now();
    if (isChange && !TeamChangePolicy.canChange(user, at)) {
      return Left(TeamChangeLockedFailure(TeamChangePolicy.nextChangeAt(user)));
    }
    // Mesmo time, sem id: completa o id sem contar como troca.
    if (user.hasFavoriteTeam && !isChange && user.favoriteTeamId == teamId) return const Right(null);

    final response = await _repository.updateFavoriteTeam(
      userId: user.id,
      team: team,
      teamId: teamId,
      stampChange: isChange,
    );
    if (response.isLeft) {
      final failure = response.left;
      // A regra recusou (o prazo do servidor ainda corre): mesma mensagem.
      if (isChange && failure is ErrorWithMessage && failure.code == 'permission-denied') {
        return Left(TeamChangeLockedFailure(TeamChangePolicy.nextChangeAt(user)));
      }
      return Left(failure);
    }
    return Right(isChange ? at : null);
  }
}
