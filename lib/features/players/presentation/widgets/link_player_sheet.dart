import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/player_link.dart';
import 'package:arena_soccer/features/players/presentation/bloc/link_player_cubit.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cubit do vínculo (o fluxo vive em folhas, sem rota própria).
LinkPlayerCubit createLinkPlayerCubit() => LinkPlayerCubit(sl(), sl(), sl());

/// Admin, no elenco do time: escolhe um atleta (sem time ou de outro time da
/// região, com ou sem conta) e as competições do time em que ele vai jogar.
Future<void> showLinkPlayerToTeam(
  BuildContext context, {
  required String teamId,
  required String team,
  required String region,
  required String season,
  LinkPlayerCubit? cubit,
}) async {
  final linkCubit = cubit ?? createLinkPlayerCubit();
  try {
    final loading = linkCubit.load(region: region, season: season);
    final player = await showModalBottomSheet<PlayerDTO>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        top: false,
        child: BlocProvider.value(
          value: linkCubit,
          child: _CandidatesSheet(teamId: teamId, team: team),
        ),
      ),
    );
    await loading;
    if (player == null || !context.mounted) return;
    await _chooseAndLink(context, linkCubit, player, teamId: teamId, team: team);
  } finally {
    if (cubit == null) await linkCubit.close();
  }
}

/// Admin, no perfil do atleta: escolhe o time (da região) e as competições dele.
Future<void> showLinkTeamForPlayer(
  BuildContext context, {
  required PlayerDTO player,
  required String region,
  required String season,
  LinkPlayerCubit? cubit,
}) async {
  final l10n = AppLocalizations.of(context);
  final linkCubit = cubit ?? createLinkPlayerCubit();
  try {
    await linkCubit.load(region: region, season: season, withCandidates: false);
    if (!context.mounted) return;
    final picked = await showTeamPickerSheet(
      context,
      title: l10n.linkPlayerPickTeam,
      teams: linkCubit.state.teams,
      selectedId: player.teamId,
      firstRegion: region,
    );
    if (picked == null || !context.mounted) return;
    await _chooseAndLink(context, linkCubit, player, teamId: picked.id, team: picked.name);
  } finally {
    if (cubit == null) await linkCubit.close();
  }
}

/// Competições + "Tornar time principal" → confirma a transferência → grava.
Future<void> _chooseAndLink(
  BuildContext context,
  LinkPlayerCubit cubit,
  PlayerDTO player, {
  required String teamId,
  required String team,
}) async {
  final l10n = AppLocalizations.of(context);
  final championships = cubit.championshipsOf(teamId: teamId, team: team);
  final choice = await showModalBottomSheet<_LinkChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SafeArea(
      top: false,
      child: _OptionsSheet(player: player, teamId: teamId, team: team, championships: championships),
    ),
  );
  if (choice == null || !context.mounted) return;
  if (choice.transfers.isNotEmpty) {
    final names = [
      for (final c in championships)
        if (choice.transfers.contains(c.championshipId)) c.title,
    ].join(', ');
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.linkPlayerTransferTitle,
      message: l10n.linkPlayerTransferMessage(player.name, names),
      confirmLabel: l10n.linkPlayerTransfer,
      icon: Icons.swap_horiz_rounded,
    );
    if (!confirmed || !context.mounted) return;
  }
  final error = await cubit.link(
    player,
    teamId: teamId,
    team: team,
    selected: choice.selected,
    transfers: choice.transfers,
    makeMain: choice.makeMain,
  );
  if (!context.mounted) return;
  showSnackBar(
    context: context,
    message: error ?? l10n.linkPlayerDone(player.name, team),
    isSuccess: error == null,
  );
}

/// Atletas que podem entrar no time: os sem time primeiro, depois os dos
/// outros times; busca sem acento.
class _CandidatesSheet extends StatefulWidget {
  final String teamId;
  final String team;

  const _CandidatesSheet({required this.teamId, required this.team});

  @override
  State<_CandidatesSheet> createState() => _CandidatesSheetState();
}

class _CandidatesSheetState extends State<_CandidatesSheet> {
  /// Itens por página da lista.
  static const _pageSize = 20;

  final _scroll = ScrollController();
  String _query = '';
  LinkAccountFilter _account = LinkAccountFilter.all;
  int _visible = _pageSize;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Perto do fim, mostra a próxima página.
  void _onScroll() {
    if (_visible < _total && _scroll.position.extentAfter < 200) _loadMore();
  }

  void _loadMore() => setState(() => _visible += _pageSize);

  // Busca ou filtro novo volta à 1ª página.
  void _reset(VoidCallback change) => setState(() {
        change();
        _visible = _pageSize;
        if (_scroll.hasClients) _scroll.jumpTo(0);
      });

  List<PlayerDTO> _filter(List<PlayerDTO> candidates, LinkAccountFilter account) => PlayerLinkPlan.filterCandidates(
        candidates,
        teamId: widget.teamId,
        team: widget.team,
        query: _query,
        account: account,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: BlocBuilder<LinkPlayerCubit, LinkPlayerState>(
        builder: (context, state) {
          final all = _filter(state.candidates, LinkAccountFilter.all);
          final withAccount = all.where((p) => p.userId.isNotEmpty).length;
          final players = switch (_account) {
            LinkAccountFilter.all => all,
            LinkAccountFilter.withAccount => all.where((p) => p.userId.isNotEmpty).toList(),
            LinkAccountFilter.withoutAccount => all.where((p) => p.userId.isEmpty).toList(),
          };
          _total = players.length;
          final shown = players.length < _visible ? players.length : _visible;
          final filters = [
            (LinkAccountFilter.all, 'link-filter-all', l10n.linkPlayerFilterAll(all.length)),
            (LinkAccountFilter.withAccount, 'link-filter-account', l10n.linkPlayerFilterAccount(withAccount)),
            (
              LinkAccountFilter.withoutAccount,
              'link-filter-noaccount',
              l10n.linkPlayerFilterNoAccount(all.length - withAccount)
            ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s12),
                child: Text(
                  l10n.linkPlayerSearchTitle(widget.team),
                  style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                child: ArenaSearchField(
                  hint: l10n.linkPlayerSearchHint,
                  autofocus: false,
                  onChanged: (value) => _reset(() => _query = value),
                ),
              ),
              const SizedBox(height: AppSizes.s8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                child: Row(
                  children: [
                    for (final (filter, key, label) in filters)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s8),
                        child: ChoiceChip(
                          key: ValueKey(key),
                          label: Text(label),
                          selected: _account == filter,
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                          onSelected: (_) => _reset(() => _account = filter),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.s8),
              Expanded(
                child: state.loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : players.isEmpty
                        ? ArenaEmptyState(message: l10n.linkPlayerEmpty, icon: Icons.person_search_rounded)
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s16),
                            itemCount: shown + 1,
                            itemBuilder: (context, i) => i < shown
                                ? _CandidateTile(
                                    player: players[i],
                                    onTap: () => Navigator.pop(context, players[i]),
                                  )
                                : _ListFooter(
                                    label: shown < players.length
                                        ? l10n.linkPlayerShowing(shown, players.length)
                                        : l10n.linkPlayerCount(players.length),
                                    onLoadMore: shown < players.length ? _loadMore : null,
                                  ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Fim da lista: quantos aparecem e "Carregar mais" (se houver).
class _ListFooter extends StatelessWidget {
  final String label;
  final VoidCallback? onLoadMore;

  const _ListFooter({required this.label, this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
      child: Column(
        children: [
          Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          if (onLoadMore != null)
            TextButton(
              key: const ValueKey('link-load-more'),
              onPressed: onLoadMore,
              child: Text(l10n.linkPlayerLoadMore, style: AppTypography.label(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final PlayerDTO player;
  final VoidCallback onTap;

  const _CandidateTile({required this.player, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final noTeam = player.team.trim().isEmpty;
    final teams = player.teamNames;
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        key: ValueKey('link-candidate-${player.id}'),
        borderRadius: BorderRadius.circular(AppSizes.s12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s8, horizontal: AppSizes.s4),
          child: Row(
            children: [
              CircleAvatar(
                radius: AppSizes.s22,
                backgroundColor: AppColors.background,
                backgroundImage: player.imageUrl.isEmpty ? null : CachedNetworkImageProvider(player.imageUrl),
                child:
                    player.imageUrl.isEmpty ? const Icon(Icons.person_rounded, color: AppColors.textSecondary) : null,
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(color: AppColors.textPrimary),
                    ),
                    Text(
                      noTeam || teams.isEmpty ? l10n.linkPlayerNoTeam : teams.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle(color: noTeam ? AppColors.warning : AppColors.textSecondary)
                          .copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
              ),
              if (player.userId.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.s20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded, size: AppSizes.s12, color: AppColors.primary),
                      const SizedBox(width: AppSizes.s4),
                      Text(
                        l10n.linkPlayerHasAccount,
                        style: AppTypography.label(color: AppColors.primary).copyWith(fontSize: AppSizes.s10),
                      ),
                    ],
                  ),
                ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// O que o admin escolheu nas opções.
class _LinkChoice {
  final Set<int> selected;
  final Set<int> transfers;
  final bool makeMain;

  const _LinkChoice({required this.selected, required this.transfers, required this.makeMain});
}

/// Competições do time (livre / já joga / joga por outro + "Transferir") e
/// "Tornar time principal".
class _OptionsSheet extends StatefulWidget {
  final PlayerDTO player;
  final String teamId;
  final String team;
  final List<ChampionshipDTO> championships;

  const _OptionsSheet({required this.player, required this.teamId, required this.team, required this.championships});

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  late final Set<int> _selected = {
    for (final c in widget.championships)
      if (_slot(c) == LinkSlot.joined) c.championshipId,
  };
  final Set<int> _transfers = {};
  late bool _makeMain = widget.player.team.trim().isEmpty && widget.player.teamId.isEmpty;

  LinkSlot _slot(ChampionshipDTO c) =>
      PlayerLinkPlan.slotOf(widget.player, c.championshipId, teamId: widget.teamId, team: widget.team);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = widget.player;
    final hasMain = player.team.trim().isNotEmpty || player.teamId.isNotEmpty;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.linkPlayerOptionsTitle(player.name, widget.team),
              style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
            ),
            const SizedBox(height: AppSizes.s6),
            Text(
              widget.championships.isEmpty ? l10n.linkPlayerNoChampionships : l10n.linkPlayerOptionsHint,
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
            ),
            const SizedBox(height: AppSizes.s12),
            for (final c in widget.championships) _championshipTile(c, l10n),
            if (hasMain)
              SwitchListTile.adaptive(
                key: const ValueKey('link-make-main'),
                contentPadding: EdgeInsets.zero,
                value: _makeMain,
                activeTrackColor: AppColors.primary,
                onChanged: (value) => setState(() => _makeMain = value),
                title: Text(l10n.linkPlayerMakeMain, style: AppTypography.label(color: AppColors.textPrimary)),
                subtitle:
                    Text(l10n.linkPlayerMakeMainHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ),
            const SizedBox(height: AppSizes.s12),
            FilledButton(
              key: const ValueKey('link-save'),
              onPressed: () => Navigator.pop(
                context,
                _LinkChoice(selected: _selected, transfers: _transfers, makeMain: _makeMain),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.s14)),
              ),
              child: Text(l10n.linkPlayerSave, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _championshipTile(ChampionshipDTO c, AppLocalizations l10n) {
    final slot = _slot(c);
    final id = c.championshipId;
    final other = slot == LinkSlot.otherTeam ? widget.player.enrollmentIn(id) : null;
    final transferring = _transfers.contains(id);
    final checked = _selected.contains(id);
    final subtitle = switch (slot) {
      LinkSlot.joined => l10n.linkPlayerAlready,
      LinkSlot.otherTeam => l10n.enrollPlayerOtherTeam(other?.team ?? ''),
      LinkSlot.free => null,
    };
    return CheckboxListTile(
      key: ValueKey('link-championship-$id'),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primary,
      value: checked,
      // Joga por outro time: só marca com "Transferir".
      onChanged: slot == LinkSlot.otherTeam && !transferring
          ? null
          : (value) => setState(() => value == true ? _selected.add(id) : _selected.remove(id)),
      title: Text(c.title, style: AppTypography.label(color: AppColors.textPrimary)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: AppTypography.subtitle(
                      color: slot == LinkSlot.otherTeam ? AppColors.warning : AppColors.textSecondary)
                  .copyWith(fontSize: AppSizes.s12),
            ),
      secondary: slot == LinkSlot.otherTeam
          ? FilterChip(
              key: ValueKey('link-transfer-$id'),
              label: Text(l10n.linkPlayerTransfer),
              selected: transferring,
              selectedColor: AppColors.warning.withValues(alpha: 0.2),
              onSelected: (value) => setState(() {
                if (value) {
                  _transfers.add(id);
                  _selected.add(id);
                } else {
                  _transfers.remove(id);
                  _selected.remove(id);
                }
              }),
            )
          : null,
    );
  }
}
