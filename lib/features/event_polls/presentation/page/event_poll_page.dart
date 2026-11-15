import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/presentation/bloc/event_poll_cubit.dart';
import 'package:arena_soccer/features/event_polls/presentation/bloc/event_poll_state.dart';
import 'package:arena_soccer/features/event_polls/presentation/widgets/event_poll_parts.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/share_art/domain/event_result_art_data.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/features/qr_codes/domain/qr_target.dart';
import 'package:arena_soccer/features/qr_codes/presentation/page/qr_poster_page.dart';

/// Página do evento de votação: cabeçalho com capa, título e prazo; as
/// opções com foto e o botão do vídeo; votar (escolhe e confirma, voto
/// único); a parcial (se o admin ligou) e o resultado final com a vencedora.
class EventPollPage extends StatefulWidget {
  final String eventId;
  final NewsDTO? initial;

  const EventPollPage({super.key, required this.eventId, this.initial});

  @override
  State<EventPollPage> createState() => _EventPollPageState();
}

class _EventPollPageState extends State<EventPollPage> {
  late final EventPollCubit _cubit;
  Timer? _clock;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<EventPollCubit>(context);
    final session = BlocProvider.of<SessionCubit>(context).state;
    _cubit.start(
      id: widget.eventId,
      initial: widget.initial,
      userId: session.user?.id,
      isAdmin: session.isAdmin,
    );
    // A contagem e o fim do prazo andam com a tela aberta.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {});
      _cubit.tick();
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  DateTime get _now => _cubit.now();

  Future<void> _confirmVote(EventPollOption option) async {
    final l10n = AppLocalizations.of(context);
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (user == null) return;
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.eventPollConfirmTitle(option.title),
      message: l10n.eventPollConfirmMessage,
      confirmLabel: l10n.eventPollConfirm,
      icon: Icons.how_to_vote_rounded,
    );
    if (!confirmed || !mounted) return;
    await _cubit.vote(optionId: option.id, userId: user.id, name: user.name);
  }

  Future<void> _confirmClose() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.eventPollCloseConfirm,
      message: l10n.eventPollCloseMessage,
      confirmLabel: l10n.eventPollCloseNow,
      icon: Icons.lock_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await _cubit.closeEvent();
  }

  /// Arte do resultado (encerrado e com votos): sem leitura nova.
  void _openResultArt(EventPollState state) {
    final news = state.news;
    final tally = state.tally;
    if (news == null || tally == null) return;
    Navigator.pushNamed(
      context,
      AppRoutes.eventResultArtPage,
      arguments: {'data': EventResultArtData.of(news, tally)},
    );
  }

  /// Pode gerar a arte: encerrado, com a apuração lida e com votos.
  bool _canShareResult(EventPollState state, DateTime now) =>
      !state.event.isOpenAt(now) && (state.tally?.total ?? 0) > 0;

  void _onNotice(BuildContext context, EventPollState state) {
    final l10n = AppLocalizations.of(context);
    switch (state.notice) {
      case EventPollNotice.voted:
        showSnackBar(context: context, message: l10n.eventPollVoted);
      case EventPollNotice.closed:
        showSnackBar(context: context, message: l10n.eventPollClosedNotice);
      case EventPollNotice.error:
        showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<SessionCubit>().state;
    final isAdmin = session.isAdmin;

    return BlocConsumer<EventPollCubit, EventPollState>(
      listenWhen: (previous, current) => previous.noticeSeq != current.noticeSeq,
      listener: _onNotice,
      builder: (context, state) {
        final news = state.news;
        final event = state.event;
        final now = _now;
        final open = event.isOpenAt(now);
        final canVote = open && !state.hasVoted && session.user != null;
        final selected = canVote ? event.optionById(_selected ?? '') : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              l10n.eventPollMenu,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
            actions: [
              if (_canShareResult(state, now))
                IconButton(
                  key: const ValueKey('event-share-result'),
                  tooltip: l10n.eventPollShareResult,
                  icon: const Icon(Icons.ios_share_rounded),
                  onPressed: () => _openResultArt(state),
                ),
              if (isAdmin && news != null) ...[
                IconButton(
                  key: const ValueKey('event-qr'),
                  tooltip: l10n.qrMenu,
                  icon: const Icon(Icons.qr_code_2_rounded),
                  onPressed: () => openQrPoster(context, QrTarget.event(news)),
                ),
                IconButton(
                  tooltip: l10n.eventPollFormTitleEdit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.eventPollFormPage, arguments: {'news': news}),
                ),
                if (open)
                  IconButton(
                    key: const ValueKey('event-close'),
                    tooltip: l10n.eventPollCloseNow,
                    icon: const Icon(Icons.lock_clock_rounded),
                    onPressed: _confirmClose,
                  ),
              ],
            ],
          ),
          bottomNavigationBar: selected == null
              ? null
              : ArenaSubmitBar(
                  title: l10n.eventPollVoteFor(selected.title.toUpperCase()),
                  loading: state.voting,
                  onPressed: () => _confirmVote(selected),
                ),
          body: news == null
              ? (state.notFound
                  ? ArenaEmptyState(message: l10n.eventPollNotFound, icon: Icons.how_to_vote_outlined)
                  : const Center(child: CircularProgressIndicator(color: AppColors.primary)))
              : _body(context, state, news, event, now, canVote, selected),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    EventPollState state,
    NewsDTO news,
    EventPoll event,
    DateTime now,
    bool canVote,
    EventPollOption? selected,
  ) {
    final l10n = AppLocalizations.of(context);
    final open = event.isOpenAt(now);
    final tally = state.tally;
    // Barras: com a apuração lida e (encerrado, ou parcial ligado e já votou, ou admin).
    final isAdmin = BlocProvider.of<SessionCubit>(context).state.isAdmin;
    final showResult = tally != null && (!open || (event.showPartial && state.hasVoted) || isAdmin);
    final winners = !open && tally != null ? tally.winners() : const <String>{};
    final loggedIn = BlocProvider.of<SessionCubit>(context).state.user != null;

    final String? hint;
    if (!open) {
      hint = null;
    } else if (!loggedIn) {
      hint = l10n.eventPollSignIn;
    } else if (!state.hasVoted) {
      hint = l10n.eventPollTapToVote;
    } else if (!event.showPartial) {
      hint = l10n.eventPollHiddenResult;
    } else {
      hint = null;
    }

    return ListView(
      padding: EdgeInsets.only(bottom: selected != null ? AppSizes.s24 : safeBottom(context, AppSizes.s32)),
      children: [
        _Header(news: news, event: event, now: now),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (showResult ? (open ? l10n.eventPollPartial : l10n.eventPollFinal) : l10n.eventPollSectionOptions)
                          .toUpperCase(),
                      style: AppTypography.label(color: AppColors.textSecondary)
                          .copyWith(fontSize: AppSizes.s12, letterSpacing: 1.1),
                    ),
                  ),
                  if (showResult)
                    Text(
                      l10n.eventPollVotesCount(tally.total),
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                ],
              ),
              if (hint != null) ...[
                const SizedBox(height: AppSizes.s8),
                _Hint(text: hint, icon: state.hasVoted ? Icons.check_circle_rounded : Icons.touch_app_rounded),
              ],
              if (!open && tally != null && tally.total == 0) ...[
                const SizedBox(height: AppSizes.s8),
                _Hint(text: l10n.eventPollNoVotes, icon: Icons.info_outline_rounded),
              ],
              const SizedBox(height: AppSizes.s10),
              for (var i = 0; i < event.options.length; i++)
                _OptionTile(
                  key: ValueKey('event-option-${event.options[i].id}'),
                  option: event.options[i],
                  number: i + 1,
                  selectable: canVote,
                  selected: selected?.id == event.options[i].id,
                  mine: state.myVote == event.options[i].id,
                  tally: showResult ? tally : null,
                  winner: winners.contains(event.options[i].id),
                  tie: winners.length > 1,
                  onTap: canVote ? () => setState(() => _selected = event.options[i].id) : null,
                ),
              if (_canShareResult(state, now)) ...[
                const SizedBox(height: AppSizes.s6),
                FilledButton.icon(
                  key: const ValueKey('event-share-result-button'),
                  onPressed: () => _openResultArt(state),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.s14)),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.gold),
                  label: Text(l10n.eventPollShareResult),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Cabeçalho: capa (ou o fundo da marca), selo, prazo, título e descrição.
class _Header extends StatelessWidget {
  final NewsDTO news;
  final EventPoll event;
  final DateTime now;

  const _Header({required this.news, required this.event, required this.now});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s20, AppSizes.s20, AppSizes.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const EventPollBadge(),
              const SizedBox(width: AppSizes.s8),
              Flexible(child: EventStatusPill(event: event, now: now)),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          Text(
            news.title.toUpperCase(),
            style: TextStyle(
              fontFamily: eventDisplayFont,
              fontSize: AppSizes.s28,
              height: 1.1,
              letterSpacing: 0.4,
              color: AppColors.white,
              shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.4), offset: const Offset(0, 2))],
            ),
          ),
          if (news.description.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s8),
            Text(news.description, style: AppTypography.subtitle(color: AppColors.whiteSoft)),
          ],
        ],
      ),
    );

    if (news.imageUrl.isEmpty) return ArenaHeroBackground(watermarkFactor: 0.8, child: content);
    return Stack(
      children: [
        Positioned.fill(child: CachedNetworkImage(imageUrl: news.imageUrl, fit: BoxFit.cover)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.black.withValues(alpha: 0.2), AppColors.primaryDark],
              ),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(top: AppSizes.s80), child: content),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Hint({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.s12),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.s18, color: AppColors.primary),
          const SizedBox(width: AppSizes.s8),
          Expanded(child: Text(text, style: AppTypography.body().copyWith(fontSize: AppSizes.s14))),
        ],
      ),
    );
  }
}

/// Uma opção: foto, título, detalhe e o vídeo; para votar, o marcador; com a
/// apuração, a barra com % e votos; a vencedora ganha moldura dourada e coroa.
class _OptionTile extends StatelessWidget {
  final EventPollOption option;
  final int number;
  final bool selectable;
  final bool selected;
  final bool mine;
  final EventTally? tally;
  final bool winner;
  final bool tie;
  final VoidCallback? onTap;

  const _OptionTile({
    super.key,
    required this.option,
    required this.number,
    required this.selectable,
    required this.selected,
    required this.mine,
    required this.tally,
    required this.winner,
    required this.tie,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tally = this.tally;
    final borderColor = winner
        ? AppColors.gold
        : selected
            ? AppColors.primary
            : mine
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.transparent;
    final radius = BorderRadius.circular(AppSizes.s16);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s10),
      child: Material(
        color: winner ? AppColors.gold.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s12),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor, width: winner || selected ? 2 : 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        EventOptionPhoto(option: option, number: number, size: AppSizes.s64),
                        if (winner)
                          const Positioned(
                            top: -AppSizes.s10,
                            left: -AppSizes.s6,
                            child: Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: AppSizes.s28),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSizes.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (winner)
                            Text(
                              tie ? l10n.eventPollTie : l10n.eventPollWinner,
                              style: AppTypography.label(color: AppColors.medalGoldDark).copyWith(
                                fontSize: AppSizes.s10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          Text(
                            option.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
                          ),
                          if (option.subtitle.isNotEmpty)
                            Text(
                              option.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                            ),
                          if (option.hasLink || mine) ...[
                            const SizedBox(height: AppSizes.s6),
                            Wrap(
                              spacing: AppSizes.s6,
                              runSpacing: AppSizes.s6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (option.hasLink) EventVideoButton(link: option.link),
                                if (mine) _MineChip(label: l10n.eventPollYourVote),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.s8),
                    if (tally != null)
                      Text(
                        '${tally.percentOf(option.id)}%',
                        style: TextStyle(
                          fontFamily: eventDisplayFont,
                          fontSize: AppSizes.s24,
                          color: winner ? AppColors.medalGoldDark : AppColors.textPrimary,
                        ),
                      )
                    else if (selectable)
                      Icon(
                        selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                  ],
                ),
                if (tally != null) ...[
                  const SizedBox(height: AppSizes.s10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.s6),
                    child: LinearProgressIndicator(
                      value: tally.shareOf(option.id),
                      minHeight: AppSizes.s8,
                      backgroundColor: AppColors.greyLight,
                      color: winner ? AppColors.gold : (mine ? AppColors.primary : AppColors.grey),
                    ),
                  ),
                  const SizedBox(height: AppSizes.s4),
                  Text(
                    l10n.eventPollVotesCount(tally.votesOf(option.id)),
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MineChip extends StatelessWidget {
  final String label;

  const _MineChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s4),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSizes.s20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: AppSizes.s14, color: AppColors.white),
          const SizedBox(width: AppSizes.s4),
          Text(label, style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
