import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_championships_usecase.dart';
import 'package:arena_soccer/features/organizer_requests/domain/usecases/organizer_request_usecases.dart';

/// Modo da home do organizador: torcedor (a home de sempre) ou organizador
/// (abas só com os campeonatos dele). O admin geral também tem o modo, com
/// todos os campeonatos da temporada atual.
class OrganizerModeState extends Equatable {
  /// Campeonatos com `idOrganizador` = conta logada (admin: todos da temporada).
  final List<ChampionshipDTO> championships;

  /// Conta admin: modo organizador em todos os campeonatos.
  final bool isAdmin;

  /// `id_campeonato` escolhido nas abas Times/Tabelas do modo (0 = o primeiro);
  /// vale enquanto o app está aberto.
  final int selectedChampionshipId;

  /// Escolha guardada no aparelho (vale só quando [isOrganizer]).
  final bool organizerMode;

  const OrganizerModeState({
    this.championships = const [],
    this.organizerMode = false,
    this.isAdmin = false,
    this.selectedChampionshipId = 0,
  });

  /// O escolhido entre [options]; sem escolha ou fora da lista, o primeiro.
  ChampionshipDTO? selectedIn(List<ChampionshipDTO> options) =>
      options.where((c) => c.championshipId == selectedChampionshipId).firstOrNull ?? options.firstOrNull;

  /// Toggle disponível: organiza algum campeonato ou é admin.
  bool get isOrganizer => isAdmin || championships.isNotEmpty;

  /// Modo organizador em uso na home.
  bool get active => isOrganizer && organizerMode;

  OrganizerModeState copyWith(
          {List<ChampionshipDTO>? championships, bool? organizerMode, bool? isAdmin, int? selectedChampionshipId}) =>
      OrganizerModeState(
        championships: championships ?? this.championships,
        organizerMode: organizerMode ?? this.organizerMode,
        isAdmin: isAdmin ?? this.isAdmin,
        selectedChampionshipId: selectedChampionshipId ?? this.selectedChampionshipId,
      );

  @override
  List<Object?> get props => [championships, organizerMode, isAdmin, selectedChampionshipId];
}

/// Global: segue a conta logada (o `OwnedTeamSync` chama [follow]) e ouve os
/// campeonatos que ela organiza. Sem campeonato, a home fica no modo torcedor.
class OrganizerModeCubit extends Cubit<OrganizerModeState> {
  final WatchMyChampionshipsUseCase watchMyChampionshipsUseCase;
  final PreferencesService preferences;
  final EnsureMyOrganizerIndexesUseCase? ensureMyIndexesUseCase;

  /// Todos os campeonatos (modo do admin).
  final WatchChampionshipsUseCase? watchAllChampionshipsUseCase;
  StreamSubscription<Either<Failure, List<ChampionshipDTO>>>? _subscription;
  String? _userId;
  bool _isAdmin = false;

  /// Campeonatos já conferidos nesta sessão (índice do organizador).
  final _indexed = <String>{};

  OrganizerModeCubit(
    this.watchMyChampionshipsUseCase,
    this.preferences, [
    this.ensureMyIndexesUseCase,
    this.watchAllChampionshipsUseCase,
  ]) : super(const OrganizerModeState());

  /// Campeonatos da temporada atual, mais novos primeiro (modo do admin).
  static List<ChampionshipDTO> currentSeasonOf(List<ChampionshipDTO> all, String season) => [
        for (final c in all)
          if (c.season == season) c
      ]..sort((a, b) => b.championshipId.compareTo(a.championshipId));

  /// [isAdmin]: o admin geral organiza todos os campeonatos da temporada atual.
  Future<void> follow(String? userId, {bool isAdmin = false}) async {
    final admin = isAdmin && watchAllChampionshipsUseCase != null;
    if (userId == _userId && admin == _isAdmin) return;
    _userId = userId;
    _isAdmin = admin;
    await _subscription?.cancel();
    _subscription = null;
    _indexed.clear();
    emit(const OrganizerModeState());
    if (userId == null) return;
    final saved = await preferences.getOrganizerMode(userId);
    if (isClosed || _userId != userId) return;
    emit(state.copyWith(organizerMode: saved, isAdmin: admin));
    if (admin) {
      // Admin: as regras já deixam gravar tudo, sem índice do organizador.
      _subscription = watchAllChampionshipsUseCase!().listen((response) {
        if (response.isLeft) return;
        emit(state.copyWith(championships: currentSeasonOf(response.right, SeasonCollection.currentSeason)));
      });
      return;
    }
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
    final pending = [
      for (final c in championships)
        if (!_indexed.contains(c.id)) c
    ];
    if (pending.isEmpty) return;
    final response = await useCase(userId, pending);
    if (response.isRight) _indexed.addAll(pending.map((c) => c.id));
  }

  /// Garante o índice da competição [championshipId] antes de gravar
  /// (partida, elenco). Devolve se o índice existe ou foi criado.
  Future<bool> ensureIndexFor(int championshipId) async {
    if (_isAdmin) return true;
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

  /// Campeonato das abas Times/Tabelas do modo (o mesmo nas duas).
  void selectChampionship(int championshipId) => emit(state.copyWith(selectedChampionshipId: championshipId));

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
