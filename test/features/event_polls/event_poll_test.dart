import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll_draft.dart';
import 'package:arena_soccer/features/event_polls/domain/usecases/event_poll_usecase.dart';
import 'package:arena_soccer/features/event_polls/presentation/bloc/event_poll_cubit.dart';
import 'package:arena_soccer/features/event_polls/presentation/page/event_poll_page.dart';
import 'package:arena_soccer/features/event_polls/presentation/widgets/event_poll_feed_card.dart';
import 'package:arena_soccer/features/event_polls/presentation/widgets/event_poll_parts.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Prévia em PNG fora do CI: EVENT_PREVIEW=1 flutter test test/features/event_polls/event_poll_test.dart
// → build/event_previews/<caso>.png

final _now = DateTime(2026, 11, 15, 10);

NewsDTO _card({bool closed = false, bool partial = true, DateTime? closesAt}) => NewsDTO(
      id: 'ev1',
      tag: NewsDTO.eventTag,
      isVisible: true,
      title: 'Gol mais bonito da rodada',
      description: 'Escolha o golaço da 5ª rodada do Municipal.',
      region: 'Floresta',
      event: EventPoll(
        closesAt: closesAt ?? _now.add(const Duration(days: 2, hours: 4)),
        closed: closed,
        showPartial: partial,
        options: const [
          EventPollOption(
              id: 'o1',
              title: 'Gol do Dudu',
              subtitle: 'Lava Jato x Volta',
              link: 'https://www.instagram.com/reel/abc'),
          EventPollOption(id: 'o2', title: 'Gol do Rafa', subtitle: 'Açaí x Gralha', link: 'https://youtu.be/xyz'),
          EventPollOption(id: 'o3', title: 'Gol do Kaio', subtitle: 'Floresta x Riacho'),
        ],
      ),
    );

class _UseCase implements EventPollUseCase {
  final card = StreamController<Either<Failure, NewsDTO?>>.broadcast();
  final myVote = StreamController<Either<Failure, String?>>.broadcast();
  final tally = StreamController<Either<Failure, EventTally>>.broadcast();
  final votes = <(String, String)>[];
  var tallyWatched = 0;
  var closed = 0;

  @override
  Stream<Either<Failure, NewsDTO?>> watch(String id) => card.stream;

  @override
  Stream<Either<Failure, String?>> watchMyVote({required String eventId, required String userId}) => myVote.stream;

  @override
  Stream<Either<Failure, EventTally>> watchTally(String eventId) {
    tallyWatched++;
    return tally.stream;
  }

  @override
  Future<Either<Failure, void>> vote({
    required String eventId,
    required String userId,
    required String optionId,
    required String name,
  }) async {
    votes.add((userId, optionId));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> close(String id) async {
    closed++;
    return const Right(null);
  }
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session({bool admin = false, bool guest = false})
      : super(guest
            ? const GuestSessionState()
            : AuthenticatedSessionState(user: UserDTO(id: 'u1', name: 'Ana', email: 'a@x.com', isAdmin: admin)));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

Widget _app(Widget home, {SessionCubit? session, Key? boundary}) => BlocProvider<SessionCubit>.value(
      value: session ?? _Session(),
      child: RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: home,
        ),
      ),
    );

void main() {
  group('domínio', () {
    test('aberto até o prazo; "Encerrar agora" fecha antes', () {
      final event = _card().event!;
      expect(event.isOpenAt(_now), isTrue);
      expect(event.isOpenAt(_now.add(const Duration(days: 3))), isFalse);
      expect(_card(closed: true).event!.isOpenAt(_now), isFalse);
    });

    test('resultado: parcial ligado sempre; desligado só depois de encerrar', () {
      expect(_card().event!.resultVisibleAt(_now), isTrue);
      expect(_card(partial: false).event!.resultVisibleAt(_now), isFalse);
      expect(_card(partial: false, closed: true).event!.resultVisibleAt(_now), isTrue);
    });

    test('apuração: percentuais, vencedora e empate', () {
      const tally = EventTally({'o1': 6, 'o2': 3, 'o3': 1});
      expect(tally.total, 10);
      expect(tally.percentOf('o1'), 60);
      expect(tally.winners(), {'o1'});
      expect(const EventTally({'o1': 2, 'o2': 2}).winners(), {'o1', 'o2'});
      expect(const EventTally({'o1': 0}).winners(), isEmpty);
      expect(const EventTally().percentOf('o1'), 0);
    });

    test('rede pelo link', () {
      expect(SocialLink.of('https://www.instagram.com/reel/abc'), SocialNetwork.instagram);
      expect(SocialLink.of('https://youtu.be/xyz'), SocialNetwork.youtube);
      expect(SocialLink.of('https://vm.tiktok.com/x'), SocialNetwork.tiktok);
      expect(SocialLink.of('https://x.com/a/status/1'), SocialNetwork.x);
      expect(SocialLink.of('https://site.com.br/video'), SocialNetwork.other);
      expect(SocialLink.of('não é link'), isNull);
      expect(SocialLink.isValid('instagram.com/x'), isFalse);
      expect(SocialLink.isValid('https://instagram.com/x'), isTrue);
    });

    test('card: campos do doc e o cache ida e volta', () {
      final card = _card();
      final map = card.toMap();
      expect(map['tag'], 'evento');
      expect(map['idsOpcoes'], ['o1', 'o2', 'o3']);
      expect(map['mostrarParcial'], isTrue);
      expect(map['encerraEm'], isNotNull);
      expect(NewsDTO.fromCache(card.toCache()).event, card.event);
    });

    test('formulário: título, prazo futuro, 2 opções com título e link válido', () {
      final blank = EventPollDraft.blank(region: 'Floresta', now: _now);
      expect(blank.options, hasLength(2));
      expect(blank.validate(_now)?.error, EventPollDraftError.title);
      var draft = blank.copyWith(title: 'Defesa do mês');
      expect(draft.validate(_now)?.error, EventPollDraftError.optionTitle);
      draft = draft.copyWith(options: [
        draft.options[0].copyWith(title: 'Defesa do Léo'),
        draft.options[1].copyWith(title: 'Defesa do Gui', link: 'youtube'),
      ]);
      expect(draft.validate(_now), (error: EventPollDraftError.optionLink, option: 1));
      draft = draft.copyWith(options: [draft.options[0], draft.options[1].copyWith(link: 'https://youtu.be/1')]);
      expect(draft.validate(_now), isNull);
      expect(draft.copyWith(closesAt: _now.subtract(const Duration(minutes: 1))).validate(_now)?.error,
          EventPollDraftError.closesAt);
      final news = draft.toNews(authorId: 'admin1');
      expect((news.tag, news.isVisible, news.authorId, news.event!.options.length), ('evento', true, 'admin1', 2));
    });
  });

  group('cubit', () {
    test('parcial desligado e aberto: não ouve a apuração; o admin ouve', () async {
      final useCase = _UseCase();
      final cubit = EventPollCubit(useCase, now: () => _now);
      cubit.start(id: 'ev1', initial: _card(partial: false), userId: 'u1');
      expect(useCase.tallyWatched, 0);
      final admin = EventPollCubit(useCase, now: () => _now)
        ..start(id: 'ev1', initial: _card(partial: false), userId: 'u1', isAdmin: true);
      expect(useCase.tallyWatched, 1);
      await cubit.close();
      await admin.close();
    });

    test('vota uma vez só', () async {
      final useCase = _UseCase();
      final cubit = EventPollCubit(useCase, now: () => _now)..start(id: 'ev1', initial: _card(), userId: 'u1');
      await cubit.vote(optionId: 'o2', userId: 'u1', name: 'Ana');
      await cubit.vote(optionId: 'o1', userId: 'u1', name: 'Ana');
      expect(useCase.votes, [('u1', 'o2')]);
      expect(cubit.state.myVote, 'o2');
      await cubit.close();
    });
  });

  group('telas', () {
    late _UseCase useCase;

    Future<void> pumpPage(WidgetTester tester, NewsDTO card, {SessionCubit? session, Key? boundary}) async {
      tester.view.physicalSize = const Size(400, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      useCase = _UseCase();
      await tester.pumpWidget(_app(
        BlocProvider<EventPollCubit>(
          create: (_) => EventPollCubit(useCase, now: () => _now),
          child: EventPollPage(eventId: card.id, initial: card),
        ),
        session: session,
        boundary: boundary,
      ));
      await tester.pump();
    }

    testWidgets('escolhe, confirma e vota; com o parcial, as barras aparecem', (tester) async {
      await pumpPage(tester, _card());
      expect(find.text('Escolha uma opção e confirme o seu voto.'), findsOneWidget);
      // Aberto: ainda sem a arte do resultado.
      expect(find.byKey(const ValueKey('event-share-result')), findsNothing);
      await tester.tap(find.text('Gol do Rafa'));
      await tester.pump();
      await tester.tap(find.text('VOTAR EM GOL DO RAFA'));
      await tester.pumpAndSettle();
      expect(find.text('Votar em Gol do Rafa?'), findsOneWidget);
      await tester.tap(find.text('Votar').last);
      await tester.pumpAndSettle();
      expect(useCase.votes, [('u1', 'o2')]);
      useCase.tally.add(const Right(EventTally({'o1': 1, 'o2': 3})));
      await tester.pump();
      await tester.pump();
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Seu voto'), findsOneWidget);
    });

    testWidgets('parcial desligado: depois de votar, só o aviso', (tester) async {
      await pumpPage(tester, _card(partial: false));
      useCase.myVote.add(const Right('o1'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Voto registrado. O resultado sai no encerramento.'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
      expect(useCase.tallyWatched, 0);
    });

    testWidgets('encerrado: vencedora em destaque, sem votar', (tester) async {
      await pumpPage(tester, _card(closed: true));
      useCase.tally.add(const Right(EventTally({'o1': 7, 'o2': 2, 'o3': 1})));
      await tester.pump();
      await tester.pump();
      expect(find.text('VENCEDOR'), findsOneWidget);
      // Encerrado e com votos: compartilhar a arte do resultado.
      expect(find.byKey(const ValueKey('event-share-result')), findsOneWidget);
      expect(find.byKey(const ValueKey('event-share-result-button')), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_off_rounded), findsNothing);
    });

    testWidgets('convidado não vota; o vídeo abre fora do app', (tester) async {
      final opened = <Uri>[];
      final original = EventLinkOpener.open;
      EventLinkOpener.open = (uri) async {
        opened.add(uri);
        return true;
      };
      addTearDown(() => EventLinkOpener.open = original);
      await pumpPage(tester, _card(), session: _Session(guest: true));
      expect(find.text('Entre na sua conta para votar.'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_off_rounded), findsNothing);
      await tester.tap(find.text('Ver no Instagram'));
      expect(opened.single.toString(), 'https://www.instagram.com/reel/abc');
    });

    testWidgets('admin encerra pela página', (tester) async {
      await pumpPage(tester, _card(), session: _Session(admin: true));
      await tester.tap(find.byKey(const ValueKey('event-close')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Encerrar agora').last);
      await tester.pumpAndSettle();
      expect(useCase.closed, 1);
    });

    testWidgets('card do feed: votar aberto, resultado encerrado', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(Scaffold(
        body: ListView(children: [
          EventPollFeedCard(news: _card(), now: _now, onTap: () => taps++),
          EventPollFeedCard(news: _card(closed: true).copyWith(id: 'ev2'), now: _now, onTap: () {}),
        ]),
      )));
      expect(find.text('VOTAR'), findsOneWidget);
      expect(find.text('VER RESULTADO'), findsOneWidget);
      expect(find.text('Encerra em 2d 4h'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('event-card-ev1')));
      expect(taps, 1);
    });

    testWidgets('prévias', (tester) async {
      await tester.runAsync(() async {
        await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
        await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
        await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
        final root = Platform.environment['FLUTTER_ROOT'] ?? '';
        await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
      });
      Directory('build/event_previews').createSync(recursive: true);
      Future<void> shot(String name, GlobalKey key) async {
        final png = await tester.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
        });
        File('build/event_previews/$name.png').writeAsBytesSync(png!);
      }

      final feed = GlobalKey();
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(
        Scaffold(
          backgroundColor: const Color(0xFFF2F4F2),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            EventPollFeedCard(news: _card(), now: _now, onTap: () {}),
            EventPollFeedCard(news: _card(closed: true).copyWith(id: 'ev2'), now: _now, onTap: () {}),
          ]),
        ),
        boundary: feed,
      ));
      await tester.pump();
      await shot('feed', feed);

      final page = GlobalKey();
      await pumpPage(tester, _card(), boundary: page);
      await tester.tap(find.text('Gol do Rafa'));
      await tester.pump();
      await shot('pagina_votar', page);

      final result = GlobalKey();
      await pumpPage(tester, _card(closed: true), boundary: result);
      useCase.myVote.add(const Right('o2'));
      useCase.tally.add(const Right(EventTally({'o1': 7, 'o2': 2, 'o3': 1})));
      await tester.pump();
      await tester.pump();
      await shot('pagina_resultado', result);
    }, skip: Platform.environment['EVENT_PREVIEW'] != '1');
  });
}
