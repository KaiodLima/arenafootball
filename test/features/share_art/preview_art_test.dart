import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/bloc/share_art_cubit.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/l10n/app_localizations_pt.dart';

// Quinta, 13/11/2026, 12h em Brasília.
final _now = DateTime.utc(2026, 11, 13, 15);

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Associação Atlética Floresta do Vale Unidos',
  awayTeam: 'Esporte Clube Santo Inácio de Loyola',
  date: '15/11/2026',
  time: '18:00',
  venue: 'Estádio Municipal Professor Doutor Fulano de Tal',
  championshipId: 7,
);

ResultArtData _data({String date = '15/11/2026', String time = '18:00'}) => ResultArtData.of(
      _match.copyWith(date: date, time: time),
      championship: 'Campeonato Intermunicipal de Futebol Amador',
      link: 'https://arenasoccerflutter.web.app/app',
      now: _now,
    );

void main() {
  final l10n = AppLocalizationsPt();

  test('título pela data: hoje, amanhã, dia da semana e sem data', () {
    String headline(String date) => PreviewArtTexts.of(l10n, _data(date: date), _now).headline;
    expect(headline('13/11/2026'), 'É HOJE!');
    expect(headline('14/11/2026'), 'AMANHÃ');
    expect(headline('15/11/2026'), 'DOMINGO');
    expect(headline('30/11/2026'), 'PRÓXIMO JOGO', reason: 'longe demais para o dia da semana');
    expect(headline(''), 'PRÓXIMO JOGO');
    final texts = PreviewArtTexts.of(l10n, _data(), _now);
    expect(texts.shortDate, 'DOM  ·  15/11');
    expect((texts.day, texts.month, texts.time), ('15', 'NOV', '18:00'));
  });

  test('sem ano na data: o ano de hoje; sem horário: aviso na divulgação', () {
    expect(ResultArtData.dayOf('15/11', _now), DateTime(2026, 11, 15));
    expect(ResultArtData.dayOf('abc', _now), isNull);
    final data = _data(time: '');
    expect(data.status, ArtMatchStatus.notStarted);
    expect(data.missing, contains(ArtMissing.time));
  });

  test('a tela vira "Divulgar partida" só antes do jogo', () {
    expect(ShareArtState(data: _data()).preview, isTrue);
    final finished = ResultArtData.of(_match.copyWith(manualStatus: MatchManualStatus.finished), now: _now);
    expect(ShareArtState(data: finished).preview, isFalse);
    expect(ShareArtState(data: _data()).templateName, 'matchday');
  });

  Widget host(Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(body: Center(child: child)),
      );

  for (final template in PreviewArtTemplate.values) {
    for (final format in ArtFormat.values) {
      testWidgets('divulgação ${template.name} em ${format.name} sem estourar (nomes longos, sem escudo)',
          (tester) async {
        tester.view.physicalSize = const Size(1600, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          host(PreviewArt(data: _data(), template: template, format: format, showQr: true, now: _now)),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('card da partida: "Divulgar" só antes do jogo', (tester) async {
    var taps = 0;
    Future<void> pump(MatchDTO match) => tester.pumpWidget(host(MatchCard(
          match: match,
          isAdmin: false,
          showVoting: false,
          onVotingTap: () {},
          onToggleVoting: () {},
          onEditScore: () {},
          onDelete: () {},
          onShareArt: () => taps++,
          now: _now,
        )));
    await pump(_match);
    await tester.tap(find.byIcon(Icons.campaign_rounded));
    expect(taps, 1);
    await pump(_match.copyWith(manualStatus: MatchManualStatus.finished));
    expect(find.byIcon(Icons.campaign_rounded), findsNothing);
  });
}
