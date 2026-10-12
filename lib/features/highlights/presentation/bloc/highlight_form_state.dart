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

  /// Destaque em edição (nulo = novo).
  final HighlightDTO? original;

  /// Edição: a foto atual foi removida (sem escolher outra).
  final bool imageRemoved;

  const HighlightFormData({
    this.title = '',
    this.link = '',
    this.isVisible = true,
    this.image,
    this.existing = const [],
    this.original,
    this.imageRemoved = false,
  });

  /// Formulário preenchido com um destaque para editar.
  factory HighlightFormData.editing(HighlightDTO highlight) => HighlightFormData(
        title: highlight.title,
        link: highlight.link,
        isVisible: highlight.isVisible,
        original: highlight,
      );

  bool get isEditing => original != null;

  /// Foto salva que continua valendo (edição sem troca/remoção).
  String get currentImageUrl => image == null && !imageRemoved ? (original?.imageUrl ?? '') : '';

  /// Edição com título novo: as notícias marcadas vão junto.
  bool get isRenamed => original != null && title.trim() != original!.title;

  /// O título é a tag que agrupa as notícias do destaque: não pode repetir
  /// (sem diferenciar acento e caixa).
  bool get isDuplicate {
    final term = foldForSearch(title.trim());
    return term.isNotEmpty &&
        existing.any((item) => item.id != original?.id && foldForSearch(item.title.trim()) == term);
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
  bool get isDirty {
    final base = original;
    if (image != null || imageRemoved) return true;
    if (base == null) return title.trim().isNotEmpty || link.trim().isNotEmpty;
    return title.trim() != base.title || link.trim() != base.link || isVisible != base.isVisible;
  }

  /// Destaque pronto para gravar (a foto nova, se houver, o UseCase envia).
  HighlightDTO toHighlight() => (original ?? const HighlightDTO()).copyWith(
        title: title.trim(),
        link: normalizeWebLink(link),
        isVisible: isVisible,
        imageUrl: imageRemoved && image == null ? '' : null,
      );

  HighlightFormData copyWith({
    String? title,
    String? link,
    bool? isVisible,
    File? image,
    bool clearImage = false,
    List<HighlightDTO>? existing,
    bool? imageRemoved,
  }) {
    return HighlightFormData(
      title: title ?? this.title,
      link: link ?? this.link,
      isVisible: isVisible ?? this.isVisible,
      image: clearImage ? null : (image ?? this.image),
      existing: existing ?? this.existing,
      original: original,
      imageRemoved: imageRemoved ?? this.imageRemoved,
    );
  }

  @override
  List<Object?> get props => [title, link, isVisible, image?.path, existing, original, imageRemoved];
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
