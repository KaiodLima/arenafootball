import 'package:flutter/widgets.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/utils/components/tour/tour_overlay.dart';
import 'package:arena_soccer/utils/components/tour/tour_step.dart';

/// Ids dos tours (guardados como vistos no aparelho).
class TourIds {
  const TourIds._();

  static const String welcome = 'boas_vindas';
  static const String home = 'home';
  static const String tables = 'tabelas';
  static const String teams = 'times';
  static const String championships = 'campeonatos';
  static const String drawer = 'menu';
  static const String album = 'album';
}

/// Tutoriais no contexto: cada tour aparece uma vez, na primeira visita
/// àquela parte do app (o "Rever tutoriais" das configurações zera). Um por
/// vez; tour sem nenhum alvo na tela não conta como visto.
class TourService {
  final PreferencesService _preferences;
  bool _showing = false;

  TourService(this._preferences);

  bool get isShowing => _showing;

  Future<bool> isSeen(String id) async => (await _preferences.getSeenTours()).contains(id);

  Future<void> markSeen(String id) => _preferences.markTourSeen(id);

  Future<void> reset() => _preferences.resetTours();

  /// Mostra o tour [id] se ainda não foi visto, depois de [delay] (a tela
  /// assentar). [steps] é montado na hora (os alvos já na tela).
  Future<void> show(
    BuildContext context,
    String id,
    List<TourStep> Function() steps, {
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    if (_showing || await isSeen(id)) return;
    _showing = true;
    try {
      await Future<void>.delayed(delay);
      if (!context.mounted) return;
      final result = await showTourOverlay(context, steps());
      if (result != null) await markSeen(id);
    } finally {
      _showing = false;
    }
  }
}
