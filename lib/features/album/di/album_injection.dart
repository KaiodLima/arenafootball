import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/album/data/datasources/album_datasource.dart';
import 'package:arena_soccer/features/album/data/repositories/album_repository_impl.dart';
import 'package:arena_soccer/features/album/domain/repositories/album_repository_interface.dart';
import 'package:arena_soccer/features/album/domain/usecases/album_usecase.dart';
import 'package:arena_soccer/features/album/domain/usecases/manage_album_usecase.dart';

final _sl = GetIt.instance;

void registerAlbumDependencies() {
  // DataSource
  _sl.registerLazySingleton<AlbumDataSource>(() => AlbumDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IAlbumRepository>(() => AlbumRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => AlbumUseCase(_sl()));
  _sl.registerLazySingleton(() => ManageAlbumUseCase(_sl(), _sl()));
}
