import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/domain/repositories/event_polls_repository_interface.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Lado do torcedor: o evento ao vivo, o voto da conta, a apuração e votar
/// (e o "Encerrar agora" do admin, na mesma tela).
class EventPollUseCase {
  final IEventPollsRepository _repository;

  EventPollUseCase(this._repository);

  Stream<Either<Failure, NewsDTO?>> watch(String id) => _repository.watch(id);

  Stream<Either<Failure, String?>> watchMyVote({required String eventId, required String userId}) =>
      _repository.watchMyVote(eventId: eventId, userId: userId);

  Stream<Either<Failure, EventTally>> watchTally(String eventId) => _repository.watchTally(eventId);

  Future<Either<Failure, void>> vote({
    required String eventId,
    required String userId,
    required String optionId,
    required String name,
  }) =>
      _repository.vote(eventId: eventId, userId: userId, optionId: optionId, name: name);

  Future<Either<Failure, void>> close(String id) => _repository.close(id);
}
