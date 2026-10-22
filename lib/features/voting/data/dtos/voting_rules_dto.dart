import 'package:equatable/equatable.dart';

/// Regras da votação de melhor jogador (`config/votacao`, ajustáveis pelo
/// admin): mínimo de votos e porcentagem mínima do mais votado. Doc ausente
/// = os padrões.
class VotingRulesDTO extends Equatable {
  static const int defaultMinVotes = 20;
  static const int defaultMinPercent = 35;

  final int minVotes;

  /// Porcentagem (0–100) dos votos que o mais votado precisa ter.
  final int minPercent;

  const VotingRulesDTO({this.minVotes = defaultMinVotes, this.minPercent = defaultMinPercent});

  static int _int(Object? value, int fallback) {
    final parsed = value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
    return parsed == null || parsed < 0 ? fallback : parsed;
  }

  factory VotingRulesDTO.fromMap(Map<String, dynamic>? data) => VotingRulesDTO(
        minVotes: _int(data?['minVotos'], defaultMinVotes),
        minPercent: _int(data?['percentualMinimo'], defaultMinPercent).clamp(0, 100),
      );

  Map<String, dynamic> toMap() => {'minVotos': minVotes, 'percentualMinimo': minPercent};

  factory VotingRulesDTO.fromCache(Map<String, dynamic> json) => VotingRulesDTO.fromMap(json);

  Map<String, dynamic> toCache() => toMap();

  @override
  List<Object?> get props => [minVotes, minPercent];
}
