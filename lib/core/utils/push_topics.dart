/// Tópicos FCM do app. O slug tem que bater com o das Cloud Functions
/// (functions/src/messages.ts): minúsculas, sem acento, e o que não for
/// [a-z0-9] vira "_" ("Santo inácio" → "santo_inacio").
library;

const String allTopic = 'todos';

/// Administradores (novos pedidos "Sou jogador").
const String adminsTopic = 'admins';

const _accents = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
  'ç': 'c', 'ñ': 'n',
};

String topicSlug(String value) {
  final folded = value.toLowerCase().split('').map((char) => _accents[char] ?? char).join();
  return folded.replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
}

String regionTopic(String region) => 'regiao_${topicSlug(region)}';

String teamTopic(String team) => 'time_${topicSlug(team)}';

/// Avisos de um usuário só (resposta do pedido "Sou jogador"). O uid já é
/// alfanumérico: vai sem slug, igual ao `userTopic` das functions.
String userTopic(String userId) => 'usuario_$userId';

/// Tópicos que o aparelho deve assinar: todos, a região escolhida, o time
/// do coração (se houver), o do próprio usuário (logado) e o dos admins.
Set<String> desiredTopics({required String region, String? favoriteTeam, String? userId, bool isAdmin = false}) {
  return {
    allTopic,
    if (topicSlug(region).isNotEmpty) regionTopic(region),
    if (favoriteTeam != null && topicSlug(favoriteTeam).isNotEmpty) teamTopic(favoriteTeam),
    if (userId != null && userId.isNotEmpty) userTopic(userId),
    if (isAdmin) adminsTopic,
  };
}
