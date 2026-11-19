import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_badge_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_floating_badge.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

class _Repo implements IFantasyRepository {
  final active = StreamController<Either<Failure, List<FantasyConfigDTO>>>.broadcast();

  @override
  Stream<Either<Failure, List<FantasyConfigDTO>>> watchActive(String season) => active.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session({bool guest = false})
      : super(
            SessionState(user: guest ? null : const UserDTO(id: 'u1', name: 'Ana', email: 'a@x.com', isAdmin: false)));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Region extends Cubit<RegionState> implements RegionCubit {
  _Region(String region) : super(RegionState(selectedRegion: region));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FantasyConfigDTO _fantasy(String id, String title, {String region = 'Floresta', int round = 0}) =>
    FantasyConfigDTO(championshipDocId: id, championshipId: 8, title: title, region: region, active: true)
        .withRound(round);

extension on FantasyConfigDTO {
  /// `rodadaAtual` vem das functions (só leitura): monta pelo `fromMap`.
  FantasyConfigDTO withRound(int round) => FantasyConfigDTO.fromMap(championshipDocId, {
        ...toAdminMap(),
        'rodadaAtual': round,
      });
}

void main() {
  test('vale para a região: pela sede (ou id) e região vazia = todas', () {
    final f = _fantasy('d1', 'Copa Verde');
    expect(f.appliesTo('Floresta'), isTrue);
    expect(f.appliesTo('floresta'), isTrue);
    expect(f.appliesTo('Colônia'), isFalse);
    expect(f.appliesTo(''), isTrue);
    final c = f.toChampionship();
    expect((c.id, c.championshipId, c.title, c.region), ('d1', 8, 'Copa Verde', 'Floresta'));
  });

  Future<(List<Object?>, _Repo)> pump(WidgetTester tester, {bool guest = false, String region = 'Floresta'}) async {
    final repo = _Repo();
    final pushed = <Object?>[];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.fantasyLineupPage) pushed.add(settings.arguments);
        if (settings.name == AppRoutes.fantasyHomePage) pushed.add(settings.name);
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('escalação')));
      },
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: _Session(guest: guest)),
          BlocProvider<RegionCubit>.value(value: _Region(region)),
          BlocProvider<FantasyBadgeCubit>(create: (_) => FantasyBadgeCubit(WatchActiveFantasiesUseCase(repo))),
        ],
        child: const MediaQuery(
          data: MediaQueryData(size: Size(400, 800), disableAnimations: true),
          child: Scaffold(body: Stack(children: [Positioned.fill(child: FantasyFloatingBadge())])),
        ),
      ),
    ));
    return (pushed, repo);
  }

  testWidgets('um Fantasy da região com rodada aberta: "Escalar!" e abre direto', (tester) async {
    final (pushed, repo) = await pump(tester);
    repo.active.add(Right([_fantasy('d1', 'Copa Verde', round: 2), _fantasy('d2', 'Copa Azul', region: 'Colônia')]));
    await tester.pump();
    expect(find.text('Escalar!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fantasy-badge')));
    await tester.pumpAndSettle();
    expect((pushed.single as ChampionshipDTO).id, 'd1');
  });

  testWidgets('dois Fantasy: abre a home do Fantasy; sem rodada aberta, "Fantasy"', (tester) async {
    final (pushed, repo) = await pump(tester);
    repo.active.add(Right([_fantasy('d1', 'Copa Verde'), _fantasy('d3', 'Taça Floresta')]));
    await tester.pump();
    expect(find.text('Fantasy'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fantasy-badge')));
    await tester.pumpAndSettle();
    expect(pushed.single, AppRoutes.fantasyHomePage);
  });

  testWidgets('região de fora: sem selo', (tester) async {
    final (_, repo) = await pump(tester, region: 'Colônia');
    repo.active.add(Right([_fantasy('d1', 'Copa Verde', round: 2)]));
    await tester.pump();
    expect(find.byKey(const ValueKey('fantasy-badge')), findsNothing);
  });

  testWidgets('convidado: sem selo', (tester) async {
    final (_, repo) = await pump(tester, guest: true);
    repo.active.add(Right([_fantasy('d1', 'Copa Verde', round: 2)]));
    await tester.pump();
    expect(find.byKey(const ValueKey('fantasy-badge')), findsNothing);
  });
}
