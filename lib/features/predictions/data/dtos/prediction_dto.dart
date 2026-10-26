import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Palpite de placar da conta numa partida (`partidas{ano}/{id}/palpites/{uid}`).
/// Depois da partida, as functions gravam [points], [exact] e [valid].
class PredictionDTO extends Equatable {
  final String uid;
  final int home;
  final int away;
  final String name;

  /// Pontos ganhos (nulo enquanto a partida não foi pontuada).
  final int? points;
  final bool exact;

  /// Falso = feito depois do prazo (vale 0).
  final bool? valid;

  const PredictionDTO({
    required this.uid,
    required this.home,
    required this.away,
    this.name = '',
    this.points,
    this.exact = false,
    this.valid,
  });

  bool get scored => valid != null;

  static int _int(Object? value) => value is num ? value.toInt() : 0;

  factory PredictionDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return PredictionDTO(
      uid: doc.id,
      home: _int(data['golsCasa']),
      away: _int(data['golsFora']),
      name: data['nome']?.toString() ?? '',
      points: data['pontos'] is num ? (data['pontos'] as num).toInt() : null,
      exact: data['exato'] == true,
      valid: data['valido'] is bool ? data['valido'] as bool : null,
    );
  }

  @override
  List<Object?> get props => [uid, home, away, name, points, exact, valid];
}

/// Linha do ranking do bolão (`palpites_ranking{ano}/{idRegiao}_{uid}`, gravado pelas functions).
class PredictionRankingEntry extends Equatable {
  final String uid;
  final String name;
  final int points;
  final int exact;
  final int count;

  const PredictionRankingEntry({
    required this.uid,
    required this.name,
    this.points = 0,
    this.exact = 0,
    this.count = 0,
  });

  factory PredictionRankingEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    int number(String key) => data[key] is num ? (data[key] as num).toInt() : 0;
    return PredictionRankingEntry(
      uid: data['uid']?.toString() ?? doc.id,
      name: data['nome']?.toString() ?? '',
      points: number('pontos'),
      exact: number('exatos'),
      count: number('palpites'),
    );
  }

  /// Ordem do ranking: pontos, depois placares exatos, depois mais palpites.
  static int compare(PredictionRankingEntry a, PredictionRankingEntry b) {
    final byPoints = b.points.compareTo(a.points);
    if (byPoints != 0) return byPoints;
    final byExact = b.exact.compareTo(a.exact);
    return byExact != 0 ? byExact : b.count.compareTo(a.count);
  }

  @override
  List<Object?> get props => [uid, name, points, exact, count];
}
