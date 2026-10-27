import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// Respostas do admin ao pedido "Sou parceiro".
class AnswerPartnerRequestUseCase {
  final IPartnerRequestsRepository _repository;

  AnswerPartnerRequestUseCase(this._repository);

  /// Aprova com [permissions] (padrão: tudo liberado, 2 destaques e 1
  /// publicidade por dia).
  Future<Either<Failure, void>> approve(String userId, {PartnerPermissions permissions = const PartnerPermissions()}) =>
      _repository.answer(userId: userId, status: PlayerRequestStatus.approved, permissions: permissions);

  Future<Either<Failure, void>> reject(String userId, {String reason = ''}) =>
      _repository.answer(userId: userId, status: PlayerRequestStatus.rejected, reason: reason);

  /// Tira o acesso do parceiro (o que ele publicou continua; só o admin mexe).
  Future<Either<Failure, void>> revoke(String userId, {String reason = ''}) =>
      _repository.answer(userId: userId, status: PlayerRequestStatus.removed, reason: reason);
}
