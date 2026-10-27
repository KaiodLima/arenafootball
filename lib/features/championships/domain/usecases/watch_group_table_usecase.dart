import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_table_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Tabela do grupo calculada pelas functions (nula = grupo sem tabela automática).
class WatchGroupTableUseCase {
  final IChampionshipsRepository _repository;

  WatchGroupTableUseCase(this._repository);

  Stream<Either<Failure, GroupTableDTO?>> call({required String groupId, String? season}) =>
      _repository.watchGroupTable(groupId: groupId, season: season);
}
