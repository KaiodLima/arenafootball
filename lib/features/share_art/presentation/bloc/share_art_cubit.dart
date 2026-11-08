import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/domain/usecases/prepare_result_art_usecase.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/result_art.dart';

class ShareArtState extends Equatable {
  final ResultArtData? data;
  final ResultArtTemplate template;

  /// Modelo da divulgação (partida que ainda não começou).
  final PreviewArtTemplate previewTemplate;

  /// Paleta da divulgação (padrão: as cores dos times).
  final ArtPalette palette;
  final ArtFormat format;
  final bool showQr;

  /// Exportando (salvar/compartilhar): botões desligados.
  final bool busy;

  const ShareArtState({
    this.data,
    this.template = ResultArtTemplate.vibrant,
    this.previewTemplate = PreviewArtTemplate.matchday,
    this.palette = ArtPalette.teams,
    this.format = ArtFormat.feed,
    this.showQr = true,
    this.busy = false,
  });

  bool get loading => data == null;

  /// Partida por começar: a tela vira "Divulgar partida" (artes de divulgação).
  bool get preview => data?.status == ArtMatchStatus.notStarted;

  /// Nome do modelo em uso (nome do arquivo exportado).
  String get templateName => preview ? previewTemplate.name : template.name;

  ShareArtState copyWith({
    ResultArtData? data,
    ResultArtTemplate? template,
    PreviewArtTemplate? previewTemplate,
    ArtPalette? palette,
    ArtFormat? format,
    bool? showQr,
    bool? busy,
  }) =>
      ShareArtState(
        data: data ?? this.data,
        template: template ?? this.template,
        previewTemplate: previewTemplate ?? this.previewTemplate,
        palette: palette ?? this.palette,
        format: format ?? this.format,
        showQr: showQr ?? this.showQr,
        busy: busy ?? this.busy,
      );

  @override
  List<Object?> get props => [data, template, previewTemplate, palette, format, showQr, busy];
}

/// "Gerar arte" da partida: os dados oficiais (pelos caches), o modelo, o
/// formato e o QR. Só apresentação: não grava nada.
class ShareArtCubit extends Cubit<ShareArtState> {
  final PrepareResultArtUseCase prepareResultArtUseCase;

  ShareArtCubit(this.prepareResultArtUseCase) : super(const ShareArtState());

  Future<void> load({required MatchDTO match, required String season}) async {
    final data = await prepareResultArtUseCase(match: match, season: season);
    if (!isClosed) emit(state.copyWith(data: data));
  }

  void selectTemplate(ResultArtTemplate template) => emit(state.copyWith(template: template));

  void selectPreviewTemplate(PreviewArtTemplate template) => emit(state.copyWith(previewTemplate: template));

  void selectPalette(ArtPalette palette) => emit(state.copyWith(palette: palette));

  void selectFormat(ArtFormat format) => emit(state.copyWith(format: format));

  void toggleQr(bool value) => emit(state.copyWith(showQr: value));

  void setBusy(bool value) => emit(state.copyWith(busy: value));
}
