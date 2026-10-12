import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/championship_rules_file.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Cria (sem id) ou atualiza o campeonato. Antes de gravar, envia o banner
/// ([banner]) e o regulamento em PDF ([rules]) escolhidos agora; sem eles,
/// mantém o que já estava no campeonato.
class SaveChampionshipUseCase {
  final IChampionshipsRepository _repository;
  final StorageUploadService _storage;

  SaveChampionshipUseCase(this._repository, this._storage);

  Future<Either<Failure, ChampionshipDTO>> call(
    ChampionshipDTO championship, {
    File? banner,
    ChampionshipRulesFile? rules,
  }) async {
    var data = championship.copyWith(
      title: championship.title.trim(),
      description: championship.description.trim(),
      rules: championship.rules.trim(),
    );
    if (banner != null) {
      final upload = await _storage.uploadImage(file: banner, folder: StorageFolder.championships);
      if (upload.isLeft) return Left(upload.left);
      data = data.copyWith(imageUrl: upload.right);
    }
    if (rules != null) {
      final upload = await _storage.uploadData(
        bytes: rules.bytes,
        folder: StorageFolder.championships,
        contentType: 'application/pdf',
        extension: 'pdf',
      );
      if (upload.isLeft) return Left(upload.left);
      data = data.copyWith(rulesUrl: upload.right, rulesFileName: rules.name);
    }
    return data.id.isEmpty ? _repository.createChampionship(data) : _repository.updateChampionship(data);
  }
}
