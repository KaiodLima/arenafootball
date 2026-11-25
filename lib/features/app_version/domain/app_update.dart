import 'package:equatable/equatable.dart';

/// Nível do aviso de atualização: nenhum, sugerido (fecha com "Depois") ou
/// obrigatório (só "Atualizar agora").
enum AppUpdateLevel { none, recommended, required }

/// Versões exigidas pelo admin (`config/versao`), por plataforma, pelo número
/// do build (o `+N` do `pubspec.yaml`: `versionCode` no Android,
/// `CFBundleVersion` no iOS). 0 = sem exigência.
class AppVersionConfig extends Equatable {
  final int minAndroid;
  final int recommendedAndroid;
  final int minIos;
  final int recommendedIos;

  /// "O que há de novo" (opcional), mostrado no aviso.
  final String message;

  const AppVersionConfig({
    this.minAndroid = 0,
    this.recommendedAndroid = 0,
    this.minIos = 0,
    this.recommendedIos = 0,
    this.message = '',
  });

  static int _int(Object? value) => (value as num?)?.toInt() ?? 0;

  factory AppVersionConfig.fromMap(Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};
    return AppVersionConfig(
      minAndroid: _int(map['minimoAndroid']),
      recommendedAndroid: _int(map['recomendadoAndroid']),
      minIos: _int(map['minimoIos']),
      recommendedIos: _int(map['recomendadoIos']),
      message: map['mensagem']?.toString().trim() ?? '',
    );
  }

  /// O que o admin grava (sem `atualizadoEm`, posto pelo data source).
  Map<String, dynamic> toMap() => {
        'minimoAndroid': minAndroid,
        'recomendadoAndroid': recommendedAndroid,
        'minimoIos': minIos,
        'recomendadoIos': recommendedIos,
        'mensagem': message.trim(),
      };

  /// Para o cache local (mesmos campos do doc, todos JSON).
  Map<String, dynamic> toCache() => toMap();

  factory AppVersionConfig.fromCache(Map<String, dynamic> json) => AppVersionConfig.fromMap(json);

  int minFor({required bool ios}) => ios ? minIos : minAndroid;

  int recommendedFor({required bool ios}) => ios ? recommendedIos : recommendedAndroid;

  AppVersionConfig copyWith({
    int? minAndroid,
    int? recommendedAndroid,
    int? minIos,
    int? recommendedIos,
    String? message,
  }) =>
      AppVersionConfig(
        minAndroid: minAndroid ?? this.minAndroid,
        recommendedAndroid: recommendedAndroid ?? this.recommendedAndroid,
        minIos: minIos ?? this.minIos,
        recommendedIos: recommendedIos ?? this.recommendedIos,
        message: message ?? this.message,
      );

  /// Mínimo ≤ recomendado nas duas plataformas (a regra do Firestore exige).
  bool get isValid => minAndroid <= recommendedAndroid && minIos <= recommendedIos;

  @override
  List<Object?> get props => [minAndroid, recommendedAndroid, minIos, recommendedIos, message];
}

/// O aviso para o build [installed]: abaixo do mínimo = obrigatório; abaixo do
/// recomendado = sugerido; senão, nenhum. Build desconhecido (0) = nenhum.
AppUpdateLevel appUpdateLevel(int installed, AppVersionConfig config, {required bool ios}) {
  if (installed <= 0) return AppUpdateLevel.none;
  if (installed < config.minFor(ios: ios)) return AppUpdateLevel.required;
  if (installed < config.recommendedFor(ios: ios)) return AppUpdateLevel.recommended;
  return AppUpdateLevel.none;
}

/// Lojas do app (as mesmas da página dos links, `functions/src/share_page.ts`).
abstract final class AppStores {
  static const String playStore = 'https://play.google.com/store/apps/details?id=com.caiolima.arenafootball';
  static const String appStore = 'https://apps.apple.com/us/app/arena-football/id6823678208';

  static String forPlatform({required bool ios}) => ios ? appStore : playStore;
}
