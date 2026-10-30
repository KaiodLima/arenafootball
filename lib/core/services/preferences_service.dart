import 'package:shared_preferences/shared_preferences.dart';

/// Preferências locais do usuário (região e temporada escolhidas).
/// As chaves são as mesmas usadas pelas versões anteriores do app, para
/// não perder a escolha de quem atualizar.
class PreferencesService {
  static const String _regionKey = 'regiaoPadrao';
  static const String _seasonKey = 'anoEscolhido';

  /// Id da região escolhida (o nome pode mudar; o id não).
  static const String _regionIdKey = 'regiaoPadraoId';

  /// Tutoriais (tours) já vistos neste aparelho.
  static const String _seenToursKey = 'tutoriaisVistos';

  Future<Set<String>> getSeenTours() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_seenToursKey) ?? const []).toSet();
  }

  Future<void> markTourSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = (prefs.getStringList(_seenToursKey) ?? const []).toSet()..add(id);
    await prefs.setStringList(_seenToursKey, seen.toList());
  }

  /// "Rever tutoriais": todos voltam a aparecer.
  Future<void> resetTours() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seenToursKey);
  }

  /// Ids das regiões escolhidas por último (seletor da home).
  static const String _recentRegionIdsKey = 'regioesRecentesIds';

  Future<List<String>> getRecentRegionIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentRegionIdsKey) ?? const [];
  }

  Future<void> setRecentRegionIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentRegionIdsKey, ids);
  }

  Future<String?> getRegion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_regionKey);
  }

  Future<void> setRegion(String region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, region);
  }

  Future<String?> getRegionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_regionIdKey);
  }

  Future<void> setRegionId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionIdKey, id);
  }

  Future<String?> getSeason() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_seasonKey);
  }

  Future<void> setSeason(String season) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_seasonKey, season);
  }
}
