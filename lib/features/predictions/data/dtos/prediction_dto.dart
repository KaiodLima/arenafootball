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

  /// Cache local (ver `CacheStore`).
  factory PredictionDTO.fromCache(Map<String, dynamic> json) => PredictionDTO(
        uid: json['uid']?.toString() ?? '',
        home: _int(json['home']),
        away: _int(json['away']),
        name: json['name']?.toString() ?? '',
        points: json['points'] is num ? (json['points'] as num).toInt() : null,
        exact: json['exact'] == true,
        valid: json['valid'] is bool ? json['valid'] as bool : null,
      );

  Map<String, dynamic> toCache() => {
        'uid': uid,
        'home': home,
        'away': away,
        'name': name,
        'points': points,
        'exact': exact,
        'valid': valid,
      };

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

  /// Cache local (ver `CacheStore`).
  factory PredictionRankingEntry.fromCache(Map<String, dynamic> json) {
    int number(String key) => json[key] is num ? (json[key] as num).toInt() : 0;
    return PredictionRankingEntry(
      uid: json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      points: number('points'),
      exact: number('exact'),
      count: number('count'),
    );
  }

  Map<String, dynamic> toCache() => {'uid': uid, 'name': name, 'points': points, 'exact': exact, 'count': count};

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

/// Linha e posição da conta no bolão da região quando ela está fora do top 50
/// (nulas = ainda sem pontos ou a contagem falhou).
class PredictionStanding extends Equatable {
  final PredictionRankingEntry? entry;
  final int? position;

  const PredictionStanding({this.entry, this.position});

  /// Cache local (ver `CacheStore`).
  factory PredictionStanding.fromCache(Map<String, dynamic> json) => PredictionStanding(
        entry: json['entry'] is Map
            ? PredictionRankingEntry.fromCache(Map<String, dynamic>.from(json['entry'] as Map))
            : null,
        position: json['position'] is num ? (json['position'] as num).toInt() : null,
      );

  Map<String, dynamic> toCache() => {'entry': entry?.toCache(), 'position': position};

  @override
  List<Object?> get props => [entry, position];
}
