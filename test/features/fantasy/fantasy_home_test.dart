import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_home_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_home_page.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_score_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

import 'fantasy_no_cache.dart';

/// Doc gravado pela function (`rodadas/{n}/atletas/{id}`).
final _scoreDoc = <String, dynamic>{
  'nome': 'Ângelo Atacante',
  'time': 'Tigres',
  'total': 20,
  'minutos': 90,
  'posicao': 'ata',
  'partidas': [
    {'idPartida': 'm1', 'minutos': 90, 'minutosEstimados': false, 'pontos': 20},
  ],
  'itens': [
    {'regra': 'base', 'qtd': 1, 'pontos': 10, 'idPartida': 'm1'},
    {'regra': 'gol', 'qtd': 2, 'pontos': 10, 'idPartida': 'm1'},
    {'regra': 'vitoria', 'qtd': 1, 'pontos': 3, 'idPartida': 'm1'},
    {'regra': 'amarelo', 'qtd': 1, 'pontos': -3, 'idPartida': 'm1'},
  ],
  'motivos': [
    {'codigo': 'bonus_minutos_insuficientes', 'idPartida': 'm1'},
  ],
  'parametros': {'minMinutos': 20, 'minMinutosDefesa': 45, 'capitao': 1.5},
};

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: child),
    );

class _Repo with FantasyNoCache implements IFantasyRepository {
  final active = StreamController<Either<Failure, List<FantasyConfigDTO>>>.broadcast();
  final rounds = <String, FantasyRoundDTO?>{};
  final participants = <String, FantasyParticipantDTO?>{};
  final lineups = <String, FantasyLineupDTO?>{};

  @override
  Stream<Either<Failure, List<FantasyConfigDTO>>> watchActive(String season) => active.stream;

  @override
  Stream<Either<Failure, FantasyRoundDTO?>> watchRound(String fantasyId, int round) =>
      Stream.value(Right(rounds[fantasyId]));

  @override
  Stream<Either<Failure, FantasyParticipantDTO?>> watchParticipant(String fantasyId, String uid) =>
      Stream.value(Right(participants[fantasyId]));

  @override
  Stream<Either<Failure, FantasyLineupDTO?>> watchLineup(String fantasyId, int round, String uid) =>
      Stream.value(Right(lineups[fantasyId]));

  @override
  Future<Either<Failure, int>> countAbove(String fantasyId, double points, {int? round}) async => const Right(4);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FantasyConfigDTO _config(String id, String title, int round) =>
    FantasyConfigDTO.fromMap(id, {'ativo': true, 'titulo': title, 'fk_competicao': 'Floresta', 'rodadaAtual': round});

final _now = DateTime(2026, 11, 18, 12);

void main() {
  test('pontuação do atleta lida do doc das functions', () {
    final s = FantasyAthleteScoreDTO.fromMap('fw', _scoreDoc);
    expect((s.total, s.minutes, s.position, s.captain), (20.0, 90, 'ata', 1.5));
    expect(s.groupedItems.map((i) => i.rule), ['base', 'gol', 'vitoria', 'amarelo']);
    expect(s.reasons.single.code, 'bonus_minutos_insuficientes');
    expect(s.minutesIn('m1'), 90);
  });

  testWidgets('folha: regras com os pontos, total, capitão 1,5× e a observação', (tester) async {
    await tester.pumpWidget(
        _app(FantasyScoreView(score: FantasyAthleteScoreDTO.fromMap('fw', _scoreDoc), captain: true, round: 3)));
    expect(find.text('Pontuação-base'), findsOneWidget);
    expect(find.text('Gols (2×)'), findsOneWidget);
    expect(find.text('+10'), findsNWidgets(2));
    expect(find.text('-3'), findsOneWidget);
    expect(find.text('Capitão (1,5×)'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Menos de 45 minutos em campo: sem o bônus de não sofrer gols.'), findsOneWidget);
    expect(find.text('90 min em campo'), findsOneWidget);
  });

  testWidgets('folha: abaixo do mínimo explica o motivo; sem apuração, aguardando', (tester) async {
    final short = FantasyAthleteScoreDTO.fromMap('sub', {
      'total': 5,
      'minutos': 15,
      'partidas': [
        {'idPartida': 'm1', 'minutos': 15},
      ],
      'itens': [
        {'regra': 'gol', 'qtd': 1, 'pontos': 5},
      ],
      'motivos': [
        {'codigo': 'minutos_insuficientes', 'idPartida': 'm1'},
      ],
    });
    await tester.pumpWidget(_app(FantasyScoreView(score: short, captain: false, round: 3)));
    expect(find.textContaining('Não atingiu o mínimo de 20 minutos (jogou 15)'), findsOneWidget);
    await tester.pumpWidget(_app(const FantasyScoreView(score: null, captain: false, round: 3)));
    expect(find.byKey(const ValueKey('fantasy-score-awaiting')), findsOneWidget);
  });

  test('home: quem a conta joga primeiro; situação da escalação e a posição', () async {
    final repo = _Repo()
      ..rounds['d1'] = FantasyRoundDTO(number: 2, status: 'aberta', closesAt: DateTime(2026, 11, 20, 18))
      ..participants['d2'] = const FantasyParticipantDTO(uid: 'u1', points: 33)
      ..rounds['d2'] = FantasyRoundDTO(number: 4, status: 'aberta', closesAt: DateTime(2026, 11, 20, 18))
      ..lineups['d2'] = const FantasyLineupDTO(uid: 'u1', copied: true);
    final cubit = FantasyHomeCubit(
      WatchActiveFantasiesUseCase(repo),
      WatchFantasyRoundUseCase(repo),
      WatchFantasyParticipantUseCase(repo),
      WatchFantasyLineupUseCase(repo),
      GetFantasyPositionCacheFirstUseCase(repo),
    );
    addTearDown(cubit.close);
    cubit.load(season: '2026', uid: 'u1');
    repo.active.add(Right([_config('d1', 'Aaa Copa', 2), _config('d2', 'Zzz Taça', 4), _config('d3', 'Fora', 0)]));
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    final items = cubit.state.forRegion('Floresta');
    expect(items.map((i) => i.config.championshipDocId), ['d2', 'd1', 'd3']);
    expect(items[0].statusAt(_now), FantasyHomeStatus.copied);
    expect(items[0].position, 5);
    expect(items[1].statusAt(_now), FantasyHomeStatus.notJoined);
    expect(
      FantasyHomeItem(
        config: _config('x', 'X', 0),
        participant: const FantasyParticipantDTO(uid: 'u1'),
      ).statusAt(_now),
      FantasyHomeStatus.noRound,
    );
    expect(
      items[0].copyWith(lineup: () => null).statusAt(_now),
      FantasyHomeStatus.pickTeam,
    );
  });

  testWidgets('cartão da home: rodada com prazo, pontos e posição, Escalar · Geral', (tester) async {
    final item = FantasyHomeItem(
      config: _config('d2', 'Taça Floresta', 4),
      round: FantasyRoundDTO(number: 4, status: 'aberta', closesAt: DateTime(2026, 11, 20, 18)),
      participant: const FantasyParticipantDTO(uid: 'u1', points: 33),
      lineup: const FantasyLineupDTO(uid: 'u1'),
      position: 5,
    );
    await tester.pumpWidget(_app(FantasyHomeCard(item: item, now: _now)));
    expect(find.text('Taça Floresta'), findsOneWidget);
    expect(find.textContaining('Rodada 4 · Fecha em 2d 6h'), findsOneWidget);
    expect(find.text('Escalação confirmada'), findsOneWidget);
    expect(find.text('pts · 5º'), findsOneWidget);
    expect(find.text('Escalar'), findsOneWidget);
    expect(find.text('Geral'), findsOneWidget);
  });
}
