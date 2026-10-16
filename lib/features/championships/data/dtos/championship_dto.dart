import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';

/// Documento da coleção `campeonatos` (sem temporada: um por região/ano).
class ChampionshipDTO extends Equatable {
  /// Id do documento.
  final String id;

  /// `id_campeonato`: número que as partidas usam para apontar o campeonato.
  final int championshipId;
  final String title;
  final String description;
  final String imageUrl;
  final String firstPrize;
  final String secondPrize;
  final String thirdPrize;
  final String topScorerPrize;
  final String goalkeeperPrize;
  final String rules;
  final String region;

  /// Campo `ano`: temporada do campeonato (usada para abrir os grupos).
  final String season;

  /// Nomes dos times participantes (cópia para exibir).
  final List<String> teams;

  /// Participa? Pelo id; o nome cobre campeonatos antigos (sem ids).
  bool hasTeam({required String id, required String name}) =>
      (id.isNotEmpty && teamIds.contains(id)) || teams.any((t) => t.trim().toLowerCase() == name.trim().toLowerCase());

  /// `ids_times`: ids dos participantes (vínculo), na ordem de [teams] (''
  /// = sem id). Vazio em campeonatos antigos (antes da migração).
  final List<String> teamIds;

  /// Regulamento em PDF (Storage `campeonatos/`); vazio se não houver.
  final String rulesUrl;
  final String rulesFileName;

  const ChampionshipDTO({
    required this.id,
    this.championshipId = 0,
    this.title = '',
    this.description = '',
    this.imageUrl = '',
    this.firstPrize = '',
    this.secondPrize = '',
    this.thirdPrize = '',
    this.topScorerPrize = '',
    this.goalkeeperPrize = '',
    this.rules = '',
    this.region = '',
    this.season = '',
    this.teams = const [],
    this.teamIds = const [],
    this.rulesUrl = '',
    this.rulesFileName = '',
  });

  factory ChampionshipDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final rawId = data['id_campeonato'];
    return ChampionshipDTO(
      id: doc.id,
      championshipId: rawId is num ? rawId.toInt() : int.tryParse(rawId?.toString() ?? '') ?? 0,
      title: data['titulo']?.toString() ?? '',
      description: data['descricao']?.toString() ?? '',
      imageUrl: data['urlImagem']?.toString() ?? '',
      firstPrize: data['premio1']?.toString() ?? '',
      secondPrize: data['premio2']?.toString() ?? '',
      thirdPrize: data['premio3']?.toString() ?? '',
      topScorerPrize: data['premioArtilheiro']?.toString() ?? '',
      goalkeeperPrize: data['premioGoleiro']?.toString() ?? '',
      rules: data['regras']?.toString() ?? '',
      region: RegionRegistry.nameFromDoc(data),
      season: data['ano']?.toString() ?? '',
      teams: (data['times'] as List?)?.map((t) => t.toString()).toList() ?? const [],
      teamIds: (data['ids_times'] as List?)?.map((t) => t.toString()).toList() ?? const [],
      rulesUrl: data['regulamentoUrl']?.toString() ?? '',
      rulesFileName: data['regulamentoNome']?.toString() ?? '',
    );
  }

  /// Cache local (ver `CacheStore`): região pelo id, com o nome atual na
  /// leitura (como no `TeamDTO`).
  factory ChampionshipDTO.fromCache(Map<String, dynamic> json) {
    List<String> list(Object? value) => (value as List?)?.map((item) => item.toString()).toList() ?? const [];
    return ChampionshipDTO(
      id: json['id']?.toString() ?? '',
      championshipId: (json['championshipId'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      firstPrize: json['firstPrize']?.toString() ?? '',
      secondPrize: json['secondPrize']?.toString() ?? '',
      thirdPrize: json['thirdPrize']?.toString() ?? '',
      topScorerPrize: json['topScorerPrize']?.toString() ?? '',
      goalkeeperPrize: json['goalkeeperPrize']?.toString() ?? '',
      rules: json['rules']?.toString() ?? '',
      region: RegionRegistry.nameOf(
        json[RegionRegistry.idField]?.toString() ?? '',
        fallback: json['region']?.toString() ?? '',
      ),
      season: json['season']?.toString() ?? '',
      teams: list(json['teams']),
      teamIds: list(json['teamIds']),
      rulesUrl: json['rulesUrl']?.toString() ?? '',
      rulesFileName: json['rulesFileName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toCache() => {
        'id': id,
        'championshipId': championshipId,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'firstPrize': firstPrize,
        'secondPrize': secondPrize,
        'thirdPrize': thirdPrize,
        'topScorerPrize': topScorerPrize,
        'goalkeeperPrize': goalkeeperPrize,
        'rules': rules,
        RegionRegistry.idField: RegionRegistry.idOf(region),
        'region': region,
        'season': season,
        'teams': teams,
        'teamIds': teamIds,
        'rulesUrl': rulesUrl,
        'rulesFileName': rulesFileName,
      };

  Map<String, dynamic> toMap() => {
        'id_campeonato': championshipId,
        'titulo': title,
        'descricao': description,
        'urlImagem': imageUrl,
        'premio1': firstPrize,
        'premio2': secondPrize,
        'premio3': thirdPrize,
        'premioArtilheiro': topScorerPrize,
        'premioGoleiro': goalkeeperPrize,
        'regras': rules,
        ...RegionRegistry.fieldsFor(region),
        'ano': season,
        'times': teams,
        'ids_times': teamIds,
        'regulamentoUrl': rulesUrl,
        'regulamentoNome': rulesFileName,
      };

  ChampionshipDTO copyWith({
    String? id,
    int? championshipId,
    String? title,
    String? description,
    String? imageUrl,
    String? firstPrize,
    String? secondPrize,
    String? thirdPrize,
    String? topScorerPrize,
    String? goalkeeperPrize,
    String? rules,
    String? region,
    String? season,
    List<String>? teams,
    List<String>? teamIds,
    String? rulesUrl,
    String? rulesFileName,
  }) {
    return ChampionshipDTO(
      id: id ?? this.id,
      championshipId: championshipId ?? this.championshipId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      firstPrize: firstPrize ?? this.firstPrize,
      secondPrize: secondPrize ?? this.secondPrize,
      thirdPrize: thirdPrize ?? this.thirdPrize,
      topScorerPrize: topScorerPrize ?? this.topScorerPrize,
      goalkeeperPrize: goalkeeperPrize ?? this.goalkeeperPrize,
      rules: rules ?? this.rules,
      region: region ?? this.region,
      season: season ?? this.season,
      teams: teams ?? this.teams,
      teamIds: teamIds ?? this.teamIds,
      rulesUrl: rulesUrl ?? this.rulesUrl,
      rulesFileName: rulesFileName ?? this.rulesFileName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        championshipId,
        title,
        description,
        imageUrl,
        firstPrize,
        secondPrize,
        thirdPrize,
        topScorerPrize,
        goalkeeperPrize,
        rules,
        region,
        season,
        teams,
        teamIds,
        rulesUrl,
        rulesFileName,
      ];
}
