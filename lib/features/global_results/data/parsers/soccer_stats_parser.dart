import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_row_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';

/// Extrai as partidas do HTML do soccerstats.com. A estrutura da página não
/// tem classes estáveis: as linhas de liga são reconhecidas pelo texto
/// "stats" e os jogos por posição. Se o site mudar, é aqui que quebra.
class SoccerStatsParser {
  List<ScrapedRowDTO> parse(String html, ResultsDay day) {
    final soup = BeautifulSoup(html);
    switch (day) {
      case ResultsDay.today:
        return _parseToday(soup);
      case ResultsDay.yesterday:
        return _parseYesterday(soup);
      case ResultsDay.tomorrow:
        return _parseTomorrow(soup);
    }
  }

  List<ScrapedRowDTO> _parseToday(BeautifulSoup soup) {
    final rows = <ScrapedRowDTO>[];
    for (final item in soup.findAll('tr', class_: 'child')) {
      if (item.children.length < 4) continue;
      rows.add(
        ScrapedRowDTO(
          league: _leagueAbove(item),
          time: item.children[0].text,
          home: item.children[1].text,
          // O placar fica dentro de um <a>, e os autores dos gols num <p>.
          score: item.children[2].a?.children.firstOrNull?.text ?? 'x',
          away: item.children[3].text,
          scorers: item.children[2].p?.text.trim() ?? '',
        ),
      );
    }
    return rows;
  }

  /// Sobe pelos irmãos anteriores até achar a linha da liga (contém "stats"
  /// e não tem horário).
  String _leagueAbove(Bs4Element item) {
    Bs4Element? current = item.previousSibling;
    while (current != null) {
      final text = current.text;
      if (text.contains('stats') && !text.contains(':')) return text.split('stats').first;
      current = current.previousSibling;
    }
    return '';
  }

  List<ScrapedRowDTO> _parseYesterday(BeautifulSoup soup) {
    // Achata, em ordem, a linha de cada liga seguida das linhas dos seus jogos.
    final texts = <String?>[];
    for (final league in soup.findAll('tr', class_: 'parent')) {
      texts.add(league.text);
      var element = league.nextSibling;
      if (element != null && element.text.contains('Scope')) element = element.nextSibling;
      texts.add(element?.text);

      while (element != null && !element.text.contains('stats')) {
        element = element.nextSibling;
        texts.add(element?.text);
        if (element == null || element.text.contains('stats')) break;
        element = element.nextSibling;
        texts.add(element?.text);
      }
    }

    final rows = <ScrapedRowDTO>[];
    var league = '';
    for (var i = 0; i < texts.length; i++) {
      final text = texts[i];
      if (text == null || text.isEmpty) continue;
      if (text.contains('stats')) {
        league = text.split('stats').first;
        continue;
      }
      // Cada linha é "<time><gols>"; o último caractere é o placar do time.
      final teamAndGoals = text.contains('analysis') ? text.split('analysis').first : text;
      if (teamAndGoals.isEmpty) continue;
      rows.add(
        ScrapedRowDTO(
          home: teamAndGoals.substring(0, teamAndGoals.length - 1),
          score: teamAndGoals[teamAndGoals.length - 1],
          league: league,
        ),
      );
    }
    return rows;
  }

  List<ScrapedRowDTO> _parseTomorrow(BeautifulSoup soup) {
    return soup
        .findAll('td', class_: 'steam')
        .map((item) => ScrapedRowDTO(home: item.text, time: item.nextElement?.text ?? ''))
        .toList();
  }
}
