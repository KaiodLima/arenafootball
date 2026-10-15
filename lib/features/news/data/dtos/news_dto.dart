import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';

/// Documento da coleção `noticias`. Notícias, cards de gol e anúncios
/// usam o mesmo documento; o que muda é a [tag].
class NewsDTO extends Equatable {
  /// Tag dos cards de gol (placar ao vivo).
  static const String goalTag = 'gol';

  /// Tag dos cards de publicidade.
  static const String adTag = 'publicidade';

  final String id;
  final DateTime? date;
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final bool isVisible;
  final String region;
  final String homeTeam;
  final String awayTeam;
  final String homeGoals;
  final String awayGoals;
  final String tag;
  final List<String> images;

  /// Card de gol: autor e quem deu o passe (id do jogador + nome no momento
  /// do gol) e a temporada dos jogadores. Vazios quando não informados.
  final String scorerId;
  final String scorerName;
  final String assistantId;
  final String assistantName;
  final String season;

  /// Card de gol: time que marcou e o escudo dele (gravado no card para o
  /// feed não precisar ler os times). Vazios quando não se sabe.
  final String scoringTeam;
  final String scoringTeamCrest;

  /// Ids dos times (`id_time_casa`, `id_time_fora`, `id_time_marcador`);
  /// vazios em cards antigos, quando valem os nomes.
  final String homeTeamId;
  final String awayTeamId;
  final String scoringTeamId;

  /// Cores do time que marcou no momento do gol (`cor_marcador`,
  /// `cor_marcador_secundaria`, hex): pintam o fundo do card. Vazias = verde.
  final String scoringTeamPrimaryColor;
  final String scoringTeamSecondaryColor;

  const NewsDTO({
    this.id = '',
    this.date,
    this.title = '',
    this.description = '',
    this.imageUrl = '',
    this.link = '',
    this.isVisible = false,
    this.region = '',
    this.homeTeam = '',
    this.awayTeam = '',
    this.homeGoals = '',
    this.awayGoals = '',
    this.tag = '',
    this.images = const [],
    this.scorerId = '',
    this.scorerName = '',
    this.assistantId = '',
    this.assistantName = '',
    this.season = '',
    this.scoringTeam = '',
    this.scoringTeamCrest = '',
    this.homeTeamId = '',
    this.awayTeamId = '',
    this.scoringTeamId = '',
    this.scoringTeamPrimaryColor = '',
    this.scoringTeamSecondaryColor = '',
  });

  bool get hasScorer => scorerId.isNotEmpty && scorerName.isNotEmpty;

  bool get hasAssistant => assistantId.isNotEmpty && assistantName.isNotEmpty;

  bool get isGoal => tag == goalTag;

  bool get isAd => tag == adTag;

  factory NewsDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final rawImages = data['images'];
    return NewsDTO(
      id: doc.id,
      date: (data['data'] as Timestamp?)?.toDate(),
      title: data['titulo']?.toString() ?? '',
      description: data['descricao']?.toString() ?? '',
      imageUrl: data['urlImagem']?.toString() ?? '',
      link: data['link']?.toString() ?? '',
      // `exibir` é gravado como string ("true"/"false").
      isVisible: data['exibir']?.toString() == 'true',
      region: RegionRegistry.nameFromDoc(data),
      homeTeam: data['time_casa']?.toString() ?? '',
      awayTeam: data['time_fora']?.toString() ?? '',
      homeGoals: data['gol_time_casa']?.toString() ?? '',
      awayGoals: data['gol_time_fora']?.toString() ?? '',
      tag: data['tag']?.toString() ?? '',
      images: rawImages is List
          ? rawImages.map((item) => item.toString()).where((url) => url.isNotEmpty).toList()
          : const [],
      scorerId: data['autor_gol_id']?.toString() ?? '',
      scorerName: data['autor_gol']?.toString() ?? '',
      assistantId: data['assistencia_id']?.toString() ?? '',
      assistantName: data['assistencia']?.toString() ?? '',
      season: data['temporada']?.toString() ?? '',
      scoringTeam: data['time_marcador']?.toString() ?? '',
      scoringTeamCrest: data['escudo_marcador']?.toString() ?? '',
      homeTeamId: data['id_time_casa']?.toString() ?? '',
      awayTeamId: data['id_time_fora']?.toString() ?? '',
      scoringTeamId: data['id_time_marcador']?.toString() ?? '',
      scoringTeamPrimaryColor: data['cor_marcador']?.toString() ?? '',
      scoringTeamSecondaryColor: data['cor_marcador_secundaria']?.toString() ?? '',
    );
  }

  /// `data` fica de fora: na criação o DataSource grava o horário do
  /// servidor; na edição, o original.
  /// `images` só é gravado quando há fotos (cards de gol/anúncio nunca
  /// tiveram esse campo).
  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': title,
        'descricao': description,
        'urlImagem': imageUrl,
        'link': link,
        'exibir': isVisible.toString(),
        ...RegionRegistry.fieldsFor(region),
        'time_casa': homeTeam,
        'time_fora': awayTeam,
        'gol_time_casa': homeGoals,
        'gol_time_fora': awayGoals,
        'tag': tag,
        if (images.isNotEmpty) 'images': images,
        // Só nos cards de gol com autor/assistência informados.
        if (scorerId.isNotEmpty) 'autor_gol_id': scorerId,
        if (scorerName.isNotEmpty) 'autor_gol': scorerName,
        if (assistantId.isNotEmpty) 'assistencia_id': assistantId,
        if (assistantName.isNotEmpty) 'assistencia': assistantName,
        if (season.isNotEmpty) 'temporada': season,
        if (scoringTeam.isNotEmpty) 'time_marcador': scoringTeam,
        if (scoringTeamCrest.isNotEmpty) 'escudo_marcador': scoringTeamCrest,
        if (homeTeamId.isNotEmpty) 'id_time_casa': homeTeamId,
        if (awayTeamId.isNotEmpty) 'id_time_fora': awayTeamId,
        if (scoringTeamId.isNotEmpty) 'id_time_marcador': scoringTeamId,
        if (scoringTeamPrimaryColor.isNotEmpty) 'cor_marcador': scoringTeamPrimaryColor,
        if (scoringTeamSecondaryColor.isNotEmpty) 'cor_marcador_secundaria': scoringTeamSecondaryColor,
      };

  NewsDTO copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? description,
    String? imageUrl,
    String? link,
    bool? isVisible,
    String? region,
    String? homeTeam,
    String? awayTeam,
    String? homeGoals,
    String? awayGoals,
    String? tag,
    List<String>? images,
    String? scorerId,
    String? scorerName,
    String? assistantId,
    String? assistantName,
    String? season,
    String? scoringTeam,
    String? scoringTeamCrest,
    String? homeTeamId,
    String? awayTeamId,
    String? scoringTeamId,
    String? scoringTeamPrimaryColor,
    String? scoringTeamSecondaryColor,
  }) {
    return NewsDTO(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      isVisible: isVisible ?? this.isVisible,
      region: region ?? this.region,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
      tag: tag ?? this.tag,
      images: images ?? this.images,
      scorerId: scorerId ?? this.scorerId,
      scorerName: scorerName ?? this.scorerName,
      assistantId: assistantId ?? this.assistantId,
      assistantName: assistantName ?? this.assistantName,
      season: season ?? this.season,
      scoringTeam: scoringTeam ?? this.scoringTeam,
      scoringTeamCrest: scoringTeamCrest ?? this.scoringTeamCrest,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      scoringTeamId: scoringTeamId ?? this.scoringTeamId,
      scoringTeamPrimaryColor: scoringTeamPrimaryColor ?? this.scoringTeamPrimaryColor,
      scoringTeamSecondaryColor: scoringTeamSecondaryColor ?? this.scoringTeamSecondaryColor,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        title,
        description,
        imageUrl,
        link,
        isVisible,
        region,
        homeTeam,
        awayTeam,
        homeGoals,
        awayGoals,
        tag,
        images,
        scorerId,
        scorerName,
        assistantId,
        assistantName,
        season,
        scoringTeam,
        scoringTeamCrest,
        homeTeamId,
        awayTeamId,
        scoringTeamId,
        scoringTeamPrimaryColor,
        scoringTeamSecondaryColor,
      ];
}
