import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';
import 'package:arena_soccer/features/partner_requests/domain/partner_slots.dart';

/// Vagas do parceiro agora: destaques ocupados e publicidades e notícias de
/// hoje (uma leitura por vaga).
class GetPartnerSlotsUseCase {
  final IPartnerRequestsRepository _repository;

  GetPartnerSlotsUseCase(this._repository);

  Future<Either<Failure, PartnerSlotUsage>> call(PartnerRequestDTO partner, {DateTime? now}) async {
    final day = now ?? DateTime.now();
    final highlightIds = PartnerSlots.highlightIds(partner.userId, partner.permissions.highlightLimit);
    final adIds = PartnerSlots.adIds(partner.userId, partner.permissions.adsPerDay, day);
    final newsIds = PartnerSlots.newsIds(partner.userId, partner.permissions.newsPerDay, day);
    final highlights = await _repository.existingIds(collection: 'destaques', ids: highlightIds);
    if (highlights.isLeft) return Left(highlights.left);
    // Publicidade e notícia: pelo marcador (apagar a publicação não libera a vaga).
    final news = await _repository.existingIds(collection: PartnerSlots.markersCollection, ids: [...adIds, ...newsIds]);
    if (news.isLeft) return Left(news.left);
    return Right(PartnerSlotUsage(
      highlightIds: highlightIds,
      takenHighlights: highlights.right,
      adIds: adIds,
      takenAds: news.right,
      newsIds: newsIds,
      takenNews: news.right,
    ));
  }
}
