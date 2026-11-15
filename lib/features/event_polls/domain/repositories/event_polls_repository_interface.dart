import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

abstract class IEventPollsRepository {
  Future<Either<Failure, String>> create(NewsDTO card);

  Future<Either<Failure, void>> update(NewsDTO card, {required bool withOptions});

  Future<Either<Failure, void>> close(String id);

  Stream<Either<Failure, NewsDTO?>> watch(String id);

  Stream<Either<Failure, String?>> watchMyVote({required String eventId, required String userId});

  Stream<Either<Failure, EventTally>> watchTally(String eventId);

  Future<Either<Failure, void>> vote({
    required String eventId,
    required String userId,
    required String optionId,
    required String name,
  });

  Future<Either<Failure, bool>> hasVotes(String eventId);
}
