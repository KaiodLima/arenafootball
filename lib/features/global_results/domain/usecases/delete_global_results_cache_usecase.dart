import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';

/// Apaga o cache dos resultados pelo mundo (lista dos dias e gols).
class DeleteGlobalResultsCacheUseCase {
  final IGlobalResultsRepository _repository;

  DeleteGlobalResultsCacheUseCase(this._repository);

  Future<void> call() => _repository.deleteGlobalResultsCache();
}
