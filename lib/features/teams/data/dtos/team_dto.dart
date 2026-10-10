import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Documento das coleções `times` / `times{ano}`.
class TeamDTO extends Equatable {
  final String id;
  final String name;
  final String description;
  final String region;
  final String imageUrl;

  const TeamDTO({
    required this.id,
    required this.name,
    this.description = '',
    this.region = '',
    this.imageUrl = '',
  });

  factory TeamDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return TeamDTO(
      // O id do time é gravado no campo (com nome errado) `id_partida`.
      id: data['id_partida']?.toString() ?? doc.id,
      name: data['nome']?.toString() ?? '',
      description: data['descricao']?.toString() ?? '',
      region: data['fk_competicao']?.toString() ?? '',
      imageUrl: data['urlImagem']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id_partida': id,
        'nome': name,
        'descricao': description,
        'fk_competicao': region,
        'urlImagem': imageUrl,
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

  TeamDTO copyWith({String? id, String? name, String? description, String? region, String? imageUrl}) {
    return TeamDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      region: region ?? this.region,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, description, region, imageUrl];
}
