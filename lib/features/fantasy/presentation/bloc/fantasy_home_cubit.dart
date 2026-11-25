import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';

/// Situação da conta num Fantasy (cartão da home).
enum FantasyHomeStatus { notJoined, noRound, pickTeam, copied, confirmed, locked }

/// Um Fantasy na home: a configuração, a rodada atual, a participação, a
/// escalação da rodada e a posição no geral.
class FantasyHomeItem extends Equatable {
  final FantasyConfigDTO config;
  final FantasyRoundDTO? round;
  final FantasyParticipantDTO? participant;
  final FantasyLineupDTO? lineup;
  final int? position;

  const FantasyHomeItem({required this.config, this.round, this.participant, this.lineup, this.position});

  bool get joined => participant != null;

  FantasyHomeStatus statusAt(DateTime now) {
    if (!joined) return FantasyHomeStatus.notJoined;
    final current = round;
    if (current == null || config.currentRound <= 0) return FantasyHomeStatus.noRound;
    if (!current.isOpenAt(now)) return FantasyHomeStatus.locked;
    if (lineup == null) return FantasyHomeStatus.pickTeam;
    return lineup!.copied ? FantasyHomeStatus.copied : FantasyHomeStatus.confirmed;
  }

  FantasyHomeItem copyWith({
    FantasyConfigDTO? config,
    FantasyRoundDTO? Function()? round,
    FantasyParticipantDTO? Function()? participant,
    FantasyLineupDTO? Function()? lineup,
    int? Function()? position,
  }) =>
      FantasyHomeItem(
        config: config ?? this.config,
        round: round != null ? round() : this.round,
        participant: participant != null ? participant() : this.participant,
        lineup: lineup != null ? lineup() : this.lineup,
        position: position != null ? position() : this.position,
      );

  @override
  List<Object?> get props => [config, round, participant, lineup, position];
}

class FantasyHomeState extends Equatable {
  final bool loaded;
  final Map<String, FantasyHomeItem> items;

  const FantasyHomeState({this.loaded = false, this.items = const {}});

  /// Os da região [region] (vazia = todas): quem a conta joga primeiro, depois
  /// pelo nome do campeonato.
  List<FantasyHomeItem> forRegion(String region) => [
        for (final item in items.values)
          if (item.config.appliesTo(region)) item,
      ]..sort((a, b) {
          if (a.joined != b.joined) return a.joined ? -1 : 1;
          return a.config.title.toLowerCase().compareTo(b.config.title.toLowerCase());
        });

  @override
  List<Object?> get props => [loaded, items];
}

/// Home do Arena Fantasy: os Fantasy ativos da temporada e, em cada um, a
/// rodada atual, a participação e a escalação da conta (poucos docs, streams
/// com o cache do Firestore).
class FantasyHomeCubit extends Cubit<FantasyHomeState> {
  final WatchActiveFantasiesUseCase _active;
  final WatchFantasyRoundUseCase _round;
  final WatchFantasyParticipantUseCase _participant;
  final WatchFantasyLineupUseCase _lineup;
  final GetFantasyPositionCacheFirstUseCase _position;

  FantasyHomeCubit(this._active, this._round, this._participant, this._lineup, this._position)
      : super(const FantasyHomeState());

  StreamSubscription<Object?>? _activeSub;

  /// Por Fantasy: as escutas e a rodada que elas seguem.
  final _subs = <String, List<StreamSubscription<Object?>>>{};
  final _followedRound = <String, int>{};
  final _pointsAsked = <String, double>{};
  String _uid = '';

  void load({required String season, required String uid}) {
    _uid = uid;
    _activeSub?.cancel();
    _activeSub = _active(season).listen((response) {
      if (isClosed) return;
      final configs = response.fold((_) => const <FantasyConfigDTO>[], (list) => list);
      final next = <String, FantasyHomeItem>{
        for (final config in configs)
          config.championshipDocId:
              (state.items[config.championshipDocId] ?? FantasyHomeItem(config: config)).copyWith(config: config),
      };
      // Fantasy que saiu (desligado): para de escutar.
      for (final id in _subs.keys.toList()) {
        if (!next.containsKey(id)) _cancel(id);
      }
      emit(FantasyHomeState(loaded: true, items: next));
      for (final config in configs) {
        _follow(config);
      }
    });
  }

  void _update(String id, FantasyHomeItem Function(FantasyHomeItem item) change) {
    final item = state.items[id];
    if (isClosed || item == null) return;
    emit(FantasyHomeState(loaded: true, items: {...state.items, id: change(item)}));
  }

  void _follow(FantasyConfigDTO config) {
    final id = config.championshipDocId;
    if (_subs.containsKey(id) && _followedRound[id] == config.currentRound) return;
    _cancel(id);
    _followedRound[id] = config.currentRound;
    final subs = <StreamSubscription<Object?>>[];
    if (config.currentRound > 0) {
      subs.add(_round(id, config.currentRound)
          .listen((r) => _update(id, (i) => i.copyWith(round: () => r.fold((_) => null, (v) => v)))));
    }
    if (_uid.isNotEmpty) {
      subs.add(_participant(id, _uid).listen((r) {
        final participant = r.fold((_) => null, (v) => v);
        _update(id, (i) => i.copyWith(participant: () => participant));
        if (participant != null) _askPosition(id, participant.points);
      }));
      if (config.currentRound > 0) {
        subs.add(_lineup(id, config.currentRound, _uid)
            .listen((r) => _update(id, (i) => i.copyWith(lineup: () => r.fold((_) => null, (v) => v)))));
      }
    }
    _subs[id] = subs;
  }

  /// Posição no geral (os que têm mais + 1; uma leitura só quando os pontos
  /// mudam, com cache de 10 min por Fantasy e conta).
  Future<void> _askPosition(String id, double points) async {
    if (_pointsAsked[id] == points) return;
    _pointsAsked[id] = points;
    final response = await _position(id, points, uid: _uid);
    _update(id, (i) => i.copyWith(position: () => response.fold((_) => null, (p) => p)));
  }

  void _cancel(String id) {
    for (final sub in _subs.remove(id) ?? const <StreamSubscription<Object?>>[]) {
      sub.cancel();
    }
    _followedRound.remove(id);
  }

  @override
  Future<void> close() async {
    await _activeSub?.cancel();
    for (final id in _subs.keys.toList()) {
      _cancel(id);
    }
    return super.close();
  }
}
