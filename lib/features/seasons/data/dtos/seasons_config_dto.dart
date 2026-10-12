import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Documento `config/temporadas`: temporada atual e as disponíveis no seletor.
class SeasonsConfigDTO extends Equatable {
  final String current;
  final List<String> seasons;

  const SeasonsConfigDTO({required this.current, required this.seasons});

  factory SeasonsConfigDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return SeasonsConfigDTO(
      current: data['atual']?.toString() ?? '',
      seasons: (data['lista'] as List?)?.map((s) => s.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toMap() => {'atual': current, 'lista': seasons};

  /// Próximo ano depois da atual ("2023" → "2024").
  static String nextSeason(String current) => '${(int.tryParse(current) ?? DateTime.now().year) + 1}';

  @override
  List<Object?> get props => [current, seasons];
}
