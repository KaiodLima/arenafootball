import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';
import 'package:arena_soccer/features/seasons/domain/team_links.dart';

/// Manutenção do admin: grava o id do time onde ainda só há o nome, na
/// temporada [season] (ver `SeasonsDataSource.linkTeams`).
class LinkTeamsByIdUseCase {
  final ISeasonsRepository _repository;

  LinkTeamsByIdUseCase(this._repository);

  Future<Either<Failure, TeamLinkReport>> call(String season) => _repository.linkTeams(season);
}
