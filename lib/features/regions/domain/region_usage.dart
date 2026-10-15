import 'package:equatable/equatable.dart';

/// O que pode estar ligado a uma região (conta para bloquear a exclusão).
enum RegionUsageKind { teams, matches, news, championships, groups }

/// Quanto conteúdo a região ainda tem, somando todas as temporadas.
class RegionUsage extends Equatable {
  final Map<RegionUsageKind, int> counts;

  const RegionUsage(this.counts);

  int of(RegionUsageKind kind) => counts[kind] ?? 0;

  bool get isEmpty => counts.values.every((count) => count == 0);

  @override
  List<Object?> get props => [counts];
}

/// Resultado da manutenção "Vincular regiões por id".
class RegionLinkReport extends Equatable {
  /// Documentos que ganharam o `idRegiao`, por coleção (nome da coleção).
  final Map<String, int> updated;

  /// Nomes de região gravados nos docs que não batem com nenhuma região.
  final List<String> unmatched;

  const RegionLinkReport({this.updated = const {}, this.unmatched = const []});

  int get total => updated.values.fold(0, (sum, count) => sum + count);

  @override
  List<Object?> get props => [updated, unmatched];
}
