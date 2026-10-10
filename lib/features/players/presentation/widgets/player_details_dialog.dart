import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_photo_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Detalhes do jogador. Para o admin, permite editar nome, foto, gols e
/// assistências; cada edição grava na hora pelo [TeamPlayersCubit].
class PlayerDetailsDialog extends StatefulWidget {
  final PlayerDTO player;

  const PlayerDetailsDialog({super.key, required this.player});

  static Future<void> show(BuildContext context, PlayerDTO player) {
    final cubit = BlocProvider.of<TeamPlayersCubit>(context);
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider<TeamPlayersCubit>.value(value: cubit, child: PlayerDetailsDialog(player: player)),
    );
  }

  @override
  State<PlayerDetailsDialog> createState() => _PlayerDetailsDialogState();
}

class _PlayerDetailsDialogState extends State<PlayerDetailsDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _rename(TeamPlayersCubit cubit, PlayerDTO player, String value, AppLocalizations l10n) {
    if (value.trim().length < 3) {
      showSnackBar(context: context, message: l10n.playersNameRequired, isSuccess: false);
      return;
    }
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
        const nameStyle = TextStyle(fontSize: AppSizes.s24, fontWeight: FontWeight.bold);

        return AlertDialog(
          title: isAdmin
              ? TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: AppSizes.s20, fontWeight: FontWeight.bold),
                  onSubmitted: (value) => _rename(cubit, player, value, l10n),
                  decoration: InputDecoration(
                    hintText: player.name,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.edit, color: AppColors.primary, size: AppSizes.s20),
                  ),
                )
              : Text(player.name, textAlign: TextAlign.center, style: nameStyle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PlayerPhoto(
                  imageUrl: player.imageUrl,
                  isSaving: isSaving,
                  onEdit: isAdmin ? () => _pickPhoto(cubit, player) : null,
                ),
                const SizedBox(height: AppSizes.s12),
                Text(l10n.playersTeamInfo(player.team), style: _statStyle),
                const SizedBox(height: AppSizes.s8),
                _StatRow(
                  label: l10n.playersGoalsCount(player.goals),
                  onDecrement: isAdmin ? () => cubit.changeGoals(player, -1) : null,
                  onIncrement: isAdmin ? () => cubit.changeGoals(player, 1) : null,
                ),
                const SizedBox(height: AppSizes.s8),
                _StatRow(
                  label: l10n.playersAssistsCount(player.assists),
                  onDecrement: isAdmin ? () => cubit.changeAssists(player, -1) : null,
                  onIncrement: isAdmin ? () => cubit.changeAssists(player, 1) : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _statStyle = TextStyle(fontSize: AppSizes.s20, fontWeight: FontWeight.bold);

/// Foto do jogador (ou avatar padrão). Com [onEdit], mostra o botão de câmera.
class _PlayerPhoto extends StatelessWidget {
  final String imageUrl;
  final bool isSaving;
  final VoidCallback? onEdit;

  const _PlayerPhoto({required this.imageUrl, required this.isSaving, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final Widget image = imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.scaleDown,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        : Image.asset(AppImages.avatar, height: AppSizes.s100);

    if (onEdit == null && !isSaving) return image;

    return SizedBox(
      height: imageUrl.isNotEmpty ? MediaQuery.of(context).size.height * 0.4 : AppSizes.s150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          image,
          if (isSaving) const CircularProgressIndicator(color: AppColors.primary),
          if (onEdit != null && !isSaving)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.photo_camera, color: imageUrl.isNotEmpty ? AppColors.white : AppColors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Gols: N" / "Assistências: N" com os botões -/+ do admin.
class _StatRow extends StatelessWidget {
  final String label;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _StatRow({required this.label, this.onDecrement, this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onDecrement != null) _RoundButton(icon: Icons.remove, onPressed: onDecrement!),
        Flexible(child: Text(label, style: _statStyle)),
        if (onIncrement != null) _RoundButton(icon: Icons.add, onPressed: onIncrement!),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: IconButton(icon: Icon(icon, color: AppColors.white), onPressed: onPressed),
    );
  }
}
