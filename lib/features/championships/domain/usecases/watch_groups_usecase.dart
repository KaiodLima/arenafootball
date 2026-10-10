import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

class WatchGroupsUseCase {
  final IChampionshipsRepository _repository;

  WatchGroupsUseCase(this._repository);

  Stream<Either<Failure, List<GroupDTO>>> call({required String region, String? season}) =>
      _repository.watchGroups(region: region, season: season);
}
