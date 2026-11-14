import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// "Mudar região" (admin): move o card do feed para outra região (só a
/// região; o card deixa de aparecer nas outras).
class UpdateNewsRegionUseCase {
  final INewsRepository _repository;

  UpdateNewsRegionUseCase(this._repository);

  Future<Either<Failure, void>> call({required String id, required String region}) =>
      _repository.updateNewsRegion(id: id, region: region);
}
