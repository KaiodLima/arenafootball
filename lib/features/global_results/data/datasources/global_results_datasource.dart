import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_row_dto.dart';
import 'package:arena_soccer/features/global_results/data/parsers/soccer_stats_parser.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';

/// Baixa a página do soccerstats.com e extrai as linhas de jogos.
class GlobalResultsDataSource {
  final http.Client _client;
  final SoccerStatsParser _parser;

  GlobalResultsDataSource(this._client, this._parser);

  static const String _userAgent =
      'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36';

  Future<Either<Failure, List<ScrapedRowDTO>>> getRows(ResultsDay day) async {
    const fallback = 'Não foi possível carregar os resultados.';
    try {
      // O site responde 403 para o User-Agent padrão do Dart (bloqueio de bot).
      final response = await _client.get(Uri.parse(day.url), headers: const {'User-Agent': _userAgent});
      if (response.statusCode != 200) {
        AppLogger.e('getRows day=${day.name} status=${response.statusCode}', name: 'GlobalResultsDataSource');
        return Left(ErrorWithMessage(fallback, code: '${response.statusCode}'));
      }
      return Right(_parser.parse(response.body, day));
    } catch (e) {
      AppLogger.e('getRows day=${day.name}', name: 'GlobalResultsDataSource', error: e);
      return Left(ErrorWithMessage(fallback));
    }
  }
}
