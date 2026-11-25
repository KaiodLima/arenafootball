import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/event_polls/data/datasources/event_polls_datasource.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/domain/repositories/event_polls_repository_interface.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

class EventPollsRepositoryImpl implements IEventPollsRepository {
  final EventPollsDataSource _dataSource;
  final CacheStore _cache;

  EventPollsRepositoryImpl(this._dataSource, this._cache);

  @override
  Future<Either<Failure, String>> create(NewsDTO card) async => _invalidate(await _dataSource.create(card));

  @override
  Future<Either<Failure, void>> update(NewsDTO card, {required bool withOptions}) async =>
      _invalidate(await _dataSource.update(card, withOptions: withOptions));

  @override
  Future<Either<Failure, void>> close(String id) async => _invalidate(await _dataSource.close(id));

  /// Criar/editar/encerrar um evento: a lista de eventos abertos do cache
  /// fica velha.
  Future<Either<Failure, T>> _invalidate<T>(Either<Failure, T> response) async {
    if (response.isRight) await _cache.delete(CacheKeys.openEvents);
    return response;
  }

  @override
  Stream<Either<Failure, NewsDTO?>> watch(String id) => _dataSource.watch(id);

  @override
  Stream<Either<Failure, String?>> watchMyVote({required String eventId, required String userId}) =>
      _dataSource.watchMyVote(eventId: eventId, userId: userId);

  @override
  Stream<Either<Failure, EventTally>> watchTally(String eventId) => _dataSource.watchTally(eventId);

  @override
  Future<Either<Failure, void>> vote({
    required String eventId,
    required String userId,
    required String optionId,
    required String name,
  }) =>
      _dataSource.vote(eventId: eventId, userId: userId, optionId: optionId, name: name);

  @override
  Future<Either<Failure, bool>> hasVotes(String eventId) => _dataSource.hasVotes(eventId);
}
