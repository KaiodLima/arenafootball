import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arena_soccer/core/utils/search_text.dart';

/// Região: doc da coleção `competicao` ([id] = id do doc, [name] = `nome`).
class RegionRef {
  final String id;
  final String name;

  const RegionRef({required this.id, required this.name});

  @override
  bool operator ==(Object other) => other is RegionRef && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// Vínculo da região por id (como o dos times): os docs gravam `idRegiao` e,
/// ao lado, o nome em `fk_competicao` (ou `regiao`) só como cópia. As regiões
/// carregadas ficam aqui (como as temporadas em `SeasonCollection`): os DTOs
/// mostram o nome **atual** pelo id e as consultas filtram pelo id. Renomear
/// uma região, então, é só trocar o `nome` em `competicao`.
abstract final class RegionRegistry {
  /// Campo do id da região nos docs.
  static const String idField = 'idRegiao';

  /// Campo antigo/cópia do nome (conteúdo). Pedidos usam `regiao`.
  static const String nameField = 'fk_competicao';

  static List<RegionRef> _regions = const [];

  static List<RegionRef> get regions => _regions;

  /// Chamado ao carregar as regiões (`RegionsDataSource.getRegions`).
  static void configure(List<RegionRef> regions) => _regions = List.unmodifiable(regions);

  static void reset() => _regions = const [];

  /// Id da região de nome [name] ('' se não houver; ignora acento e caixa).
  static String idOf(String name) {
    final key = foldForSearch(name.trim());
    if (key.isEmpty) return '';
    for (final region in _regions) {
      if (foldForSearch(region.name.trim()) == key) return region.id;
    }
    return '';
  }

  /// Nome atual da região [id]; sem id (doc antigo) ou id desconhecido, o
  /// nome gravado no doc ([fallback]).
  static String nameOf(String id, {String fallback = ''}) {
    if (id.isNotEmpty) {
      for (final region in _regions) {
        if (region.id == id) return region.name;
      }
    }
    return fallback;
  }

  /// Nome a mostrar de um doc: pelo `idRegiao`; senão, a cópia em [nameKey].
  static String nameFromDoc(Map<String, dynamic> data, {String nameKey = nameField}) =>
      nameOf(data[idField]?.toString() ?? '', fallback: data[nameKey]?.toString() ?? '');

  /// Campos para gravar a região [name]: o nome (cópia) e, se conhecido, o id.
  static Map<String, dynamic> fieldsFor(String name, {String nameKey = nameField}) {
    final id = idOf(name);
    return {nameKey: name, if (id.isNotEmpty) idField: id};
  }

  /// Filtro de região: pelo id quando a região é conhecida; senão pelo nome
  /// (doc antigo, região fora da lista).
  static Query<Map<String, dynamic>> where(Query<Map<String, dynamic>> query, String name) {
    final id = idOf(name);
    return id.isNotEmpty ? query.where(idField, isEqualTo: id) : query.where(nameField, isEqualTo: name);
  }
}
