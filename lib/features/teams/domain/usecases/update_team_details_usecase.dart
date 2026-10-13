import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

/// Dono (ou admin) troca o escudo, a descrição e as cores do time na
/// temporada [season] (nulo = atual).
/// Com [crest], envia o escudo novo para `times/` antes. [changeRegion] (só o
/// admin) grava também a região de `team.region`.
class UpdateTeamDetailsUseCase {
  final ITeamsRepository _repository;
  final StorageUploadService _storage;

  UpdateTeamDetailsUseCase(this._repository, this._storage);

  Future<Either<Failure, TeamDTO>> call(TeamDTO team, {File? crest, bool changeRegion = false, String? season}) async {
    var imageUrl = team.imageUrl;
    if (crest != null) {
      final upload = await _storage.uploadImage(file: crest, folder: StorageFolder.teams);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }
    final updated = team.copyWith(description: team.description.trim(), imageUrl: imageUrl);
    final response = await _repository.updateTeamDetails(
      id: updated.id,
      description: updated.description,
      imageUrl: updated.imageUrl,
      primaryColor: updated.primaryColor,
      secondaryColor: updated.secondaryColor,
      region: changeRegion ? updated.region : null,
      season: season,
    );
    return response.map((_) => updated);
  }
}
