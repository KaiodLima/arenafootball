import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_photo_framing.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/player_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_art.dart';

/// Escolhas da arte do atleta: modelo, paleta, formato e QR (sem leitura).
class PlayerArtState extends Equatable {
  final PlayerArtData data;
  final PlayerArtTemplate template;
  final ArtPalette palette;
  final ArtFormat format;
  final bool showQr;
  final bool busy;

  /// Enquadramento da foto (arrastar e pinça na prévia).
  final ArtPhotoFraming framing;

  /// Foto do aparelho (galeria/câmera) usada só nesta arte, no lugar da do
  /// atleta: nada é enviado nem muda o cadastro. Nulo = a foto do atleta.
  final String? localPhoto;

  const PlayerArtState({
    required this.data,
    this.template = PlayerArtTemplate.signing,
    this.palette = ArtPalette.teams,
    this.format = ArtFormat.feed,
    this.showQr = true,
    this.busy = false,
    this.framing = ArtPhotoFraming.centered,
    this.localPhoto,
  });

  PlayerArtState copyWith({
    PlayerArtTemplate? template,
    ArtPalette? palette,
    ArtFormat? format,
    bool? showQr,
    bool? busy,
    ArtPhotoFraming? framing,
    String? Function()? localPhoto,
  }) =>
      PlayerArtState(
        data: data,
        template: template ?? this.template,
        palette: palette ?? this.palette,
        format: format ?? this.format,
        showQr: showQr ?? this.showQr,
        busy: busy ?? this.busy,
        framing: framing ?? this.framing,
        localPhoto: localPhoto != null ? localPhoto() : this.localPhoto,
      );

  @override
  List<Object?> get props => [data, template, palette, format, showQr, busy, framing, localPhoto];
}

class PlayerArtCubit extends Cubit<PlayerArtState> {
  PlayerArtCubit(PlayerArtData data) : super(PlayerArtState(data: data));

  void selectTemplate(PlayerArtTemplate template) => emit(state.copyWith(template: template));
  void selectPalette(ArtPalette palette) => emit(state.copyWith(palette: palette));
  void selectFormat(ArtFormat format) => emit(state.copyWith(format: format));
  void toggleQr(bool value) => emit(state.copyWith(showQr: value));
  void setBusy(bool value) => emit(state.copyWith(busy: value));
  void moveFraming(double dx, double dy) => emit(state.copyWith(framing: state.framing.moved(dx, dy)));
  void zoomFraming(double factor) => emit(state.copyWith(framing: state.framing.zoomed(factor)));
  void resetFraming() => emit(state.copyWith(framing: ArtPhotoFraming.centered));

  /// Usa a foto do aparelho só nesta arte (o enquadramento recomeça).
  void useLocalPhoto(String path) => emit(state.copyWith(localPhoto: () => path, framing: ArtPhotoFraming.centered));

  /// Volta à foto do atleta.
  void clearLocalPhoto() => emit(state.copyWith(localPhoto: () => null, framing: ArtPhotoFraming.centered));
}
