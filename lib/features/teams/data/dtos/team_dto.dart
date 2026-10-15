import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';

/// Documento das coleções `times` / `times{ano}`.
class TeamDTO extends Equatable {
  final String id;
  final String name;
  final String description;
  final String region;
  final String imageUrl;

  /// `idDono`: uid do dono (time criado pelo "Sou dono de time"); vazio nos demais.
  final String ownerId;

  /// `corPrimaria` / `corSecundaria`: hex ("#2E7D32"); vazio = não informada.
  final String primaryColor;
  final String secondaryColor;

  const TeamDTO({
    required this.id,
    required this.name,
    this.description = '',
    this.region = '',
    this.imageUrl = '',
    this.ownerId = '',
    this.primaryColor = '',
    this.secondaryColor = '',
  });

  factory TeamDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return TeamDTO(
      // O id do time é gravado no campo (com nome errado) `id_partida`.
      id: data['id_partida']?.toString() ?? doc.id,
      name: data['nome']?.toString() ?? '',
      description: data['descricao']?.toString() ?? '',
      region: RegionRegistry.nameFromDoc(data),
      imageUrl: data['urlImagem']?.toString() ?? '',
      ownerId: data['idDono']?.toString() ?? '',
      primaryColor: data['corPrimaria']?.toString() ?? '',
      secondaryColor: data['corSecundaria']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id_partida': id,
        'nome': name,
        'descricao': description,
        ...RegionRegistry.fieldsFor(region),
        'urlImagem': imageUrl,
        // Só nos times com dono (os antigos não têm o campo).
        if (ownerId.isNotEmpty) 'idDono': ownerId,
        if (primaryColor.isNotEmpty) 'corPrimaria': primaryColor,
        if (secondaryColor.isNotEmpty) 'corSecundaria': secondaryColor,
      };

  /// Linha inicial do time na `classificacao`: os campos do time + as
  /// estatísticas zeradas e sem grupo. Inclui `saldo_gols`, que o app antigo
  /// não gravava: sem ele o time some da classificação (ordenada por esse campo).
  Map<String, dynamic> toStandingsMap() => {
        ...toMap(),
        'vitorias': 0,
        'derrotas': 0,
        'empates': 0,
        'gols_feitos': 0,
        'gols_sofridos': 0,
        'pontos': 0,
        'saldo_gols': 0,
        'fk_grupo': '',
      };

  TeamDTO copyWith({
    String? id,
    String? name,
    String? description,
    String? region,
    String? imageUrl,
    String? ownerId,
    String? primaryColor,
    String? secondaryColor,
  }) {
    return TeamDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      region: region ?? this.region,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }

  @override
  List<Object?> get props => [id, name, description, region, imageUrl, ownerId, primaryColor, secondaryColor];
}
