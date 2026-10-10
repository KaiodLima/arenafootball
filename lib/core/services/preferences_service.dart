import 'package:shared_preferences/shared_preferences.dart';

/// Preferências locais do usuário (região e temporada escolhidas).
/// As chaves são as mesmas usadas pelas versões anteriores do app, para
/// não perder a escolha de quem atualizar.
class PreferencesService {
  static const String _regionKey = 'regiaoPadrao';
  static const String _seasonKey = 'anoEscolhido';

  Future<String?> getRegion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_regionKey);
  }

  Future<void> setRegion(String region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, region);
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
