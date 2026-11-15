import 'package:equatable/equatable.dart';

/// Uma opção do evento de votação: título ("Gol do Dudu"), subtítulo
/// ("Lava Jato x Volta"), foto opcional e o link do vídeo do lance numa rede
/// social (opcional).
class EventPollOption extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String link;

  const EventPollOption({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.link = '',
  });

  bool get hasLink => link.trim().isNotEmpty;

  factory EventPollOption.fromMap(Map<String, dynamic> data) => EventPollOption(
        id: data['id']?.toString() ?? '',
        title: data['titulo']?.toString() ?? '',
        subtitle: data['subtitulo']?.toString() ?? '',
        imageUrl: data['urlImagem']?.toString() ?? '',
        link: data['link']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': title,
        if (subtitle.isNotEmpty) 'subtitulo': subtitle,
        if (imageUrl.isNotEmpty) 'urlImagem': imageUrl,
        if (link.isNotEmpty) 'link': link,
      };

  EventPollOption copyWith({String? title, String? subtitle, String? imageUrl, String? link}) => EventPollOption(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        imageUrl: imageUrl ?? this.imageUrl,
        link: link ?? this.link,
      );

  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, link];
}

/// Evento de votação do admin (card `tag: "evento"` em `noticias`): as
/// opções, o prazo, o "Encerrar agora" e se o resultado parcial aparece.
class EventPoll extends Equatable {
  static const int minOptions = 2;
  static const int maxOptions = 8;

  final List<EventPollOption> options;

  /// Fim da votação (`encerraEm`); nulo = sem prazo (só pelo "Encerrar agora").
  final DateTime? closesAt;

  /// "Encerrar agora" do admin (`encerrado`).
  final bool closed;

  /// O resultado parcial aparece para quem já votou (`mostrarParcial`).
  final bool showPartial;

  const EventPoll({this.options = const [], this.closesAt, this.closed = false, this.showPartial = true});

  /// Aberto: não encerrado na mão e antes do prazo.
  bool isOpenAt(DateTime now) => !closed && (closesAt == null || now.isBefore(closesAt!));

  /// O resultado pode ser lido (as regras liberam o mesmo): parcial ligado
  /// ou evento encerrado.
  bool resultVisibleAt(DateTime now) => showPartial || !isOpenAt(now);

  EventPollOption? optionById(String id) {
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  /// Campos do doc (o prazo é gravado pelo DataSource, como Timestamp).
  Map<String, dynamic> toMap() => {
        'opcoes': [for (final option in options) option.toMap()],
        'idsOpcoes': [for (final option in options) option.id],
        'encerrado': closed,
        'mostrarParcial': showPartial,
      };

  factory EventPoll.fromMap(Map<String, dynamic> data, {DateTime? closesAt}) {
    final raw = data['opcoes'];
    return EventPoll(
      options: raw is List
          ? [
              for (final item in raw)
                if (item is Map) EventPollOption.fromMap(Map<String, dynamic>.from(item)),
            ]
          : const [],
      closesAt: closesAt,
      closed: data['encerrado'] == true,
      showPartial: data['mostrarParcial'] != false,
    );
  }

  /// Cache local: o prazo em ms.
  Map<String, dynamic> toCache() => {...toMap(), 'closesAt': closesAt?.millisecondsSinceEpoch};

  factory EventPoll.fromCache(Map<String, dynamic> json) {
    final ms = json['closesAt'] as num?;
    return EventPoll.fromMap(json, closesAt: ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms.toInt()));
  }

  EventPoll copyWith({List<EventPollOption>? options, DateTime? closesAt, bool? closed, bool? showPartial}) =>
      EventPoll(
        options: options ?? this.options,
        closesAt: closesAt ?? this.closesAt,
        closed: closed ?? this.closed,
        showPartial: showPartial ?? this.showPartial,
      );

  @override
  List<Object?> get props => [options, closesAt, closed, showPartial];
}

/// Apuração do evento (`noticias/{id}/apuracao/total`, gravada pelas
/// functions): votos por opção e o total.
class EventTally extends Equatable {
  final Map<String, int> votes;

  const EventTally([this.votes = const {}]);

  int get total => votes.values.fold(0, (sum, n) => sum + n);

  int votesOf(String optionId) => votes[optionId] ?? 0;

  /// Percentual inteiro (0–100) da opção; sem votos, 0.
  int percentOf(String optionId) => total == 0 ? 0 : (votesOf(optionId) * 100 / total).round();

  /// Fração (0–1) para a barra.
  double shareOf(String optionId) => total == 0 ? 0 : votesOf(optionId) / total;

  /// Vencedoras: a(s) com mais votos (empate = todas as empatadas); sem votos, nenhuma.
  Set<String> winners() {
    final most = votes.values.fold(0, (max, n) => n > max ? n : max);
    if (most == 0) return const {};
    return {
      for (final entry in votes.entries)
        if (entry.value == most) entry.key,
    };
  }

  factory EventTally.fromMap(Map<String, dynamic> data) {
    final raw = data['votos'];
    return EventTally({
      if (raw is Map)
        for (final entry in raw.entries)
          if (entry.value is num) entry.key.toString(): (entry.value as num).toInt(),
    });
  }

  @override
  List<Object?> get props => [votes];
}

/// Rede social do link do vídeo: o ícone e o nome no botão "Ver no …".
enum SocialNetwork { instagram, youtube, tiktok, facebook, x, other }

abstract final class SocialLink {
  /// A rede pelo endereço; link vazio ou inválido = nulo.
  static SocialNetwork? of(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    final host = uri.host.toLowerCase();
    bool on(List<String> domains) => domains.any((d) => host == d || host.endsWith('.$d'));
    if (on(['instagram.com', 'instagr.am'])) return SocialNetwork.instagram;
    if (on(['youtube.com', 'youtu.be'])) return SocialNetwork.youtube;
    if (on(['tiktok.com'])) return SocialNetwork.tiktok;
    if (on(['facebook.com', 'fb.watch', 'fb.com'])) return SocialNetwork.facebook;
    if (on(['x.com', 'twitter.com'])) return SocialNetwork.x;
    return SocialNetwork.other;
  }

  /// Link aceito no formulário: http(s) com host.
  static bool isValid(String link) {
    final uri = Uri.tryParse(link.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.contains('.');
  }
}
