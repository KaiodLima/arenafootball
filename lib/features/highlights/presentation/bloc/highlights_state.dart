import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';

class HighlightsState extends Equatable {
  final List<HighlightDTO> highlights;

  const HighlightsState({this.highlights = const []});

  @override
  List<Object?> get props => [highlights];
}

class LoadingHighlightsState extends HighlightsState {
  const LoadingHighlightsState({super.highlights});
}

class SuccessHighlightsState extends HighlightsState {
  const SuccessHighlightsState({required super.highlights});
}

class ErrorHighlightsState extends HighlightsState {
  final String errorMessage;

  const ErrorHighlightsState({required this.errorMessage, super.highlights});

  @override
  List<Object?> get props => [highlights, errorMessage];
}
