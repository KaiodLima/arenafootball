import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_pack_id.dart';
import 'package:arena_soccer/features/album/domain/usecases/album_usecase.dart';

/// Evento do álbum ativo e se o pacotinho da conta está liberado (o botão
/// flutuante da home). [event] nulo = evento desligado.
class AlbumEventState extends Equatable {
  final AlbumEventDTO? event;
  final String userId;
  final bool isAdmin;
  final bool packAvailable;

  /// Quando libera o próximo (contagem do selo); nulo = liberado.
  final DateTime? nextPackAt;

  const AlbumEventState({
    this.event,
    this.userId = '',
    this.isAdmin = false,
    this.packAvailable = false,
    this.nextPackAt,
  });

  /// Mostra o botão flutuante: evento ativo e conta logada; em teste, só
  /// para o admin.
  bool get visible => event != null && userId.isNotEmpty && (!event!.adminOnly || isAdmin);

  @override
  List<Object?> get props => [event, userId, isAdmin, packAvailable, nextPackAt];
}

/// Global: segue o evento ativo e o álbum da conta logada (o `OwnedTeamSync`
/// chama [follow] quando a sessão muda). O pacote libera 24 h depois do
/// último (`ultimoPacote`); um timer vira o selo na hora, com o app aberto.
/// Falha de leitura só esconde o botão.
class AlbumEventCubit extends Cubit<AlbumEventState> {
  final AlbumUseCase albumUseCase;
  StreamSubscription<Either<Failure, AlbumEventDTO?>>? _event;
  StreamSubscription<Either<Failure, UserAlbumDTO>>? _album;
  Timer? _readyTimer;
  DateTime? _lastPackAt;
  bool _albumLoaded = false;
  String _userId = '';
  bool _isAdmin = false;
  bool _started = false;

  AlbumEventCubit(this.albumUseCase) : super(const AlbumEventState());

  void follow(String? userId, {bool isAdmin = false}) {
    _userId = userId ?? '';
    _isAdmin = isAdmin;
    if (!_started) {
      _started = true;
      _event = albumUseCase.watchActiveEvent().listen((response) {
        if (isClosed) return;
        final event = response.fold((_) => null, (e) => e);
        final changed = event?.id != state.event?.id;
        _emit(event: event);
        if (changed) _watchAlbum(event);
      });
    }
    _emit(event: state.event);
    _watchAlbum(state.event);
  }

  /// Revê o pacote (ex.: depois de abrir um).
  void refresh() => _schedule();

  void _watchAlbum(AlbumEventDTO? event) {
    _album?.cancel();
    _album = null;
    _albumLoaded = false;
    _lastPackAt = null;
    _schedule();
    if (event == null || _userId.isEmpty) return;
    _album = albumUseCase.watchMyAlbum(userId: _userId, eventId: event.id).listen((response) {
      if (isClosed || response.isLeft) return;
      _albumLoaded = true;
      _lastPackAt = response.right.lastPackAt;
      _schedule();
    });
  }

  /// Liberado = já passaram 24 h do último (ou nunca abriu); senão, agenda
  /// a virada para a hora exata.
  void _schedule() {
    _readyTimer?.cancel();
    final now = DateTime.now();
    final ready = _albumLoaded && AlbumPackId.isAvailable(_lastPackAt, now);
    _emit(event: state.event, packAvailable: ready, nextPackAt: ready ? null : AlbumPackId.nextAt(_lastPackAt));
    if (_albumLoaded && !ready) {
      _readyTimer = Timer(AlbumPackId.untilNext(_lastPackAt, now), () {
        if (!isClosed) _schedule();
      });
    }
  }

  void _emit({AlbumEventDTO? event, bool? packAvailable, DateTime? nextPackAt}) {
    final hasUser = event != null && _userId.isNotEmpty;
    emit(AlbumEventState(
      event: event,
      userId: _userId,
      isAdmin: _isAdmin,
      packAvailable: hasUser && (packAvailable ?? state.packAvailable),
      nextPackAt: hasUser ? (packAvailable == null ? state.nextPackAt : nextPackAt) : null,
    ));
  }

  @override
  Future<void> close() {
    _event?.cancel();
    _album?.cancel();
    _readyTimer?.cancel();
    return super.close();
  }
}
