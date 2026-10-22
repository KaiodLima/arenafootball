import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';

/// Conquista do catálogo (`conquistas/{id}`, criada pelo admin): medalha
/// ganha quando a [metric] do usuário chega à [goal].
class AchievementDTO extends Equatable {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;

  /// Chave do ícone (`achievementIcons`).
  final String icon;
  final AchievementTier tier;

  /// Métrica medida (`metrica`); nula se o doc tiver uma chave desconhecida
  /// (app antigo diante de métrica nova): a conquista não aparece.
  final AchievementMetric? metric;
  final int goal;

  /// XP que a conquista dá.
  final int points;

  /// Bloqueada aparece como "?" (não revela o que é).
  final bool secret;

  /// Inativa não aparece nem é desbloqueada.
  final bool active;
  final int order;

  const AchievementDTO({
    this.id = '',
    required this.title,
    this.description = '',
    this.category = AchievementCategory.fan,
    this.icon = 'trophy',
    this.tier = AchievementTier.bronze,
    required this.metric,
    this.goal = 1,
    this.points = 10,
    this.secret = false,
    this.active = true,
    this.order = 0,
  });

  static int _int(Object? value, int fallback) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? fallback;

  factory AchievementDTO.fromMap(String id, Map<String, dynamic> data) => AchievementDTO(
        id: id,
        title: data['titulo']?.toString() ?? '',
        description: data['descricao']?.toString() ?? '',
        category: AchievementCategory.fromKey(data['categoria']?.toString()),
        icon: data['icone']?.toString() ?? 'trophy',
        tier: AchievementTier.fromKey(data['nivel']?.toString()),
        metric: AchievementMetric.fromKey(data['metrica']?.toString()),
        goal: _int(data['meta'], 1).clamp(1, 1000000),
        points: _int(data['pontos'], 0).clamp(0, 100000),
        secret: data['secreta'] == true,
        active: data['ativa'] != false,
        order: _int(data['ordem'], 0),
      );

  factory AchievementDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) =>
      AchievementDTO.fromMap(doc.id, doc.data() ?? const {});

  Map<String, dynamic> toMap() => {
        'titulo': title,
        'descricao': description,
        'categoria': category.key,
        'icone': icon,
        'nivel': tier.key,
        'metrica': metric?.key ?? '',
        'meta': goal,
        'pontos': points,
        'secreta': secret,
        'ativa': active,
        'ordem': order,
      };

  AchievementDTO copyWith({
    String? id,
    String? title,
    String? description,
    AchievementCategory? category,
    String? icon,
    AchievementTier? tier,
    AchievementMetric? metric,
    int? goal,
    int? points,
    bool? secret,
    bool? active,
    int? order,
  }) {
    return AchievementDTO(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      tier: tier ?? this.tier,
      metric: metric ?? this.metric,
      goal: goal ?? this.goal,
      points: points ?? this.points,
      secret: secret ?? this.secret,
      active: active ?? this.active,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, category, icon, tier, metric, goal, points, secret, active, order];
}
