import 'dart:typed_data';

/// Regulamento escolhido no aparelho para enviar (PDF).
class ChampionshipRulesFile {
  final Uint8List bytes;
  final String name;

  const ChampionshipRulesFile({required this.bytes, required this.name});
}
