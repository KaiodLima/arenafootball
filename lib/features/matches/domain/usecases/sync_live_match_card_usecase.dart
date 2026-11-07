import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/live_match_card.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Atualiza o card "ao vivo" da partida no feed a partir de [match] (o estado
/// salvo) comparado com [before] (o de antes): com lance novo, o card destaca
/// esse lance e sobe ao topo; sem, só acompanha (lance apagado/editado). Cada
/// vermelho novo grava também o card oculto que dispara o push "Expulso!".
class SyncLiveMatchCardUseCase {
  final INewsRepository _news;
  final CreateNewsUseCase _createNews;
  final GetTeamsCacheFirstUseCase _getTeams;

  SyncLiveMatchCardUseCase(this._news, this._createNews, this._getTeams);

  Future<Either<Failure, void>> call({required MatchDTO match, MatchDTO? before, String? season}) async {
    final last = LiveMatchCard.newestEvent(before, match);
    final teams = await _getTeams(season: season).last;
    final byId = teams.fold((_) => const <String, TeamDTO>{}, (list) => {for (final t in list) t.id: t});
    final card = LiveMatchCard.build(match, byId, season: season ?? '', last: last);
    final synced = await _news.syncLiveCard(card, bump: last != null);
    if (synced.isLeft) return synced;
    for (final booking in LiveMatchCard.newReds(before, match)) {
      final response = await _createNews(news: LiveMatchCard.redCard(match, booking, byId, season: season ?? ''));
      if (response.isLeft) return Left(response.left);
    }
    return const Right(null);
  }
}
