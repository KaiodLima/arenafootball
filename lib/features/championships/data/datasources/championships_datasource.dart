import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';

class ChampionshipsDataSource {
  final FirebaseFirestore _firestore;

  ChampionshipsDataSource(this._firestore);

  static const String _logName = 'ChampionshipsDataSource';

  /// Campeonatos da região (sem região: todos). A coleção `campeonatos` não
  /// é separada por temporada.
  Stream<Either<Failure, List<ChampionshipDTO>>> watchChampionships({String? region}) {
    Query<Map<String, dynamic>> query = _firestore.collection('campeonatos');
    // Também os intermunicipais com time da região (`idsRegioes`).
    if (region != null) {
      query = RegionRegistry.whereRegionOrIn(query, region, listField: ChampionshipDTO.regionIdsField);
    }
    return query.snapshots().toEither(
          (snapshot) => snapshot.docs.map(ChampionshipDTO.fromFirestore).toList(),
          fallbackMessage: 'Não foi possível carregar as competições.',
          logName: _logName,
        );
  }

  Stream<Either<Failure, List<GroupDTO>>> watchGroups({required String region, String? season}) {
    return RegionRegistry.where(_firestore.collection(SeasonCollection.name('grupos', season)), region)
        .snapshots()
        .toEither(
          (snapshot) => snapshot.docs.map(GroupDTO.fromFirestore).toList(),
          fallbackMessage: 'Não foi possível carregar os grupos.',
          logName: _logName,
        );
  }

  /// Classificação de um grupo. Mesma consulta do app antigo (dois `where` +
  /// dois `orderBy`), para continuar usando os índices compostos existentes.
  Stream<Either<Failure, List<StandingDTO>>> watchStandings({
    required String region,
    required String group,
    String? season,
  }) {
    return RegionRegistry.where(_firestore.collection(SeasonCollection.name('classificacao', season)), region)
        .where('fk_grupo', isEqualTo: group)
        .orderBy('pontos', descending: true)
        .orderBy('saldo_gols', descending: true)
        .snapshots()
        .toEither(
          (snapshot) => snapshot.docs.map(StandingDTO.fromFirestore).toList(),
          fallbackMessage: 'Não foi possível carregar a classificação.',
          logName: _logName,
        );
  }

  CollectionReference<Map<String, dynamic>> get _championships => _firestore.collection('campeonatos');

  static const String _saveFallback = 'Não foi possível salvar o campeonato.';

  /// Cria o campeonato com o próximo `id_campeonato` (maior existente + 1).
  Future<Either<Failure, ChampionshipDTO>> createChampionship(ChampionshipDTO championship) async {
    try {
      final existing = await _championships.get();
      final ids = existing.docs.map((doc) => ChampionshipDTO.fromFirestore(doc).championshipId);
      final next = nextChampionshipId(ids);
      final ref = _championships.doc();
      final created = championship.copyWith(id: ref.id, championshipId: next);
      await ref.set(created.toMap());
      return Right(created);
    } catch (e) {
      AppLogger.e('createChampionship', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Próximo número de campeonato: maior existente + 1 (1 se não houver).
  static int nextChampionshipId(Iterable<int> ids) => ids.fold(0, (max, id) => id > max ? id : max) + 1;

  /// Regrava o campeonato mantendo o `id_campeonato` (as partidas apontam para ele).
  Future<Either<Failure, ChampionshipDTO>> updateChampionship(ChampionshipDTO championship) async {
    try {
      await _championships.doc(championship.id).set(championship.toMap());
      return Right(championship);
    } catch (e) {
      AppLogger.e('updateChampionship id=${championship.id}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Competições da temporada [season] (`ano`), de todas as regiões.
  Future<Either<Failure, List<ChampionshipDTO>>> getSeasonChampionships(String season) async {
    try {
      final result = await _championships.where('ano', isEqualTo: season).get();
      final list = result.docs.map(ChampionshipDTO.fromFirestore).toList()
        ..sort((a, b) => a.championshipId.compareTo(b.championshipId));
      return Right(list);
    } catch (e) {
      AppLogger.e('getSeasonChampionships season=$season', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar os campeonatos.'));
    }
  }

  /// Código da recusa: campeonato municipal de outra região.
  static const String outsideRegionCode = 'championship-outside-region';

  /// Inscreve ([enrolled]) ou tira o [team] do campeonato [championshipDocId],
  /// numa transação (lê o doc e regrava `times`/`ids_times` alinhados e
  /// `idsRegioes`).
  Future<Either<Failure, ChampionshipDTO>> setTeamEnrollment({
    required String championshipDocId,
    required TeamDTO team,
    required bool enrolled,
  }) async {
    try {
      final ref = _championships.doc(championshipDocId);
      final updated = await _firestore.runTransaction<ChampionshipDTO?>((tx) async {
        final current = ChampionshipDTO.fromFirestore(await tx.get(ref));
        final next = withTeam(current, team, enrolled: enrolled);
        if (next == null) return null;
        tx.update(ref, {
          'times': next.teams,
          'ids_times': next.teamIds,
          ChampionshipDTO.regionIdsField: next.regionIds,
        });
        return next;
      });
      if (updated == null) {
        return Left(
            ErrorWithMessage('Campeonato municipal só aceita times da própria região.', code: outsideRegionCode));
      }
      return Right(updated);
    } catch (e) {
      AppLogger.e('setTeamEnrollment id=$championshipDocId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// O campeonato com o [team] incluído ou tirado: `times`/`ids_times` ficam
  /// alinhados e `idsRegioes` ganha a região do time (ao tirar, as regiões
  /// ficam: sem os outros times à mão, não dá para saber se alguma esvaziou).
  /// Nulo = municipal de outra região (recusado).
  static ChampionshipDTO? withTeam(ChampionshipDTO championship, TeamDTO team, {required bool enrolled}) {
    bool same(int i) {
      final id = i < championship.teamIds.length ? championship.teamIds[i] : '';
      return sameTeam(idA: id, nameA: championship.teams[i], idB: team.id, nameB: team.name);
    }

    final names = <String>[];
    final ids = <String>[];
    for (var i = 0; i < championship.teams.length; i++) {
      if (same(i)) continue;
      names.add(championship.teams[i]);
      ids.add(i < championship.teamIds.length ? championship.teamIds[i] : '');
    }
    if (!enrolled) return championship.copyWith(teams: names, teamIds: ids);

    final homeRegion = championship.region.trim().toLowerCase();
    if (!championship.isIntermunicipal && team.region.trim().toLowerCase() != homeRegion) return null;
    final regionIds = {
      ...championship.regionIds,
      RegionRegistry.idOf(championship.region),
      RegionRegistry.idOf(team.region)
    }..remove('');
    return championship.copyWith(
      teams: [...names, team.name],
      teamIds: [...ids, team.id],
      regionIds: regionIds.toList(),
    );
  }

  /// Apaga só o campeonato (partidas, grupos e classificação continuam).
  Future<Either<Failure, void>> deleteChampionship(String id) async {
    try {
      await _championships.doc(id).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('deleteChampionship id=$id', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível excluir o campeonato.'));
    }
  }

  /// Campeonatos da região na temporada (`ano`), do mais antigo (menor
  /// `id_campeonato`) para o mais novo.
  Future<Either<Failure, List<ChampionshipDTO>>> getRegionChampionships({
    required String region,
    required String season,
  }) async {
    try {
      final result =
          await RegionRegistry.whereRegionOrIn(_championships, region, listField: ChampionshipDTO.regionIdsField).get();
      final list = result.docs.map(ChampionshipDTO.fromFirestore).where((c) => c.season == season).toList()
        ..sort((a, b) => a.championshipId.compareTo(b.championshipId));
      return Right(list);
    } catch (e) {
      AppLogger.e('getRegionChampionships region=$region', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar os campeonatos.'));
    }
  }

  /// Campeonato da região na temporada (`ano`); nulo se não houver.
  Future<Either<Failure, ChampionshipDTO?>> getChampionshipForRegion({
    required String region,
    required String season,
  }) async {
    try {
      final result =
          await RegionRegistry.whereRegionOrIn(_championships, region, listField: ChampionshipDTO.regionIdsField).get();
      final list = result.docs.map(ChampionshipDTO.fromFirestore).toList();
      return Right(pickChampionshipForSeason(list, season));
    } catch (e) {
      AppLogger.e('getChampionshipForRegion region=$region', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar o campeonato.'));
    }
  }

  /// O da temporada; sem ele, nulo (quem chama decide o que fazer).
  static ChampionshipDTO? pickChampionshipForSeason(List<ChampionshipDTO> championships, String season) {
    for (final championship in championships) {
      if (championship.season == season) return championship;
    }
    return null;
  }
}
