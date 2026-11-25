import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/repositories/album_repository_interface.dart';
import 'package:arena_soccer/features/album/domain/usecases/manage_album_usecase.dart';
import 'package:arena_soccer/features/album/presentation/bloc/manage_album_cubit.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

const _event = AlbumEventDTO(id: 'e1', title: 'Copa', teamIds: ['t1'], teams: ['Lava Jato']);
const _stickers = [
  StickerDTO(id: 'c1', number: 1, kind: StickerKind.crest, teamId: 't1', team: 'Lava Jato', imageUrl: 'crest'),
  StickerDTO(id: 's1', number: 2, name: 'Dudu', teamId: 't1', team: 'Lava Jato', playerId: 'p1', imageUrl: 'old'),
  StickerDTO(id: 's2', number: 3, name: 'Ana', teamId: 't1', team: 'Lava Jato', playerId: 'p2', imageUrl: 'same'),
  StickerDTO(id: 's3', number: 4, name: 'Rafa', teamId: 't1', team: 'Lava Jato', playerId: 'p3', imageUrl: 'keep'),
];

class _Repo implements IAlbumRepository {
  Map<String, String>? updated;

  @override
  Stream<Either<Failure, List<AlbumEventDTO>>> watchEvents() => Stream.value(const Right([_event]));

  @override
  Stream<Either<Failure, List<StickerDTO>>> watchStickers(String eventId) => Stream.value(const Right(_stickers));

  @override
  Future<Either<Failure, void>> updateStickerPhotos(
      {required String eventId, required Map<String, String> photos}) async {
    updated = photos;
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
      Stream.value(const Right([TeamDTO(id: 't1', name: 'Lava Jato')]));
}

class _Squads implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(const Right([
        PlayerDTO(id: 'p1', name: 'Dudu', team: 'Lava Jato', imageUrl: 'new'),
        PlayerDTO(id: 'p2', name: 'Ana', team: 'Lava Jato', imageUrl: 'same'),
        PlayerDTO(id: 'p3', name: 'Rafa', team: 'Lava Jato'),
      ]));
}

class _Championships implements GetSeasonChampionshipsCacheFirstUseCase {
  @override
  Future<Either<Failure, List<ChampionshipDTO>>> latest(String season, {bool force = false}) async => const Right([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('"Atualizar fotos dos atletas": só as figurinhas de atleta com foto diferente', () async {
    final repo = _Repo();
    final cubit = ManageAlbumCubit(ManageAlbumUseCase(repo, _Storage()), _Teams(), _Squads(), _Championships())
      ..watch()
      ..edit(_event);
    await Future<void>.delayed(Duration.zero);
    final states = <ManageAlbumState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.syncAthletePhotos();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    await cubit.close();
    // Escudo fica; foto igual fica; atleta sem foto não apaga a da figurinha.
    expect(repo.updated, {'s1': 'new'});
    final notice = states.whereType<NoticeManageAlbumState>().single;
    expect((notice.notice, notice.count), (ManageAlbumNotice.photosSynced, 1));
  });
}
