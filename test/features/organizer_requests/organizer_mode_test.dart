import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/home/presentation/home_mode.dart';
import 'package:arena_soccer/features/home/presentation/widgets/home_header.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_tab.dart';
import 'package:arena_soccer/features/organizer_requests/domain/repositories/organizer_requests_repository_interface.dart';
import 'package:arena_soccer/features/organizer_requests/domain/usecases/organizer_request_usecases.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_mode_cubit.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_teams_cubit.dart';
import 'package:arena_soccer/features/teams/data/datasources/teams_datasource.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/themes/app_theme.dart';
import 'package:arena_soccer/utils/themes/arena_palette.dart';

class _Repo implements IOrganizerRequestsRepository {
  final controller = StreamController<Either<Failure, List<ChampionshipDTO>>>.broadcast();

  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> watchMyChampionships(String userId) => controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Prefs implements PreferencesService {
  final values = <String, bool>{};

  @override
  Future<bool> getOrganizerMode(String uid) async => values[uid] ?? false;

  @override
  Future<void> setOrganizerMode(String uid, bool value) async => values[uid] = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _copa = ChampionshipDTO(id: 'c1', title: 'Copa Verde', season: '2026', organizerId: 'org1');

class _AllRepo implements IChampionshipsRepository {
  final controller = StreamController<Either<Failure, List<ChampionshipDTO>>>.broadcast();

  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> watchChampionships({String? region}) => controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('campeonato escolhido: o mesmo para Times e Tabelas; fora da lista, o primeiro', () async {
    final cubit = OrganizerModeCubit(WatchMyChampionshipsUseCase(_Repo()), _Prefs());
    const a = ChampionshipDTO(id: 'a', championshipId: 1, title: 'A');
    const b = ChampionshipDTO(id: 'b', championshipId: 2, title: 'B');
    expect(cubit.state.selectedIn(const [a, b]), a);
    cubit.selectChampionship(2);
    expect(cubit.state.selectedIn(const [a, b]), b);
    expect(cubit.state.selectedIn(const [a]), a, reason: 'o escolhido saiu da lista');
    expect(cubit.state.selectedIn(const []), isNull);
    await cubit.close();
  });

  test('admin: modo organizador com todos os campeonatos da temporada atual', () async {
    final all = _AllRepo();
    final cubit =
        OrganizerModeCubit(WatchMyChampionshipsUseCase(_Repo()), _Prefs(), null, WatchChampionshipsUseCase(all));
    await cubit.follow('adm', isAdmin: true);
    // Toggle disponível mesmo antes de chegar algum campeonato.
    expect(cubit.state.isOrganizer, isTrue);
    expect(await cubit.ensureIndexFor(99), isTrue, reason: 'admin não precisa do índice');
    final season = SeasonCollection.currentSeason;
    all.controller.add(Right([
      ChampionshipDTO(id: 'a', championshipId: 3, title: 'A', season: season),
      ChampionshipDTO(id: 'b', championshipId: 8, title: 'B', season: season),
      const ChampionshipDTO(id: 'old', championshipId: 9, title: 'Velho', season: '1999'),
    ]));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.championships.map((c) => c.id), ['b', 'a']);
    await cubit.toggle();
    expect(cubit.state.active, isTrue);
    // Deixou de ser admin: volta para os campeonatos dele.
    await cubit.follow('adm');
    expect(cubit.state.isAdmin, isFalse);
    expect(cubit.state.isOrganizer, isFalse);
    await cubit.close();
  });

  test('modo organizador: segue a conta, troca e volta a torcedor sem campeonatos', () async {
    final repo = _Repo();
    final prefs = _Prefs()..values['org1'] = true;
    final cubit = OrganizerModeCubit(WatchMyChampionshipsUseCase(repo), prefs);

    await cubit.follow('org1');
    // Lembrado no aparelho, mas sem campeonato ainda: torcedor.
    expect(cubit.state.organizerMode, isTrue);
    expect(cubit.state.active, isFalse);

    repo.controller.add(const Right([_copa]));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isOrganizer, isTrue);
    expect(cubit.state.active, isTrue);

    await cubit.toggle();
    expect(cubit.state.active, isFalse);
    expect(prefs.values['org1'], isFalse);

    await cubit.toggle();
    repo.controller.add(const Right([]));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.active, isFalse);

    await cubit.follow(null);
    expect(cubit.state, const OrganizerModeState());
    await cubit.close();
  });

  test('times por id em lotes de 30', () {
    final ids = [for (var i = 0; i < 65; i++) 't$i'];
    expect(chunked(ids).map((c) => c.length), [30, 30, 5]);
    expect(chunked(<String>[]), isEmpty);
  });

  test('participantes do campeonato: pelo id, depois pelo nome, senão só o nome', () {
    const championship = ChampionshipDTO(
      id: 'c1',
      teams: ['Leões', 'Tigres', 'Sumido'],
      teamIds: ['t1', '', ''],
    );
    final directory = TeamDirectory(const [TeamDTO(id: 't1', name: 'Leões FC'), TeamDTO(id: 't2', name: 'Tigres')]);
    final teams = participantsOf(championship, directory);
    expect(teams.map((t) => t.id), ['t1', 't2', '']);
    expect(teams.last.name, 'Sumido');
  });

  test('seletor do organizador: temporadas mais recentes primeiro', () {
    final ordered = organizerTableChampionships(const [
      ChampionshipDTO(id: 'a', season: '2025', championshipId: 1),
      ChampionshipDTO(id: 'b', season: '2026', championshipId: 9),
      ChampionshipDTO(id: 'c', season: '2026', championshipId: 3),
    ]);
    expect(ordered.map((c) => c.id), ['c', 'b', 'a']);
  });

  testWidgets('toggle troca de modo ao tocar; o 3º modo (jogador) só para o admin', (tester) async {
    var taps = 0;
    Future<void> pump({required bool showPlayer}) => tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: HomeModeToggle(mode: HomeMode.standard, showPlayer: showPlayer, onTap: () => taps++),
          ),
        ));
    await pump(showPlayer: false);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
    expect(find.byIcon(Icons.sports_soccer_rounded), findsNothing);
    await tester.tap(find.byType(HomeModeToggle));
    expect(taps, 1);
    await pump(showPlayer: true);
    expect(find.byIcon(Icons.sports_soccer_rounded), findsOneWidget);
  });

  test('ciclo do toggle: admin → organizador → jogador → admin; organizador comum ↔', () {
    HomeMode next(HomeMode m, {bool admin = false, bool organizer = false}) =>
        nextHomeMode(m, isAccountAdmin: admin, isOrganizer: organizer);
    expect(next(HomeMode.standard, admin: true), HomeMode.organizer);
    expect(next(HomeMode.organizer, admin: true), HomeMode.player);
    expect(next(HomeMode.player, admin: true), HomeMode.standard);
    expect(next(HomeMode.standard, organizer: true), HomeMode.organizer);
    expect(next(HomeMode.organizer, organizer: true), HomeMode.standard);
    expect(next(HomeMode.standard), HomeMode.standard);
  });

  testWidgets('paleta: verde por padrão, azul no tema do organizador', (tester) async {
    late ArenaPalette fan;
    late ArenaPalette organizer;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(builder: (context) {
        fan = ArenaPalette.of(context);
        return Theme(
          data: ArenaPalette.organizerTheme(Theme.of(context)),
          child: Builder(builder: (context) {
            organizer = ArenaPalette.of(context);
            return const SizedBox();
          }),
        );
      }),
    ));
    expect(fan.primary, AppColors.primary);
    expect(organizer.primary, AppColors.organizerPrimary);
    expect(organizer.primaryDark, AppColors.organizerDark);
  });
}
