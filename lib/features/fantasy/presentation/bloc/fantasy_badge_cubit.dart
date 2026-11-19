import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';

class FantasyBadgeState extends Equatable {
  /// Fantasy ativos da temporada (todas as regiões; o selo filtra a escolhida).
  final List<FantasyConfigDTO> active;

  const FantasyBadgeState({this.active = const []});

  /// Os que valem para a região [region] (vazia = todas).
  List<FantasyConfigDTO> forRegion(String region) => [
        for (final config in active)
          if (config.appliesTo(region)) config,
      ];

  @override
  List<Object?> get props => [active];
}

/// Selo do Arena Fantasy na home: escuta os Fantasy ativos da temporada (uma
/// consulta, cache do Firestore).
class FantasyBadgeCubit extends Cubit<FantasyBadgeState> {
  final WatchActiveFantasiesUseCase _watchActive;

  FantasyBadgeCubit(this._watchActive) : super(const FantasyBadgeState());

  StreamSubscription<Object?>? _subscription;
  String? _season;

  /// Liga a escuta da [season] (de novo só se a temporada mudar).
  void follow(String season) {
    if (_season == season) return;
    _season = season;
    _subscription?.cancel();
    _subscription = _watchActive(season).listen((response) {
      if (isClosed) return;
      // Falha: some o selo (não atrapalha a home).
      emit(FantasyBadgeState(active: response.fold((_) => const [], (list) => list)));
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
