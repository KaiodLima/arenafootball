/// Vagas do parceiro: cada destaque e cada publicidade do dia tem um id de
/// documento fixo, e as regras do Firestore só aceitam as vagas dentro do
/// limite. Assim o limite vale sem contador nem function.
///
/// - Destaque: `dest<n>_<uid>` (n < `limiteDestaques`); apagar libera a vaga.
/// - Publicidade: `pub<n>_<uid>_<a>-<m>-<d>` (n < `limitePublicidadeDia`, data
///   de hoje em Brasília, sem zeros à esquerda — igual ao `firestore.rules`).
/// - Notícia: `not<n>_<uid>_<a>-<m>-<d>` (n < `limiteNoticiasDia`); sem vaga, a
///   notícia vai para o admin aprovar (`noticias_pendentes`).
class PartnerSlots {
  const PartnerSlots._();

  /// Marcadores das vagas do dia já usadas (`vagas_parceiro/{id da vaga}`):
  /// gravados junto com a notícia/publicidade e nunca apagados pelo parceiro,
  /// assim apagar a publicação não devolve a vaga no mesmo dia.
  static const String markersCollection = 'vagas_parceiro';

  /// `priority` do destaque do parceiro: depois dos do admin.
  static const String highlightPriority = '900';

  static String highlightId(String userId, int slot) => 'dest${slot}_$userId';

  static List<String> highlightIds(String userId, int limit) =>
      [for (var slot = 0; slot < limit; slot++) highlightId(userId, slot)];

  /// Dia de [now] no horário de Brasília (UTC-3, sem horário de verão).
  static String brasiliaDay(DateTime now) {
    final local = now.toUtc().subtract(const Duration(hours: 3));
    return '${local.year}-${local.month}-${local.day}';
  }

  static String adId(String userId, int slot, DateTime now) => 'pub${slot}_${userId}_${brasiliaDay(now)}';

  static List<String> adIds(String userId, int limit, DateTime now) =>
      [for (var slot = 0; slot < limit; slot++) adId(userId, slot, now)];

  static String newsId(String userId, int slot, DateTime now) => 'not${slot}_${userId}_${brasiliaDay(now)}';

  static List<String> newsIds(String userId, int limit, DateTime now) =>
      [for (var slot = 0; slot < limit; slot++) newsId(userId, slot, now)];

  /// Primeira vaga de [candidates] fora de [taken] (nula = limite atingido).
  static String? firstFree(List<String> candidates, Set<String> taken) {
    for (final id in candidates) {
      if (!taken.contains(id)) return id;
    }
    return null;
  }
}

/// Vagas do parceiro e quais já estão ocupadas.
class PartnerSlotUsage {
  final List<String> highlightIds;
  final Set<String> takenHighlights;
  final List<String> adIds;
  final Set<String> takenAds;
  final List<String> newsIds;
  final Set<String> takenNews;

  const PartnerSlotUsage({
    this.highlightIds = const [],
    this.takenHighlights = const {},
    this.adIds = const [],
    this.takenAds = const {},
    this.newsIds = const [],
    this.takenNews = const {},
  });

  int get usedHighlights => highlightIds.where(takenHighlights.contains).length;

  int get usedAds => adIds.where(takenAds.contains).length;

  String? get freeHighlight => PartnerSlots.firstFree(highlightIds, takenHighlights);

  String? get freeAd => PartnerSlots.firstFree(adIds, takenAds);

  int get usedNews => newsIds.where(takenNews.contains).length;

  String? get freeNews => PartnerSlots.firstFree(newsIds, takenNews);
}

/// Vínculo de destaques sem dono ao parceiro (feito pelo admin): cada destaque
/// vai para uma vaga livre `dest<n>_<uid>` e o limite sobe para caber.
class HighlightLinkPlan {
  /// Id antigo do destaque → id da vaga.
  final Map<String, String> slots;

  /// `limiteDestaques` depois do vínculo (nunca menor que o atual).
  final int highlightLimit;

  const HighlightLinkPlan({required this.slots, required this.highlightLimit});

  /// [claimed]: destaques a vincular (ainda sem dono), na ordem do pedido;
  /// [taken]: vagas já ocupadas. Sem vaga até [maxSlots], o que sobra fica de fora.
  factory HighlightLinkPlan.of({
    required String userId,
    required int currentLimit,
    required List<String> claimed,
    required Set<String> taken,
    int maxSlots = 9,
  }) {
    final free = PartnerSlots.highlightIds(userId, maxSlots).where((id) => !taken.contains(id)).toList();
    final slots = <String, String>{};
    for (var i = 0; i < claimed.length && i < free.length; i++) {
      slots[claimed[i]] = free[i];
    }
    var limit = currentLimit;
    for (final slot in slots.values) {
      final number = int.parse(slot.substring(4, slot.indexOf('_')));
      if (number + 1 > limit) limit = number + 1;
    }
    return HighlightLinkPlan(slots: slots, highlightLimit: limit);
  }
}
