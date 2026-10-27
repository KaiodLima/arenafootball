import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// O que o parceiro aprovado pode publicar. Só o admin grava (as regras
/// conferem cada publicação contra estes campos).
class PartnerPermissions extends Equatable {
  static const int defaultHighlightLimit = 2;
  static const int defaultAdsPerDay = 1;

  /// Teto dos limites no painel (as vagas viram ids de documento).
  static const int maxLimit = 9;

  /// `podeNoticias`, `podeDestaques`, `podePublicidade`.
  final bool canNews;
  final bool canHighlights;
  final bool canAds;

  /// `limiteDestaques`: destaques ao mesmo tempo.
  final int highlightLimit;

  /// `limitePublicidadeDia`: publicidades por dia (horário de Brasília).
  final int adsPerDay;

  const PartnerPermissions({
    this.canNews = true,
    this.canHighlights = true,
    this.canAds = true,
    this.highlightLimit = defaultHighlightLimit,
    this.adsPerDay = defaultAdsPerDay,
  });

  /// Sem os campos (pedido nunca aprovado), os padrões.
  factory PartnerPermissions.fromMap(Map<String, dynamic> data) {
    int limit(String key, int fallback) => ((data[key] as num?)?.toInt() ?? fallback).clamp(0, maxLimit);
    return PartnerPermissions(
      canNews: data['podeNoticias'] as bool? ?? true,
      canHighlights: data['podeDestaques'] as bool? ?? true,
      canAds: data['podePublicidade'] as bool? ?? true,
      highlightLimit: limit('limiteDestaques', defaultHighlightLimit),
      adsPerDay: limit('limitePublicidadeDia', defaultAdsPerDay),
    );
  }

  Map<String, dynamic> toMap() => {
        'podeNoticias': canNews,
        'podeDestaques': canHighlights,
        'podePublicidade': canAds,
        'limiteDestaques': highlightLimit,
        'limitePublicidadeDia': adsPerDay,
      };

  bool get canHighlightsNow => canHighlights && highlightLimit > 0;

  bool get canAdsNow => canAds && adsPerDay > 0;

  /// Pode publicar alguma coisa.
  bool get canPublish => canNews || canHighlightsNow || canAdsNow;

  PartnerPermissions copyWith({
    bool? canNews,
    bool? canHighlights,
    bool? canAds,
    int? highlightLimit,
    int? adsPerDay,
  }) {
    return PartnerPermissions(
      canNews: canNews ?? this.canNews,
      canHighlights: canHighlights ?? this.canHighlights,
      canAds: canAds ?? this.canAds,
      highlightLimit: (highlightLimit ?? this.highlightLimit).clamp(0, maxLimit),
      adsPerDay: (adsPerDay ?? this.adsPerDay).clamp(0, maxLimit),
    );
  }

  @override
  List<Object?> get props => [canNews, canHighlights, canAds, highlightLimit, adsPerDay];
}

/// Documento de `solicitacoes_parceiro/{uid}`: pedido "Sou parceiro" (sub
/// admin que publica notícias, destaques e publicidade na região dele). Um por
/// usuário (id do doc = uid). Aprovado, é o registro que as regras consultam.
/// Status: pendente/aprovada/rejeitada/removido (o admin tirou o acesso).
class PartnerRequestDTO extends Equatable {
  final String userId;
  final String userName;
  final String email;

  /// Nome do parceiro (página, veículo, loja...).
  final String name;
  final String region;

  /// WhatsApp (só ele e o admin leem).
  final String contact;
  final String message;
  final PlayerRequestStatus status;
  final String reason;
  final PartnerPermissions permissions;

  /// `idsDestaquesVinculo`: destaques sem dono que o usuário diz serem dele
  /// (o admin confirma; vinculado, a lista é limpa).
  final List<String> claimedHighlightIds;
  final DateTime? createdAt;

  const PartnerRequestDTO({
    required this.userId,
    this.userName = '',
    this.email = '',
    required this.name,
    required this.region,
    this.contact = '',
    this.message = '',
    this.status = PlayerRequestStatus.pending,
    this.reason = '',
    this.permissions = const PartnerPermissions(),
    this.claimedHighlightIds = const [],
    this.createdAt,
  });

  bool get isPending => status == PlayerRequestStatus.pending;

  bool get isApproved => status == PlayerRequestStatus.approved;

  factory PartnerRequestDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    String text(String key) => data[key]?.toString() ?? '';
    return PartnerRequestDTO(
      userId: doc.id,
      userName: text('nome_usuario'),
      email: text('email'),
      name: text('nome'),
      region: RegionRegistry.nameFromDoc(data, nameKey: 'regiao'),
      contact: text('contato'),
      message: text('mensagem'),
      status: PlayerRequestStatus.fromKey(text('status')),
      reason: text('motivo'),
      permissions: PartnerPermissions.fromMap(data),
      claimedHighlightIds: (data['idsDestaquesVinculo'] as List?)?.map((id) => id.toString()).toList() ?? const [],
      createdAt: (data['data'] as Timestamp?)?.toDate(),
    );
  }

  /// Campos que o próprio usuário grava ao enviar (as regras aceitam só estes;
  /// as permissões ficam com o admin).
  Map<String, dynamic> toSubmitMap() => {
        'uid': userId,
        'nome_usuario': userName,
        'email': email,
        'nome': name,
        ...RegionRegistry.fieldsFor(region, nameKey: 'regiao'),
        'contato': contact,
        'mensagem': message,
        'status': PlayerRequestStatus.pending.key,
        if (claimedHighlightIds.isNotEmpty) 'idsDestaquesVinculo': claimedHighlightIds,
      };

  /// Link do WhatsApp do contato (só dígitos; sem DDI assume Brasil).
  String get whatsAppUrl {
    var digits = contact.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length <= 11) digits = '55$digits';
    return 'https://wa.me/$digits';
  }

  PartnerRequestDTO copyWith({
    String? name,
    String? region,
    String? contact,
    String? message,
    PlayerRequestStatus? status,
    String? reason,
    PartnerPermissions? permissions,
    List<String>? claimedHighlightIds,
  }) {
    return PartnerRequestDTO(
      userId: userId,
      userName: userName,
      email: email,
      name: name ?? this.name,
      region: region ?? this.region,
      contact: contact ?? this.contact,
      message: message ?? this.message,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      permissions: permissions ?? this.permissions,
      claimedHighlightIds: claimedHighlightIds ?? this.claimedHighlightIds,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [
        userId,
        userName,
        email,
        name,
        region,
        contact,
        message,
        status,
        reason,
        permissions,
        claimedHighlightIds,
        createdAt,
      ];
}
