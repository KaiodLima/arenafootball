import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

/// Apaga todo o cache de times (as gravações de time já fazem isso no
/// repositório; use depois de escritas que passam por outro caminho).
class DeleteTeamsCacheUseCase {
  final ITeamsRepository _repository;

  DeleteTeamsCacheUseCase(this._repository);

  Future<void> call() => _repository.deleteTeamsCache();
}
