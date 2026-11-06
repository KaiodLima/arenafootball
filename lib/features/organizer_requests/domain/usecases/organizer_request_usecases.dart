import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';
import 'package:arena_soccer/features/organizer_requests/domain/repositories/organizer_requests_repository_interface.dart';

/// Pedido atual da conta (nulo = nenhum).
class WatchMyOrganizerRequestUseCase {
  final IOrganizerRequestsRepository _repository;

  WatchMyOrganizerRequestUseCase(this._repository);

  Stream<Either<Failure, OrganizerRequestDTO?>> call(String userId) => _repository.watchMyRequest(userId);
}

/// Campeonatos que a conta organiza.
class WatchMyChampionshipsUseCase {
  final IOrganizerRequestsRepository _repository;

  WatchMyChampionshipsUseCase(this._repository);

  Stream<Either<Failure, List<ChampionshipDTO>>> call(String userId) => _repository.watchMyChampionships(userId);
}

/// Envia (ou reenvia) o pedido. Com [logo], sobe a imagem para
/// `campeonatos/` antes (vira a imagem do campeonato se aprovado).
class SubmitOrganizerRequestUseCase {
  final IOrganizerRequestsRepository _repository;
  final StorageUploadService _storage;

  SubmitOrganizerRequestUseCase(this._repository, this._storage);

  Future<Either<Failure, void>> call(OrganizerRequestDTO request, {File? logo}) async {
    var imageUrl = request.imageUrl;
    if (logo != null) {
      final upload = await _storage.uploadImage(file: logo, folder: StorageFolder.championships);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }
    return _repository.submit(request.copyWith(
      name: request.name.trim(),
      description: request.description.trim(),
      contact: request.contact.trim(),
      season: SeasonCollection.currentSeason,
      imageUrl: imageUrl,
    ));
  }
}

/// Desiste do pedido pendente.
class CancelOrganizerRequestUseCase {
  final IOrganizerRequestsRepository _repository;

  CancelOrganizerRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId) => _repository.cancel(userId);
}

/// Painel do admin: todos os pedidos (mais novos primeiro).
class WatchOrganizerRequestsUseCase {
  final IOrganizerRequestsRepository _repository;

  WatchOrganizerRequestsUseCase(this._repository);

  Stream<Either<Failure, List<OrganizerRequestDTO>>> call() => _repository.watchRequests();
}

/// Admin corrige nome, região ou abrangência antes de responder.
class UpdateOrganizerRequestUseCase {
  final IOrganizerRequestsRepository _repository;

  UpdateOrganizerRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(OrganizerRequestDTO request) =>
      _repository.update(request.copyWith(name: request.name.trim()));
}

/// Aprova: cria o campeonato na temporada atual, com a sede, a abrangência,
/// a logo e o organizador do pedido. Devolve o campeonato criado.
class ApproveOrganizerRequestUseCase {
  final IOrganizerRequestsRepository _repository;

  ApproveOrganizerRequestUseCase(this._repository);

  Future<Either<Failure, ChampionshipDTO>> call(OrganizerRequestDTO request) => _repository.approve(
        request: request,
        championship: request.toChampionship(SeasonCollection.currentSeason),
      );
}

/// Rejeita com motivo (o usuário vê e pode mandar outro pedido).
class RejectOrganizerRequestUseCase {
  final IOrganizerRequestsRepository _repository;

  RejectOrganizerRequestUseCase(this._repository);

  Future<Either<Failure, void>> call({required String userId, required String reason}) =>
      _repository.reject(userId: userId, reason: reason.trim());
}
