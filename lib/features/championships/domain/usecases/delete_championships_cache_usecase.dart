import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Apaga todo o cache de campeonatos (as gravações de campeonato já fazem
/// isso no repositório).
class DeleteChampionshipsCacheUseCase {
  final IChampionshipsRepository _repository;

  DeleteChampionshipsCacheUseCase(this._repository);

  Future<void> call() => _repository.deleteChampionshipsCache();
}
