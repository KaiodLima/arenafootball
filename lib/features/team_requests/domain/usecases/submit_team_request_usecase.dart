import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';

/// Envia (ou reenvia) o pedido de time. Com [crest], sobe o escudo para
/// `times/` antes (vira o escudo do time se aprovado).
class SubmitTeamRequestUseCase {
  final ITeamRequestsRepository _repository;
  final StorageUploadService _storage;

  SubmitTeamRequestUseCase(this._repository, this._storage);

  Future<Either<Failure, void>> call(TeamRequestDTO request, {File? crest}) async {
    var imageUrl = request.imageUrl;
    if (crest != null) {
      final upload = await _storage.uploadImage(file: crest, folder: StorageFolder.teams);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }
    return _repository.submit(request.copyWith(
      name: request.name.trim(),
      description: request.description.trim(),
      contact: request.contact.trim(),
      message: request.message.trim(),
      season: SeasonCollection.currentSeason,
      imageUrl: imageUrl,
    ));
  }
}
