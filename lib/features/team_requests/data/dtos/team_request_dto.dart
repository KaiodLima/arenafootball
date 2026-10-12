import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// Documento de `solicitacoes_time/{uid}`: pedido de um usuário para criar o
/// próprio time. Um por usuário (id do doc = uid). Aprovado, é também o
/// registro de dono que as regras consultam. Usa os mesmos status do
/// "Sou jogador" (pendente/aprovada/rejeitada).
class TeamRequestDTO extends Equatable {
  final String userId;
  final String userName;
  final String email;

  /// Nome do time (chave usada em partidas, jogadores e grupos).
  final String name;
  final String region;
  final String description;
  final String imageUrl;

  /// WhatsApp do dono (só ele e o admin leem).
  final String contact;
  final String message;
  final String season;
  final PlayerRequestStatus status;
  final String reason;

  /// Id do time criado na aprovação.
  final String teamId;
  final DateTime? createdAt;

  const TeamRequestDTO({
    required this.userId,
    this.userName = '',
    this.email = '',
    required this.name,
    required this.region,
    this.description = '',
    this.imageUrl = '',
    this.contact = '',
    this.message = '',
    this.season = '',
    this.status = PlayerRequestStatus.pending,
    this.reason = '',
    this.teamId = '',
    this.createdAt,
  });

  bool get isPending => status == PlayerRequestStatus.pending;

  bool get isApproved => status == PlayerRequestStatus.approved;

  factory TeamRequestDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    String text(String key) => data[key]?.toString() ?? '';
    return TeamRequestDTO(
      userId: doc.id,
      userName: text('nome_usuario'),
      email: text('email'),
      name: text('nome'),
      region: text('regiao'),
      description: text('descricao'),
      imageUrl: text('urlImagem'),
      contact: text('contato'),
      message: text('mensagem'),
      season: text('temporada'),
      status: PlayerRequestStatus.fromKey(text('status')),
      reason: text('motivo'),
      teamId: text('idTime'),
      createdAt: (data['data'] as Timestamp?)?.toDate(),
    );
  }

  /// Campos que o próprio usuário grava ao enviar (as regras aceitam só estes).
  Map<String, dynamic> toSubmitMap() => {
        'uid': userId,
        'nome_usuario': userName,
        'email': email,
        'nome': name,
        'regiao': region,
        'descricao': description,
        'urlImagem': imageUrl,
        'contato': contact,
        'mensagem': message,
        'temporada': season,
        'status': PlayerRequestStatus.pending.key,
      };

  /// Link do WhatsApp do contato (só dígitos; sem DDI assume Brasil).
  String get whatsAppUrl {
    var digits = contact.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length <= 11) digits = '55$digits';
    return 'https://wa.me/$digits';
  }

  TeamRequestDTO copyWith({
    String? name,
    String? region,
    String? description,
    String? imageUrl,
    String? contact,
    String? message,
    String? season,
    PlayerRequestStatus? status,
    String? reason,
    String? teamId,
  }) {
    return TeamRequestDTO(
      userId: userId,
      userName: userName,
      email: email,
      name: name ?? this.name,
      region: region ?? this.region,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      contact: contact ?? this.contact,
      message: message ?? this.message,
      season: season ?? this.season,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      teamId: teamId ?? this.teamId,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        email,
        name,
        region,
        description,
        imageUrl,
        contact,
        message,
        season,
        status,
        reason,
        teamId,
        createdAt,
      ];
}
