import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_round.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/player_season_summary.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';

/// Ida e volta pelo JSON, como no Hive.
Map<String, dynamic> _roundTrip(Map<String, dynamic> json) => jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

void main() {
  tearDown(RegionRegistry.reset);

  test('TeamDTO: todos os campos; região pelo id com o nome atual', () {
    RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta')]);
    const team = TeamDTO(
      id: '1_Lava_Jato',
      name: 'Lava Jato',
      description: 'desc',
      region: 'Floresta',
      imageUrl: 'https://img/x.png',
      ownerId: 'u1',
      primaryColor: '#112233',
      secondaryColor: '#445566',
    );
    final json = _roundTrip(team.toCache());
    expect(json[RegionRegistry.idField], 'fl');
    expect(TeamDTO.fromCache(json), team);

    // Região renomeada depois de salvar: mostra o nome novo.
    RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta Sul')]);
    expect(TeamDTO.fromCache(json).region, 'Floresta Sul');

    // Região sem id conhecido: fica o nome salvo.
    RegionRegistry.reset();
    expect(TeamDTO.fromCache(_roundTrip(team.copyWith(region: 'Velha').toCache())).region, 'Velha');
  });

  test('SeasonsConfigDTO', () {
    const config = SeasonsConfigDTO(current: '2025', seasons: ['2023', '2024', '2025']);
    expect(SeasonsConfigDTO.fromCache(_roundTrip(config.toCache())), config);
  });

  test('UserDTO', () {
    const user = UserDTO(
      id: 'u1',
      name: 'Kaio',
      email: 'k@x.com',
      favoriteTeam: 'Lava Jato',
      favoriteTeamId: '1_Lava_Jato',
      isAdmin: true,
      photoUrl: 'https://img/u.png',
    );
    expect(UserDTO.fromCache(_roundTrip(user.toCache())), user);
    final changed = user.copyWith(teamChangedAt: DateTime(2026, 10, 1, 14, 30));
    expect(UserDTO.fromCache(_roundTrip(changed.toCache())), changed);
  });

  test('RegionRef', () {
    const region = RegionRef(id: 'si', name: 'Santo inacio');
    expect(RegionRef.fromCache(_roundTrip(region.toCache())), region);
  });

  test('HighlightDTO', () {
    const highlight = HighlightDTO(
      id: 'h1',
      title: 'Copa',
      link: 'https://x',
      imageUrl: 'https://img/h.png',
      isVisible: true,
      priority: '002',
    );
    expect(HighlightDTO.fromCache(_roundTrip(highlight.toCache())), highlight);
  });

  test('ChampionshipDTO: todos os campos; região pelo id', () {
    RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta')]);
    const championship = ChampionshipDTO(
      id: 'c1',
      championshipId: 7,
      title: 'Copa',
      description: 'desc',
      imageUrl: 'https://img/c.png',
      firstPrize: 'R\$ 500',
      secondPrize: '2',
      thirdPrize: '3',
      topScorerPrize: 'bola',
      goalkeeperPrize: 'luva',
      rules: 'regras',
      region: 'Floresta',
      season: '2024',
      teams: ['Lava Jato', 'Volta'],
      teamIds: ['1', ''],
      rulesUrl: 'https://pdf',
      rulesFileName: 'regulamento.pdf',
    );
    final json = _roundTrip(championship.toCache());
    expect(ChampionshipDTO.fromCache(json), championship);
    RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta Sul')]);
    expect(ChampionshipDTO.fromCache(json).region, 'Floresta Sul');
  });

  test('PlayerDTO e o ranking (RankingEntry/StatsRanking)', () {
    const player = PlayerDTO(
      id: 'p1',
      name: 'Dudu',
      team: 'Lava Jato',
      teamId: '1',
      imageUrl: 'https://img/p.png',
      goals: 9,
      assists: 4,
      userId: 'u1',
      position: 'atacante',
    );
    expect(PlayerDTO.fromCache(_roundTrip(player.toCache())), player);

    const ranking = StatsRanking(
      entries: [
        RankingEntry(player: player, value: 9, position: 1),
        RankingEntry(player: PlayerDTO(id: 'p2', name: 'Léo', team: 'Volta', goals: 9), value: 9, position: 1),
      ],
      crests: {'Lava Jato': 'https://img/lj.png'},
    );
    expect(StatsRanking.fromCache(_roundTrip(ranking.toCache())), ranking);
  });

  test('PlayerSeasonSummary (histórico do atleta)', () {
    const summary = PlayerSeasonSummary(
      season: '2025',
      player: PlayerDTO(id: 'p1', name: 'Dudu', team: 'Lava Jato', teamId: '1', goals: 3, userId: 'u1'),
      awards: 2,
    );
    expect(PlayerSeasonSummary.fromCache(_roundTrip(summary.toCache())), summary);
  });

  test('bolão: PredictionDTO (pontuado e não), PredictionRankingEntry e PredictionStanding', () {
    const scored = PredictionDTO(uid: 'u1', home: 2, away: 1, name: 'Kaio', points: 10, exact: true, valid: true);
    const open = PredictionDTO(uid: 'u1', home: 0, away: 0);
    expect(PredictionDTO.fromCache(_roundTrip(scored.toCache())), scored);
    expect(PredictionDTO.fromCache(_roundTrip(open.toCache())), open);

    const entry = PredictionRankingEntry(uid: 'u1', name: 'Kaio', points: 22, exact: 1, count: 4);
    expect(PredictionRankingEntry.fromCache(_roundTrip(entry.toCache())), entry);

    const standing = PredictionStanding(entry: entry, position: 64);
    expect(PredictionStanding.fromCache(_roundTrip(standing.toCache())), standing);
    expect(PredictionStanding.fromCache(_roundTrip(const PredictionStanding().toCache())), const PredictionStanding());
  });

  test('NewsDTO: card de gol com todos os campos (data em ms; região pelo id)', () {
    RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta')]);
    final news = NewsDTO(
      id: 'n1',
      date: DateTime(2026, 10, 2, 15, 30, 12, 345),
      title: 'Gol',
      description: 'desc',
      imageUrl: 'https://img/n.png',
      link: 'https://x',
      isVisible: true,
      region: 'Floresta',
      homeTeam: 'Lava Jato',
      awayTeam: 'Volta',
      homeGoals: '2',
      awayGoals: '1',
      tag: NewsDTO.goalTag,
      images: const ['https://img/1.png'],
      scorerId: 'p1',
      scorerName: 'Dudu',
      assistantId: 'p2',
      assistantName: 'Léo',
      season: '2024',
      scoringTeam: 'Lava Jato',
      scoringTeamCrest: 'https://img/lj.png',
      homeTeamId: '1',
      awayTeamId: '2',
      scoringTeamId: '1',
      scoringTeamPrimaryColor: '#C62828',
      scoringTeamSecondaryColor: '#FFFFFF',
    );
    final json = _roundTrip(news.toCache());
    expect(json[RegionRegistry.idField], 'fl');
    expect(NewsDTO.fromCache(json), news);
    // Sem data.
    expect(NewsDTO.fromCache(_roundTrip(const NewsDTO(id: 'x').toCache())), const NewsDTO(id: 'x'));
  });

  test('ScrapedMatchDTO e ScrapedGoalDTO (nulos preservados)', () {
    const match = ScrapedMatchDTO(
      homeTeam: 'Arsenal',
      awayTeam: 'Chelsea',
      league: 'England',
      flagBase64: 'iVBORw0KGgo=',
      kickoff: '16:00',
      statusText: "87'",
      isLive: true,
      featured: true,
      homeGoals: 2,
      awayGoals: 1,
      goals: [
        ScrapedGoalDTO(homeScore: 1, awayScore: 0, scorer: 'Saka', minute: '10'),
        ScrapedGoalDTO(
            homeScore: 1, awayScore: 1, scorer: 'Palmer (pen.)', minute: '50', isHome: false, isPenalty: true),
        ScrapedGoalDTO(homeScore: 2, awayScore: 1, scorer: 'Contra', minute: '80', isHome: true, isOwnGoal: true),
      ],
      detailsUrl: 'https://x/round_details.asp?m=1',
    );
    expect(ScrapedMatchDTO.fromCache(_roundTrip(match.toCache())), match);
    const scheduled = ScrapedMatchDTO(homeTeam: 'A', awayTeam: 'B', postponed: true);
    expect(ScrapedMatchDTO.fromCache(_roundTrip(scheduled.toCache())), scheduled);
  });

  test('VoteDTO', () {
    const vote = VoteDTO(voterId: 'u1', playerName: 'Dudu', team: 'Lava Jato', teamId: '1');
    expect(VoteDTO.fromCache(_roundTrip(vote.toCache())), vote);
  });

  test('MatchDTO: todos os campos (horas em ms, craque, súmula); região pelo id', () {
    RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta')]);
    final match = MatchDTO(
      id: 'm1',
      homeTeam: 'Lava Jato',
      awayTeam: 'Volta',
      homeTeamId: '1',
      awayTeamId: '2',
      date: '18/10',
      time: '16:30',
      originalTime: '16:00',
      venue: 'Campo',
      championshipId: 7,
      round: const MatchRound.group(groupId: 'g1', groupName: 'A'),
      matchday: 3,
      isTest: true,
      region: 'Floresta',
      homeGoals: 2,
      awayGoals: 1,
      isVotingOpen: true,
      votingTitle: 'Craque',
      bestPlayer: 'Dudu',
      electedPlayerId: 'p1',
      electedPlayerName: 'Dudu',
      votesCount: '12',
      registeredAt: DateTime(2026, 10, 1, 9, 30, 1, 250),
      regionIds: const ['fl', 'si'],
      goals: const [
        MatchGoal(id: 'g1', side: MatchSide.home, scorerId: 'p1', scorerName: 'Dudu', minute: 12),
        MatchGoal(
            id: 'g2',
            side: MatchSide.away,
            scorerId: 'p2',
            scorerName: 'Léo',
            assistantId: 'p3',
            assistantName: 'Rafa'),
      ],
      durationMinutes: 60,
      manualStatus: MatchManualStatus.halfTime,
      startedAt: DateTime(2026, 10, 18, 16, 31),
      halfTimeAt: DateTime(2026, 10, 18, 17, 2),
      statusAt: DateTime(2026, 10, 18, 17, 2, 5),
      bookings: const [MatchBooking(id: 'b1', side: MatchSide.away, type: BookingType.red, playerId: 'p2', minute: 20)],
      substitutions: const [
        MatchSubstitution(id: 's1', side: MatchSide.home, outId: 'p1', outName: 'Dudu', inId: 'p4', inName: 'Gui'),
      ],
      lineup: const MatchLineup(home: [LineupEntry(playerId: 'p1', playerName: 'Dudu', number: 9)]),
      referee: 'Juiz',
      notes: 'obs',
    );
    final json = _roundTrip(match.toCache());
    expect(MatchDTO.fromCache(json), match);
    expect(
        MatchDTO.fromCache(_roundTrip(
                const MatchDTO(id: 'k', homeTeam: 'A', awayTeam: 'B', round: MatchRound.knockout(MatchStage.finalMatch))
                    .toCache()))
            .round,
        const MatchRound.knockout(MatchStage.finalMatch));

    // Região renomeada depois de salvar: mostra o nome novo.
    RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta Sul')]);
    expect(MatchDTO.fromCache(json).region, 'Floresta Sul');
  });

  test('AppVersionConfig', () {
    const config =
        AppVersionConfig(minAndroid: 40, recommendedAndroid: 44, minIos: 1, recommendedIos: 2, message: 'Novo');
    expect(AppVersionConfig.fromCache(_roundTrip(config.toCache())), config);
  });

  test('AchievementDTO', () {
    const achievement = AchievementDTO(
      id: 'a1',
      title: 'Torcedor',
      description: 'desc',
      category: AchievementCategory.fan,
      icon: 'heart',
      tier: AchievementTier.gold,
      metric: AchievementMetric.votes,
      goal: 10,
      points: 50,
      packs: 2,
      secret: true,
      active: false,
      order: 3,
    );
    expect(AchievementDTO.fromCache(_roundTrip(achievement.toCache())), achievement);
  });
}
