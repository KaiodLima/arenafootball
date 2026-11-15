import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/presentation/widgets/event_poll_parts.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card do evento de votação no feed: fundo escuro com o filete dourado, o
/// selo "EVENTO", o prazo, o título grande, as fotos das opções e o botão
/// "Votar" (aberto) ou "Ver resultado" (encerrado). O toque abre a página.
class EventPollFeedCard extends StatelessWidget {
  final NewsDTO news;
  final VoidCallback onTap;
  final Widget? trailing;

  /// Relógio (teste).
  final DateTime? now;

  const EventPollFeedCard({super.key, required this.news, required this.onTap, this.trailing, this.now});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final event = news.event ?? const EventPoll();
    final clock = now ?? DateTime.now();
    final open = event.isOpenAt(clock);
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s16),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          key: ValueKey('event-card-${news.id}'),
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: eventCardGradient,
              borderRadius: radius,
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 1.2),
              boxShadow: [
                BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    blurRadius: AppSizes.s12,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (news.imageUrl.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16 / 7,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(imageUrl: news.imageUrl, fit: BoxFit.cover),
                          // Funde a capa com o fundo escuro.
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColors.transparent, AppColors.primaryDark],
                                stops: [0.45, 1],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s8, 0),
                    child: Row(
                      children: [
                        const EventPollBadge(),
                        const SizedBox(width: AppSizes.s8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: EventStatusPill(event: event, now: clock),
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s10, AppSizes.s16, 0),
                    child: Text(
                      news.title.toUpperCase(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: eventDisplayFont,
                        fontSize: AppSizes.s24,
                        height: 1.1,
                        letterSpacing: 0.4,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  if (news.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s6, AppSizes.s16, 0),
                      child: Text(
                        news.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitle(color: AppColors.whiteSoft),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s16, AppSizes.s16),
                    child: Row(
                      children: [
                        _OptionsPreview(options: event.options),
                        const SizedBox(width: AppSizes.s10),
                        Expanded(
                          child: Text(
                            l10n.eventPollOptionsCount(event.options.length),
                            style: AppTypography.label(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                          ),
                        ),
                        _Cta(label: open ? l10n.eventPollVoteNow : l10n.eventPollSeeResult, gold: open),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Até 4 fotos sobrepostas das opções (com "+N").
class _OptionsPreview extends StatelessWidget {
  final List<EventPollOption> options;

  const _OptionsPreview({required this.options});

  @override
  Widget build(BuildContext context) {
    const size = AppSizes.s36;
    const step = AppSizes.s24;
    final shown = options.take(4).toList();
    final extra = options.length - shown.length;
    final count = shown.length + (extra > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();
    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: step * i,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.s2),
                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppSizes.s10)),
                child: EventOptionPhoto(option: shown[i], number: i + 1, size: size - AppSizes.s4),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: step * shown.length,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                ),
                child: Text('+$extra', style: AppTypography.label(color: AppColors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  final String label;
  final bool gold;

  const _Cta({required this.label, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s8),
      decoration: BoxDecoration(
        gradient: gold
            ? const LinearGradient(colors: [AppColors.medalGoldLight, AppColors.gold, AppColors.medalGoldDark])
            : null,
        color: gold ? null : AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            gold ? Icons.how_to_vote_rounded : Icons.bar_chart_rounded,
            size: AppSizes.s16,
            color: gold ? AppColors.black : AppColors.white,
          ),
          const SizedBox(width: AppSizes.s6),
          Text(
            label,
            style: AppTypography.label(color: gold ? AppColors.black : AppColors.white).copyWith(
              fontSize: AppSizes.s12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
