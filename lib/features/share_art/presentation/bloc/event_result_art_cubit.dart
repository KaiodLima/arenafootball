import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/event_result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/event_result_art.dart';

/// Escolhas da arte do resultado do evento: modelo, paleta, formato e QR.
class EventResultArtState extends Equatable {
  final EventResultArtData data;
  final EventResultArtTemplate template;
  final ArtPalette palette;
  final ArtFormat format;
  final bool showQr;
  final bool busy;

  const EventResultArtState({
    required this.data,
    this.template = EventResultArtTemplate.champion,
    this.palette = ArtPalette.arena,
    this.format = ArtFormat.feed,
    this.showQr = true,
    this.busy = false,
  });

  EventResultArtState copyWith({
    EventResultArtTemplate? template,
    ArtPalette? palette,
    ArtFormat? format,
    bool? showQr,
    bool? busy,
  }) =>
      EventResultArtState(
        data: data,
        template: template ?? this.template,
        palette: palette ?? this.palette,
        format: format ?? this.format,
        showQr: showQr ?? this.showQr,
        busy: busy ?? this.busy,
      );

  @override
  List<Object?> get props => [data, template, palette, format, showQr, busy];
}

class EventResultArtCubit extends Cubit<EventResultArtState> {
  EventResultArtCubit(EventResultArtData data) : super(EventResultArtState(data: data));

  void selectTemplate(EventResultArtTemplate template) => emit(state.copyWith(template: template));
  void selectPalette(ArtPalette palette) => emit(state.copyWith(palette: palette));
  void selectFormat(ArtFormat format) => emit(state.copyWith(format: format));
  void toggleQr(bool value) => emit(state.copyWith(showQr: value));
  void setBusy(bool value) => emit(state.copyWith(busy: value));
}
