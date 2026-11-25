import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_cache_first_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/open_events_cache_usecases.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_hub.dart';
import 'package:arena_soccer/features/qr_codes/domain/qr_target.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Central "QR codes" do admin: o que está ativo agora na região.
class QrCodesState extends Equatable {
  final String region;
  final bool loading;

  /// Eventos de votação abertos.
  final List<QrTarget> events;

  /// Votações do craque abertas.
  final List<QrTarget> votes;

  /// Próximas partidas (palpite), até 6.
  final List<QrTarget> matches;

  const QrCodesState({
    this.region = '',
    this.loading = true,
    this.events = const [],
    this.votes = const [],
    this.matches = const [],
  });

  @override
  List<Object?> get props => [region, loading, events, votes, matches];
}

class QrCodesCubit extends Cubit<QrCodesState> {
  final GetRegionMatchesCacheFirstUseCase getRegionMatchesUseCase;

  /// Eventos de votação abertos (cache de 3 min).
  final GetOpenEventsCacheFirstUseCase getOpenEventsUseCase;
  final GetTeamsCacheFirstUseCase? getTeamsCacheFirstUseCase;
  final DateTime Function() now;

  QrCodesCubit(
    this.getRegionMatchesUseCase,
    this.getOpenEventsUseCase, [
    this.getTeamsCacheFirstUseCase,
    DateTime Function()? now,
  ])  : now = now ?? DateTime.now,
        super(const QrCodesState());

  /// Time da partida com escudo e cores (do cache); sem achar, só o nome.
  static ArtTeam artTeam(TeamDirectory teams, {required String id, required String name}) {
    final TeamDTO? team = teams.resolve(id: id, name: name);
    return ArtTeam(
      name: name,
      crestUrl: team?.imageUrl ?? '',
      primaryColor: team?.primaryColor ?? '',
      secondaryColor: team?.secondaryColor ?? '',
    );
  }

  static QrTarget targetOf(MatchDTO match, String season, TeamDirectory teams, {bool? voting}) => QrTarget.forMatch(
        match,
        season: season,
        voting: voting,
        home: artTeam(teams, id: match.homeTeamId, name: match.homeTeam),
        away: artTeam(teams, id: match.awayTeamId, name: match.awayTeam),
      );

  Future<void> load({required String region, required String season}) async {
    emit(QrCodesState(region: region));
    final clock = now();
    // As três leituras correm juntas (cada uma já começou antes do await).
    final matchesFuture = getRegionMatchesUseCase.latest(region: region, season: season);
    final newsFuture = getOpenEventsUseCase.latest();
    final teamsFuture = getTeamsCacheFirstUseCase?.call(region: region, season: season).first;
    final matches = (await matchesFuture).fold((_) => const <MatchDTO>[], (m) => m);
    final news = (await newsFuture).fold((_) => const <NewsDTO>[], (n) => n);
    final teamList =
        teamsFuture == null ? const <TeamDTO>[] : (await teamsFuture).fold((_) => const <TeamDTO>[], (t) => t);
    if (isClosed || state.region != region) return;
    final teams = TeamDirectory(teamList);

    final votes = PredictionHub.byKickoff(matches.where((m) => m.isVotingOpen), clock, descending: true)
        .map((m) => targetOf(m, season, teams, voting: true))
        .toList();
    final upcoming = PredictionHub.byKickoff(
      matches.where((m) => MatchCardStatus.of(m, clock).upcoming && PredictionHub.kickoffOf(m, clock) != null),
      clock,
    ).take(PredictionHub.upcomingLimit).map((m) => targetOf(m, season, teams, voting: false)).toList();
    final events = news
        .where((n) => n.isEvent && n.isVisible && n.region == region && (n.event?.isOpenAt(clock) ?? false))
        .map(QrTarget.event)
        .toList();

    emit(QrCodesState(region: region, loading: false, events: events, votes: votes, matches: upcoming));
  }
}
