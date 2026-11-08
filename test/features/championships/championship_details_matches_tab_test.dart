import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_details_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/page/championship_details_page.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delay_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delete_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_score_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

/// Use case qualquer: o teste não chega a chamá-lo.
class _Unused {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Teams extends _Unused implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      const Stream.empty();
}

class _Watch extends _Unused implements WatchMatchesUseCase {}

class _Score extends _Unused implements UpdateMatchScoreUseCase {}

class _Voting extends _Unused implements ToggleMatchVotingUseCase {}

class _Delete extends _Unused implements DeleteMatchUseCase {}

class _Phase extends _Unused implements SetMatchPhaseUseCase {}

class _Delay extends _Unused implements DelayMatchUseCase {}

/// Guarda os pedidos de `watch` (sem ler nada).
class _SpyMatchesCubit extends MatchesCubit {
  final calls = <(int?, MatchesFilter, String, String)>[];

  _SpyMatchesCubit() : super(_Watch(), _Score(), _Voting(), _Delete(), _Teams(), _Phase(), _Delay());

  @override
  void watch({int? championshipId, required MatchesFilter filter, required String region, required String season}) =>
      calls.add((championshipId, filter, region, season));
}

void main() {
  testWidgets('aba "Jogos" existe e só pede as partidas da competição quando é aberta', (tester) async {
    final matches = _SpyMatchesCubit();
    const championship = ChampionshipDTO(
      id: 'doc1',
      championshipId: 7,
      title: 'Copa Açaí de Futsal',
      region: 'Floresta',
      season: '2026',
    );
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ChampionshipDetailsCubit>(create: (_) => ChampionshipDetailsCubit(_Teams())),
          BlocProvider<MatchesCubit>.value(value: matches),
        ],
        child: const ChampionshipDetailsPage(championship: championship),
      ),
    ));
    await tester.pump();
    expect(find.text('Jogos'), findsOneWidget);
    expect(matches.calls, isEmpty, reason: 'sem abrir a aba, nenhuma leitura de partidas');
  });
}
