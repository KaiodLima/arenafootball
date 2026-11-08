import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/share_art/domain/usecases/prepare_result_art_usecase.dart';

final _sl = GetIt.instance;

/// Cards compartilháveis: só leitura (dados pelos caches de times e
/// campeonatos); o cubit fica na rota.
void registerShareArtDependencies() {
  _sl.registerLazySingleton(() => PrepareResultArtUseCase(_sl(), _sl()));
}
