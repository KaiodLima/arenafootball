import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

/// Arena Fantasy: a configuração por campeonato (`fantasy/{idDocCampeonato}`),
/// as rodadas, o participante, a escalação e os atletas elegíveis.
class FantasyDataSource {
  final FirebaseFirestore _firestore;

  FantasyDataSource(this._firestore);

  static const String _logName = 'FantasyDataSource';

  DocumentReference<Map<String, dynamic>> _doc(String championshipDocId) =>
      _firestore.collection(FantasyConfigDTO.collection).doc(championshipDocId);

  DocumentReference<Map<String, dynamic>> _round(String fantasyId, int round) =>
      _doc(fantasyId).collection('rodadas').doc('$round');

  /// Configuração do [championship] (sem o doc = desligado com os padrões).
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship) {
    return _doc(championship.id).snapshots().toEither(
          (doc) => FantasyConfigDTO.fromMap(doc.id, doc.data(), championship: championship),
          fallbackMessage: 'Não foi possível carregar o Arena Fantasy.',
          logName: _logName,
        );
  }

  /// Fantasy ativos da temporada [season] (selo da home; poucos docs).
  Stream<Either<Failure, List<FantasyConfigDTO>>> watchActive(String season) {
    return _firestore
        .collection(FantasyConfigDTO.collection)
        .where('ativo', isEqualTo: true)
        .where('temporada', isEqualTo: season)
        .snapshots()
        .toEither(
          (snapshot) => [for (final doc in snapshot.docs) FantasyConfigDTO.fromMap(doc.id, doc.data())],
          fallbackMessage: 'Não foi possível carregar o Arena Fantasy.',
          logName: _logName,
        );
  }

  /// Admin grava a chave, os parâmetros e as cópias do campeonato.
  Future<Either<Failure, void>> saveConfig(FantasyConfigDTO config) async {
    try {
      await _doc(config.championshipDocId).set(
        {...config.toAdminMap(), 'atualizadoEm': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      AppLogger.e('saveConfig ${config.championshipDocId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível salvar o Arena Fantasy.'));
    }
  }

  /// Rodada [round] (nula = ainda não existe).
  Stream<Either<Failure, FantasyRoundDTO?>> watchRound(String fantasyId, int round) {
    return _round(fantasyId, round).snapshots().toEither(
          (doc) => doc.exists ? FantasyRoundDTO.fromMap(doc.id, doc.data()) : null,
          fallbackMessage: 'Não foi possível carregar a rodada.',
          logName: _logName,
        );
  }

  /// Participação da conta [uid] (nula = ainda não entrou).
  Stream<Either<Failure, FantasyParticipantDTO?>> watchParticipant(String fantasyId, String uid) {
    return _doc(fantasyId).collection('participantes').doc(uid).snapshots().toEither(
          (doc) => doc.exists ? FantasyParticipantDTO.fromMap(doc.id, doc.data() ?? const {}) : null,
          fallbackMessage: 'Não foi possível carregar a sua participação.',
          logName: _logName,
        );
  }

  /// Entra no Fantasy a partir da rodada atual [currentRound] (sem pontos
  /// retroativos).
  Future<Either<Failure, void>> join(
    String fantasyId, {
    required String uid,
    required String name,
    required String photoUrl,
    required int currentRound,
  }) async {
    try {
      await _doc(fantasyId).collection('participantes').doc(uid).set({
        'uid': uid,
        'nome': name,
        'urlImagem': photoUrl,
        'entrouEm': FieldValue.serverTimestamp(),
        'rodadaInicial': currentRound,
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('join $fantasyId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível entrar no Arena Fantasy.'));
    }
  }

  /// Escalação da conta [uid] na rodada [round] (nula = ainda não montou).
  Stream<Either<Failure, FantasyLineupDTO?>> watchLineup(String fantasyId, int round, String uid) {
    return _round(fantasyId, round).collection('escalacoes').doc(uid).snapshots().toEither(
          (doc) => doc.exists ? FantasyLineupDTO.fromMap(doc.id, doc.data() ?? const {}) : null,
          fallbackMessage: 'Não foi possível carregar a sua escalação.',
          logName: _logName,
        );
  }

  /// Grava a escalação (as regras conferem prazo, vagas e inscrições).
  Future<Either<Failure, void>> saveLineup(String fantasyId, int round, FantasyLineupDTO lineup) async {
    try {
      await _round(fantasyId, round).collection('escalacoes').doc(lineup.uid).set(
        {...lineup.toOwnerMap(), 'atualizadoEm': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      AppLogger.e('saveLineup $fantasyId/$round', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível salvar a escalação.'));
    }
  }

  /// Atletas inscritos na competição: a consulta ordenada pelos gols da
  /// inscrição só traz quem tem a chave `inscricoes.c<id>` (índice automático,
  /// o mesmo do ranking por competição); fica quem tem time e posição.
  Future<Either<Failure, List<FantasyAthleteDTO>>> getEligibleAthletes(FantasyConfigDTO config) async {
    try {
      final key = PlayerEnrollment.keyOf(config.championshipId);
      final snapshot = await _firestore
          .collection(SeasonCollection.name('jogadores', config.season.isEmpty ? null : config.season))
          .orderBy('${PlayerEnrollment.field}.$key.nGols', descending: true)
          .get();
      final athletes = [
        for (final doc in snapshot.docs) FantasyAthleteDTO.of(PlayerDTO.fromFirestore(doc), config.championshipId),
      ].whereType<FantasyAthleteDTO>().toList();
      return Right(athletes);
    } catch (e) {
      AppLogger.e('getEligibleAthletes ${config.championshipDocId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar os atletas.'));
    }
  }
}
