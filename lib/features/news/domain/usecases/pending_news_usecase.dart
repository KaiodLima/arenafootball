import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/pending_news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Notícias do parceiro além do limite do dia (`noticias_pendentes`): o
/// parceiro acompanha e apaga as dele; o admin aprova (publica) ou rejeita.
/// O envio é pelo `CreateNewsUseCase` (`forApproval`), que sobe as imagens.
class PendingNewsUseCase {
  final INewsRepository _repository;

  PendingNewsUseCase(this._repository);

  Stream<Either<Failure, List<PendingNewsDTO>>> watchMine(String authorId) => _repository.watchMyPendingNews(authorId);

  Stream<Either<Failure, List<PendingNewsDTO>>> watchPending() => _repository.watchPendingNews();

  Future<Either<Failure, void>> approve(PendingNewsDTO pending) => _repository.approvePendingNews(pending);

  Future<Either<Failure, void>> reject(String id, {String reason = ''}) =>
      _repository.rejectPendingNews(id: id, reason: reason);

  Future<Either<Failure, void>> delete(String id) => _repository.deletePendingNews(id);
}
