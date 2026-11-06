import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// Pedidos "Sou organizador de campeonato" (`solicitacoes_organizador/{uid}`)
/// e os campeonatos da conta (`campeonatos` com `idOrganizador`). O usuário
/// grava o próprio pedido; o admin edita, aprova (cria o campeonato) ou rejeita.
/// `campeonatos_org/c<id_campeonato>`: {idOrganizador, idCampeonatoDoc}.
const String organizerIndexCollection = 'campeonatos_org';

class OrganizerRequestsDataSource {
  final FirebaseFirestore _firestore;

  OrganizerRequestsDataSource(this._firestore);

  static const String _logName = 'OrganizerRequestsDataSource';
  static const String _loadFallback = 'Não foi possível carregar os pedidos de organizador.';
  static const String _saveFallback = 'Não foi possível salvar o pedido de organizador.';

  CollectionReference<Map<String, dynamic>> get _requests => _firestore.collection('solicitacoes_organizador');

  CollectionReference<Map<String, dynamic>> get _championships => _firestore.collection('campeonatos');

  Stream<Either<Failure, OrganizerRequestDTO?>> watchMyRequest(String userId) {
    return _requests.doc(userId).snapshots().toEither(
          (doc) => doc.exists ? OrganizerRequestDTO.fromFirestore(doc) : null,
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Campeonatos organizados pela conta (mais novos primeiro, no app).
  Stream<Either<Failure, List<ChampionshipDTO>>> watchMyChampionships(String userId) {
    return _championships.where(ChampionshipDTO.organizerField, isEqualTo: userId).snapshots().toEither(
          (snapshot) => snapshot.docs.map(ChampionshipDTO.fromFirestore).toList()
            ..sort((a, b) => b.championshipId.compareTo(a.championshipId)),
          fallbackMessage: 'Não foi possível carregar os seus campeonatos.',
          logName: _logName,
        );
  }

  /// Envia ou reenvia: regrava o doc inteiro como pendente.
  Future<Either<Failure, void>> submit(OrganizerRequestDTO request) async {
    try {
      await _requests.doc(request.userId).set({
        ...request.toSubmitMap(),
        'data': FieldValue.serverTimestamp(),
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('submit uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> cancel(String userId) async {
    try {
      await _requests.doc(userId).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('cancel uid=$userId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Stream<Either<Failure, List<OrganizerRequestDTO>>> watchRequests() {
    return _requests.orderBy('data', descending: true).snapshots().toEither(
          (snapshot) => snapshot.docs.map(OrganizerRequestDTO.fromFirestore).toList(),
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Edição do admin antes de responder: nome, região e abrangência.
  Future<Either<Failure, void>> update(OrganizerRequestDTO request) async {
    try {
      await _requests.doc(request.userId).update({
        'nome': request.name,
        ...RegionRegistry.fieldsFor(request.region, nameKey: 'regiao'),
        'abrangencia': request.scope.key,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('update uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Cria o campeonato [championship] (com o próximo `id_campeonato`, como o
  /// cadastro do admin) e marca o pedido como aprovado, numa escrita só.
  /// Organizador: cria os índices `campeonatos_org/c<id>` que faltam nos
  /// campeonatos dele (aprovados antes do índice). 1 leitura por campeonato.
  Future<Either<Failure, int>> ensureMyIndexes(String userId, List<ChampionshipDTO> championships) async {
    try {
      var created = 0;
      for (final championship in championships) {
        if (championship.organizerId != userId || championship.championshipId <= 0) continue;
        final ref = _firestore.collection(organizerIndexCollection).doc('c${championship.championshipId}');
        if ((await ref.get()).exists) continue;
        await ref.set({'idOrganizador': userId, 'idCampeonatoDoc': championship.id});
        created++;
      }
      return Right(created);
    } catch (e) {
      AppLogger.e('ensureMyIndexes uid=$userId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível preparar os seus campeonatos.'));
    }
  }

  /// Índices do organizador que faltam (campeonatos aprovados antes do
  /// índice existir): `campeonatos_org/c<id>` de cada campeonato com
  /// `idOrganizador`. Só grava os que não existem. Devolve quantos criou.
  Future<Either<Failure, int>> ensureIndexes() async {
    try {
      final championships =
          await _championships.where(ChampionshipDTO.organizerField, isGreaterThan: '').get();
      var created = 0;
      for (final doc in championships.docs) {
        final championship = ChampionshipDTO.fromFirestore(doc);
        if (championship.organizerId.isEmpty || championship.championshipId <= 0) continue;
        final ref = _firestore.collection(organizerIndexCollection).doc('c${championship.championshipId}');
        final current = await ref.get();
        if (current.exists &&
            current.data()?['idOrganizador'] == championship.organizerId &&
            current.data()?['idCampeonatoDoc'] == doc.id) {
          continue;
        }
        await ref.set({'idOrganizador': championship.organizerId, 'idCampeonatoDoc': doc.id});
        created++;
      }
      return Right(created);
    } catch (e) {
      AppLogger.e('ensureIndexes', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível atualizar os organizadores.'));
    }
  }

  Future<Either<Failure, ChampionshipDTO>> approve({
    required OrganizerRequestDTO request,
    required ChampionshipDTO championship,
  }) async {
    try {
      final existing = await _championships.get();
      final ids = existing.docs.map((doc) => ChampionshipDTO.fromFirestore(doc).championshipId);
      final ref = _championships.doc();
      final created = championship.copyWith(
        id: ref.id,
        championshipId: ChampionshipsDataSource.nextChampionshipId(ids),
      );
      final batch = _firestore.batch()
        ..set(ref, created.toMap())
        // Índice que as regras consultam (pela chave da inscrição `c<id>`):
        // o organizador mexe nos elencos desta competição.
        ..set(_firestore.collection(organizerIndexCollection).doc('c${created.championshipId}'), {
          'idOrganizador': request.userId,
          'idCampeonatoDoc': ref.id,
        })
        ..update(_requests.doc(request.userId), {
          'status': PlayerRequestStatus.approved.key,
          'idCampeonato': ref.id,
          'temporada': created.season,
          'motivo': '',
          'atualizado_em': FieldValue.serverTimestamp(),
        });
      await batch.commit();
      return Right(created);
    } catch (e) {
      AppLogger.e('approve uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível aprovar o campeonato.'));
    }
  }

  Future<Either<Failure, void>> reject({required String userId, required String reason}) async {
    try {
      await _requests.doc(userId).update({
        'status': PlayerRequestStatus.rejected.key,
        'motivo': reason,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('reject uid=$userId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível rejeitar o pedido.'));
    }
  }
}
