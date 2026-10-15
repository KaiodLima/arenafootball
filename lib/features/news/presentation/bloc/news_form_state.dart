import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/web_link.dart';
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

  /// Na notícia comum, o título do destaque a que ela pertence (o destaque
  /// lista as notícias com essa tag); vazio = nenhum. Fixa em anúncio/gol.
  final String tag;
  final String link;
  final bool isVisible;
  final List<String> regions;
  final String? selectedRegion;

  /// Títulos dos destaques existentes, para o vínculo.
  final List<String> highlights;

  /// Capa nova escolhida (substitui a atual).
  final File? cover;

  /// A capa atual foi removida (e nenhuma nova escolhida).
  final bool coverRemoved;

  /// Fotos novas do álbum (enviadas ao salvar).
  final List<File> album;

  /// Fotos do álbum já salvas que continuam (edição).
  final List<String> keptImages;

  const NewsFormData({
    this.original,
    this.title = '',
    this.description = '',
    this.tag = '',
    this.link = '',
    this.isVisible = false,
    this.regions = const [],
    this.selectedRegion,
    this.highlights = const [],
    this.cover,
    this.coverRemoved = false,
    this.album = const [],
    this.keptImages = const [],
  });

  bool get isEditing => original != null;

  /// Anúncio: o título é opcional.
  bool get isAd => tag == NewsDTO.adTag;

  /// URL da capa atual que continua valendo (edição sem troca/remoção).
  String get currentCoverUrl => cover == null && !coverRemoved ? (original?.imageUrl ?? '') : '';

  bool get hasCover => cover != null || currentCoverUrl.isNotEmpty;

  int get albumCount => keptImages.length + album.length;

  NewsTitleError? get titleError {
    if (isAd) return null;
    if (title.trim().isEmpty) return NewsTitleError.required;
    if (title.trim().length < 3) return NewsTitleError.tooShort;
    return null;
  }

  /// Link como será gravado: sem esquema, ganha "https://".
  String get normalizedLink => normalizeWebLink(link);

  /// Link preenchido que não é um endereço web (ex.: "abc").
  bool get linkInvalid => !isValidWebLink(link);

  /// Como no app antigo, título curto mostra aviso mas não bloqueia. O
  /// anúncio precisa do banner e de um link válido (se houver).
  bool get canSubmit =>
      titleError != NewsTitleError.required && selectedRegion != null && (!isAd || (hasCover && !linkInvalid));

  /// Há algo que se perderia ao sair (para o aviso de descartar).
  bool get isDirty {
    final base = original;
    if (cover != null || coverRemoved || album.isNotEmpty) return true;
    if (base == null) {
      return title.trim().isNotEmpty || description.trim().isNotEmpty || link.trim().isNotEmpty;
    }
    return title != base.title ||
        description != base.description ||
        tag != base.tag ||
        link != base.link ||
        isVisible != base.isVisible ||
        (selectedRegion != null && base.region.isNotEmpty && selectedRegion != base.region) ||
        keptImages.length != base.images.length;
  }

  /// Notícia pronta para gravar (sem as imagens novas, que o UseCase envia).
  NewsDTO toNews() {
    final base = original ?? const NewsDTO();
    return base.copyWith(
      title: title.trim(),
      description: description,
      tag: tag,
      link: normalizedLink,
      isVisible: isVisible,
      region: selectedRegion,
      imageUrl: currentCoverUrl,
      images: keptImages,
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
    List<String>? highlights,
    File? cover,
    bool clearCover = false,
    bool? coverRemoved,
    List<File>? album,
    List<String>? keptImages,
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
      highlights: highlights ?? this.highlights,
      cover: clearCover ? null : (cover ?? this.cover),
      coverRemoved: coverRemoved ?? this.coverRemoved,
      album: album ?? this.album,
      keptImages: keptImages ?? this.keptImages,
    );
  }

  @override
  List<Object?> get props => [
        original,
        title,
        description,
        tag,
        link,
        isVisible,
        regions,
        selectedRegion,
        highlights,
        cover?.path,
        coverRemoved,
        album,
        keptImages,
      ];
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
