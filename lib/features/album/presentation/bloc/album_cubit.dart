import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_layout.dart';
import 'package:arena_soccer/features/album/domain/usecases/album_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

class AlbumState extends Equatable {
  final AlbumEventDTO? event;
  final List<StickerDTO> stickers;
  final UserAlbumDTO album;

  /// Pacote de hoje (nulo = ainda disponível).
  final AlbumPackDTO? todayPack;
  final bool loading;

  /// Pacote pedido, esperando o sorteio do servidor.
  final bool opening;

  /// Times da temporada (cores e escudo das páginas), pelo id.
  final Map<String, TeamDTO> teams;

  const AlbumState({
    this.event,
    this.stickers = const [],
    this.album = const UserAlbumDTO(),
    this.todayPack,
    this.loading = true,
    this.opening = false,
    this.teams = const {},
  });

  List<AlbumTeamPage> get pages => event == null ? const [] : AlbumLayout.pages(event!, stickers);

  int get collected => album.collected(stickers);

  bool get packAvailable => todayPack == null && !opening;

  /// Figurinha pelo id (nula se saiu do catálogo).
  StickerDTO? sticker(String id) {
    for (final s in stickers) {
      if (s.id == id) return s;
    }
    return null;
  }

  AlbumState copyWith({
    AlbumEventDTO? event,
    List<StickerDTO>? stickers,
    UserAlbumDTO? album,
    AlbumPackDTO? Function()? todayPack,
    bool? loading,
    bool? opening,
    Map<String, TeamDTO>? teams,
  }) {
    return AlbumState(
      event: event ?? this.event,
      stickers: stickers ?? this.stickers,
      album: album ?? this.album,
      todayPack: todayPack != null ? todayPack() : this.todayPack,
      loading: loading ?? this.loading,
      opening: opening ?? this.opening,
      teams: teams ?? this.teams,
    );
  }

  @override
  List<Object?> get props => [event, stickers, album, todayPack, loading, opening, teams];
}

/// O pacote acabou de abrir: a tela mostra a animação com [pack].
class PackOpenedAlbumState extends AlbumState {
  final AlbumPackDTO pack;

  PackOpenedAlbumState(AlbumState from, this.pack)
      : super(
          event: from.event,
          stickers: from.stickers,
          album: from.album,
          todayPack: from.todayPack,
          loading: false,
          teams: from.teams,
        );

  @override
  List<Object?> get props => [...super.props, pack];
}

class ErrorAlbumState extends AlbumState {
  final String errorMessage;

  ErrorAlbumState(AlbumState from, this.errorMessage)
      : super(
          event: from.event,
          stickers: from.stickers,
          album: from.album,
          todayPack: from.todayPack,
          loading: false,
          teams: from.teams,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Tela do álbum: catálogo, figurinhas da conta e o pacote do dia (pedir e
/// esperar o sorteio do servidor).
class AlbumCubit extends Cubit<AlbumState> {
  final AlbumUseCase albumUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  late String _userId;

  AlbumCubit(this.albumUseCase, this.getTeamsCacheFirstUseCase) : super(const AlbumState());

  void start({required AlbumEventDTO event, required String userId}) {
    _userId = userId;
    emit(state.copyWith(event: event));
    _subscriptions
      ..add(albumUseCase.watchStickers(event.id).listen((response) {
        if (isClosed) return;
        response.fold(
          (failure) => emit(ErrorAlbumState(state, failure.toString())),
          (stickers) => emit(state.copyWith(stickers: stickers, loading: false)),
        );
      }))
      ..add(albumUseCase.watchMyAlbum(userId: userId, eventId: event.id).listen((response) {
        if (isClosed || response.isLeft) return;
        emit(state.copyWith(album: response.right));
      }))
      ..add(albumUseCase.watchTodayPack(userId: userId, eventId: event.id).listen(_onPack));
    _loadTeams();
  }

  /// Cores e escudos das páginas. Falha só deixa as páginas no verde do app.
  Future<void> _loadTeams() async {
    final response = await getTeamsCacheFirstUseCase().last;
    if (isClosed || response.isLeft) return;
    emit(state.copyWith(teams: {for (final team in response.right) team.id: team}));
  }

  void _onPack(Either<Failure, AlbumPackDTO?> response) {
    if (isClosed || response.isLeft) return;
    final pack = response.right;
    final wasOpening = state.opening;
    final next = state.copyWith(todayPack: () => pack, opening: pack != null && !pack.isOpened && wasOpening);
    if (wasOpening && pack != null && pack.isOpened) {
      emit(PackOpenedAlbumState(next, pack));
      return;
    }
    if (wasOpening &&
        pack != null &&
        (pack.status == AlbumPackStatus.refused || pack.status == AlbumPackStatus.error)) {
      emit(ErrorAlbumState(next, ''));
      return;
    }
    emit(next);
  }

  /// Pede o pacote do dia; a animação começa quando o servidor sorteia.
  Future<void> openPack() async {
    final event = state.event;
    if (event == null || !state.packAvailable) return;
    emit(state.copyWith(opening: true));
    final response = await albumUseCase.openTodayPack(userId: _userId, eventId: event.id);
    if (isClosed) return;
    if (response.isLeft) emit(ErrorAlbumState(state.copyWith(opening: false), response.left.toString()));
  }

  @override
  Future<void> close() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    return super.close();
  }
}
