import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Recusa da indicação, gravada pelas functions (`indicacoes/{uid}.recusa`).
enum ReferralRefusal {
  code('codigo'),
  own('propria'),
  oldAccount('conta_antiga');

  final String key;

  const ReferralRefusal(this.key);

  static ReferralRefusal? fromKey(String? key) => values.where((r) => r.key == key).firstOrNull;
}

/// `indicacoes/{uid}` (só as functions gravam): saldo de pacotinhos extras,
/// quantos amigos a conta indicou e se a indicação dela valeu.
class ReferralDTO extends Equatable {
  final int invited;
  final int extraPacks;
  final int extraPacksEarned;
  final bool validated;
  final ReferralRefusal? refusal;

  const ReferralDTO({
    this.invited = 0,
    this.extraPacks = 0,
    this.extraPacksEarned = 0,
    this.validated = false,
    this.refusal,
  });

  factory ReferralDTO.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const ReferralDTO();
    int count(Object? value) => value is num ? value.toInt() : 0;
    return ReferralDTO(
      invited: count(data['indicados']),
      extraPacks: count(data['pacotesExtras']),
      extraPacksEarned: count(data['pacotesExtrasGanhos']),
      validated: data['validadaEm'] != null,
      refusal: ReferralRefusal.fromKey(data['recusa']?.toString()),
    );
  }

  @override
  List<Object?> get props => [invited, extraPacks, extraPacksEarned, validated, refusal];
}

/// `config/indicacao`: o admin liga/desliga o "Indique amigos" (sem o doc =
/// desligado).
class ReferralConfigDTO extends Equatable {
  final bool enabled;

  const ReferralConfigDTO({this.enabled = false});

  factory ReferralConfigDTO.fromMap(Map<String, dynamic>? data) => ReferralConfigDTO(enabled: data?['ativo'] == true);

  @override
  List<Object?> get props => [enabled];
}

/// Amigo que entrou pelo convite (`indicacoes/{uid}/indicados/{uidAmigo}`).
class ReferredFriendDTO extends Equatable {
  final String id;
  final String name;
  final DateTime? at;

  const ReferredFriendDTO({required this.id, required this.name, this.at});

  factory ReferredFriendDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final at = data['em'];
    return ReferredFriendDTO(
      id: doc.id,
      name: (data['nome'] ?? '').toString(),
      at: at is Timestamp ? at.toDate() : null,
    );
  }

  @override
  List<Object?> get props => [id, name, at];
}
