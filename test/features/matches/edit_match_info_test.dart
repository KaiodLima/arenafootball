import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_info_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/edit_match_info_sheet.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

class _Repo implements IMatchesRepository {
  final calls = <Map<String, Object>>[];

  @override
  Future<Either<Failure, void>> updateMatchInfo({
    required String matchId,
    required String date,
    required String time,
    required int durationMinutes,
    required String venue,
    String? season,
  }) async {
    calls.add({'id': matchId, 'data': date, 'horario': time, 'duracao': durationMinutes, 'local': venue});
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Lava Jato',
  awayTeam: 'Volta',
  date: '15/11/2026',
  time: '18:00',
  venue: 'Campo do Ipê',
);

Widget _app(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: home),
    );

void main() {
  test('use case: grava só data, horário, duração e local; sem mudança, não grava', () async {
    final repo = _Repo();
    final useCase = UpdateMatchInfoUseCase(repo);
    final same = await useCase(
      match: _match,
      info: (date: '15/11/2026', time: '18:00', durationMinutes: 90, venue: 'Campo do Ipê'),
    );
    expect(same.right, _match);
    expect(repo.calls, isEmpty);
    final changed = await useCase(
      match: _match,
      info: (date: '15/11/2026', time: '19:30', durationMinutes: 80, venue: ' Arena Orlandão '),
    );
    expect(repo.calls.single, {
      'id': 'm1',
      'data': '15/11/2026',
      'horario': '19:30',
      'duracao': 80,
      'local': 'Arena Orlandão',
    });
    expect((changed.right.time, changed.right.venue, changed.right.durationMinutes), ('19:30', 'Arena Orlandão', 80));
  });

  testWidgets('folha: abre com os dados da partida e devolve o que mudou', (tester) async {
    MatchInfoEdit? result;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showEditMatchInfoSheet(context, match: _match),
        child: const Text('abrir'),
      ),
    )));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Editar partida'), findsOneWidget);
    expect(find.text('Campo do Ipê'), findsOneWidget);
    await tester.tap(find.text('20:00'));
    await tester.enterText(find.widgetWithText(TextField, 'Campo do Ipê'), 'Arena Orlandão');
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(result, (date: '15/11/2026', time: '20:00', durationMinutes: 85, venue: 'Arena Orlandão'));
  });

  testWidgets('card: quem gerencia vê "Editar partida" na engrenagem', (tester) async {
    var opened = 0;
    await tester.pumpWidget(_app(MatchCard(
      match: _match,
      isAdmin: true,
      onVotingTap: () {},
      onToggleVoting: () {},
      onEditScore: () {},
      onDelete: () {},
      onEditInfo: () => opened++,
    )));
    await tester.tap(find.byIcon(Icons.settings_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar partida'));
    await tester.pumpAndSettle();
    expect(opened, 1);
  });
}
