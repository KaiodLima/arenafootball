import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Destino do toque numa notificação: a aba (`data.aba`) e, quando houver, a
/// tela específica (`data.tela`: partida, votação ou notícia, com `id` e
/// `temporada`), montados pelas Cloud Functions (`openData` em `messages.ts`).
class PushTarget extends Equatable {
  static const String matchScreen = 'partida';
  static const String votingScreen = 'votacao';
  static const String newsScreen = 'noticia';

  final String tab;
  final String screen;
  final String id;
  final String season;

  const PushTarget({this.tab = '', this.screen = '', this.id = '', this.season = ''});

  factory PushTarget.fromData(Map<String, dynamic> data) {
    String text(String key) => data[key]?.toString() ?? '';
    return PushTarget(tab: text('aba'), screen: text('tela'), id: text('id'), season: text('temporada'));
  }

  /// Payload da notificação local (mostrada com o app aberto).
  String toPayload() => jsonEncode({'aba': tab, 'tela': screen, 'id': id, 'temporada': season});

  /// Lê o payload; o antigo (só o nome da aba) também vale.
  static PushTarget? fromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) return PushTarget.fromData(data);
    } catch (_) {
      // Payload antigo: só a aba.
    }
    return PushTarget(tab: payload);
  }

  bool get isEmpty => tab.isEmpty && (screen.isEmpty || id.isEmpty);

  /// Abre uma tela específica (e não só a aba).
  bool get hasScreen => screen.isNotEmpty && id.isNotEmpty;

  @override
  List<Object?> get props => [tab, screen, id, season];
}
