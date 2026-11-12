import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_photo_framing.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/player_match_art_data.dart';
import 'package:arena_soccer/features/share_art/domain/usecases/prepare_result_art_usecase.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';

class PlayerMatchArtState extends Equatable {
  /// Nulo enquanto prepara a partida (escudos e cores pelo cache).
  final PlayerMatchArtData? data;
  final PlayerMatchArtTemplate template;
  final ArtPalette palette;
  final ArtFormat format;
  final bool showQr;
  final bool busy;

  /// Enquadramento da foto (arrastar e pinça na prévia).
  final ArtPhotoFraming framing;

  const PlayerMatchArtState({
    this.data,
    this.template = PlayerMatchArtTemplate.cover,
    this.palette = ArtPalette.teams,
    this.format = ArtFormat.feed,
    this.showQr = true,
    this.busy = false,
    this.framing = ArtPhotoFraming.centered,
  });

  PlayerMatchArtState copyWith({
    PlayerMatchArtData? data,
    PlayerMatchArtTemplate? template,
    ArtPalette? palette,
    ArtFormat? format,
    bool? showQr,
    bool? busy,
    ArtPhotoFraming? framing,
  }) =>
      PlayerMatchArtState(
        data: data ?? this.data,
        template: template ?? this.template,
        palette: palette ?? this.palette,
        format: format ?? this.format,
        showQr: showQr ?? this.showQr,
        busy: busy ?? this.busy,
        framing: framing ?? this.framing,
      );

  @override
  List<Object?> get props => [data, template, palette, format, showQr, busy, framing];
}

/// Arte do atleta na partida: prepara a partida (a mesma leitura em cache da
/// divulgação) e guarda as escolhas de modelo, cores, formato e QR.
class PlayerMatchArtCubit extends Cubit<PlayerMatchArtState> {
  final PrepareResultArtUseCase _prepare;

  PlayerMatchArtCubit(this._prepare) : super(const PlayerMatchArtState());

  Future<void> load({
    required MatchDTO match,
    required String season,
    required PlayerDTO player,
    required MatchSide side,
  }) async {
    final prepared = await _prepare(match: match, season: season);
    if (isClosed) return;
    emit(state.copyWith(
      data: PlayerMatchArtData.of(
        player: player,
        match: prepared,
        side: side,
        championshipId: match.championshipId,
        season: season,
      ),
    ));
  }

  void selectTemplate(PlayerMatchArtTemplate template) => emit(state.copyWith(template: template));
  void selectPalette(ArtPalette palette) => emit(state.copyWith(palette: palette));
  void selectFormat(ArtFormat format) => emit(state.copyWith(format: format));
  void toggleQr(bool value) => emit(state.copyWith(showQr: value));
  void setBusy(bool value) => emit(state.copyWith(busy: value));
  void moveFraming(double dx, double dy) => emit(state.copyWith(framing: state.framing.moved(dx, dy)));
  void zoomFraming(double factor) => emit(state.copyWith(framing: state.framing.zoomed(factor)));
  void resetFraming() => emit(state.copyWith(framing: ArtPhotoFraming.centered));
}
