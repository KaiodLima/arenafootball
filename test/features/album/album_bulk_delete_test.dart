import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/repositories/album_repository_interface.dart';
import 'package:arena_soccer/features/album/domain/usecases/manage_album_usecase.dart';
import 'package:arena_soccer/features/album/presentation/bloc/manage_album_cubit.dart';
import 'package:arena_soccer/features/album/presentation/page/manage_album_page.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _event = AlbumEventDTO(id: 'e1', title: 'Copa 2026', teamIds: ['t1', 't2'], teams: ['Lava Jato', 'Volta']);
const _stickers = [
  StickerDTO(id: 's1', number: 1, name: 'Dudu', teamId: 't1', team: 'Lava Jato', order: 1),
  StickerDTO(id: 's2', number: 2, name: 'Ana', teamId: 't1', team: 'Lava Jato', order: 2),
  StickerDTO(id: 's3', number: 3, name: 'Rafa', teamId: 't2', team: 'Volta', order: 1),
];

class _Repo implements IAlbumRepository {
  final deletedBatches = <List<String>>[];
  var renumbers = 0;

  @override
  Stream<Either<Failure, List<AlbumEventDTO>>> watchEvents() => Stream.value(const Right([_event]));

  @override
  Stream<Either<Failure, List<StickerDTO>>> watchStickers(String eventId) => Stream.value(const Right(_stickers));

  @override
  Future<Either<Failure, void>> deleteStickers({required String eventId, required List<String> stickerIds}) async {
    deletedBatches.add(stickerIds);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveStickers({required String eventId, required List<StickerDTO> stickers}) async {
    renumbers++;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Storage implements StorageUploadService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Teams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.value(const Right([TeamDTO(id: 't1', name: 'Lava Jato'), TeamDTO(id: 't2', name: 'Volta')]));
}

class _Squads implements WatchTeamPlayersUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Championships implements GetSeasonChampionshipsUseCase {
  @override
  Future<Either<Failure, List<ChampionshipDTO>>> call(String season) async => const Right([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Region extends Cubit<RegionState> implements RegionCubit {
  _Region() : super(const RegionState(regions: ['Floresta'], selectedRegion: 'Floresta'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Repo repo;
  late ManageAlbumCubit cubit;

  setUp(() {
    repo = _Repo();
    cubit = ManageAlbumCubit(ManageAlbumUseCase(repo, _Storage()), _Teams(), _Squads(), _Championships());
  });

  tearDown(() => cubit.close());

  test('use case: apaga as marcadas numa chamada só', () async {
    final useCase = ManageAlbumUseCase(repo, _Storage());
    final response = await useCase.deleteStickers(_event, _stickers.take(2).toList());
    expect(response.isRight, isTrue);
    expect(repo.deletedBatches, [
      ['s1', 's2'],
    ]);
  });

  test('cubit: aviso com a contagem', () async {
    cubit
      ..watch()
      ..edit(_event);
    await Future<void>.delayed(Duration.zero);
    final notices = <ManageAlbumState>[];
    final sub = cubit.stream.listen(notices.add);
    await cubit.deleteStickers(_stickers.take(2).toList());
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    final notice = notices.whereType<NoticeManageAlbumState>().single;
    expect((notice.notice, notice.count), (ManageAlbumNotice.stickersDeleted, 2));
  });

  Future<void> pumpEditor(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<ManageAlbumCubit>.value(value: cubit),
        BlocProvider<RegionCubit>(create: (_) => _Region()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: ManageAlbumPage(),
      ),
    ));
    await tester.pumpAndSettle();
    cubit.edit(_event);
    await tester.pumpAndSettle();
  }

  testWidgets('segurar seleciona; tocar marca outra; excluir confirma e apaga as marcadas', (tester) async {
    await pumpEditor(tester);
    expect(find.textContaining('selecionada'), findsNothing);
    await tester.longPress(find.byKey(const ValueKey('album-sticker-s1')));
    await tester.pumpAndSettle();
    expect(find.text('1 selecionada'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('album-sticker-s2')));
    await tester.pumpAndSettle();
    expect(find.text('2 selecionadas'), findsOneWidget);
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir 2 figurinhas?'), findsOneWidget);
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    expect(repo.deletedBatches.single, unorderedEquals(['s1', 's2']));
    expect(find.textContaining('selecionada'), findsNothing);
  });

  testWidgets('"Selecionar todas" do time e "Cancelar" sai sem excluir', (tester) async {
    await pumpEditor(tester);
    await tester.longPress(find.byKey(const ValueKey('album-sticker-s1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selecionar todas').last);
    await tester.pumpAndSettle();
    expect(find.text('2 selecionadas'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('selecionada'), findsNothing);
    expect(repo.deletedBatches, isEmpty);
  });
}
