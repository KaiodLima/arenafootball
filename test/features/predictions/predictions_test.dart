import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/count_predictions_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_prediction_ranking_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/save_prediction_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/watch_my_prediction_usecase.dart';
import 'package:arena_soccer/features/predictions/presentation/bloc/prediction_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

class _FakeRepository implements IPredictionsRepository {
  final mineController = StreamController<Either<Failure, PredictionDTO?>>();
  List<PredictionRankingEntry> top = const [];
  PredictionRankingEntry? mineEntry;
  int ahead = 0;
  Map<String, Object>? saved;

  @override
  Stream<Either<Failure, PredictionDTO?>> watchMine({required String matchId, required String uid, String? season}) =>
      mineController.stream;

  @override
  Future<Either<Failure, void>> save({
    required String matchId,
    required String uid,
    required String name,
    required int home,
    required int away,
    String? season,
  }) async {
    saved = {'matchId': matchId, 'uid': uid, 'name': name, 'home': home, 'away': away};
    return const Right(null);
  }

  @override
  Future<Either<Failure, int>> count({required String matchId, String? season}) async => const Right(12);

  @override
  Future<Either<Failure, List<PredictionRankingEntry>>> topOfRegion({required String regionId, String? season}) async =>
      Right(top);

  @override
  Future<Either<Failure, PredictionRankingEntry?>> mine(
          {required String regionId, required String uid, String? season}) async =>
      Right(mineEntry);

  @override
  Future<Either<Failure, int>> aheadOf({required String regionId, required int points, String? season}) async =>
      Right(ahead);
}

void main() {
  test('ranking: pontos, depois exatos, depois palpites', () {
    const a = PredictionRankingEntry(uid: 'a', name: 'A', points: 20, exact: 1, count: 5);
    const b = PredictionRankingEntry(uid: 'b', name: 'B', points: 20, exact: 2, count: 3);
    const c = PredictionRankingEntry(uid: 'c', name: 'C', points: 30);
    const d = PredictionRankingEntry(uid: 'd', name: 'D', points: 20, exact: 1, count: 9);
    final sorted = [a, b, c, d]..sort(PredictionRankingEntry.compare);
    expect(sorted.map((e) => e.uid), ['c', 'b', 'd', 'a']);
  });

  group('GetPredictionRankingUseCase', () {
    test('conta no top: posição pela lista, sem leitura extra', () async {
      final repository = _FakeRepository()
        ..top = const [
          PredictionRankingEntry(uid: 'x', name: 'X', points: 5),
          PredictionRankingEntry(uid: 'me', name: 'Eu', points: 17),
        ];
      final result = await GetPredictionRankingUseCase(repository)(regionId: 'r1', uid: 'me');
      expect(result.right.top.first.uid, 'me');
      expect(result.right.myPosition, 1);
    });

    test('conta fora do top: lê a linha e conta quem está à frente', () async {
      final repository = _FakeRepository()
        ..top = const [PredictionRankingEntry(uid: 'x', name: 'X', points: 50)]
        ..mineEntry = const PredictionRankingEntry(uid: 'me', name: 'Eu', points: 7)
        ..ahead = 63;
      final result = await GetPredictionRankingUseCase(repository)(regionId: 'r1', uid: 'me');
      expect(result.right.mine?.points, 7);
      expect(result.right.myPosition, 64);
    });

    test('sem pontos ainda: sem posição', () async {
      final result = await GetPredictionRankingUseCase(_FakeRepository())(regionId: 'r1', uid: 'me');
      expect(result.right.mine, isNull);
      expect(result.right.myPosition, isNull);
    });
  });

  test('cubit: o palpite gravado vira o rascunho, −/+ limitado e salvar grava o rascunho', () async {
    final repository = _FakeRepository();
    final cubit = PredictionCubit(
      WatchMyPredictionUseCase(repository),
      SavePredictionUseCase(repository),
      CountPredictionsUseCase(repository),
    )..watch(matchId: 'm1', uid: 'me', season: '2026');
    repository.mineController.add(const Right(PredictionDTO(uid: 'me', home: 2, away: 1)));
    await Future<void>.delayed(Duration.zero);
    expect((cubit.state.home, cubit.state.away), (2, 1));
    expect(cubit.state.changed, isFalse);

    cubit.changeAway(-1);
    cubit.changeAway(-1);
    cubit.changeHome(1);
    expect((cubit.state.home, cubit.state.away), (3, 0));
    expect(cubit.state.changed, isTrue);

    await cubit.save(uid: 'me', name: ' Kaio ');
    expect(repository.saved, {'matchId': 'm1', 'uid': 'me', 'name': 'Kaio', 'home': 3, 'away': 0});
    expect(cubit.state.saved, isTrue);

    await cubit.loadCount();
    expect(cubit.state.count, 12);
    await cubit.close();
  });

  group('pílula "Palpitar" no card', () {
    Future<void> pump(WidgetTester tester, MatchDTO match, VoidCallback onPredict) => tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: MatchCard(
              match: match,
              isAdmin: false,
              now: DateTime(2026, 10, 22, 15, 30),
              onVotingTap: () {},
              onToggleVoting: () {},
              onEditScore: () {},
              onDelete: () {},
              onPredict: onPredict,
            ),
          ),
        ));

    testWidgets('antes do jogo: aparece e abre o palpite', (tester) async {
      var taps = 0;
      await pump(
        tester,
        const MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta', date: '22/10', time: '16:00'),
        () => taps++,
      );
      await tester.tap(find.text('Palpitar'));
      expect(taps, 1);
    });

    testWidgets('jogo começado: sem a pílula', (tester) async {
      await pump(
        tester,
        const MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta', date: '22/10', time: '15:00'),
        () {},
      );
      expect(find.text('Palpitar'), findsNothing);
    });
  });
}
