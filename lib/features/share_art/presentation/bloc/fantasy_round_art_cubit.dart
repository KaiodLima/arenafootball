import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/fantasy_round_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/fantasy/fantasy_round_art.dart';

/// Escolhas da arte dos "Craques da rodada": modelo, paleta, formato e QR.
class FantasyRoundArtState extends Equatable {
  final FantasyRoundArtData data;
  final FantasyRoundArtTemplate template;
  final ArtPalette palette;
  final ArtFormat format;
  final bool showQr;
  final bool busy;

  const FantasyRoundArtState({
    required this.data,
    this.template = FantasyRoundArtTemplate.podium,
    this.palette = ArtPalette.arena,
    this.format = ArtFormat.feed,
    this.showQr = true,
    this.busy = false,
  });

  FantasyRoundArtState copyWith({
    FantasyRoundArtTemplate? template,
    ArtPalette? palette,
    ArtFormat? format,
    bool? showQr,
    bool? busy,
  }) =>
      FantasyRoundArtState(
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

class FantasyRoundArtCubit extends Cubit<FantasyRoundArtState> {
  FantasyRoundArtCubit(FantasyRoundArtData data) : super(FantasyRoundArtState(data: data));

  void selectTemplate(FantasyRoundArtTemplate template) => emit(state.copyWith(template: template));
  void selectPalette(ArtPalette palette) => emit(state.copyWith(palette: palette));
  void selectFormat(ArtFormat format) => emit(state.copyWith(format: format));
  void toggleQr(bool value) => emit(state.copyWith(showQr: value));
  void setBusy(bool value) => emit(state.copyWith(busy: value));
}
