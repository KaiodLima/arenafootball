import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_mode_cubit.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/widgets/quick_player_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/themes/arena_palette.dart';

/// Mensagem do erro ao mexer no elenco: sem permissão (regras sem publicar
/// ou campeonato sem o índice do organizador) explica o que fazer; os demais
/// mostram a mensagem do Firestore.
String squadErrorMessage(AppLocalizations l10n, Failure failure) {
  if (failure is ErrorWithMessage) {
    if (failure.code == 'permission-denied') return l10n.organizerSquadPermission;
    if (failure.message.isNotEmpty) return failure.message;
  }
  return l10n.organizerSquadError;
}

/// Atletas do elenco geral que podem entrar na competição: ainda não jogam
/// nela por este time, não jogam nela por outro (um time por competição) e
/// não são antigos (o antigo já conta em todas as do time).
List<PlayerDTO> squadCandidates(
  List<PlayerDTO> players,
  int championshipId, {
  required String teamId,
  required String teamName,
}) =>
    [
      for (final p in players)
        if (!p.isLegacy &&
            p.enrollmentIn(championshipId) == null &&
            !p.playsIn(championshipId, teamId: teamId, teamName: teamName))
          p,
    ];

/// Botões do organizador no elenco da competição: "Do elenco geral" e
/// "Novo atleta".
class OrganizerSquadActions extends StatelessWidget {
  final TeamPlayersCubit cubit;
  final List<PlayerDTO> players;
  final int championshipId;
  final String championshipTitle;
  final String teamId;
  final String teamName;

  const OrganizerSquadActions({
    super.key,
    required this.cubit,
    required this.players,
    required this.championshipId,
    required this.championshipTitle,
    required this.teamId,
    required this.teamName,
  });

  Future<void> _addFromSquad(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final candidates = squadCandidates(players, championshipId, teamId: teamId, teamName: teamName)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (candidates.isEmpty) {
      showSnackBar(context: context, message: l10n.organizerSquadNone, isSuccess: false);
      return;
    }
    final picked = await showModalBottomSheet<List<PlayerDTO>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _safeSheet(Theme(
        data: Theme.of(context),
        child: _SquadPicker(
          players: candidates,
          title: l10n.organizerSquadAddTitle,
          hint: l10n.organizerSquadAddHint(championshipTitle),
        ),
      )),
    );
    if (picked == null || picked.isEmpty || !context.mounted) return;
    await BlocProvider.of<OrganizerModeCubit>(context).ensureIndexFor(championshipId);
    if (!context.mounted) return;
    final result = await cubit.addToChampionship(picked, championshipId);
    if (!context.mounted) return;
    showSnackBar(
      context: context,
      message: result.error == null ? l10n.organizerSquadAdded(result.added) : squadErrorMessage(l10n, result.error!),
      isSuccess: result.error == null,
    );
  }

  Future<void> _newPlayer(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showQuickPlayerSheet(
      context,
      title: l10n.organizerSquadNew,
      hint: l10n.organizerSquadNewHint(championshipTitle),
      confirmLabel: l10n.matchReportAdd,
    );
    if (result == null || !context.mounted) return;
    await BlocProvider.of<OrganizerModeCubit>(context).ensureIndexFor(championshipId);
    if (!context.mounted) return;
    final error = await cubit.createInChampionship(
      championshipId,
      name: result.name,
      position: result.position,
      photo: result.photo,
    );
    if (!context.mounted) return;
    showSnackBar(
      context: context,
      message: error == null ? l10n.organizerSquadCreated(result.name) : squadErrorMessage(l10n, error),
      isSuccess: error == null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _addFromSquad(context),
            icon: const Icon(Icons.playlist_add_rounded),
            label: Text(l10n.organizerSquadAdd, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: AppSizes.s8),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _newPlayer(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(l10n.organizerSquadNew, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

/// Organizador: tira o atleta da competição (fica no elenco geral).
Future<void> organizerRemoveFromChampionship(
  BuildContext context, {
  required TeamPlayersCubit cubit,
  required PlayerDTO player,
  required int championshipId,
}) async {
  final l10n = AppLocalizations.of(context);
  if (player.isLegacy) {
    showSnackBar(context: context, message: l10n.organizerSquadLegacy, isSuccess: false);
    return;
  }
  final confirmed = await showArenaConfirm(
    context,
    title: l10n.organizerSquadRemoveTitle(player.name),
    message: l10n.organizerSquadRemoveMessage,
    confirmLabel: l10n.organizerSquadRemove,
    icon: Icons.person_remove_alt_1_rounded,
    tone: ArenaAlertTone.danger,
  );
  if (!confirmed || !context.mounted) return;
  await BlocProvider.of<OrganizerModeCubit>(context).ensureIndexFor(championshipId);
  if (!context.mounted) return;
  final error = await cubit.setInChampionship(player, championshipId, enrolled: false);
  if (!context.mounted) return;
  showSnackBar(
    context: context,
    message: error == null ? l10n.organizerSquadRemoved(player.name) : squadErrorMessage(l10n, error),
    isSuccess: error == null,
  );
}

/// Lista com caixas para escolher vários atletas.
class _SquadPicker extends StatefulWidget {
  final List<PlayerDTO> players;
  final String title;
  final String hint;

  const _SquadPicker({required this.players, required this.title, required this.hint});

  @override
  State<_SquadPicker> createState() => _SquadPickerState();
}

class _SquadPickerState extends State<_SquadPicker> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = ArenaPalette.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppTypography.title()),
            Text(widget.hint, style: AppTypography.subtitle()),
            const SizedBox(height: AppSizes.s12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final player in widget.players)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: palette.primary,
                      value: _selected.contains(player.id),
                      onChanged: (value) => setState(
                        () => value == true ? _selected.add(player.id) : _selected.remove(player.id),
                      ),
                      secondary: TeamCrest(imageUrl: player.imageUrl, size: AppSizes.s36),
                      title: Text(player.name, style: AppTypography.body()),
                      subtitle: player.position.isEmpty
                          ? null
                          : Text(player.position,
                              style: AppTypography.subtitle().copyWith(color: AppColors.textSecondary)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.s12),
            ArenaButton.primary(
              title: l10n.organizerSquadAddConfirm(_selected.length),
              function: _selected.isEmpty
                  ? null
                  : () => Navigator.pop(context, [
                        for (final p in widget.players)
                          if (_selected.contains(p.id)) p
                      ]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Folha acima da barra de navegação do sistema (Android de ponta a ponta).
Widget _safeSheet(Widget child) => SafeArea(top: false, child: child);
