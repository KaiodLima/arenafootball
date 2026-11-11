import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_table_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/championship_groups_usecases.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_group_table_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_groups_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/group_card.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Prévia em PNG fora do CI: GROUPS_PREVIEW=1 flutter test test/features/championships/group_card_test.dart
// → build/groups_previews/<caso>.png

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

const _group = GroupDTO(
  id: 'g1',
  description: 'A',
  teams: ['Mulekada', 'Açaí No Gralle', 'Lava Jato FC', ''],
  teamIds: ['t1', 't2', 't3', ''],
  championshipId: 7,
);

const _table = GroupTableDTO(
  groupId: 'g1',
  championshipId: 7,
  group: 'A',
  rows: [
    StandingDTO(id: 't2', teamName: 'Açaí No Gralle', wins: 2, goalsFor: 5, goalsAgainst: 1, points: 6),
    StandingDTO(id: 't3', teamName: 'Lava Jato FC', wins: 1, losses: 1, goalsFor: 3, goalsAgainst: 3, points: 3),
    StandingDTO(id: 't1', teamName: 'Mulekada', losses: 2, goalsFor: 1, goalsAgainst: 5),
  ],
);

class _FakeGroups implements WatchGroupsUseCase {
  final List<GroupDTO> groups;
  _FakeGroups(this.groups);

  @override
  Stream<Either<Failure, List<GroupDTO>>> call({required String region, String? season}) => Stream.value(Right(groups));
}

class _FakeTeams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      const Stream.empty();
}

class _FakeTable implements WatchGroupTableUseCase {
  final watched = <String>[];

  @override
  Stream<Either<Failure, GroupTableDTO?>> call({required String groupId, String? season}) {
    watched.add(groupId);
    return Stream.value(Right(groupId == 'g1' ? _table : null));
  }
}

class _FakeChampionshipGroups implements WatchChampionshipGroupsUseCase {
  final List<GroupDTO> groups;
  _FakeChampionshipGroups(this.groups);

  @override
  Stream<Either<Failure, List<GroupDTO>>> call({required int championshipId, String? season}) => Stream.value(Right([
        for (final g in groups)
          if (g.championshipId == championshipId) g
      ]));
}

void main() {
  test('selo do grupo: a letra', () {
    expect(GroupCard.badgeOf('A'), 'A');
    expect(GroupCard.badgeOf('Grupo B'), 'B');
    expect(GroupCard.badgeOf('Ouro'), 'O');
  });

  test('grupos do campeonato: os dele ordenados; sem grupos, legado só em temporada antiga', () {
    const b = GroupDTO(id: 'b', description: 'B', championshipId: 7);
    const aa = GroupDTO(id: 'a', description: 'A', championshipId: 7);
    const other = GroupDTO(id: 'o', description: 'A', championshipId: 9);
    const legacy = GroupDTO(id: 'l', description: 'A');
    expect(GroupsCubit.resolve(own: const [b, aa], region: const []).map((g) => g.id), ['a', 'b']);
    expect(GroupsCubit.resolve(own: const [], region: const [other, legacy]), isEmpty,
        reason: 'campeonato novo sem grupos não mostra os de outro');
    expect(GroupsCubit.resolve(own: const [], region: const [legacy]).single.id, 'l');
  });

  test('cubit: busca pelo campeonato (sede em outra região também)', () async {
    final cubit = GroupsCubit(
      _FakeGroups(const []),
      _FakeTeams(),
      _FakeTable(),
      _FakeChampionshipGroups([_group]),
    );
    cubit.watch(region: 'Outra', season: '2026', championshipId: 7);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.groups.single.id, 'g1');
    await cubit.close();
  });

  test('cubit: escuta a tabela só dos grupos de campeonato e guarda por id', () async {
    final tables = _FakeTable();
    final cubit = GroupsCubit(
      _FakeGroups([
        _group,
        const GroupDTO(id: 'old', description: 'B', teams: ['X'])
      ]),
      _FakeTeams(),
      tables,
    );
    cubit.watch(region: 'Floresta', season: '2026');
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(tables.watched, ['g1']);
    expect(cubit.state.tableOf(_group), _table);
    await cubit.close();
  });

  Future<void> pump(WidgetTester tester, GroupCard card, {GlobalKey? key}) async {
    tester.view.physicalSize = const Size(392, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        backgroundColor: const Color(0xFFF3F6F3),
        body: Align(
          alignment: Alignment.topCenter,
          child: RepaintBoundary(
            key: key,
            child: Container(
              color: const Color(0xFFF3F6F3),
              padding: const EdgeInsets.all(16),
              child: card,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  GroupCard card({GroupTableDTO? table, GroupDTO group = _group}) => GroupCard(
        group: group,
        table: table,
        crestOf: (_) => null,
        isFavorite: (id, name) => id == 't3',
        onTap: () {},
      );

  testWidgets('com tabela: ordem, números e resumo de jogos', (tester) async {
    await pump(tester, card(table: _table));
    expect(find.text('GRUPO A'), findsOneWidget);
    expect(find.text('3 JOGOS'), findsOneWidget);
    expect(find.text('+4'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    final first = tester.getTopLeft(find.text('Açaí No Gralle')).dy;
    final last = tester.getTopLeft(find.text('Mulekada')).dy;
    expect(first, lessThan(last));
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem tabela: só os times e o total', (tester) async {
    await pump(tester, card());
    expect(find.text('3 TIMES'), findsOneWidget);
    expect(find.text('PTS'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('prévias do card de grupo', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('BarlowCondensed', [
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-SemiBold.ttf',
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-Bold.ttf',
      ]);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/groups_previews').createSync(recursive: true);
    final cases = {
      'com_tabela': card(table: _table),
      'sem_tabela': card(),
      'nomes_longos': card(
        group: _group,
        table: const GroupTableDTO(groupId: 'g1', rows: [
          StandingDTO(
              id: 't9', teamName: 'Associação Atlética Floresta do Vale Unidos', wins: 3, points: 9, goalsFor: 12),
          StandingDTO(id: 't3', teamName: 'Esporte Clube Santo Inácio de Loyola', draws: 1, points: 1),
        ]),
      ),
    };
    for (final entry in cases.entries) {
      final key = GlobalKey();
      await pump(tester, entry.value, key: key);
      expect(tester.takeException(), isNull, reason: entry.key);
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.5);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('build/groups_previews/${entry.key}.png').writeAsBytesSync(png!);
    }
  }, skip: Platform.environment['GROUPS_PREVIEW'] != '1');
}
