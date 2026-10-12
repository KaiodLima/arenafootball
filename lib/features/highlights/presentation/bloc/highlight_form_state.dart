import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/core/utils/web_link.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';

enum HighlightTitleError { required, tooShort, duplicate }

/// Dados do formulário de destaque.
class HighlightFormData extends Equatable {
  static const int titleMaxLength = 20;

  final String title;
  final String link;
  final bool isVisible;
  final File? image;

  /// Destaques já cadastrados (prévia do carrossel e checagem de duplicado).
  final List<HighlightDTO> existing;

  const HighlightFormData({
    this.title = '',
    this.link = '',
    this.isVisible = true,
    this.image,
    this.existing = const [],
  });

  /// O título é a tag que agrupa as notícias do destaque: não pode repetir
  /// (sem diferenciar acento e caixa).
  bool get isDuplicate {
    final term = foldForSearch(title.trim());
    return term.isNotEmpty && existing.any((item) => foldForSearch(item.title.trim()) == term);
  }

  HighlightTitleError? get titleError {
    final value = title.trim();
    if (value.isEmpty) return HighlightTitleError.required;
    if (value.length < 3) return HighlightTitleError.tooShort;
    if (isDuplicate) return HighlightTitleError.duplicate;
    return null;
  }

  bool get linkInvalid => !isValidWebLink(link);

  bool get canSubmit => titleError == null && !linkInvalid;

  /// Há algo que se perderia ao sair (para o aviso de descartar).
  bool get isDirty => title.trim().isNotEmpty || link.trim().isNotEmpty || image != null;

  HighlightDTO toHighlight() => HighlightDTO(title: title.trim(), link: normalizeWebLink(link), isVisible: isVisible);

  HighlightFormData copyWith({
    String? title,
    String? link,
    bool? isVisible,
    File? image,
    bool clearImage = false,
    List<HighlightDTO>? existing,
  }) {
    return HighlightFormData(
      title: title ?? this.title,
      link: link ?? this.link,
      isVisible: isVisible ?? this.isVisible,
      image: clearImage ? null : (image ?? this.image),
      existing: existing ?? this.existing,
    );
  }

  @override
  List<Object?> get props => [title, link, isVisible, image?.path, existing];
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
