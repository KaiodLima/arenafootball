import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Eventos de votação abertos (não encerrados na mão), os 20 mais recentes,
/// numa leitura.
class GetOpenEventsUseCase {
  final INewsRepository _repository;

  GetOpenEventsUseCase(this._repository);

  Future<Either<Failure, List<NewsDTO>>> call() => _repository.getOpenEvents();
}

/// Eventos abertos do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedOpenEventsUseCase {
  final INewsRepository _repository;

  GetCachedOpenEventsUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<NewsDTO>>?>> call() => _repository.getCachedOpenEvents();
}

class SaveOpenEventsCacheUseCase {
  final INewsRepository _repository;

  SaveOpenEventsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(List<NewsDTO> events) => _repository.saveOpenEventsCache(events);
}

/// Eventos abertos pelo fluxo [cacheFirst] (validade [CacheTtl.openEvents]).
/// A consulta é a mesma para todas as regiões (o app filtra a região e o
/// prazo), então o cache também. Gravar notícia/evento apaga (no
/// repositório).
class GetOpenEventsCacheFirstUseCase {
  final GetOpenEventsUseCase _getEvents;
  final GetCachedOpenEventsUseCase _getCached;
  final SaveOpenEventsCacheUseCase _saveCache;

  GetOpenEventsCacheFirstUseCase(this._getEvents, this._getCached, this._saveCache);

  Stream<Either<Failure, List<NewsDTO>>> call({bool force = false}) => cacheFirst<List<NewsDTO>>(
        readCache: _getCached.call,
        fetchRemote: _getEvents.call,
        saveCache: _saveCache.call,
        ttl: CacheTtl.openEvents,
        force: force,
        logName: 'GetOpenEventsCacheFirstUseCase',
      );

  /// O valor mais novo numa leitura só.
  Future<Either<Failure, List<NewsDTO>>> latest({bool force = false}) => call(force: force).last;
}
