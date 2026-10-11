import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';

/// Extrai as partidas do HTML do soccerstats.com. A página não tem classes
/// estáveis para tudo; a estrutura usada (conferida em out/2026):
///
/// - Hoje (página inicial): linhas `tr.parent` com a liga seguidas de
///   `tr.child` com os jogos (≥4 `td`: status/horário, casa, placar, fora).
///   Há duas seções: a de destaque (o 1º `td` tem `<a href='#mNN'>`), com
///   minuto ao vivo em vermelho, FT/HT e os autores dos gols em
///   `p.ScorersList`; e a lista completa do dia, com horário e o placar final
///   (ou "vs").
/// - Ontem/Amanhã: `tr.parent` com a liga e cada jogo em `tr.team1row` +
///   `tr.team2row`; o 2º `td` traz os gols (ontem), o horário (amanhã) ou
///   "pp." (adiado).
///
/// As linhas são percorridas na ordem do documento, guardando a última liga
/// vista. Se o site mudar, é aqui que quebra.
class SoccerStatsParser {
  static const String _liveColor = '#c70039';
  static final RegExp _score = RegExp(r'(\d+)\s*:\s*(\d+)');
  static final RegExp _kickoff = RegExp(r'^\d{1,2}:\d{2}$');
  static final RegExp _goal = RegExp(r"^(\d+)-(\d+)\s+(.+?)\s*\((\d+(?:\+\d+)?)'\)$");
  static final RegExp _timelineScore = RegExp(r'^(\d+):(\d+)$');
  static final RegExp _timelineMinute = RegExp(r'\((\d+(?:\+\d+)?)\)\s*$');
  static const String _baseUrl = 'https://www.soccerstats.com/';

  List<ScrapedMatchDTO> parse(String html, ResultsDay day) {
    final soup = BeautifulSoup(html);
    return day == ResultsDay.today ? _parseToday(soup) : _parseByTeamRows(soup);
  }

  List<ScrapedMatchDTO> _parseToday(BeautifulSoup soup) {
    final matches = <ScrapedMatchDTO>[];
    var league = '';
    var flag = '';
    for (final row in soup.findAll('tr')) {
      if (row.classes.contains('parent')) {
        league = _leagueName(row);
        flag = _flag(row);
        continue;
      }
      if (!row.classes.contains('child')) continue;
      final cells = row.findAll('td');
      if (cells.length < 4) continue;

      final status = cells[0];
      final featured = status.find('a')?.attributes['href']?.startsWith('#m') ?? false;
      final statusText = _clean(status.text);
      final scoreCell = cells[2];
      final scorers = scoreCell.find('p', class_: 'ScorersList');
      final scoreText = scorers == null ? scoreCell.text : scoreCell.text.replaceFirst(scorers.text, '');
      final score = _score.firstMatch(scoreText);

      matches.add(ScrapedMatchDTO(
        league: league,
        flagBase64: flag,
        // Na lista completa o 1º `td` é o horário; no destaque, o status.
        kickoff: _kickoff.hasMatch(statusText) ? statusText : '',
        statusText: featured ? statusText : '',
        isLive: featured && (status.find('font')?.attributes['color']?.toLowerCase() == _liveColor),
        featured: featured,
        homeTeam: _clean(cells[1].text),
        awayTeam: _clean(cells[3].text),
        homeGoals: score == null ? null : int.parse(score.group(1)!),
        awayGoals: score == null ? null : int.parse(score.group(2)!),
        goals: scorers == null ? const [] : _goals(scorers),
        detailsUrl: _detailsUrl(row),
      ));
    }
    return matches;
  }

  List<ScrapedMatchDTO> _parseByTeamRows(BeautifulSoup soup) {
    final matches = <ScrapedMatchDTO>[];
    var league = '';
    var flag = '';
    Bs4Element? home;
    for (final row in soup.findAll('tr')) {
      if (row.classes.contains('parent')) {
        league = _leagueName(row);
        flag = _flag(row);
      } else if (row.classes.contains('team1row')) {
        home = row;
      } else if (row.classes.contains('team2row') && home != null) {
        final home0 = home;
        final homeCells = home.findAll('td');
        final awayCells = row.findAll('td');
        home = null;
        if (homeCells.length < 2 || awayCells.isEmpty) continue;

        final info = _clean(homeCells[1].text);
        final postponed = info.toLowerCase().startsWith('pp');
        final homeGoals = int.tryParse(info);
        matches.add(ScrapedMatchDTO(
          league: league,
          flagBase64: flag,
          kickoff: _kickoff.hasMatch(info) ? info : '',
          homeTeam: _clean(homeCells[0].text),
          awayTeam: _clean(awayCells[0].text),
          homeGoals: homeGoals,
          // O placar do visitante só existe quando o da casa existe (o horário
          // e o "pp." ocupam as duas linhas com rowspan).
          awayGoals: homeGoals == null || awayCells.length < 2 ? null : int.tryParse(_clean(awayCells[1].text)),
          postponed: postponed,
          detailsUrl: _detailsUrl(home0),
        ));
      }
    }
    return matches;
  }

  /// Cronologia dos gols da página de análise do jogo (`round_details.asp`):
  /// uma linha por gol com 3 `td` — autor da casa | placar parcial | autor do
  /// visitante. O lado preenchido diz de quem é o gol; "(o.g.)" é gol contra
  /// (fica do lado do time beneficiado) e "(pen.)", pênalti.
  List<ScrapedGoalDTO> parseGoals(String html) {
    final goals = <ScrapedGoalDTO>[];
    for (final row in BeautifulSoup(html).findAll('tr')) {
      final cells = row.children.where((c) => c.name == 'td').toList();
      if (cells.length != 3) continue;
      final score = _timelineScore.firstMatch(_clean(cells[1].text));
      if (score == null) continue;
      final home = _clean(cells[0].text);
      final away = _clean(cells[2].text);
      if (home.isEmpty == away.isEmpty) continue;

      final text = home.isNotEmpty ? home : away;
      final minute = _timelineMinute.firstMatch(text)?.group(1) ?? '';
      final isOwnGoal = text.contains('(o.g.)');
      final isPenalty = text.contains('(pen.)');
      final scorer = text
          .replaceAll(_timelineMinute, '')
          .replaceAll('(o.g.)', '')
          .replaceAll('(pen.)', '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      goals.add(ScrapedGoalDTO(
        homeScore: int.parse(score.group(1)!),
        awayScore: int.parse(score.group(2)!),
        scorer: scorer,
        minute: minute,
        isHome: home.isNotEmpty,
        isOwnGoal: isOwnGoal,
        isPenalty: isPenalty,
      ));
    }
    return goals;
  }

  /// Link da página de análise do jogo (só existe para jogos encerrados).
  String _detailsUrl(Bs4Element row) {
    for (final link in row.findAll('a')) {
      final href = link.attributes['href'] ?? '';
      if (href.contains('round_details.asp')) return href.startsWith('http') ? href : '$_baseUrl$href';
    }
    return '';
  }

  /// "England - Premier League" (sem o link "stats" que algumas páginas
  /// colocam na mesma linha).
  String _leagueName(Bs4Element row) {
    final text = _clean(row.text);
    final index = text.lastIndexOf(' stats');
    return (index >= 0 ? text.substring(0, index) : text).trim();
  }

  String _flag(Bs4Element row) {
    final src = row.find('img')?.attributes['src'] ?? '';
    final comma = src.indexOf('base64,');
    return src.startsWith('data:image') && comma >= 0 ? src.substring(comma + 'base64,'.length) : '';
  }

  /// Autores dos gols, um por `<br>`: "<b>0-1</b>&nbsp;&nbsp;Erling Haaland  (65')".
  /// O "---" separa os tempos e é ignorado.
  List<ScrapedGoalDTO> _goals(Bs4Element list) {
    final goals = <ScrapedGoalDTO>[];
    for (final line in list.innerHtml.split(RegExp(r'<br\s*/?>', caseSensitive: false))) {
      final text = _clean(line.replaceAll(RegExp(r'<[^>]+>'), ' '));
      final match = _goal.firstMatch(text);
      if (match == null) continue;
      goals.add(ScrapedGoalDTO(
        homeScore: int.parse(match.group(1)!),
        awayScore: int.parse(match.group(2)!),
        scorer: match.group(3)!.trim(),
        minute: match.group(4)!,
      ));
    }
    return goals;
  }

  /// Junta espaços (inclui `&nbsp;`) e apara.
  static String _clean(String text) =>
      text.replaceAll('&nbsp;', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
