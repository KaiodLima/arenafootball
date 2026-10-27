import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';

/// Documento da coleção `destaques` (carrossel do topo da home).
class HighlightDTO extends Equatable {
  final String id;
  final String title;
  final String link;
  final String imageUrl;
  final bool isVisible;

  /// Ordem no carrossel. Gravada como string, como no app antigo.
  final String priority;

  /// Região do destaque (`idRegiao`/`regiao`): só os do parceiro têm; vazio =
  /// aparece em todas as regiões (os do admin).
  final String region;

  /// `idAutor`: uid do parceiro que publicou (vazio = admin).
  final String authorId;

  const HighlightDTO({
    this.id = '',
    this.title = '',
    this.link = '',
    this.imageUrl = '',
    this.isVisible = false,
    this.priority = '',
    this.region = '',
    this.authorId = '',
  });

  factory HighlightDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return HighlightDTO(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      link: data['link']?.toString() ?? '',
      imageUrl: data['urlImagem']?.toString() ?? '',
      // `exibir` é gravado como string ("true"/"false").
      isVisible: data['exibir']?.toString() == 'true',
      priority: data['priority']?.toString() ?? '',
      region: RegionRegistry.nameFromDoc(data, nameKey: 'regiao'),
      authorId: data['idAutor']?.toString() ?? '',
    );
  }

  /// Cache local (ver `CacheStore`).
  factory HighlightDTO.fromCache(Map<String, dynamic> json) {
    return HighlightDTO(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isVisible: json['isVisible'] == true,
      priority: json['priority']?.toString() ?? '',
      region: RegionRegistry.nameOf(json[RegionRegistry.idField]?.toString() ?? '',
          fallback: json['region']?.toString() ?? ''),
      authorId: json['authorId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toCache() => {
        'id': id,
        'title': title,
        'link': link,
        'imageUrl': imageUrl,
        'isVisible': isVisible,
        'priority': priority,
        if (region.isNotEmpty) RegionRegistry.idField: RegionRegistry.idOf(region),
        if (region.isNotEmpty) 'region': region,
        if (authorId.isNotEmpty) 'authorId': authorId,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'link': link,
        'urlImagem': imageUrl,
        'exibir': isVisible.toString(),
        'priority': priority,
        if (region.isNotEmpty) ...RegionRegistry.fieldsFor(region, nameKey: 'regiao'),
        if (authorId.isNotEmpty) 'idAutor': authorId,
      };

  HighlightDTO copyWith({
    String? id,
    String? title,
    String? link,
    String? imageUrl,
    bool? isVisible,
    String? priority,
    String? region,
    String? authorId,
  }) {
    return HighlightDTO(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
      isVisible: isVisible ?? this.isVisible,
      priority: priority ?? this.priority,
      region: region ?? this.region,
      authorId: authorId ?? this.authorId,
    );
  }

  @override
  List<Object?> get props => [id, title, link, imageUrl, isVisible, priority, region, authorId];
}

/// `priority` como número (string no Firestore); sem valor vai para o fim.
int highlightPriorityOf(HighlightDTO highlight) => int.tryParse(highlight.priority.trim()) ?? 1 << 30;

/// Destaques na ordem do carrossel (empate mantém a ordem recebida).
List<HighlightDTO> sortHighlightsByPriority(List<HighlightDTO> highlights) {
  final indexed = highlights.asMap().entries.toList()
    ..sort((a, b) {
      final byPriority = highlightPriorityOf(a.value).compareTo(highlightPriorityOf(b.value));
      return byPriority != 0 ? byPriority : a.key.compareTo(b.key);
    });
  return indexed.map((entry) => entry.value).toList();
}

/// `priority` gravado com 3 dígitos ("007"): a ordenação por string do
/// carrossel fica igual à numérica.
String highlightPriorityAt(int index) => index.toString().padLeft(3, '0');

/// Destaques do carrossel na região [region]: os gerais (sem região, do
/// admin) e os da região (dos parceiros).
List<HighlightDTO> highlightsForRegion(List<HighlightDTO> highlights, String region) =>
    highlights.where((h) => h.region.isEmpty || h.region == region).toList();
