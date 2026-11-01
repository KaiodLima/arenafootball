import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delay_match_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/delay_match_sheet.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';

class _Repo implements IMatchesRepository {
  final calls = <Map<String, Object?>>[];

  @override
  Future<Either<Failure, void>> delayMatch({
    required String matchId,
    required String newTime,
    required String originalTime,
    required bool resetClock,
    String? season,
  }) async {
    calls.add({'id': matchId, 'time': newTime, 'original': originalTime, 'reset': resetClock});
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setManualStatus({
    required String matchId,
    required MatchManualStatus status,
    String? stampField,
    List<String> clearFields = const [],
    String? season,
  }) async {
    calls.add({'status': status.key, 'stamp': stampField, 'clear': clearFields});
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const match = MatchDTO(id: 'm1', homeTeam: 'Casa', awayTeam: 'Fora', date: '01/11', time: '17:55');

  test('soma os minutos sem passar de 23:59', () {
    expect(DelayMatchUseCase.addMinutes('17:55', 15), '18:10');
    expect(DelayMatchUseCase.addMinutes('23:50', 30), '23:59');
    expect(DelayMatchUseCase.addMinutes('', 10), isNull);
  });

  test('guarda o horário original e mantém o primeiro ao atrasar de novo', () async {
    final repo = _Repo();
    final delay = DelayMatchUseCase(repo);
    final first = (await delay(match: match, newTime: '18:10')).right;
    expect(first.time, '18:10');
    expect(first.originalTime, '17:55');
    expect(first.delayed, isTrue);
    final second = (await delay(match: first, newTime: '18:30')).right;
    expect(second.originalTime, '17:55');
    expect(repo.calls.last, {'id': 'm1', 'time': '18:30', 'original': '17:55', 'reset': false});
  });

  test('iniciada antes da hora: atrasar volta para antes do jogo', () async {
    final repo = _Repo();
    final started = match.withRestartedClock(DateTime.utc(2026, 11, 1, 20, 56));
    final delayed = (await DelayMatchUseCase(repo)(match: started, newTime: '18:10')).right;
    expect(repo.calls.single['reset'], isTrue);
    expect(delayed.manualStatus, MatchManualStatus.none);
    expect(delayed.startedAt, isNull);
  });

  test('card: atrasada antes do novo horário; "Iniciar agora" ao vivo só pelo horário', () {
    final delayed = match.copyWith(time: '18:10', originalTime: '17:55');
    // 18:00 em Brasília.
    final status = MatchCardStatus.of(delayed, DateTime.utc(2026, 11, 1, 21, 0));
    expect(status.upcoming, isTrue);
    expect(delayed.delayed, isTrue);
    expect(canDelayMatch(delayed, status), isTrue);

    // 18:00 com a partida das 17:55 sem atraso: em andamento pelo horário.
    final live = MatchCardStatus.of(match, DateTime.utc(2026, 11, 1, 21, 0));
    expect(live.live, isTrue);
    expect(canStartMatchNow(match, live), isTrue);
  });

  testWidgets('folha: +15 grava 18:10', (tester) async {
    String? chosen;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDelayMatchSheet(
              context,
              match: match,
              canStartNow: true,
              onDelay: (time) => chosen = time,
              onStartNow: () {},
              onPause: () => chosen = 'pausa',
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Começou agora'), findsOneWidget);
    await tester.tap(find.text('+15 min · 18:10'));
    await tester.pumpAndSettle();
    expect(chosen, '18:10');

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pausar até começar'));
    await tester.pumpAndSettle();
    expect(chosen, 'pausa');
  });

  test('pausada: sem relógio nem palpite, "Iniciar partida" e dá para atrasar', () {
    final paused = match.copyWith(manualStatus: MatchManualStatus.waiting);
    // 19:00 em Brasília: pelo horário já estaria em andamento.
    final now = DateTime.utc(2026, 11, 1, 22, 0);
    final status = MatchCardStatus.of(paused, now);
    expect(status.waiting, isTrue);
    expect(status.live, isFalse);
    expect(status.upcoming, isFalse);
    expect(canDelayMatch(paused, status), isTrue);
    expect(canStartMatchNow(paused, status), isFalse);
    // Dia seguinte: esquecida pausada conta como encerrada.
    expect(MatchCardStatus.of(paused, DateTime.utc(2026, 11, 2, 15)).finished, isTrue);
  });

  test('pausar grava "aguardando" e apaga o relógio', () async {
    final repo = _Repo();
    final started = match.withRestartedClock(DateTime.utc(2026, 11, 1, 20, 56));
    final paused = (await SetMatchPhaseUseCase(repo)(match: started, phase: MatchPhase.wait)).right;
    expect(repo.calls.single, {
      'status': 'aguardando',
      'stamp': null,
      'clear': ['inicioEm', 'intervaloEm', 'segundoTempoEm'],
    });
    expect(paused.manualStatus, MatchManualStatus.waiting);
    expect(paused.startedAt, isNull);
  });

  test('atrasar uma partida pausada tira a pausa', () async {
    final repo = _Repo();
    final paused = match.copyWith(manualStatus: MatchManualStatus.waiting);
    final delayed = (await DelayMatchUseCase(repo)(match: paused, newTime: '18:30')).right;
    expect(repo.calls.single['reset'], isTrue);
    expect(delayed.manualStatus, MatchManualStatus.none);
    expect(delayed.time, '18:30');
  });
}
