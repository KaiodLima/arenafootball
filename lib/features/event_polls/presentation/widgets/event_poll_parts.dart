import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Fonte de destaque dos títulos do evento (a mesma das artes).
const String eventDisplayFont = 'Anton';

/// Degradê escuro dos cards do evento, com o dourado nas bordas.
const LinearGradient eventCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primaryDark, AppColors.black],
);

/// "2d 4h", "5h 20min", "12min" até [closesAt]; já passou = vazio.
String eventRemaining(DateTime closesAt, DateTime now) {
  final left = closesAt.difference(now);
  if (left.isNegative) return '';
  if (left.inDays > 0) return '${left.inDays}d ${left.inHours % 24}h';
  if (left.inHours > 0) return '${left.inHours}h ${left.inMinutes % 60}min';
  return '${left.inMinutes < 1 ? 1 : left.inMinutes}min';
}

/// "Encerra em 2d 4h" ou "Encerrado"; sem prazo e aberto, vazio.
String eventStatusLabel(AppLocalizations l10n, EventPoll event, DateTime now) {
  if (!event.isOpenAt(now)) return l10n.eventPollEnded;
  final closesAt = event.closesAt;
  return closesAt == null ? '' : l10n.eventPollEndsIn(eventRemaining(closesAt, now));
}

/// Selo dourado "🏆 EVENTO".
class EventPollBadge extends StatelessWidget {
  const EventPollBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.medalGoldLight, AppColors.gold, AppColors.medalGoldDark]),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded, size: AppSizes.s14, color: AppColors.black),
          const SizedBox(width: AppSizes.s4),
          Text(
            l10n.eventPollTag,
            style: AppTypography.label(color: AppColors.black).copyWith(
              fontSize: AppSizes.s12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pílula do prazo: relógio + "Encerra em…" (aberto) ou cadeado + "Encerrado".
class EventStatusPill extends StatelessWidget {
  final EventPoll event;
  final DateTime now;

  const EventStatusPill({super.key, required this.event, required this.now});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final open = event.isOpenAt(now);
    final label = eventStatusLabel(l10n, event, now);
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(
        color: open ? AppColors.white.withValues(alpha: 0.12) : AppColors.danger.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(open ? Icons.schedule_rounded : Icons.lock_rounded, size: AppSizes.s14, color: AppColors.white),
          const SizedBox(width: AppSizes.s4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Foto da opção (quadrado arredondado); sem foto, o número da opção.
class EventOptionPhoto extends StatelessWidget {
  final EventPollOption option;
  final int number;
  final double size;

  const EventOptionPhoto({super.key, required this.option, required this.number, this.size = AppSizes.s56});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.22);
    final fallback = DecoratedBox(
      decoration: BoxDecoration(gradient: eventCardGradient, borderRadius: radius),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(fontFamily: eventDisplayFont, fontSize: size * 0.42, color: AppColors.gold),
        ),
      ),
    );
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: radius,
        child: option.imageUrl.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: option.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

/// Nome da rede no botão ("Ver no Instagram"); outra = "Ver vídeo".
String socialNetworkName(SocialNetwork network) => switch (network) {
      SocialNetwork.instagram => 'Instagram',
      SocialNetwork.youtube => 'YouTube',
      SocialNetwork.tiktok => 'TikTok',
      SocialNetwork.facebook => 'Facebook',
      SocialNetwork.x => 'X',
      SocialNetwork.other => '',
    };

Color _networkColor(SocialNetwork network) => switch (network) {
      SocialNetwork.instagram => AppColors.teamPink,
      SocialNetwork.youtube => AppColors.danger,
      SocialNetwork.tiktok => AppColors.black,
      SocialNetwork.facebook => AppColors.teamBlue,
      SocialNetwork.x => AppColors.black,
      SocialNetwork.other => AppColors.primary,
    };

/// Abre o link fora do app (o app da rede, se instalado). Trocável no teste.
class EventLinkOpener {
  static Future<bool> Function(Uri uri) open = (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Botão "▶ Ver no Instagram" da opção.
class EventVideoButton extends StatelessWidget {
  final String link;

  const EventVideoButton({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final network = SocialLink.of(link);
    if (network == null) return const SizedBox.shrink();
    final name = socialNetworkName(network);
    final color = _networkColor(network);
    return Material(
      color: color.withValues(alpha: 0.1),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {
          final uri = Uri.tryParse(link.trim());
          if (uri != null) EventLinkOpener.open(uri);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s6, AppSizes.s4, AppSizes.s10, AppSizes.s4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_fill_rounded, size: AppSizes.s18, color: color),
              const SizedBox(width: AppSizes.s4),
              Flexible(
                child: Text(
                  name.isEmpty ? l10n.eventPollOpenLink : l10n.eventPollWatchOn(name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
