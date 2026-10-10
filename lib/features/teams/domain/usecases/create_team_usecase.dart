import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_next_team_number_usecase.dart';

/// Cadastra um time: envia o escudo para `times/`, monta o id
/// (`{número}_{Nome_Do_Time}`) e grava o time + a linha zerada da
/// classificação. Como no app antigo, sempre na temporada corrente
/// (coleções `times` e `classificacao` sem sufixo).
class CreateTeamUseCase {
  final ITeamsRepository _repository;
  final GetNextTeamNumberUseCase _getNextTeamNumber;
  final StorageUploadService _storage;

  CreateTeamUseCase(this._repository, this._getNextTeamNumber, this._storage);

  static String buildId(int number, String name) => '${number}_${name.replaceAll(' ', '_')}';

  Future<Either<Failure, TeamDTO>> call({required TeamDTO team, File? crest}) async {
    final name = team.name.trim();

    String imageUrl = team.imageUrl;
    if (crest != null) {
      final upload = await _storage.uploadImage(file: crest, folder: StorageFolder.teams);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }

    // Recalcula na hora de gravar: o número mostrado na tela pode ter ficado
    // velho se outro time foi cadastrado nesse meio tempo.
    final number = await _getNextTeamNumber();
    if (number.isLeft) return Left(number.left);

    final created = team.copyWith(id: buildId(number.right, name), name: name, imageUrl: imageUrl);
    final response = await _repository.createTeam(created);
    return response.map((_) => created);
  }
}
