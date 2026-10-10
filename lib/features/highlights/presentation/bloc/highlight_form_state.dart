import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';

/// Dados do formulário de destaque.
class HighlightFormData extends Equatable {
  final String title;
  final String link;
  final bool isVisible;
  final File? image;

  const HighlightFormData({this.title = '', this.link = '', this.isVisible = false, this.image});

  /// Título com no mínimo 3 caracteres (regra do app antigo).
  bool get isTitleValid => title.trim().length >= 3;

  HighlightDTO toHighlight() => HighlightDTO(title: title.trim(), link: link.trim(), isVisible: isVisible);

  HighlightFormData copyWith({String? title, String? link, bool? isVisible, File? image}) {
    return HighlightFormData(
      title: title ?? this.title,
      link: link ?? this.link,
      isVisible: isVisible ?? this.isVisible,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [title, link, isVisible, image?.path];
}

class HighlightFormState extends Equatable {
  final HighlightFormData form;

  const HighlightFormState({this.form = const HighlightFormData()});

  @override
  List<Object?> get props => [form];
}

class EditingHighlightFormState extends HighlightFormState {
  const EditingHighlightFormState({super.form});
}

class SubmittingHighlightFormState extends HighlightFormState {
  const SubmittingHighlightFormState({required super.form});
}

class SuccessHighlightFormState extends HighlightFormState {
  const SuccessHighlightFormState({required super.form});
}

class ErrorHighlightFormState extends HighlightFormState {
  final String errorMessage;

  const ErrorHighlightFormState({required super.form, required this.errorMessage});

  @override
  List<Object?> get props => [form, errorMessage];
}
