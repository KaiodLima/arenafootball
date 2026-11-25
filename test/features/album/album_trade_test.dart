import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_trade.dart';
import 'package:arena_soccer/features/album/domain/usecases/album_usecase.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_cubit.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_trade_widgets.dart';
import 'package:arena_soccer/features/referrals/data/dtos/referral_dto.dart';
import 'package:arena_soccer/features/referrals/domain/usecases/referral_usecases.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _stickers = [
  StickerDTO(id: 'a', number: 1),
  StickerDTO(id: 'b', number: 2),
  StickerDTO(id: 'c', number: 3),
  StickerDTO(id: 'd', number: 4),
];
const _album = UserAlbumDTO(counts: {'a': 2, 'b': 4, 'c': 1, 'd': 3}, packs: 3);
const _event = AlbumEventDTO(id: 'ev', active: true, tradeSize: 2, tradesPerDay: 1);

class _UseCase implements AlbumUseCase {
  final stickers = StreamController<Either<Failure, List<StickerDTO>>>.broadcast();
  final album = StreamController<Either<Failure, UserAlbumDTO>>.broadcast();
  final pack = StreamController<Either<Failure, AlbumPackDTO?>>.broadcast();
  final requests = <({int opened, bool extra, List<String> trade})>[];

  @override
  Stream<Either<Failure, List<StickerDTO>>> watchStickers(String eventId) => stickers.stream;

  @override
  Stream<Either<Failure, UserAlbumDTO>> watchMyAlbum({required String userId, required String eventId}) => album.stream;

  @override
  Stream<Either<Failure, AlbumPackDTO?>> watchPack(String packId) => pack.stream;

  @override
  Future<Either<Failure, String>> openPack({
    required String userId,
    required String eventId,
    required int opened,
    bool extra = false,
    List<String> trade = const [],
  }) async {
    requests.add((opened: opened, extra: extra, trade: trade));
    return Right('${eventId}_${userId}_${opened + 1}');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Teams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.value(const Right([]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Referral implements WatchReferralUseCase {
  @override
  Stream<Either<Failure, ReferralDTO>> call(String uid) => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _tick() => Future<void>.delayed(Duration.zero);

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: child),
    );

void main() {
  test('config da troca no evento: desligada sem o campo; faixa de 2 a 30', () {
    AlbumEventDTO parse(Map<String, dynamic> data) => AlbumEventDTO.fromMap('ev', data);
    expect(parse({}).tradeOn, isFalse);
    expect(parse({'trocaQtd': 5, 'trocasPorDia': 2}).tradeSize, 5);
    expect(parse({'trocaQtd': 5, 'trocasPorDia': 2}).tradesPerDay, 2);
    expect(parse({'trocaQtd': 1}).tradeOn, isFalse);
    expect(parse({'trocaQtd': 40}).tradeOn, isFalse);
    expect(parse({'trocasPorDia': 99}).tradesPerDay, AlbumEventDTO.maxTradesPerDay);
    expect(_event.toMap()['trocaQtd'], 2);
    expect(_event.toMap()['trocasPorDia'], 1);
  });

  test('repetidas: da mais repetida, automático, limite do dia em Brasília', () {
    expect(AlbumTrade.duplicates(_stickers, _album).map((s) => s.id), ['b', 'd', 'a']);
    expect(AlbumTrade.autoPick(_stickers, _album, 2), ['b', 'd']);
    final now = DateTime.utc(2026, 11, 25, 15);
    expect(AlbumTrade.tradesLeft(_event, _album, now), 1);
    expect(AlbumTrade.canTrade(_event, _stickers, _album, now), isTrue);
    final traded = UserAlbumDTO.fromMap({
      'figurinhas': {'a': 2, 'b': 4},
      'trocasDia': {'dia': '2026-11-25', 'qtd': 1},
    });
    expect(AlbumTrade.tradesLeft(_event, traded, now), 0);
    // 01:00 UTC do dia 26 ainda é dia 25 em Brasília; 04:00 UTC já é 26.
    expect(AlbumTrade.tradesLeft(_event, traded, DateTime.utc(2026, 11, 26, 1)), 0);
    expect(AlbumTrade.tradesLeft(_event, traded, DateTime.utc(2026, 11, 26, 4)), 1);
    expect(AlbumTrade.hasEnough(_event.copyWith(tradeSize: 4), _stickers, _album), isFalse);
    expect(AlbumTrade.validSelection(_event, _album, ['a', 'b']), isTrue);
    expect(AlbumTrade.validSelection(_event, _album, ['a', 'c']), isFalse, reason: 'c não é repetida');
    expect(AlbumTrade.validSelection(_event, _album, ['a', 'a']), isFalse);
    expect(AlbumTrade.validSelection(_event, _album, ['a']), isFalse);
  });

  test('cubit: a troca pede o próximo pacote com as repetidas; recusa traz o motivo', () async {
    final useCase = _UseCase();
    final cubit = AlbumCubit(useCase, _Teams(), _Referral());
    addTearDown(cubit.close);
    cubit.start(event: _event, userId: 'u1');
    useCase.stickers.add(const Right(_stickers));
    useCase.album.add(const Right(_album));
    await _tick();

    await cubit.tradeDuplicates(['a']);
    expect(useCase.requests, isEmpty, reason: 'menos que o tamanho da troca');
    await cubit.tradeDuplicates(['b', 'd']);
    expect(useCase.requests.single.trade, ['b', 'd']);
    expect(useCase.requests.single.opened, 3);
    expect(useCase.requests.single.extra, isFalse);
    expect(cubit.state.opening, isTrue);

    useCase.pack.add(const Right(AlbumPackDTO(id: 'ev_u1_4', status: AlbumPackStatus.refused, refusal: 'limite_dia')));
    await _tick();
    expect(cubit.state, isA<ErrorAlbumState>());
    expect((cubit.state as ErrorAlbumState).refusal, 'limite_dia');
    expect(cubit.state.opening, isFalse);
  });

  testWidgets('cartão da troca: status e botão conforme repetidas e trocas do dia', (tester) async {
    var started = false;
    await tester.pumpWidget(_app(AlbumTradeCard(
      size: 3,
      distinctDuplicates: 2,
      tradesLeft: 1,
      opening: false,
      onStart: () => started = true,
    )));
    expect(find.text('Troque 3 repetidas diferentes por 1 pacotinho'), findsOneWidget);
    expect(find.text('Você tem 2 de 3 repetidas diferentes.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('album-trade-start')));
    expect(started, isFalse);

    await tester.pumpWidget(_app(AlbumTradeCard(
      size: 2,
      distinctDuplicates: 2,
      tradesLeft: 0,
      opening: false,
      onStart: () => started = true,
    )));
    expect(find.text('Trocas de hoje usadas. Volte amanhã!'), findsOneWidget);

    await tester.pumpWidget(_app(AlbumTradeCard(
      size: 2,
      distinctDuplicates: 3,
      tradesLeft: 2,
      opening: false,
      onStart: () => started = true,
    )));
    expect(find.text('Você tem 2 trocas hoje'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('album-trade-start')));
    expect(started, isTrue);
  });

  testWidgets('seleção: marca com o "−1"; a barra só troca com o número certo', (tester) async {
    var traded = false;
    Widget build(bool selected, int count) => _app(Column(
          children: [
            SizedBox(
              width: 100,
              height: 130,
              child: AlbumTradeSelectable(
                stickerId: 'a',
                selected: selected,
                onTap: () {},
                child: const ColoredBox(color: Colors.white),
              ),
            ),
            const Spacer(),
            AlbumTradeBar(
              selected: count,
              size: 2,
              opening: false,
              onCancel: () {},
              onAuto: () {},
              onTrade: () => traded = true,
            ),
          ],
        ));
    await tester.pumpWidget(build(false, 1));
    expect(find.byKey(const ValueKey('album-trade-mark-a')), findsNothing);
    expect(find.text('1 de 2 escolhidas'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('album-trade-confirm')));
    expect(traded, isFalse);

    await tester.pumpWidget(build(true, 2));
    expect(find.byKey(const ValueKey('album-trade-mark-a')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('album-trade-confirm')));
    expect(traded, isTrue);
  });
}
