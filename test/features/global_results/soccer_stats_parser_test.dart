import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/data/parsers/soccer_stats_parser.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_global_results_usecase.dart';

// Trechos reduzidos do HTML real do soccerstats.com (out/2026).
const _todayHtml = '''
<table id='btable'>
<tr class='parent'><td colspan='4'>&nbsp;&nbsp;<a class='vsmall' href='latest.asp?league=england'>&nbsp;<img src='data:image/png;base64,iVBORw0KGgo=' alt='ENGLAND'>England - Premier League</a></td><td></td></tr>
<tr class='child'>
<td><a href='#m95' title='MN 95'></a><font color='#C70039'>87'</font></td>
<td>Liverpool</td>
<td><a href='#m95' class='tooltip4'><font style='color:#C70039;'>0:3</font><span><p class='ScorersList'>
---<br>
&nbsp;&nbsp;&nbsp;<b>0-1</b>&nbsp;&nbsp;
Erling Haaland  (65')
<br>
&nbsp;&nbsp;&nbsp;<b>1-1</b>&nbsp;&nbsp;
Mohamed Salah (pen.) (70')
<br>
&nbsp;&nbsp;&nbsp;<b>1-2</b>&nbsp;&nbsp;
Jérémy Doku  (90+2')
</p></span></a></td>
<td>Manchester City</td>
<td><a class='vsmall' href='pmatch.asp'>stats</a></td>
</tr>
<tr class='child'>
<td><a href='#m110'></a><font color='#C70039'>'</font></td>
<td>Jong Gent</td><td><font>0:0</font></td><td>Seraing</td><td></td>
</tr>
<tr class='child'>
<td><a href='#m123'></a><font color='#666666'>'</font></td>
<td>Dusseldorf</td><td><b>&nbsp; - &nbsp;</b></td><td>Verl</td><td></td>
</tr>
<tr class='child'>
<td><a href='#m98'></a><font color='#666666'>FT</font></td>
<td>Rennes</td><td><font>4:1</font></td><td>Auxerre</td><td></td>
</tr>
</table>
<h2>Today</h2>
<table id='btable'>
<tr class='parent'><td colspan='7'>&nbsp;<a class='vsmall' href='latest.asp?league=germany3'>&nbsp;<img src='data:image/png;base64,AAAA' alt='GERMANY3'>Germany - <font color='#222222'>3. Liga</font></a><td colspan='1'></td></td></tr>
<tr class='child'><td align='center'><font color='#222222'>12:30</font></td><td align='right'>
FC Ingolstadt
</td><td><b>2:4</b></td><td colspan='4'>
Wehen Wiesbaden
</td><td><a class='vsmall' href='round_details.asp?league=germany3&mrevid=m77&st1=11&st2=7' title='Result analysis'><img src='img/own/sshplogo.png'></a></td></tr>
<tr class='child'><td align='center'><font color='green'>18:30</font></td><td align='right'>Dusseldorf</td><td> vs </td><td colspan='4'>Verl</td><td></td></tr>
<tr class='child'><td align='center'><font color='green'>16:30</font></td><td align='right'>Liverpool</td><td> vs </td><td colspan='4'>Manchester City</td><td></td></tr>
</table>
''';

const _yesterdayHtml = '''
<table>
<tr class='parent'><td colspan='20'>&nbsp;<img src='data:image/png;base64,BBBB' alt='SPAIN'>&nbsp;&nbsp;<font size='2'>Spain - LaLiga</font>&nbsp;&nbsp;&nbsp;<a class='vsmall' href='latest.asp?league=spain'>stats</a></td></tr>
<tr class='child'><td></td><td></td><td class='sgray'>Scope</td></tr>
<tr class='team1row'><td class='steam'>Rayo Vallecano</td><td rowspan='2'>pp.</td><td></td></tr>
<tr class='team2row'><td class='steam'>Athletic Bilbao</td><td></td></tr>
<tr height='14'><td colspan='9'></td></tr>
<tr class='team1row'><td class='steam'>Alaves</td><td><b>1</b></td><td></td><td rowspan='2'><a class='vsmall' href='round_details.asp?league=spain&mrevid=m80&st1=1&st2=13'>analysis</a></td></tr>
<tr class='team2row'><td class='steam'>Atletico Madrid</td><td><b>2</b></td><td></td></tr>
</table>
''';

// Cronologia da página de análise (FC Ingolstadt 2x4 Wehen Wiesbaden).
const _goalsHtml = '''
<table>
<tr><td height='8' colspan='3' align='center'></td></tr>
<tr><td align='right'></td><td align='center'> <font><b>0:1</b></font> </td><td align='left'>
Florian Hübner <font color='green'>(59)</font>
</td></tr>
<tr><td align='right'>
Michael Schultz <font color='gray'>(o.g.)</font> <font color='green'>(73)</font>
</td><td align='center'> <font><b>1:1</b></font> </td><td align='left'></td></tr>
<tr><td align='right'>
O. Ugondu (pen.) <font color='green'>(90+3)</font>
</td><td align='center'> <font><b>2:1</b></font> </td><td align='left'></td></tr>
</table>
<table><tr><td>Lead durations</td><td>0</td><td>90</td></tr></table>
''';

const _tomorrowHtml = '''
<table>
<tr class='parent'><td colspan='20'>&nbsp;<font size='2'>England - Premier League</font>&nbsp;<a class='vsmall'>stats</a></td></tr>
<tr class='team1row'><td class='steam'>Coventry City</td><td rowspan='2'><font size='1' color='gray'>17:00</font></td><td class='sgray'>home</td></tr>
<tr class='team2row'><td class='steam'>Newcastle Utd</td><td class='sgray'>away</td></tr>
</table>
''';

void main() {
  final parser = SoccerStatsParser();

  group('SoccerStatsParser hoje', () {
    final rows = parser.parse(_todayHtml, ResultsDay.today);

    test('lê as duas seções com a liga e a bandeira da linha parent', () {
      expect(rows.length, 7);
      expect(rows.first.league, 'England - Premier League');
      expect(rows.first.flagBase64, 'iVBORw0KGgo=');
      expect(rows[4].league, 'Germany - 3. Liga');
    });

    test('destaque ao vivo: status, cor, placar e gols', () {
      final live = rows.first;
      expect(live.featured, isTrue);
      expect(live.statusText, "87'");
      expect(live.isLive, isTrue);
      expect([live.homeGoals, live.awayGoals], [0, 3]);
      expect(live.goals.map((g) => '${g.homeScore}-${g.awayScore} ${g.scorer} ${g.minute}'), [
        '0-1 Erling Haaland 65',
        '1-1 Mohamed Salah (pen.) 70',
        '1-2 Jérémy Doku 90+2',
      ]);
    });

    test('lista completa: horário, placar final ou vs', () {
      final finished = rows[4];
      expect(finished.featured, isFalse);
      expect(finished.kickoff, '12:30');
      expect(finished.homeTeam, 'FC Ingolstadt');
      expect(finished.awayTeam, 'Wehen Wiesbaden');
      expect([finished.homeGoals, finished.awayGoals], [2, 4]);
      expect(finished.detailsUrl,
          'https://www.soccerstats.com/round_details.asp?league=germany3&mrevid=m77&st1=11&st2=7');
      expect(rows[5].homeGoals, isNull);
      expect(rows[5].detailsUrl, isEmpty);
    });
  });

  group('SoccerStatsParser ontem/amanhã', () {
    test('ontem: pares team1row/team2row, adiado e placar', () {
      final rows = parser.parse(_yesterdayHtml, ResultsDay.yesterday);
      expect(rows.length, 2);
      expect(rows[0].postponed, isTrue);
      expect(rows[0].homeTeam, 'Rayo Vallecano');
      expect(rows[0].awayTeam, 'Athletic Bilbao');
      expect(rows[0].homeGoals, isNull);
      expect(rows[1].league, 'Spain - LaLiga');
      expect(rows[1].flagBase64, 'BBBB');
      expect([rows[1].homeGoals, rows[1].awayGoals], [1, 2]);
      expect(rows[1].detailsUrl, 'https://www.soccerstats.com/round_details.asp?league=spain&mrevid=m80&st1=1&st2=13');
      expect(rows[0].detailsUrl, isEmpty);
    });

    test('cronologia da análise: lado, minuto, gol contra e pênalti', () {
      final goals = GetGlobalResultsUseCase.goalsOf(parser.parseGoals(_goalsHtml));
      expect(goals.map((g) => '${g.isHome ? 'C' : 'F'} ${g.minute} ${g.scorer}'), [
        'F 59 Florian Hübner',
        'C 73 Michael Schultz',
        'C 90+3 O. Ugondu',
      ]);
      expect(goals.map((g) => g.isOwnGoal), [false, true, false]);
      expect(goals.map((g) => g.isPenalty), [false, false, true]);
    });

    test('amanhã: horário no lugar do placar', () {
      final rows = parser.parse(_tomorrowHtml, ResultsDay.tomorrow);
      expect(rows.single.kickoff, '17:00');
      expect(rows.single.homeGoals, isNull);
      expect(rows.single.awayGoals, isNull);
      expect(rows.single.league, 'England - Premier League');
    });
  });

  group('GetGlobalResultsUseCase.toMatches', () {
    test('hoje: a lista completa é a base e o destaque sobrepõe status, placar e gols', () {
      final matches = GetGlobalResultsUseCase.toMatches(parser.parse(_todayHtml, ResultsDay.today), ResultsDay.today);
      final byTeams = {for (final m in matches) m.homeTeam: m};

      // 3 da lista completa + Jong Gent e Rennes, que só estão no destaque.
      expect(matches.length, 5);
      final liverpool = byTeams['Liverpool']!;
      expect(liverpool.status, MatchStatus.live);
      expect(liverpool.minute, '87');
      expect(liverpool.kickoff, '16:30');
      expect(liverpool.league, 'England - Premier League');
      expect([liverpool.homeGoals, liverpool.awayGoals], [0, 3]);
      expect(liverpool.goals.map((g) => g.isHome), [false, true, false]);
      expect(liverpool.goals[1].isPenalty, isTrue);
      expect(liverpool.goals[1].scorer, 'Mohamed Salah');

      expect(byTeams['FC Ingolstadt']!.status, MatchStatus.finished);
      expect(byTeams['FC Ingolstadt']!.canLoadGoals, isTrue);
      // O destaque já traz os gols: não precisa buscar.
      expect(liverpool.canLoadGoals, isFalse);
      expect(byTeams['Dusseldorf']!.status, MatchStatus.scheduled);
      expect(byTeams['Dusseldorf']!.homeGoals, isNull);
      expect(byTeams['Jong Gent']!.status, MatchStatus.live);
      expect(byTeams['Rennes']!.status, MatchStatus.finished);
      expect(byTeams['Rennes']!.homeWon, isTrue);
    });

    test('intervalo e adiado', () {
      final half = GetGlobalResultsUseCase.toMatches(const [
        ScrapedMatchDTO(homeTeam: 'A', awayTeam: 'B', featured: true, statusText: 'HT', homeGoals: 1, awayGoals: 0),
      ], ResultsDay.today);
      expect(half.single.status, MatchStatus.halfTime);
      expect(half.single.isLive, isTrue);

      final postponed = GetGlobalResultsUseCase.toMatches(
        parser.parse(_yesterdayHtml, ResultsDay.yesterday),
        ResultsDay.yesterday,
      );
      expect(postponed.map((m) => m.status), [MatchStatus.postponed, MatchStatus.finished]);
      expect(postponed[1].awayWon, isTrue);
    });
  });
}
