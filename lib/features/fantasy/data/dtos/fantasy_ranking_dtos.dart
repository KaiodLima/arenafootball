import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';

/// Linha do ranking (escalação da rodada ou participante no geral).
class FantasyRankingEntry extends Equatable {
  final String uid;
  final String name;
  final String photoUrl;
  final double points;

  const FantasyRankingEntry({required this.uid, this.name = '', this.photoUrl = '', this.points = 0});

  factory FantasyRankingEntry.fromMap(String id, Map<String, dynamic> data) => FantasyRankingEntry(
        uid: id,
        name: data['nome']?.toString() ?? '',
        photoUrl: data['urlImagem']?.toString() ?? '',
        points: (data['pontos'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toCache() => {'uid': uid, 'name': name, 'photoUrl': photoUrl, 'points': points};

  factory FantasyRankingEntry.fromCache(Map<String, dynamic> json) => FantasyRankingEntry(
        uid: json['uid']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        photoUrl: json['photoUrl']?.toString() ?? '',
        points: (json['points'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [uid, name, photoUrl, points];
}

/// Ranking em ordem: pontos (maior primeiro) e, no empate, o nome.
List<FantasyRankingEntry> sortFantasyRanking(List<FantasyRankingEntry> entries) => [...entries]..sort((a, b) {
    final byPoints = b.points.compareTo(a.points);
    return byPoints != 0 ? byPoints : foldForSearch(a.name).compareTo(foldForSearch(b.name));
  });

/// Posições do ranking já ordenado: pontos iguais, mesma posição (1, 1, 3).
List<int> fantasyPositions(List<FantasyRankingEntry> sorted) {
  final positions = <int>[];
  for (var i = 0; i < sorted.length; i++) {
    positions.add(i > 0 && sorted[i].points == sorted[i - 1].points ? positions[i - 1] : i + 1);
  }
  return positions;
}

/// "12" / "7,5" (uma casa só quando houver).
String fantasyPointsLabel(double points) {
  final rounded = (points * 10).round() / 10;
  final text = rounded == rounded.truncateToDouble() ? rounded.toInt().toString() : rounded.toStringAsFixed(1);
  return text.replaceAll('.', ',');
}

/// Rodada no histórico da conta: a escalação usada e a posição na rodada
/// (nula = ainda sem apuração).
class FantasyHistoryItem extends Equatable {
  final FantasyRoundDTO round;
  final FantasyLineupDTO lineup;
  final int? position;

  const FantasyHistoryItem({required this.round, required this.lineup, this.position});

  @override
  List<Object?> get props => [round, lineup, position];
}

/// Posição da conta guardada no cache: vale só para os mesmos [points].
class FantasyPositionRecord extends Equatable {
  final double points;
  final int position;

  const FantasyPositionRecord({required this.points, required this.position});

  Map<String, dynamic> toCache() => {'points': points, 'position': position};

  factory FantasyPositionRecord.fromCache(Map<String, dynamic> json) => FantasyPositionRecord(
        points: (json['points'] as num?)?.toDouble() ?? 0,
        position: (json['position'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [points, position];
}

/// A conta numa rodada fechada: a escalação (nula = não jogou) e a posição
/// (nula = sem apuração). [version] = a [FantasyRoundDTO.scoringVersion] de
/// quando foi lida: reapurada, o cache não vale.
class FantasyRoundRecord extends Equatable {
  final int version;
  final FantasyLineupDTO? lineup;
  final int? position;

  const FantasyRoundRecord({this.version = 0, this.lineup, this.position});

  Map<String, dynamic> toCache() => {'version': version, 'lineup': lineup?.toCache(), 'position': position};

  factory FantasyRoundRecord.fromCache(Map<String, dynamic> json) => FantasyRoundRecord(
        version: (json['version'] as num?)?.toInt() ?? 0,
        lineup:
            json['lineup'] is Map ? FantasyLineupDTO.fromCache(Map<String, dynamic>.from(json['lineup'] as Map)) : null,
        position: (json['position'] as num?)?.toInt(),
      );

  @override
  List<Object?> get props => [version, lineup, position];
}

/// Pontuação detalhada do atleta guardada no cache (nula = sem doc na
/// rodada apurada), com a [version] da apuração.
class FantasyAthleteScoreRecord extends Equatable {
  final int version;
  final FantasyAthleteScoreDTO? score;

  const FantasyAthleteScoreRecord({this.version = 0, this.score});

  Map<String, dynamic> toCache() => {'version': version, 'score': score?.toDetailCache()};

  factory FantasyAthleteScoreRecord.fromCache(Map<String, dynamic> json) => FantasyAthleteScoreRecord(
        version: (json['version'] as num?)?.toInt() ?? 0,
        score: json['score'] is Map
            ? FantasyAthleteScoreDTO.fromCache(Map<String, dynamic>.from(json['score'] as Map))
            : null,
      );

  @override
  List<Object?> get props => [version, score];
}
