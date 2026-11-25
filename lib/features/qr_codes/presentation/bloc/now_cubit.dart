import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_cache_first_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/open_events_cache_usecases.dart';
import 'package:arena_soccer/features/qr_codes/domain/now_feed.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// "Acontecendo agora" da região do QR fixo: as partidas e os eventos ativos
/// (as mesmas leituras da central de QR codes) e os times (escudos/cores).
class NowState extends Equatable {
  final String regionId;

  /// Nome atual da região (pelo id); vazio = região que não existe mais.
  final String region;
  final bool loading;
  final NowFeed feed;
  final TeamDirectory? teamDirectory;

  const NowState({
    this.regionId = '',
    this.region = '',
    this.loading = true,
    this.feed = const NowFeed(),
    this.teamDirectory,
  });

  TeamDirectory get teams => teamDirectory ?? TeamDirectory.empty;

  @override
  List<Object?> get props => [regionId, region, loading, feed, teamDirectory];
}

class NowCubit extends Cubit<NowState> {
  final GetRegionMatchesCacheFirstUseCase getRegionMatchesUseCase;

  /// Eventos de votação abertos (cache de 3 min).
  final GetOpenEventsCacheFirstUseCase getOpenEventsUseCase;
  final GetTeamsCacheFirstUseCase? getTeamsCacheFirstUseCase;
  final DateTime Function() now;

  NowCubit(
    this.getRegionMatchesUseCase,
    this.getOpenEventsUseCase, [
    this.getTeamsCacheFirstUseCase,
    DateTime Function()? now,
  ])  : now = now ?? DateTime.now,
        super(const NowState());

  Future<void> load({required String regionId, required String season}) async {
    final region = RegionRegistry.nameOf(regionId);
    emit(NowState(regionId: regionId, region: region));
    if (region.isEmpty) {
      emit(NowState(regionId: regionId, loading: false));
      return;
    }
    // As três leituras correm juntas (cada uma já começou antes do await).
    final matchesFuture = getRegionMatchesUseCase.latest(region: region, season: season);
    final newsFuture = getOpenEventsUseCase.latest();
    final teamsFuture = getTeamsCacheFirstUseCase?.call(region: region, season: season).first;
    final matches = (await matchesFuture).fold((_) => const <MatchDTO>[], (m) => m);
    final news = (await newsFuture).fold((_) => const <NewsDTO>[], (n) => n);
    final teams =
        teamsFuture == null ? const <TeamDTO>[] : (await teamsFuture).fold((_) => const <TeamDTO>[], (t) => t);
    if (isClosed || state.regionId != regionId) return;
    emit(NowState(
      regionId: regionId,
      region: region,
      loading: false,
      feed: NowFeed.of(matches: matches, news: news, region: region, now: now()),
      teamDirectory: TeamDirectory(teams),
    ));
  }
}
