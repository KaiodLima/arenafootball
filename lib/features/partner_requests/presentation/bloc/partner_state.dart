import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';

/// Pedido "Sou parceiro" da conta logada. Aprovado, diz a região e o que ela
/// pode publicar.
class PartnerState extends Equatable {
  final PartnerRequestDTO? request;

  const PartnerState({this.request});

  /// Parceiro aprovado (nulo se não é).
  PartnerRequestDTO? get partner => request != null && request!.isApproved ? request : null;

  bool get isPartner => partner != null;

  String get region => partner?.region ?? '';

  PartnerPermissions get permissions => partner?.permissions ?? const PartnerPermissions();

  /// O parceiro pode mexer no conteúdo de [authorId] (o que ele publicou).
  bool owns(String authorId) => isPartner && authorId.isNotEmpty && authorId == partner!.userId;

  @override
  List<Object?> get props => [request];
}
