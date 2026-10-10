import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Erro de validação do título, traduzido na página via l10n.
enum NewsTitleError { required, tooShort }

/// Dados do formulário de notícia/anúncio. Sobrevive às transições
/// Editing → Submitting → Error/Success.
class NewsFormData extends Equatable {
  /// Notícia sendo editada; nulo na criação.
  final NewsDTO? original;
  final String title;
  final String description;
  final String tag;
  final String link;
  final bool isVisible;
  final List<String> regions;
  final String? selectedRegion;
  final File? cover;
  final List<File> album;

  const NewsFormData({
    this.original,
    this.title = '',
    this.description = '',
    this.tag = '',
    this.link = '',
    this.isVisible = false,
    this.regions = const [],
    this.selectedRegion,
    this.cover,
    this.album = const [],
  });

  bool get isEditing => original != null;

  /// Anúncio: o título é opcional.
  bool get isAd => tag == NewsDTO.adTag;

  NewsTitleError? get titleError {
    if (isAd) return null;
    if (title.trim().isEmpty) return NewsTitleError.required;
    if (title.trim().length < 3) return NewsTitleError.tooShort;
    return null;
  }

  /// Como no app antigo, título curto mostra aviso mas não bloqueia.
  bool get canSubmit => titleError != NewsTitleError.required && selectedRegion != null;

  /// Notícia pronta para gravar (sem as imagens novas, que o UseCase envia).
  NewsDTO toNews() {
    final base = original ?? const NewsDTO();
    return base.copyWith(
      title: title.trim(),
      description: description,
      tag: tag,
      link: link.trim(),
      isVisible: isVisible,
      region: selectedRegion,
    );
  }

  NewsFormData copyWith({
    String? title,
    String? description,
    String? tag,
    String? link,
    bool? isVisible,
    List<String>? regions,
    String? selectedRegion,
    File? cover,
    List<File>? album,
  }) {
    return NewsFormData(
      original: original,
      title: title ?? this.title,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      link: link ?? this.link,
      isVisible: isVisible ?? this.isVisible,
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      cover: cover ?? this.cover,
      album: album ?? this.album,
    );
  }

  @override
  List<Object?> get props =>
      [original, title, description, tag, link, isVisible, regions, selectedRegion, cover?.path, album];
}

class NewsFormState extends Equatable {
  final NewsFormData form;

  const NewsFormState({this.form = const NewsFormData()});

  @override
  List<Object?> get props => [form];
}

class EditingNewsFormState extends NewsFormState {
  const EditingNewsFormState({super.form});
}

class SubmittingNewsFormState extends NewsFormState {
  const SubmittingNewsFormState({required super.form});
}

class SuccessNewsFormState extends NewsFormState {
  const SuccessNewsFormState({required super.form});
}

class ErrorNewsFormState extends NewsFormState {
  final String errorMessage;

  const ErrorNewsFormState({required super.form, required this.errorMessage});

  @override
  List<Object?> get props => [form, errorMessage];
}
