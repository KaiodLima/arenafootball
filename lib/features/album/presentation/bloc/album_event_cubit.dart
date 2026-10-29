import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/usecases/album_usecase.dart';

/// Evento do álbum ativo e se o pacote de hoje da conta ainda está disponível
/// (o botão flutuante da home). [event] nulo = evento desligado.
class AlbumEventState extends Equatable {
  final AlbumEventDTO? event;
  final String userId;
  final bool packAvailable;

  const AlbumEventState({this.event, this.userId = '', this.packAvailable = false});

  /// Mostra o botão flutuante: evento ativo e conta logada.
  bool get visible => event != null && userId.isNotEmpty;

  @override
  List<Object?> get props => [event, userId, packAvailable];
}

/// Global: segue o evento ativo e o pacote do dia da conta logada (o
/// `OwnedTeamSync` chama [follow] quando a sessão muda). Falha de leitura só
/// esconde o botão.
class AlbumEventCubit extends Cubit<AlbumEventState> {
  final AlbumUseCase albumUseCase;
  StreamSubscription<Either<Failure, AlbumEventDTO?>>? _event;
  StreamSubscription<Either<Failure, AlbumPackDTO?>>? _pack;
  String _userId = '';
  bool _started = false;

  AlbumEventCubit(this.albumUseCase) : super(const AlbumEventState());

  void follow(String? userId) {
    _userId = userId ?? '';
    if (!_started) {
      _started = true;
      _event = albumUseCase.watchActiveEvent().listen((response) {
        if (isClosed) return;
        final event = response.fold((_) => null, (e) => e);
        if (event?.id != state.event?.id) _watchPack(event);
        emit(AlbumEventState(event: event, userId: _userId, packAvailable: state.packAvailable));
      });
    }
    emit(AlbumEventState(event: state.event, userId: _userId, packAvailable: state.packAvailable));
    _watchPack(state.event);
  }

  /// Revê o pacote do dia (ex.: virou o dia com o app aberto).
  void refresh() => _watchPack(state.event);

  void _watchPack(AlbumEventDTO? event) {
    _pack?.cancel();
    _pack = null;
    if (event == null || _userId.isEmpty) {
      if (state.packAvailable) emit(AlbumEventState(event: event, userId: _userId));
      return;
    }
    _pack = albumUseCase.watchTodayPack(userId: _userId, eventId: event.id).listen((response) {
      if (isClosed) return;
      final available = response.fold((_) => false, (pack) => pack == null);
      emit(AlbumEventState(event: state.event, userId: _userId, packAvailable: available));
    });
  }

  @override
  Future<void> close() {
    _event?.cancel();
    _pack?.cancel();
    return super.close();
  }
}
