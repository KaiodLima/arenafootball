import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/utils/team_key.dart';

/// Um time no ranking de torcidas (`ranking_torcidas/{temporada}.times[]`).
class FanRankingEntry extends Equatable {
  final String teamId;
  final String name;

  /// `idRegiao`: o vínculo; [region] é o nome atual (pelo `RegionRegistry`).
  final String regionId;
  final String region;
  final String imageUrl;
  final String primaryColor;
  final String secondaryColor;
  final int fans;

  const FanRankingEntry({
    required this.teamId,
    required this.name,
    this.regionId = '',
    this.region = '',
    this.imageUrl = '',
    this.primaryColor = '',
    this.secondaryColor = '',
    this.fans = 0,
  });

  factory FanRankingEntry.fromMap(Map<String, dynamic> data) {
    String text(String key) => data[key]?.toString() ?? '';
    final fans = data['torcedores'];
    return FanRankingEntry(
      teamId: text('id'),
      name: text('nome'),
      regionId: text('idRegiao'),
      region: RegionRegistry.nameFromDoc({'idRegiao': data['idRegiao'], 'fk_competicao': data['regiao']}),
      imageUrl: text('urlImagem'),
      primaryColor: text('corPrimaria'),
      secondaryColor: text('corSecundaria'),
      fans: fans is num ? fans.toInt() : 0,
    );
  }

  /// Cache: mesmo formato do Firestore (a região volta a ser resolvida pelo id).
  Map<String, dynamic> toMap() => {
        'id': teamId,
        'nome': name,
        'idRegiao': regionId,
        'regiao': region,
        'urlImagem': imageUrl,
        'corPrimaria': primaryColor,
        'corSecundaria': secondaryColor,
        'torcedores': fans,
      };

  /// É da região [name]? Pelo id quando os dois lados têm; senão, pelo nome.
  bool isFromRegion(String name) {
    final id = RegionRegistry.idOf(name);
    if (id.isNotEmpty && regionId.isNotEmpty) return id == regionId;
    return region.trim().toLowerCase() == name.trim().toLowerCase();
  }

  /// É o time de id [id] (ou, sem id, de nome [teamName])?
  bool isTeam({String id = '', String teamName = ''}) => sameTeam(idA: teamId, nameA: name, idB: id, nameB: teamName);

  @override
  List<Object?> get props => [teamId, name, regionId, region, imageUrl, primaryColor, secondaryColor, fans];
}

/// Ranking de torcidas da temporada, gravado de hora em hora pela function
/// `fanRanking`. Sem o doc ainda: [entries] vazio e [updatedAt] nulo.
class FanRankingDTO extends Equatable {
  final String season;
  final DateTime? updatedAt;
  final List<FanRankingEntry> entries;

  const FanRankingDTO({required this.season, this.updatedAt, this.entries = const []});

  bool get isEmpty => entries.isEmpty;

  factory FanRankingDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final teams = data['times'];
    return FanRankingDTO(
      season: data['temporada']?.toString() ?? doc.id,
      updatedAt: (data['atualizado_em'] as Timestamp?)?.toDate(),
      entries: teams is List
          ? [
              for (final item in teams)
                if (item is Map) FanRankingEntry.fromMap(Map<String, dynamic>.from(item))
            ]
          : const [],
    );
  }

  factory FanRankingDTO.fromCache(Map<String, dynamic> json) {
    final teams = json['entries'];
    final updatedAt = json['updatedAt'];
    return FanRankingDTO(
      season: json['season']?.toString() ?? '',
      updatedAt: updatedAt is int ? DateTime.fromMillisecondsSinceEpoch(updatedAt) : null,
      entries: teams is List
          ? [for (final item in teams) FanRankingEntry.fromMap(Map<String, dynamic>.from(item as Map))]
          : const [],
    );
  }

  Map<String, dynamic> toCache() => {
        'season': season,
        if (updatedAt != null) 'updatedAt': updatedAt!.millisecondsSinceEpoch,
        'entries': [for (final entry in entries) entry.toMap()],
      };

  /// Times da região [region], na ordem do ranking.
  List<FanRankingEntry> entriesOf(String region) => entries.where((e) => e.isFromRegion(region)).toList();

  @override
  List<Object?> get props => [season, updatedAt, entries];
}
