import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Eventos de votação do admin: o card é uma notícia (`tag: "evento"`) em
/// `noticias`; os votos ficam em `noticias/{id}/votos_evento/{uid}` (um por
/// conta, criado uma vez) e a apuração em `noticias/{id}/apuracao/total`,
/// gravada só pelas functions.
class EventPollsDataSource {
  final FirebaseFirestore _firestore;

  EventPollsDataSource(this._firestore);

  static const String _news = 'noticias';
  static const String votesCollection = 'votos_evento';
  static const String _tallyCollection = 'apuracao';
  static const String _tallyId = 'total';
  static const String _loadFallback = 'Não foi possível carregar o evento.';
  static const String _saveFallback = 'Não foi possível salvar o evento.';
  static const String _voteFallback = 'Não foi possível registrar o seu voto.';

  DocumentReference<Map<String, dynamic>> _doc(String id) => _firestore.collection(_news).doc(id);

  /// Novo evento: o doc inteiro (campos de notícia legíveis no app antigo +
  /// os do evento) com a hora do servidor; devolve o id.
  Future<Either<Failure, String>> create(NewsDTO card) async {
    try {
      final ref = _firestore.collection(_news).doc();
      await ref.set({...card.copyWith(id: ref.id).toMap(), 'data': FieldValue.serverTimestamp()});
      return Right(ref.id);
    } catch (e) {
      AppLogger.e('create event', name: 'EventPollsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Edição: só os campos do card e do evento (a data e o resto ficam).
  /// [withOptions] falso (já há votos): as opções não mudam.
  Future<Either<Failure, void>> update(NewsDTO card, {required bool withOptions}) async {
    final event = card.event ?? const EventPoll();
    try {
      await _doc(card.id).update({
        'titulo': card.title,
        'descricao': card.description,
        'urlImagem': card.imageUrl,
        ...RegionRegistry.fieldsFor(card.region),
        'encerraEm': event.closesAt == null ? FieldValue.delete() : Timestamp.fromDate(event.closesAt!),
        'mostrarParcial': event.showPartial,
        if (withOptions) 'opcoes': [for (final option in event.options) option.toMap()],
        if (withOptions) 'idsOpcoes': [for (final option in event.options) option.id],
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('update event id=${card.id}', name: 'EventPollsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// "Encerrar agora" do admin.
  Future<Either<Failure, void>> close(String id) async {
    try {
      await _doc(id).update({'encerrado': true});
      return const Right(null);
    } catch (e) {
      AppLogger.e('close event id=$id', name: 'EventPollsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// O card ao vivo (encerrado/prazo mudam na tela). Apagado = nulo.
  Stream<Either<Failure, NewsDTO?>> watch(String id) {
    return _doc(id).snapshots().toEither(
          (doc) => doc.exists ? NewsDTO.fromFirestore(doc) : null,
          fallbackMessage: _loadFallback,
          logName: 'EventPollsDataSource',
        );
  }

  /// O voto da conta (id da opção); sem voto = nulo.
  Stream<Either<Failure, String?>> watchMyVote({required String eventId, required String userId}) {
    return _doc(eventId).collection(votesCollection).doc(userId).snapshots().toEither(
      (doc) {
        final data = doc.data();
        return data == null ? null : data['opcao']?.toString();
      },
      fallbackMessage: _loadFallback,
      logName: 'EventPollsDataSource',
    );
  }

  /// Apuração (só quando as regras deixam ler: parcial ligado, encerrado ou admin).
  Stream<Either<Failure, EventTally>> watchTally(String eventId) {
    return _doc(eventId).collection(_tallyCollection).doc(_tallyId).snapshots().toEither(
          (doc) => EventTally.fromMap(doc.data() ?? const {}),
          fallbackMessage: _loadFallback,
          logName: 'EventPollsDataSource',
        );
  }

  /// Voto único: cria o doc com o uid (as regras recusam o segundo).
  Future<Either<Failure, void>> vote({
    required String eventId,
    required String userId,
    required String optionId,
    required String name,
  }) async {
    try {
      await _doc(eventId).collection(votesCollection).doc(userId).set({
        'opcao': optionId,
        'nome': name,
        'uid': userId,
        'em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('vote event=$eventId', name: 'EventPollsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _voteFallback));
    }
  }

  /// Já há votos (as opções ficam travadas na edição): um doc basta.
  Future<Either<Failure, bool>> hasVotes(String eventId) async {
    try {
      final snapshot = await _doc(eventId).collection(votesCollection).limit(1).get();
      return Right(snapshot.docs.isNotEmpty);
    } catch (e) {
      AppLogger.e('hasVotes event=$eventId', name: 'EventPollsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _loadFallback));
    }
  }
}
