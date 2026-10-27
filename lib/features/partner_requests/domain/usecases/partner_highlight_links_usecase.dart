import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';

/// Vínculo de destaques sem dono ao parceiro: o usuário pede, o admin vincula
/// (ou recusa, limpando o pedido).
class PartnerHighlightLinksUseCase {
  final IPartnerRequestsRepository _repository;

  PartnerHighlightLinksUseCase(this._repository);

  /// Usuário marca/desmarca os destaques que são dele.
  Future<Either<Failure, void>> request(String userId, List<String> ids) =>
      _repository.setHighlightClaims(userId: userId, ids: ids);

  /// Admin vincula; devolve quantos destaques passaram para o parceiro.
  Future<Either<Failure, int>> link(PartnerRequestDTO request) => _repository.linkHighlights(request);

  /// Admin recusa o vínculo.
  Future<Either<Failure, void>> clear(String userId) => _repository.setHighlightClaims(userId: userId, ids: const []);
}
