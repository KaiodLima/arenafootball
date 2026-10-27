import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// Painel do admin "Parceiros": pedidos pendentes, parceiros ativos e os
/// respondidos (rejeitados/removidos).
class PartnerRequestsPanelState extends Equatable {
  final List<PartnerRequestDTO> requests;
  final Set<String> busy;
  final bool loading;

  /// Título de cada destaque (id → título), para os pedidos de vínculo.
  final Map<String, String> highlightTitles;

  const PartnerRequestsPanelState({
    this.requests = const [],
    this.busy = const {},
    this.loading = true,
    this.highlightTitles = const {},
  });

  List<PartnerRequestDTO> get pending => requests.where((r) => r.isPending).toList();

  List<PartnerRequestDTO> get active => requests.where((r) => r.isApproved).toList();

  List<PartnerRequestDTO> get answered =>
      requests.where((r) => r.status == PlayerRequestStatus.rejected || r.status == PlayerRequestStatus.removed).toList();

  PartnerRequestsPanelState copyWith({
    List<PartnerRequestDTO>? requests,
    Set<String>? busy,
    bool? loading,
    Map<String, String>? highlightTitles,
  }) {
    return PartnerRequestsPanelState(
      requests: requests ?? this.requests,
      busy: busy ?? this.busy,
      loading: loading ?? this.loading,
      highlightTitles: highlightTitles ?? this.highlightTitles,
    );
  }

  @override
  List<Object?> get props => [requests, busy, loading, highlightTitles];
}

enum PartnerRequestsNotice { approved, rejected, revoked, permissionsSaved, linked, linksCleared }

class NoticePartnerRequestsPanelState extends PartnerRequestsPanelState {
  final PartnerRequestsNotice notice;
  final String name;

  /// Destaques vinculados ([PartnerRequestsNotice.linked]).
  final int count;

  NoticePartnerRequestsPanelState(PartnerRequestsPanelState from, {required this.notice, this.name = '', this.count = 0})
      : super(requests: from.requests, busy: from.busy, loading: from.loading, highlightTitles: from.highlightTitles);

  @override
  List<Object?> get props => [...super.props, notice, name, count];
}

class ErrorPartnerRequestsPanelState extends PartnerRequestsPanelState {
  final String errorMessage;

  ErrorPartnerRequestsPanelState(PartnerRequestsPanelState from, {required this.errorMessage})
      : super(requests: from.requests, busy: from.busy, loading: false, highlightTitles: from.highlightTitles);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
