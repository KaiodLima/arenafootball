import 'dart:convert';
import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';

/// Resultados pelo mundo de um dia, já com o status interpretado.
///
/// Hoje: a lista completa do dia é a base (horário e placar final); a seção
/// de destaque, que tem o minuto ao vivo, o placar parcial e os gols, é
/// sobreposta pela chave casa+fora. Ontem: placar final ou adiado. Amanhã:
/// só o horário.
class GetGlobalResultsUseCase {
  final IGlobalResultsRepository _repository;

  GetGlobalResultsUseCase(this._repository);

  static final RegExp _minute = RegExp(r"^(\d+(?:\+\d+)?)'$");

  Future<Either<Failure, List<GlobalMatch>>> call(ResultsDay day) async {
    final response = await scrape(day);
    return response.map((matches) => toMatches(matches, day));
  }

  /// Partidas cruas do site (o que vai para o cache local).
  Future<Either<Failure, List<ScrapedMatchDTO>>> scrape(ResultsDay day) => _repository.getMatches(day);

  /// Público para teste.
  static List<GlobalMatch> toMatches(List<ScrapedMatchDTO> scraped, ResultsDay day) {
    final flags = <String, Uint8List?>{};
    Uint8List? flagOf(ScrapedMatchDTO dto) => flags.putIfAbsent(dto.flagBase64, () {
          if (dto.flagBase64.isEmpty) return null;
          try {
            return base64Decode(dto.flagBase64);
          } catch (_) {
            return null;
          }
        });

    if (day != ResultsDay.today) {
      return [for (final dto in scraped) _fromRow(dto, flagOf(dto))];
    }

    String key(ScrapedMatchDTO dto) => '${dto.homeTeam}|${dto.awayTeam}'.toLowerCase();
    final featured = {for (final dto in scraped.where((d) => d.featured)) key(dto): dto};
    final used = <String>{};
    final matches = <GlobalMatch>[];
    for (final dto in scraped.where((d) => !d.featured)) {
      final live = featured[key(dto)];
      if (live != null) used.add(key(dto));
      matches.add(live == null
          ? _fromRow(dto, flagOf(dto))
          : _fromFeatured(live, flagOf(dto), kickoff: dto.kickoff, detailsUrl: dto.detailsUrl));
    }
    for (final entry in featured.entries) {
      if (!used.contains(entry.key)) matches.add(_fromFeatured(entry.value, flagOf(entry.value)));
    }
    return matches;
  }

  /// Linha sem status explícito: com placar é jogo encerrado; sem, agendado.
  static GlobalMatch _fromRow(ScrapedMatchDTO dto, Uint8List? flag) {
    final hasScore = dto.homeGoals != null && dto.awayGoals != null;
    return GlobalMatch(
      league: dto.league,
      flag: flag,
      kickoff: dto.kickoff,
      status: dto.postponed
          ? MatchStatus.postponed
          : hasScore
              ? MatchStatus.finished
              : MatchStatus.scheduled,
      homeTeam: dto.homeTeam,
      awayTeam: dto.awayTeam,
      homeGoals: hasScore ? dto.homeGoals : null,
      awayGoals: hasScore ? dto.awayGoals : null,
      detailsUrl: dto.detailsUrl,
    );
  }

  /// Seção de destaque: "FT" encerrado, "HT" intervalo, "87'" (ou "'" em
  /// vermelho) ao vivo; "'" cinza ainda não começou.
  static GlobalMatch _fromFeatured(ScrapedMatchDTO dto, Uint8List? flag, {String? kickoff, String? detailsUrl}) {
    final text = dto.statusText.toUpperCase();
    final minute = _minute.firstMatch(dto.statusText)?.group(1) ?? '';
    final MatchStatus status;
    if (text == 'FT') {
      status = MatchStatus.finished;
    } else if (text == 'HT') {
      status = MatchStatus.halfTime;
    } else if (minute.isNotEmpty || dto.isLive) {
      status = MatchStatus.live;
    } else if (dto.homeGoals != null && !_isKickoff(dto.statusText)) {
      status = MatchStatus.finished;
    } else {
      status = MatchStatus.scheduled;
    }
    final started = status != MatchStatus.scheduled;

    return GlobalMatch(
      league: dto.league,
      flag: flag,
      kickoff: (kickoff ?? '').isNotEmpty ? kickoff! : dto.kickoff,
      status: status,
      minute: minute,
      homeTeam: dto.homeTeam,
      awayTeam: dto.awayTeam,
      homeGoals: started ? dto.homeGoals : null,
      awayGoals: started ? dto.awayGoals : null,
      goals: goalsOf(dto.goals),
      detailsUrl: (detailsUrl ?? '').isNotEmpty ? detailsUrl! : dto.detailsUrl,
    );
  }

  static bool _isKickoff(String text) => RegExp(r'^\d{1,2}:\d{2}$').hasMatch(text);

  /// Converte os gols do site. Quando o lado não vem informado (destaque),
  /// sai da mudança do placar parcial ("0-1" depois de "0-0" é gol do
  /// visitante). "(pen.)" no nome vira flag.
  static List<GoalEvent> goalsOf(List<ScrapedGoalDTO> scraped) {
    var home = 0;
    final goals = <GoalEvent>[];
    for (final goal in scraped) {
      final isHome = goal.isHome ?? goal.homeScore > home;
      home = goal.homeScore;
      final isPenalty = goal.isPenalty || goal.scorer.contains('(pen.)');
      goals.add(GoalEvent(
        minute: goal.minute,
        scorer: goal.scorer.replaceAll('(pen.)', '').trim(),
        isHome: isHome,
        isPenalty: isPenalty,
        isOwnGoal: goal.isOwnGoal,
      ));
    }
    return goals;
  }
}
