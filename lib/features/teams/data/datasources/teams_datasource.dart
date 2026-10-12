import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

class TeamsDataSource {
  final FirebaseFirestore _firestore;

  TeamsDataSource(this._firestore);

  static const String _fallback = 'Não foi possível carregar os times.';

  Query<Map<String, dynamic>> _teamsQuery({String? region, String? season}) {
    Query<Map<String, dynamic>> query = _firestore.collection(SeasonCollection.name('times', season));
    if (region != null) query = query.where('fk_competicao', isEqualTo: region);
    return query;
  }

  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season}) async {
    try {
      final result = await _teamsQuery(region: region, season: season).get();
      return Right(result.docs.map(TeamDTO.fromFirestore).toList());
    } catch (e) {
      AppLogger.e('getTeams region=$region season=$season', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _fallback));
    }
  }

  Future<Either<Failure, TeamDTO?>> getTeamByName(String name) async {
    try {
      final result = await _firestore.collection(SeasonCollection.name('times', null)).where('nome', isEqualTo: name).limit(1).get();
      return Right(result.docs.isEmpty ? null : TeamDTO.fromFirestore(result.docs.first));
    } catch (e) {
      AppLogger.e('getTeamByName name=$name', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _fallback));
    }
  }

  /// Total de times da temporada, de todas as regiões (base do número
  /// sequencial do id de um time novo).
  Future<Either<Failure, int>> countTeams({String? season}) async {
    try {
      final result = await _firestore.collection(SeasonCollection.name('times', season)).get();
      return Right(result.docs.length);
    } catch (e) {
      AppLogger.e('countTeams season=$season', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _fallback));
    }
  }

  /// Grava o time em `times` e a linha zerada dele em `classificacao`, ambos
  /// com o id do time como id do documento. Num batch, para não sobrar um
  /// sem o outro.
  Future<Either<Failure, void>> createTeam(TeamDTO team, {String? season}) async {
    try {
      final batch = _firestore.batch();
      batch.set(_firestore.collection(SeasonCollection.name('times', season)).doc(team.id), team.toMap());
      batch.set(
        _firestore.collection(SeasonCollection.name('classificacao', season)).doc(team.id),
        team.toStandingsMap(),
      );
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('createTeam id=${team.id}', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível cadastrar o time.'));
    }
  }

  Stream<Either<Failure, List<TeamDTO>>> watchTeams({String? region, String? season}) {
    return _teamsQuery(region: region, season: season).snapshots().toEither(
          (snapshot) => snapshot.docs.map(TeamDTO.fromFirestore).toList(),
          fallbackMessage: _fallback,
          logName: 'TeamsDataSource',
        );
  }

  /// Time pelo id na temporada; nulo se não existir.
  Future<Either<Failure, TeamDTO?>> getTeam({required String id, String? season}) async {
    try {
      final doc = await _firestore.collection(SeasonCollection.name('times', season)).doc(id).get();
      return Right(doc.exists ? TeamDTO.fromFirestore(doc) : null);
    } catch (e) {
      AppLogger.e('getTeam id=$id', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _fallback));
    }
  }

  /// Escudo, descrição e cores (o que o dono pode mudar), no time e na linha
  /// da classificação, juntos.
  Future<Either<Failure, void>> updateTeamDetails({
    required String id,
    required String description,
    required String imageUrl,
    String primaryColor = '',
    String secondaryColor = '',
    String? season,
  }) async {
    try {
      final data = {
        'descricao': description,
        'urlImagem': imageUrl,
        'corPrimaria': primaryColor,
        'corSecundaria': secondaryColor,
      };
      final batch = _firestore.batch()
        ..update(_firestore.collection(SeasonCollection.name('times', season)).doc(id), data)
        ..update(_firestore.collection(SeasonCollection.name('classificacao', season)).doc(id), data);
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('updateTeamDetails id=$id', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível salvar o time.'));
    }
  }

  /// Limite de escritas por batch do Firestore (500), com folga.
  static const int _batchSize = 400;

  /// Exclui o time da temporada [season] (nulo = atual):
  /// - jogadores do elenco: com conta vinculada ficam sem time (mantêm os
  ///   números); os sem vínculo são apagados;
  /// - pedidos "Sou jogador" da temporada para o time: aprovados viram
  ///   "removido", pendentes são rejeitados;
  /// - na temporada atual, o registro de dono (`solicitacoes_time`) é apagado;
  /// - o nome sai dos times participantes dos campeonatos da temporada;
  /// - por último, o time e a linha da classificação.
  /// Partidas, notícias e grupos ficam como estão (histórico).
  Future<Either<Failure, void>> deleteTeam(TeamDTO team, {String? season}) async {
    try {
      final seasonKey = (season == null || season.isEmpty) ? SeasonCollection.currentSeason : season;
      final writes = <void Function(WriteBatch batch)>[];

      final players = await _firestore
          .collection(SeasonCollection.name('jogadores', season))
          .where('time', isEqualTo: team.name)
          .get();
      for (final doc in players.docs) {
        final linked = (doc.data()['idUsuario']?.toString() ?? '').isNotEmpty;
        writes.add((batch) => linked ? batch.update(doc.reference, {'time': ''}) : batch.delete(doc.reference));
      }

      final requests = await _firestore.collection('solicitacoes_jogador').where('time', isEqualTo: team.name).get();
      for (final doc in requests.docs) {
        final data = doc.data();
        if (data['temporada']?.toString() != seasonKey) continue;
        final status = data['status']?.toString();
        if (status == 'aprovada') {
          writes.add((batch) => batch.update(doc.reference, {
                'status': 'removido',
                'motivo': '',
                'atualizado_em': FieldValue.serverTimestamp(),
              }));
        } else if (status == 'pendente') {
          writes.add((batch) => batch.update(doc.reference, {
                'status': 'rejeitada',
                'motivo': 'Time excluído',
                'atualizado_em': FieldValue.serverTimestamp(),
              }));
        }
      }

      // O dono é do time da temporada atual (times copiados mantêm o id).
      if (seasonKey == SeasonCollection.currentSeason) {
        final owners = await _firestore.collection('solicitacoes_time').where('idTime', isEqualTo: team.id).get();
        for (final doc in owners.docs) {
          writes.add((batch) => batch.delete(doc.reference));
        }
      }

      final championships =
          await _firestore.collection('campeonatos').where('times', arrayContains: team.name).get();
      for (final doc in championships.docs) {
        if (doc.data()['ano']?.toString() != seasonKey) continue;
        writes.add((batch) => batch.update(doc.reference, {
              'times': FieldValue.arrayRemove([team.name]),
            }));
      }

      writes
        ..add((batch) => batch.delete(_firestore.collection(SeasonCollection.name('times', season)).doc(team.id)))
        ..add((batch) =>
            batch.delete(_firestore.collection(SeasonCollection.name('classificacao', season)).doc(team.id)));

      for (var i = 0; i < writes.length; i += _batchSize) {
        final batch = _firestore.batch();
        for (final write in writes.skip(i).take(_batchSize)) {
          write(batch);
        }
        await batch.commit();
      }
      return const Right(null);
    } catch (e) {
      AppLogger.e('deleteTeam id=${team.id}', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível excluir o time.'));
    }
  }
}
