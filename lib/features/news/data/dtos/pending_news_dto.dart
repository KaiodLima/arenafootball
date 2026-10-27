import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Situação da notícia que espera o admin. A chave é o valor de `status`.
enum PendingNewsStatus {
  pending('pendente'),
  approved('aprovada'),
  rejected('rejeitada');

  final String key;

  const PendingNewsStatus(this.key);

  static PendingNewsStatus fromKey(String? key) {
    for (final status in values) {
      if (status.key == key) return status;
    }
    return pending;
  }
}

/// Documento de `noticias_pendentes/{id}`: notícia do parceiro além do limite
/// do dia, esperando o admin. Mesmos campos da notícia + `status`, `motivo`,
/// `criadoEm` e `idNoticia` (o doc criado em `noticias` ao aprovar).
class PendingNewsDTO extends Equatable {
  final NewsDTO news;
  final PendingNewsStatus status;
  final String reason;
  final String publishedId;
  final DateTime? createdAt;

  const PendingNewsDTO({
    required this.news,
    this.status = PendingNewsStatus.pending,
    this.reason = '',
    this.publishedId = '',
    this.createdAt,
  });

  String get id => news.id;

  bool get isPending => status == PendingNewsStatus.pending;

  factory PendingNewsDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return PendingNewsDTO(
      news: NewsDTO.fromFirestore(doc),
      status: PendingNewsStatus.fromKey(data['status']?.toString()),
      reason: data['motivo']?.toString() ?? '',
      publishedId: data['idNoticia']?.toString() ?? '',
      createdAt: (data['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  /// Gravação do parceiro (as datas o DataSource põe com a hora do servidor).
  Map<String, dynamic> toSubmitMap() => {...news.toMap(), 'status': PendingNewsStatus.pending.key};

  @override
  List<Object?> get props => [news, status, reason, publishedId, createdAt];
}
