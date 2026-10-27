import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/partner_slots.dart';

/// Primeiro campo inválido do formulário (traduzido na página).
enum PartnerRequestFormError { name, contact }

/// Dados do formulário "Sou parceiro".
class PartnerRequestForm extends Equatable {
  static const int nameMinLength = 3;
  static const int nameMaxLength = 40;
  static const int messageMaxLength = 200;

  final List<String> regions;
  final String? selectedRegion;
  final String name;
  final String contact;
  final String message;

  /// Destaques sem dono marcados como "é meu" (vão no pedido).
  final List<String> claimedHighlightIds;

  const PartnerRequestForm({
    this.regions = const [],
    this.selectedRegion,
    this.name = '',
    this.contact = '',
    this.message = '',
    this.claimedHighlightIds = const [],
  });

  PartnerRequestFormError? get error {
    if (name.trim().length < nameMinLength) return PartnerRequestFormError.name;
    if (contact.replaceAll(RegExp(r'\D'), '').length < 10) return PartnerRequestFormError.contact;
    return null;
  }

  PartnerRequestForm copyWith({
    List<String>? regions,
    String? selectedRegion,
    String? name,
    String? contact,
    String? message,
    List<String>? claimedHighlightIds,
  }) {
    return PartnerRequestForm(
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      message: message ?? this.message,
      claimedHighlightIds: claimedHighlightIds ?? this.claimedHighlightIds,
    );
  }

  @override
  List<Object?> get props => [regions, selectedRegion, name, contact, message, claimedHighlightIds];
}

/// Tela "Sou parceiro": o pedido atual (ou nulo), o formulário e, aprovado,
/// as vagas usadas e os destaques do parceiro.
class PartnerRequestState extends Equatable {
  final PartnerRequestDTO? request;
  final PartnerRequestForm form;
  final bool editing;

  /// Vagas de destaque/publicidade (nulo enquanto carrega ou se falhar).
  final PartnerSlotUsage? slots;

  /// Destaques publicados pelo parceiro.
  final List<HighlightDTO> highlights;

  /// Destaques sem dono (sem `idAutor`): o usuário pode pedir o vínculo.
  final List<HighlightDTO> unlinkedHighlights;

  const PartnerRequestState({
    this.request,
    this.form = const PartnerRequestForm(),
    this.editing = false,
    this.slots,
    this.highlights = const [],
    this.unlinkedHighlights = const [],
  });

  bool get showForm => request == null || editing;

  @override
  List<Object?> get props => [request, form, editing, slots?.takenHighlights, slots?.takenAds, highlights, unlinkedHighlights];
}

class LoadingPartnerRequestState extends PartnerRequestState {
  const LoadingPartnerRequestState();
}

class ReadyPartnerRequestState extends PartnerRequestState {
  const ReadyPartnerRequestState({
    super.request,
    super.form,
    super.editing,
    super.slots,
    super.highlights,
    super.unlinkedHighlights,
  });
}

class SubmittingPartnerRequestState extends PartnerRequestState {
  SubmittingPartnerRequestState(PartnerRequestState from)
      : super(
          request: from.request,
          form: from.form,
          editing: from.editing,
          slots: from.slots,
          highlights: from.highlights,
          unlinkedHighlights: from.unlinkedHighlights,
        );
}

/// Aviso de ação concluída (o snackbar mostra pelo [notice]).
enum PartnerRequestNotice { submitted, cancelled, highlightDeleted, linkRequested }

class NoticePartnerRequestState extends PartnerRequestState {
  final PartnerRequestNotice notice;

  NoticePartnerRequestState(PartnerRequestState from, {required this.notice})
      : super(
          request: from.request,
          form: from.form,
          editing: (notice == PartnerRequestNotice.highlightDeleted || notice == PartnerRequestNotice.linkRequested) &&
              from.editing,
          slots: from.slots,
          highlights: from.highlights,
          unlinkedHighlights: from.unlinkedHighlights,
        );

  @override
  List<Object?> get props => [...super.props, notice];
}

class ErrorPartnerRequestState extends PartnerRequestState {
  final String errorMessage;

  ErrorPartnerRequestState(PartnerRequestState from, {required this.errorMessage})
      : super(
          request: from.request,
          form: from.form,
          editing: from.editing,
          slots: from.slots,
          highlights: from.highlights,
          unlinkedHighlights: from.unlinkedHighlights,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

class LoadErrorPartnerRequestState extends PartnerRequestState {
  final String errorMessage;

  const LoadErrorPartnerRequestState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
