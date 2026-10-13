import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/team_links.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

class SeasonsDataSource {
  final FirebaseFirestore _firestore;

  SeasonsDataSource(this._firestore);

  static const String _logName = 'SeasonsDataSource';

  /// Limite de escritas por batch do Firestore (500), com folga.
  static const int _batchSize = 400;

  DocumentReference<Map<String, dynamic>> get _config => _firestore.doc('config/temporadas');

  /// Config de temporadas; nulo se ainda não foi criada (app usa o padrão).
  Future<Either<Failure, SeasonsConfigDTO?>> getConfig() async {
    try {
      final doc = await _config.get();
      return Right(doc.exists ? SeasonsConfigDTO.fromFirestore(doc) : null);
    } catch (e) {
      AppLogger.e('getConfig', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar as temporadas.'));
    }
  }

  /// Abre a temporada [season]. Com [copyTeamsFrom], copia os times dessa
  /// temporada para a nova (e cria a linha zerada da classificação de cada
  /// um). Por último troca a atual na config: se a cópia falhar no meio, a
  /// temporada em uso não muda.
  Future<Either<Failure, SeasonsConfigDTO>> startSeason({
    required String season,
    required List<String> seasons,
    String? copyTeamsFrom,
  }) async {
    try {
      if (copyTeamsFrom != null) {
        final teams = await _firestore.collection(SeasonCollection.name('times', copyTeamsFrom)).get();
        final newTeams = _firestore.collection(SeasonCollection.name('times', season));
        final newStandings = _firestore.collection(SeasonCollection.name('classificacao', season));
        final docs = teams.docs.map(TeamDTO.fromFirestore).toList();
        for (var i = 0; i < docs.length; i += _batchSize ~/ 2) {
          final batch = _firestore.batch();
          for (final team in docs.skip(i).take(_batchSize ~/ 2)) {
            batch
              ..set(newTeams.doc(team.id), team.toMap())
              ..set(newStandings.doc(team.id), team.toStandingsMap());
          }
          await batch.commit();
        }
      }
      final config = SeasonsConfigDTO(current: season, seasons: ({...seasons, season}.toList()..sort()));
      await _config.set(config.toMap());
      return Right(config);
    } catch (e) {
      AppLogger.e('startSeason season=$season', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível iniciar a temporada.'));
    }
  }

  /// Manutenção "Vincular times por id" da temporada [season]: grava o id do
  /// time ao lado do nome onde ainda falta (jogadores, partidas, grupos,
  /// campeonatos e pedidos "Sou jogador" da temporada, cards de gol e, na
  /// temporada atual, o time do coração das contas) e copia os votos antigos
  /// (`melhorjogador{timeC}{timeF}`) para `partidas{ano}/{id}/votos`. Só
  /// completa o que falta: rodar de novo não muda nada.
  Future<Either<Failure, TeamLinkReport>> linkTeams(String season) async {
    try {
      final isCurrent = season == SeasonCollection.currentSeason;
      final teams = await _firestore.collection(SeasonCollection.name('times', season)).get();
      final linker = TeamLinker(TeamDirectory(teams.docs.map(TeamDTO.fromFirestore)));
      final writes = <void Function(WriteBatch batch)>[];
      final updated = <TeamLinkTarget, int>{};

      void plan(
        TeamLinkTarget target,
        Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
        Map<String, dynamic> Function(Map<String, dynamic> data) changes,
      ) {
        for (final doc in docs) {
          final update = changes(doc.data());
          if (update.isEmpty) continue;
          writes.add((batch) => batch.update(doc.reference, update));
          updated[target] = (updated[target] ?? 0) + 1;
        }
      }

      final players = await _firestore.collection(SeasonCollection.name('jogadores', season)).get();
      plan(TeamLinkTarget.players, players.docs, (d) => linker.missingIds(d, TeamLinkFields.players));

      final matches = await _firestore.collection(SeasonCollection.name('partidas', season)).get();
      plan(TeamLinkTarget.matches, matches.docs, (d) => linker.missingIds(d, TeamLinkFields.matches));

      final groups = await _firestore.collection(SeasonCollection.name('grupos', season)).get();
      plan(TeamLinkTarget.groups, groups.docs, (d) => linker.missingIds(d, TeamLinkFields.groups));

      final championships = await _firestore.collection('campeonatos').where('ano', isEqualTo: season).get();
      plan(TeamLinkTarget.championships, championships.docs, linker.championshipIds);

      final requests = await _firestore.collection('solicitacoes_jogador').where('temporada', isEqualTo: season).get();
      plan(TeamLinkTarget.playerRequests, requests.docs, (d) => linker.missingIds(d, TeamLinkFields.playerRequests));

      // Cards de gol: os da temporada; sem temporada gravada, contam na atual.
      final goals = await _firestore.collection('noticias').where('tag', isEqualTo: 'gol').get();
      plan(
        TeamLinkTarget.goalCards,
        goals.docs.where((doc) {
          final cardSeason = doc.data()['temporada']?.toString() ?? '';
          return cardSeason == season || (cardSeason.isEmpty && isCurrent);
        }),
        (d) => linker.missingIds(d, TeamLinkFields.goalCards),
      );

      // Time do coração: escolhido entre os times da temporada atual.
      if (isCurrent) {
        final users = await _firestore.collection('usuarios').get();
        plan(TeamLinkTarget.users, users.docs, (d) => linker.missingIds(d, TeamLinkFields.users));
      }

      // Votos antigos: a coleção não tem temporada, então só copia quando o
      // confronto aparece uma vez na temporada e a partida ainda não tem votos.
      final pairs = <String, int>{};
      String pairOf(Map<String, dynamic> data) => '${data['timeC'] ?? ''}${data['timeF'] ?? ''}';
      for (final doc in matches.docs) {
        pairs.update(pairOf(doc.data()), (n) => n + 1, ifAbsent: () => 1);
      }
      var votesCopied = 0;
      final skippedVotes = <String>[];
      for (final match in matches.docs) {
        final data = match.data();
        final home = data['timeC']?.toString() ?? '';
        final away = data['timeF']?.toString() ?? '';
        // Nome vazio ou com "/" não forma nome de coleção válido.
        if (home.isEmpty || away.isEmpty || '$home$away'.contains('/')) continue;
        final legacy = await _firestore.collection('melhorjogador$home$away').get();
        if (legacy.docs.isEmpty) continue;
        if (pairs[pairOf(data)]! > 1) {
          skippedVotes.add('$home × $away');
          continue;
        }
        final votes = match.reference.collection('votos');
        if ((await votes.limit(1).get()).docs.isNotEmpty) continue;
        for (final vote in legacy.docs) {
          final voteData = vote.data();
          final copy = {
            'nome': voteData['nome']?.toString() ?? '',
            'time': voteData['time']?.toString() ?? '',
            ...linker.missingIds(voteData, TeamLinkFields.votes),
          };
          writes.add((batch) => batch.set(votes.doc(vote.id), copy));
          votesCopied++;
        }
      }

      for (var i = 0; i < writes.length; i += _batchSize) {
        final batch = _firestore.batch();
        for (final write in writes.skip(i).take(_batchSize)) {
          write(batch);
        }
        await batch.commit();
      }
      return Right(TeamLinkReport(
        updated: updated,
        votesCopied: votesCopied,
        unmatched: linker.unmatched,
        ambiguous: linker.ambiguous,
        skippedVotes: (skippedVotes.toSet().toList()..sort()),
      ));
    } catch (e) {
      AppLogger.e('linkTeams season=$season', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível vincular os times.'));
    }
  }
}
