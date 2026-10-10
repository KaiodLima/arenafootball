import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Documento da coleção `destaques` (carrossel do topo da home).
class HighlightDTO extends Equatable {
  final String id;
  final String title;
  final String link;
  final String imageUrl;
  final bool isVisible;

  /// Ordem no carrossel. Gravada como string, como no app antigo.
  final String priority;

  const HighlightDTO({
    this.id = '',
    this.title = '',
    this.link = '',
    this.imageUrl = '',
    this.isVisible = false,
    this.priority = '',
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
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'link': link,
        'urlImagem': imageUrl,
        'exibir': isVisible.toString(),
        'priority': priority,
      };

  HighlightDTO copyWith({
    String? id,
    String? title,
    String? link,
    String? imageUrl,
    bool? isVisible,
    String? priority,
  }) {
    return HighlightDTO(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
      isVisible: isVisible ?? this.isVisible,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [id, title, link, imageUrl, isVisible, priority];
}
