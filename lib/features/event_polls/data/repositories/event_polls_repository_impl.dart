import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/event_polls/data/datasources/event_polls_datasource.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/domain/repositories/event_polls_repository_interface.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

class EventPollsRepositoryImpl implements IEventPollsRepository {
  final EventPollsDataSource _dataSource;

  EventPollsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, String>> create(NewsDTO card) => _dataSource.create(card);

  @override
  Future<Either<Failure, void>> update(NewsDTO card, {required bool withOptions}) =>
      _dataSource.update(card, withOptions: withOptions);

  @override
  Future<Either<Failure, void>> close(String id) => _dataSource.close(id);

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
