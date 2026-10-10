import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/update_news_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';

/// Formulário de notícia (criar/editar) e de anúncio (tag "publicidade").
class NewsFormCubit extends Cubit<NewsFormState> {
  final CreateNewsUseCase createNewsUseCase;
  final UpdateNewsUseCase updateNewsUseCase;
  final GetRegionsUseCase getRegionsUseCase;

  NewsFormCubit(
    this.createNewsUseCase,
    this.updateNewsUseCase,
    this.getRegionsUseCase,
  ) : super(const EditingNewsFormState());

  void _edit(NewsFormData form) => emit(EditingNewsFormState(form: form));

  /// [news] preenche o formulário para edição. [tag] fixa a tag na criação
  /// (ex.: anúncio).
  Future<void> load({NewsDTO? news, required String initialRegion, String tag = ''}) async {
    final region = (news != null && news.region.isNotEmpty) ? news.region : initialRegion;
    _edit(NewsFormData(
      original: news,
      title: news?.title ?? '',
      description: news?.description ?? '',
      tag: news?.tag ?? tag,
      link: news?.link ?? '',
      isVisible: news?.isVisible ?? false,
      regions: [region],
      selectedRegion: region,
    ));

    final response = await getRegionsUseCase();
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isEmpty) return;
    final current = state.form.selectedRegion ?? region;
    _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
  }

  void changeTitle(String value) => _edit(state.form.copyWith(title: value));

  void changeDescription(String value) => _edit(state.form.copyWith(description: value));

  void changeTag(String value) => _edit(state.form.copyWith(tag: value));

  void changeLink(String value) => _edit(state.form.copyWith(link: value));

  void changeVisible(bool value) => _edit(state.form.copyWith(isVisible: value));

  void selectRegion(String region) => _edit(state.form.copyWith(selectedRegion: region));

  void setCover(File file) => _edit(state.form.copyWith(cover: file));

  void addAlbumPhotos(List<File> files) => _edit(state.form.copyWith(album: [...state.form.album, ...files]));

  void removeAlbumPhoto(int index) {
    final album = [...state.form.album]..removeAt(index);
    _edit(state.form.copyWith(album: album));
  }

  Future<void> submit() async {
    final form = state.form;
    if (!form.canSubmit || state is SubmittingNewsFormState) return;
    emit(SubmittingNewsFormState(form: form));

    final response = form.isEditing
        ? await updateNewsUseCase(news: form.toNews(), cover: form.cover)
        : await createNewsUseCase(news: form.toNews(), cover: form.cover, album: form.album);
    response.fold(
      (failure) => emit(ErrorNewsFormState(form: form, errorMessage: failure.toString())),
      (_) => emit(SuccessNewsFormState(form: form)),
    );
  }
}
