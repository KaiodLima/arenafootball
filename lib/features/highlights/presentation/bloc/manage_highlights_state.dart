import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';

/// Painel de destaques: a lista na ordem do carrossel, preservada em todas
/// as transições.
class ManageHighlightsState extends Equatable {
  final List<HighlightDTO> highlights;

  const ManageHighlightsState({this.highlights = const []});

  @override
  List<Object?> get props => [highlights];
}

class LoadingManageHighlightsState extends ManageHighlightsState {
  const LoadingManageHighlightsState({super.highlights});
}

class SuccessManageHighlightsState extends ManageHighlightsState {
  const SuccessManageHighlightsState({required super.highlights});
}

/// Falha de leitura ou de gravação (a lista volta ao que era).
class ErrorManageHighlightsState extends ManageHighlightsState {
  final String errorMessage;

  const ErrorManageHighlightsState({required this.errorMessage, super.highlights});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Destaque excluído (a tela avisa).
class DeletedManageHighlightsState extends ManageHighlightsState {
  final String title;

  const DeletedManageHighlightsState({required this.title, required super.highlights});

  @override
  List<Object?> get props => [...super.props, title];
}
