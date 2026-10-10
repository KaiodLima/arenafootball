import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
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
    if (region != null) query = query.where('fk_competicao', isEqualTo: region);
    return query.snapshots().toEither(
          (snapshot) => snapshot.docs.map(ChampionshipDTO.fromFirestore).toList(),
          fallbackMessage: 'Não foi possível carregar as competições.',
          logName: _logName,
        );
  }

  Stream<Either<Failure, List<GroupDTO>>> watchGroups({required String region, String? season}) {
    return _firestore
        .collection(SeasonCollection.name('grupos', season))
        .where('fk_competicao', isEqualTo: region)
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
    return _firestore
        .collection(SeasonCollection.name('classificacao', season))
        .where('fk_competicao', isEqualTo: region)
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
}
