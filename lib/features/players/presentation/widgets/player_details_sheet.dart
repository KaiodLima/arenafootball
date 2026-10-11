import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_photo_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/photo_gallery_page.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel do jogador (sobe de baixo): foto, nome, time, gols e assistências.
/// Para o admin, também edita nome, foto e os números; cada edição grava na
/// hora pelo [TeamPlayersCubit] e o painel reflete ao vivo.
class PlayerDetailsSheet extends StatefulWidget {
  final PlayerDTO player;

  const PlayerDetailsSheet({super.key, required this.player});

  static Future<void> show(BuildContext context, PlayerDTO player) {
    final cubit = BlocProvider.of<TeamPlayersCubit>(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider<TeamPlayersCubit>.value(value: cubit, child: PlayerDetailsSheet(player: player)),
    );
  }

  @override
  State<PlayerDetailsSheet> createState() => _PlayerDetailsSheetState();
}

class _PlayerDetailsSheetState extends State<PlayerDetailsSheet> {
  late final _nameController = TextEditingController(text: widget.player.name);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _rename(TeamPlayersCubit cubit, PlayerDTO player, AppLocalizations l10n) {
    final value = _nameController.text;
    if (value.trim().length < 3) {
      showSnackBar(context: context, message: l10n.playersNameRequired, isSuccess: false);
      return;
    }
    FocusScope.of(context).unfocus();
    cubit.rename(player, value);
  }

  Future<void> _pickPhoto(TeamPlayersCubit cubit, PlayerDTO player) async {
    final file = await PlayerPhotoDialog.show(context);
    if (file != null) await cubit.changePhoto(player, file);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = context.watch<SessionCubit>().state.isAdmin;
    final cubit = BlocProvider.of<TeamPlayersCubit>(context);

    return BlocBuilder<TeamPlayersCubit, TeamPlayersState>(
      builder: (context, state) {
        final player = state.playerById(widget.player.id, widget.player);
        final isSaving = state is SavingTeamPlayersState && state.playerId == player.id;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: player.imageUrl.isEmpty
                        ? null
                        : () => PhotoGalleryPage.open(context, images: [player.imageUrl]),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PlayerAvatar(player: player, size: AppSizes.s120),
                        if (isSaving)
                          const SizedBox(
                            width: AppSizes.s120,
                            height: AppSizes.s120,
                            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                          ),
                      ],
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: AppSizes.s8),
                    TextButton.icon(
                      onPressed: isSaving ? null : () => _pickPhoto(cubit, player),
                      icon: const Icon(Icons.photo_camera_outlined, size: AppSizes.s18),
                      label: Text(l10n.playersChangePhoto),
                    ),
                  ] else
                    const SizedBox(height: AppSizes.s16),
                  Text(
                    player.name,
                    textAlign: TextAlign.center,
                    style: AppTypography.display().copyWith(fontSize: AppSizes.s24),
                  ),
                  if (player.team.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.s8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppSizes.s20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_outlined, size: AppSizes.s14, color: AppColors.primaryDark),
                          const SizedBox(width: AppSizes.s4),
                          Text(
                            player.team,
                            style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.s20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.sports_soccer_rounded,
                          label: l10n.playersSummaryGoals,
                          value: player.goals,
                          onDecrement: isAdmin ? () => cubit.changeGoals(player, -1) : null,
                          onIncrement: isAdmin ? () => cubit.changeGoals(player, 1) : null,
                        ),
                      ),
                      const SizedBox(width: AppSizes.s12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.assistant_rounded,
                          label: l10n.playersSummaryAssists,
                          value: player.assists,
                          onDecrement: isAdmin ? () => cubit.changeAssists(player, -1) : null,
                          onIncrement: isAdmin ? () => cubit.changeAssists(player, 1) : null,
                        ),
                      ),
                    ],
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: AppSizes.s20),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _rename(cubit, player, l10n),
                      decoration: InputDecoration(
                        labelText: l10n.playersEditName,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          tooltip: l10n.playersSaveName,
                          onPressed: () => _rename(cubit, player, l10n),
                          icon: const Icon(Icons.check_rounded, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Número grande (gols/assistências) com os botões −/+ do admin.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _StatCard({required this.icon, required this.label, required this.value, this.onDecrement, this.onIncrement});

  @override
  Widget build(BuildContext context) {
    final editable = onDecrement != null && onIncrement != null;

    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s16, horizontal: AppSizes.s8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.s16, color: AppColors.primary),
              const SizedBox(width: AppSizes.s4),
              Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            ],
          ),
          const SizedBox(height: AppSizes.s6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (editable) _StepButton(icon: Icons.remove_rounded, onTap: onDecrement!),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10),
                child: Text('$value', style: AppTypography.display().copyWith(fontSize: AppSizes.s32)),
              ),
              if (editable) _StepButton(icon: Icons.add_rounded, onTap: onIncrement!),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: AppSizes.s32,
          height: AppSizes.s32,
          child: Icon(icon, size: AppSizes.s18, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}
