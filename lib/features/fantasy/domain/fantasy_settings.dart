import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';

/// Padrões e faixas dos parâmetros do Arena Fantasy (as mesmas das regras do
/// Firestore).
class FantasyLimits {
  const FantasyLimits._();

  static const int defaultMinMinutes = 20;
  static const int defaultMinDefenseMinutes = 45;
  static const double defaultCaptain = 1.5;

  static const int maxMinutes = 120;
  static const int minutesStep = 5;
  static const double minCaptain = 1;
  static const double maxCaptain = 3;
  static const double captainStep = 0.1;
}

/// Problema nos parâmetros do Fantasy.
enum FantasySettingsError { minMinutesRange, defenseBelowMin, defenseRange, captainRange, formationTotal }

/// Regras puras da configuração do Fantasy.
class FantasySettings {
  const FantasySettings._();

  /// Nulo = parâmetros válidos.
  static FantasySettingsError? validate({
    required int minMinutes,
    required int minDefenseMinutes,
    required double captainMultiplier,
    FantasyFormation formation = FantasyFormation.defaults,
  }) {
    if (minMinutes < 0 || minMinutes > FantasyLimits.maxMinutes) return FantasySettingsError.minMinutesRange;
    if (minDefenseMinutes > FantasyLimits.maxMinutes) return FantasySettingsError.defenseRange;
    if (minDefenseMinutes < minMinutes) return FantasySettingsError.defenseBelowMin;
    if (captainMultiplier < FantasyLimits.minCaptain || captainMultiplier > FantasyLimits.maxCaptain) {
      return FantasySettingsError.captainRange;
    }
    if (!formation.isValid) return FantasySettingsError.formationTotal;
    return null;
  }

  /// Multiplicador arredondado a uma casa (evita 1.5000000001 do −/+).
  static double roundCaptain(double value) => (value * 10).round() / 10;

  /// "1,5×" / "2×" (vírgula decimal).
  static String captainLabel(double value) {
    final rounded = roundCaptain(value);
    final text = rounded == rounded.truncateToDouble() ? rounded.toInt().toString() : rounded.toString();
    return '${text.replaceAll('.', ',')}×';
  }
}
