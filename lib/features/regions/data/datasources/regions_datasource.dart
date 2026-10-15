import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/regions/domain/region_usage.dart';

/// Regiões (competições) cadastradas na coleção `competicao`. O id do doc é o
/// vínculo (`idRegiao` nos outros docs); o `nome` pode mudar.
class RegionsDataSource {
  final FirebaseFirestore _firestore;

  RegionsDataSource(this._firestore);

  static const String _logName = 'RegionsDataSource';
  static const String _saveFallback = 'Não foi possível salvar a região.';

  CollectionReference<Map<String, dynamic>> get _regions => _firestore.collection('competicao');

  /// Nomes das regiões. Também carrega o [RegionRegistry] (id ↔ nome), que
  /// os DTOs e as consultas usam.
  Future<Either<Failure, List<String>>> getRegions() async {
    const fallback = 'Não foi possível carregar as regiões.';
    try {
      final result = await _regions.get();
      final regions = [
        for (final doc in result.docs)
          if ((doc.data()['nome']?.toString() ?? '').isNotEmpty)
            RegionRef(id: doc.id, name: doc.data()['nome'].toString()),
      ];
      RegionRegistry.configure(regions);
      return Right(regions.map((region) => region.name).toList());
    } catch (e) {
      AppLogger.e('getRegions', name: 'RegionsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  /// Nova região (doc em `competicao`).
  Future<Either<Failure, void>> createRegion(String name) async {
    try {
      await _firestore.collection('competicao').add({'nome': name});
      return const Right(null);
    } catch (e) {
      AppLogger.e('createRegion', name: 'RegionsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível criar a região.'));
    }
  }

  /// Troca só o nome: o conteúdo aponta para o id e passa a mostrar o novo.
  Future<Either<Failure, void>> renameRegion({required String id, required String name}) async {
    try {
      await _regions.doc(id).update({'nome': name});
      return const Right(null);
    } catch (e) {
      AppLogger.e('renameRegion id=$id', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> deleteRegion(String id) async {
    try {
      await _regions.doc(id).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('deleteRegion id=$id', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível excluir a região.'));
    }
  }

  /// Conteúdo ligado à região em todas as temporadas (contagens agregadas,
  /// sem baixar os docs). Conta pelo id e pelo nome (doc ainda sem id) e fica
  /// com o maior.
  Future<Either<Failure, RegionUsage>> regionUsage({required String id, required String name}) async {
    try {
      Future<int> count(String collection) async {
        final ref = _firestore.collection(collection);
        final byName = (await ref.where(RegionRegistry.nameField, isEqualTo: name).count().get()).count ?? 0;
        if (id.isEmpty) return byName;
        final byId = (await ref.where(RegionRegistry.idField, isEqualTo: id).count().get()).count ?? 0;
        return byId > byName ? byId : byName;
      }

      Future<int> perSeason(String base) async {
        var total = 0;
        for (final season in SeasonCollection.seasons) {
          total += await count(SeasonCollection.name(base, season));
        }
        return total;
      }

      return Right(RegionUsage({
        RegionUsageKind.teams: await perSeason('times'),
        RegionUsageKind.matches: await perSeason('partidas'),
        RegionUsageKind.groups: await perSeason('grupos'),
        RegionUsageKind.news: await count('noticias'),
        RegionUsageKind.championships: await count('campeonatos'),
      }));
    } catch (e) {
      AppLogger.e('regionUsage id=$id', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível verificar o conteúdo da região.'));
    }
  }

  /// Manutenção "Vincular regiões por id": grava o `idRegiao` nos docs que só
  /// têm o nome (ou têm um id que não é de nenhuma região), casando o nome com
  /// as regiões carregadas. Pode rodar de novo: só mexe no que falta.
  Future<Either<Failure, RegionLinkReport>> linkRegions() async {
    try {
      final updated = <String, int>{};
      final unmatched = <String>{};

      Future<void> link(String collection, {String nameKey = RegionRegistry.nameField}) async {
        final docs = (await _firestore.collection(collection).get()).docs;
        final writes = <void Function(WriteBatch)>[];
        for (final doc in docs) {
          final data = doc.data();
          final currentId = data[RegionRegistry.idField]?.toString() ?? '';
          if (RegionRegistry.nameOf(currentId).isNotEmpty) continue;
          final name = data[nameKey]?.toString().trim() ?? '';
          if (name.isEmpty) continue;
          final id = RegionRegistry.idOf(name);
          if (id.isEmpty) {
            unmatched.add(name);
            continue;
          }
          writes.add((batch) => batch.update(doc.reference, {RegionRegistry.idField: id}));
        }
        await _commit(writes);
        if (writes.isNotEmpty) updated[collection] = writes.length;
      }

      await link('noticias');
      await link('campeonatos');
      for (final season in SeasonCollection.seasons) {
        for (final base in ['times', 'classificacao', 'partidas', 'grupos']) {
          await link(SeasonCollection.name(base, season));
        }
      }
      await link('solicitacoes_jogador', nameKey: 'regiao');
      await link('solicitacoes_time', nameKey: 'regiao');
      return Right(RegionLinkReport(updated: updated, unmatched: unmatched.toList()..sort()));
    } catch (e) {
      AppLogger.e('linkRegions', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível vincular as regiões.'));
    }
  }

  /// Grava em lotes (limite de 500 operações por batch do Firestore).
  Future<void> _commit(List<void Function(WriteBatch)> writes) async {
    const chunk = 450;
    for (var start = 0; start < writes.length; start += chunk) {
      final batch = _firestore.batch();
      for (final write in writes.skip(start).take(chunk)) {
        write(batch);
      }
      await batch.commit();
    }
  }
}
