import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/domain/usecases/organizer_request_usecases.dart';

/// Modo da home do organizador: torcedor (a home de sempre) ou organizador
/// (abas só com os campeonatos dele).
class OrganizerModeState extends Equatable {
  /// Campeonatos com `idOrganizador` = conta logada.
  final List<ChampionshipDTO> championships;

  /// Escolha guardada no aparelho (vale só quando [isOrganizer]).
  final bool organizerMode;

  const OrganizerModeState({this.championships = const [], this.organizerMode = false});

  bool get isOrganizer => championships.isNotEmpty;

  /// Modo organizador em uso na home.
  bool get active => isOrganizer && organizerMode;

  OrganizerModeState copyWith({List<ChampionshipDTO>? championships, bool? organizerMode}) => OrganizerModeState(
        championships: championships ?? this.championships,
        organizerMode: organizerMode ?? this.organizerMode,
      );

  @override
  List<Object?> get props => [championships, organizerMode];
}

/// Global: segue a conta logada (o `OwnedTeamSync` chama [follow]) e ouve os
/// campeonatos que ela organiza. Sem campeonato, a home fica no modo torcedor.
class OrganizerModeCubit extends Cubit<OrganizerModeState> {
  final WatchMyChampionshipsUseCase watchMyChampionshipsUseCase;
  final PreferencesService preferences;
  final EnsureMyOrganizerIndexesUseCase? ensureMyIndexesUseCase;
  StreamSubscription<Either<Failure, List<ChampionshipDTO>>>? _subscription;
  String? _userId;

  /// Campeonatos já conferidos nesta sessão (índice do organizador).
  final _indexed = <String>{};

  OrganizerModeCubit(this.watchMyChampionshipsUseCase, this.preferences, [this.ensureMyIndexesUseCase])
      : super(const OrganizerModeState());

  Future<void> follow(String? userId) async {
    if (userId == _userId) return;
    _userId = userId;
    await _subscription?.cancel();
    _subscription = null;
    _indexed.clear();
    emit(const OrganizerModeState());
    if (userId == null) return;
    final saved = await preferences.getOrganizerMode(userId);
    if (isClosed || _userId != userId) return;
    emit(state.copyWith(organizerMode: saved));
    // Falha de leitura: segue como torcedor (o que muda é só a vitrine).
    _subscription = watchMyChampionshipsUseCase(userId).listen((response) {
      if (response.isLeft) return;
      emit(state.copyWith(championships: response.right));
      unawaited(_ensureIndexes(userId, response.right));
    });
  }

  /// Cria o índice que falta dos campeonatos novos nesta sessão (aprovados
  /// antes do índice existir). Só fica marcado quando deu certo: falhou
  /// (regras ainda sem publicar, sem rede), tenta de novo na próxima vez.
  Future<void> _ensureIndexes(String userId, List<ChampionshipDTO> championships) async {
    final useCase = ensureMyIndexesUseCase;
    if (useCase == null) return;
    final pending = [for (final c in championships) if (!_indexed.contains(c.id)) c];
    if (pending.isEmpty) return;
    final response = await useCase(userId, pending);
    if (response.isRight) _indexed.addAll(pending.map((c) => c.id));
  }

  /// Garante o índice da competição [championshipId] antes de gravar
  /// (partida, elenco). Devolve se o índice existe ou foi criado.
  Future<bool> ensureIndexFor(int championshipId) async {
    final userId = _userId;
    final useCase = ensureMyIndexesUseCase;
    final championship = state.championships.where((c) => c.championshipId == championshipId).firstOrNull;
    if (userId == null || useCase == null || championship == null) return false;
    if (_indexed.contains(championship.id)) return true;
    final response = await useCase(userId, [championship]);
    if (response.isLeft) return false;
    _indexed.add(championship.id);
    return true;
  }

  /// Troca entre torcedor e organizador (lembrado no aparelho, por conta).
  Future<void> toggle() async {
    final userId = _userId;
    if (userId == null || !state.isOrganizer) return;
    final value = !state.organizerMode;
    emit(state.copyWith(organizerMode: value));
    await preferences.setOrganizerMode(userId, value);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
