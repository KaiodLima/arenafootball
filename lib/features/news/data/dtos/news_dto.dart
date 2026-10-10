import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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
  });

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
      region: data['fk_competicao']?.toString() ?? '',
      homeTeam: data['time_casa']?.toString() ?? '',
      awayTeam: data['time_fora']?.toString() ?? '',
      homeGoals: data['gol_time_casa']?.toString() ?? '',
      awayGoals: data['gol_time_fora']?.toString() ?? '',
      tag: data['tag']?.toString() ?? '',
      images: rawImages is List
          ? rawImages.map((item) => item.toString()).where((url) => url.isNotEmpty).toList()
          : const [],
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
        'fk_competicao': region,
        'time_casa': homeTeam,
        'time_fora': awayTeam,
        'gol_time_casa': homeGoals,
        'gol_time_fora': awayGoals,
        'tag': tag,
        if (images.isNotEmpty) 'images': images,
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
      ];
}
