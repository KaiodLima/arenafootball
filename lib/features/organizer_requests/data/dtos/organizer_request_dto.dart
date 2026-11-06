import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// Documento de `solicitacoes_organizador/{uid}`: pedido para organizar um
/// campeonato. Um doc por conta com o pedido atual: respondido, o usuário
/// pode mandar outro (regrava o mesmo doc como pendente). Aprovado, o
/// campeonato é criado com o `idOrganizador`. Usa os status do "Sou jogador".
class OrganizerRequestDTO extends Equatable {
  static const int nameMinLength = 3;
  static const int nameMaxLength = 60;
  static const int descriptionMaxLength = 300;

  final String userId;
  final String userName;
  final String email;

  /// Nome da competição.
  final String name;
  final String region;
  final ChampionshipScope scope;
  final String description;

  /// Logo (Storage `campeonatos/`; vazio = sem logo).
  final String imageUrl;

  /// WhatsApp do organizador (só ele e o admin leem).
  final String contact;
  final String season;
  final PlayerRequestStatus status;
  final String reason;

  /// Doc do campeonato criado na aprovação.
  final String championshipDocId;
  final DateTime? createdAt;

  const OrganizerRequestDTO({
    required this.userId,
    this.userName = '',
    this.email = '',
    required this.name,
    required this.region,
    this.scope = ChampionshipScope.municipal,
    this.description = '',
    this.imageUrl = '',
    this.contact = '',
    this.season = '',
    this.status = PlayerRequestStatus.pending,
    this.reason = '',
    this.championshipDocId = '',
    this.createdAt,
  });

  bool get isPending => status == PlayerRequestStatus.pending;

  bool get isApproved => status == PlayerRequestStatus.approved;

  bool get isRejected => status == PlayerRequestStatus.rejected;

  factory OrganizerRequestDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    String text(String key) => data[key]?.toString() ?? '';
    return OrganizerRequestDTO(
      userId: doc.id,
      userName: text('nome_usuario'),
      email: text('email'),
      name: text('nome'),
      region: RegionRegistry.nameFromDoc(data, nameKey: 'regiao'),
      scope: ChampionshipScope.fromKey(text('abrangencia')),
      description: text('descricao'),
      imageUrl: text('urlImagem'),
      contact: text('contato'),
      season: text('temporada'),
      status: PlayerRequestStatus.fromKey(text('status')),
      reason: text('motivo'),
      championshipDocId: text('idCampeonato'),
      createdAt: (data['data'] as Timestamp?)?.toDate(),
    );
  }

  /// Campos que o próprio usuário grava ao enviar (as regras aceitam só estes).
  Map<String, dynamic> toSubmitMap() => {
        'uid': userId,
        'nome_usuario': userName,
        'email': email,
        'nome': name,
        ...RegionRegistry.fieldsFor(region, nameKey: 'regiao'),
        'abrangencia': scope.key,
        'descricao': description,
        'urlImagem': imageUrl,
        'contato': contact,
        'temporada': season,
        'status': PlayerRequestStatus.pending.key,
      };

  /// Campeonato criado na aprovação: temporada [season], sede e abrangência
  /// do pedido, com o organizador. O `id_campeonato` sai na gravação.
  ChampionshipDTO toChampionship(String season) => ChampionshipDTO(
        id: '',
        title: name.trim(),
        description: description.trim(),
        imageUrl: imageUrl,
        region: region,
        season: season,
        scope: scope,
        regionIds: [RegionRegistry.idOf(region)].where((id) => id.isNotEmpty).toList(),
        organizerId: userId,
      );

  /// Link do WhatsApp do contato (só dígitos; sem DDI assume Brasil).
  String get whatsAppUrl {
    var digits = contact.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length <= 11) digits = '55$digits';
    return 'https://wa.me/$digits';
  }

  OrganizerRequestDTO copyWith({
    String? name,
    String? region,
    ChampionshipScope? scope,
    String? description,
    String? imageUrl,
    String? contact,
    String? season,
    PlayerRequestStatus? status,
    String? reason,
    String? championshipDocId,
  }) {
    return OrganizerRequestDTO(
      userId: userId,
      userName: userName,
      email: email,
      name: name ?? this.name,
      region: region ?? this.region,
      scope: scope ?? this.scope,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      contact: contact ?? this.contact,
      season: season ?? this.season,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      championshipDocId: championshipDocId ?? this.championshipDocId,
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
        scope,
        description,
        imageUrl,
        contact,
        season,
        status,
        reason,
        championshipDocId,
        createdAt,
      ];
}
