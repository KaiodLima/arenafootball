import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_match_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/pending_news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/pending_news_usecase.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_highlights_cache_first_usecase.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_state.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/watch_pending_partner_requests_count_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_pending_player_requests_count_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/watch_pending_team_requests_count_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_cache_first_usecase.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetTeamByNameCacheFirstUseCase getTeamByNameCacheFirstUseCase;
  final WatchPendingPlayerRequestsCountUseCase watchPendingPlayerRequestsCountUseCase;
  final WatchPendingTeamRequestsCountUseCase watchPendingTeamRequestsCountUseCase;
  final GetHighlightsCacheFirstUseCase getHighlightsCacheFirstUseCase;
  final WatchPendingPartnerRequestsCountUseCase watchPendingPartnerRequestsCountUseCase;
  final PendingNewsUseCase pendingNewsUseCase;
  final WatchMatchUseCase watchMatchUseCase;
  StreamSubscription<Either<Failure, int>>? _pendingRequests;
  StreamSubscription<Either<Failure, int>>? _pendingTeamRequests;
  StreamSubscription<Either<Failure, int>>? _pendingPartnerRequests;
  StreamSubscription<Either<Failure, List<PendingNewsDTO>>>? _pendingPartnerNews;

  HomeCubit(
    this.getTeamByNameCacheFirstUseCase,
    this.watchPendingPlayerRequestsCountUseCase,
    this.watchPendingTeamRequestsCountUseCase,
    this.getHighlightsCacheFirstUseCase,
    this.watchPendingPartnerRequestsCountUseCase,
    this.pendingNewsUseCase,
    this.watchMatchUseCase,
  ) : super(const HomeState());

  void selectTab(HomeTab tab) => emit(state.copyWith(tab: tab));

  /// Escudo do time do coração (cache local primeiro, ver `cacheFirst`).
  Future<void> loadFavoriteTeam(String teamName, {String teamId = '', bool force = false}) async {
    if (teamName.isEmpty && teamId.isEmpty) return;
    await for (final response in getTeamByNameCacheFirstUseCase(teamName, id: teamId, force: force)) {
      if (isClosed) return;
      response.fold(
        // O escudo é só decorativo; sem ele o drawer mostra o avatar vazio.
        (_) => null,
        (team) {
          if (team != null && team.imageUrl.isNotEmpty) emit(state.copyWith(favoriteTeamImage: team.imageUrl));
        },
      );
    }
  }

  /// Partida de um push (gol, votação, jogo do dia); nula se não existe ou
  /// a leitura falhar (o push cai na aba).
  Future<MatchDTO?> findMatch(String id, {String? season}) async {
    final response = await watchMatchUseCase(matchId: id, season: season).first;
    return response.fold((_) => null, (match) => match);
  }

  /// Destaque de um deep link (`/destaque/<id>`); nulo se não existe mais.
  /// Procura no cache primeiro; não achou (destaque novo), busca de novo.
  Future<Either<Failure, HighlightDTO?>> findHighlight(String id) async {
    final cached = _find(await getHighlightsCacheFirstUseCase().last, id);
    if (cached.isLeft || cached.right != null) return cached;
    return _find(await getHighlightsCacheFirstUseCase(force: true).last, id);
  }

  Either<Failure, HighlightDTO?> _find(Either<Failure, List<HighlightDTO>> response, String id) =>
      response.map((highlights) {
        for (final highlight in highlights) {
          if (highlight.id == id) return highlight;
        }
        return null;
      });

  /// Contador do menu do admin. Falha só deixa o contador como está.
  void watchPendingPlayerRequests() {
    _pendingRequests?.cancel();
    _pendingRequests = watchPendingPlayerRequestsCountUseCase().listen((response) {
      if (response.isRight) emit(state.copyWith(pendingPlayerRequests: response.right));
    });
    _pendingTeamRequests?.cancel();
    _pendingTeamRequests = watchPendingTeamRequestsCountUseCase().listen((response) {
      if (response.isRight) emit(state.copyWith(pendingTeamRequests: response.right));
    });
    _pendingPartnerRequests?.cancel();
    _pendingPartnerRequests = watchPendingPartnerRequestsCountUseCase().listen((response) {
      if (response.isRight) emit(state.copyWith(pendingPartnerRequests: response.right));
    });
    _pendingPartnerNews?.cancel();
    _pendingPartnerNews = pendingNewsUseCase.watchPending().listen((response) {
      if (response.isRight) emit(state.copyWith(pendingPartnerNews: response.right.length));
    });
  }

  @override
  Future<void> close() {
    _pendingRequests?.cancel();
    _pendingTeamRequests?.cancel();
    _pendingPartnerRequests?.cancel();
    _pendingPartnerNews?.cancel();
    return super.close();
  }
}
