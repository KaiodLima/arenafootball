import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_highlights_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/update_news_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_state.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/get_partner_slots_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';

/// Formulário de notícia (criar/editar) e de anúncio (tag "publicidade").
/// O parceiro publica só na região dele, e o anúncio dele vai numa vaga do
/// dia (`PartnerSlots`).
class NewsFormCubit extends Cubit<NewsFormState> {
  final CreateNewsUseCase createNewsUseCase;
  final UpdateNewsUseCase updateNewsUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final WatchHighlightsUseCase watchHighlightsUseCase;
  final GetPartnerSlotsUseCase getPartnerSlotsUseCase;
  PartnerRequestDTO? _partner;

  NewsFormCubit(
    this.createNewsUseCase,
    this.updateNewsUseCase,
    this.getRegionsUseCase,
    this.watchHighlightsUseCase,
    this.getPartnerSlotsUseCase,
  ) : super(const EditingNewsFormState());

  void _edit(NewsFormData form) => emit(EditingNewsFormState(form: form));

  /// [news] preenche o formulário para edição. [tag] fixa a tag na criação
  /// (ex.: anúncio). [authorId]: quem publica. [partner]: quem publica é o
  /// parceiro (região fixa na dele).
  Future<void> load({
    NewsDTO? news,
    required String initialRegion,
    String tag = '',
    String authorId = '',
    PartnerRequestDTO? partner,
  }) async {
    _partner = partner;
    final region = partner != null
        ? partner.region
        : (news != null && news.region.isNotEmpty)
            ? news.region
            : initialRegion;
    _edit(NewsFormData(
      original: news,
      title: news?.title ?? '',
      description: news?.description ?? '',
      tag: news?.tag ?? tag,
      link: news?.link ?? '',
      isVisible: news?.isVisible ?? false,
      regions: [region],
      selectedRegion: region,
      keptImages: news?.images ?? const [],
      authorId: partner?.userId ?? authorId,
      regionLocked: partner != null,
    ));

    await Future.wait([if (partner == null) _loadRegions(region), _loadHighlights()]);
  }

  Future<void> _loadRegions(String region) async {
    final response = await getRegionsUseCase();
    if (isClosed) return;
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isEmpty) return;
    final current = state.form.selectedRegion ?? region;
    _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
  }

  /// Destaques para o vínculo. Falhar só esconde as opções.
  Future<void> _loadHighlights() async {
    final response = await watchHighlightsUseCase().first;
    if (isClosed) return;
    final titles = response.fold(
      (_) => <String>[],
      (list) => list.map((h) => h.title.trim()).where((t) => t.isNotEmpty).toSet().toList(),
    );
    _edit(state.form.copyWith(highlights: titles));
  }

  void changeTitle(String value) => _edit(state.form.copyWith(title: value));

  void changeDescription(String value) => _edit(state.form.copyWith(description: value));

  void changeTag(String value) => _edit(state.form.copyWith(tag: value));

  /// Vincula a notícia a um destaque (pelo título); null desfaz o vínculo.
  void selectHighlight(String? title) => _edit(state.form.copyWith(tag: title ?? ''));

  void changeLink(String value) => _edit(state.form.copyWith(link: value));

  void changeVisible(bool value) => _edit(state.form.copyWith(isVisible: value));

  void selectRegion(String region) => _edit(state.form.copyWith(selectedRegion: region));

  void setCover(File file) => _edit(state.form.copyWith(cover: file, coverRemoved: false));

  void clearCover() => _edit(state.form.copyWith(clearCover: true, coverRemoved: true));

  void addAlbumPhotos(List<File> files) => _edit(state.form.copyWith(album: [...state.form.album, ...files]));

  void removeAlbumPhoto(int index) {
    final album = [...state.form.album]..removeAt(index);
    _edit(state.form.copyWith(album: album));
  }

  void removeKeptImage(String url) =>
      _edit(state.form.copyWith(keptImages: state.form.keptImages.where((u) => u != url).toList()));

  Future<void> submit() async {
    final form = state.form;
    if (!form.canSubmit || state is SubmittingNewsFormState) return;
    emit(SubmittingNewsFormState(form: form));

    var news = form.toNews();
    final partner = _partner;
    // Parceiro: notícia nova e publicidade vão na vaga do dia. Sem vaga, a
    // publicidade para; a notícia pode ir para o admin aprovar.
    if (!form.isEditing && partner != null) {
      final slots = await getPartnerSlotsUseCase(partner);
      if (isClosed) return;
      if (slots.isLeft) {
        emit(ErrorNewsFormState(form: form, errorMessage: slots.left.toString()));
        return;
      }
      final slot = form.isAd ? slots.right.freeAd : slots.right.freeNews;
      if (slot == null) {
        emit(form.isAd
            ? ErrorNewsFormState(form: form, errorMessage: '', limitReached: true)
            : NewsLimitNewsFormState(form: form, limit: partner.permissions.newsPerDay));
        return;
      }
      news = news.copyWith(id: slot);
    }

    final response = form.isEditing
        ? await updateNewsUseCase(news: news, cover: form.cover, album: form.album)
        : await createNewsUseCase(news: news, cover: form.cover, album: form.album);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorNewsFormState(form: form, errorMessage: failure.toString())),
      (_) => emit(SuccessNewsFormState(form: form)),
    );
  }

  /// Parceiro sem vaga de notícia hoje confirmou: vai para o admin aprovar.
  Future<void> submitForApproval() async {
    final form = state.form;
    if (_partner == null || form.isEditing || form.isAd || state is SubmittingNewsFormState) return;
    emit(SubmittingNewsFormState(form: form));
    final response = await createNewsUseCase(
      news: form.toNews(),
      cover: form.cover,
      album: form.album,
      forApproval: true,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorNewsFormState(form: form, errorMessage: failure.toString())),
      (_) => emit(SuccessNewsFormState(form: form, pendingApproval: true)),
    );
  }

  /// Desistiu de mandar para aprovação: volta a editar.
  void keepEditing() => _edit(state.form);
}
