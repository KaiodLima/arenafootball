import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/data/parsers/soccer_stats_parser.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';

/// Baixa as páginas do soccerstats.com e extrai as partidas e os gols.
class GlobalResultsDataSource {
  final http.Client _client;
  final SoccerStatsParser _parser;

  GlobalResultsDataSource(this._client, this._parser);

  static const String _logName = 'GlobalResultsDataSource';
  static const String _userAgent =
      'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36';

  Future<Either<Failure, List<ScrapedMatchDTO>>> getMatches(ResultsDay day) =>
      _fetch(day.url, 'Não foi possível carregar os resultados.', (html) => _parser.parse(html, day));

  /// Cronologia dos gols de um jogo encerrado (página de análise).
  Future<Either<Failure, List<ScrapedGoalDTO>>> getMatchGoals(String url) =>
      _fetch(url, 'Não foi possível carregar os gols.', _parser.parseGoals);

  Future<Either<Failure, T>> _fetch<T>(String url, String fallback, T Function(String html) parse) async {
    try {
      // O site responde 403 para o User-Agent padrão do Dart (bloqueio de bot).
      // O cookie `tz` (minutos em relação ao UTC) faz o site mandar os
      // horários no fuso do aparelho; sem ele, vêm em UTC.
      final response = await _client.get(Uri.parse(url), headers: {
        'User-Agent': _userAgent,
        'Cookie': 'tz=${DateTime.now().timeZoneOffset.inMinutes}',
      });
      if (response.statusCode != 200) {
        AppLogger.e('GET $url status=${response.statusCode}', name: _logName);
        return Left(ErrorWithMessage(fallback, code: '${response.statusCode}'));
      }
      return Right(parse(response.body));
    } catch (e) {
      AppLogger.e('GET $url', name: _logName, error: e);
      return Left(ErrorWithMessage(fallback));
    }
  }
}
