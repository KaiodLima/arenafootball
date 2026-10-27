import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Admin: pede às functions que refaçam as tabelas dos grupos do campeonato.
class RequestTablesRecomputeUseCase {
  final IChampionshipsRepository _repository;

  RequestTablesRecomputeUseCase(this._repository);

  Future<Either<Failure, void>> call(String championshipDocId) => _repository.requestTablesRecompute(championshipDocId);
}
