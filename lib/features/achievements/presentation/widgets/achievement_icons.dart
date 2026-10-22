import 'package:flutter/material.dart';

/// Ícones que o admin escolhe para as medalhas (chave gravada em `icone`).
const Map<String, IconData> achievementIcons = {
  'trophy': Icons.emoji_events_rounded,
  'medal': Icons.military_tech_rounded,
  'crown': Icons.workspace_premium_rounded,
  'star': Icons.star_rounded,
  'diamond': Icons.diamond_rounded,
  'heart': Icons.favorite_rounded,
  'camera': Icons.photo_camera_rounded,
  'calendar': Icons.calendar_month_rounded,
  'stadium': Icons.stadium_rounded,
  'fire': Icons.local_fire_department_rounded,
  'bolt': Icons.bolt_rounded,
  'vote': Icons.how_to_vote_rounded,
  'whistle': Icons.sports_rounded,
  'megaphone': Icons.campaign_rounded,
  'share': Icons.share_rounded,
  'rocket': Icons.rocket_launch_rounded,
  'news': Icons.newspaper_rounded,
  'eye': Icons.visibility_rounded,
  'ball': Icons.sports_soccer_rounded,
  'target': Icons.gps_fixed_rounded,
  'handshake': Icons.handshake_rounded,
  'shield': Icons.shield_rounded,
  'flag': Icons.flag_rounded,
  'groups': Icons.groups_rounded,
};

IconData achievementIcon(String key) => achievementIcons[key] ?? Icons.emoji_events_rounded;
