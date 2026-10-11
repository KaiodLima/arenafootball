import 'package:flutter/material.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Barra fixa embaixo da votação. Logado: o botão "Votar em X" / "Trocar voto
/// para X" (desabilitado sem escolha ou quando a escolha já é o voto atual).
/// Convidado: o convite para entrar.
class VoteActionBar extends StatelessWidget {
  final VoteBestPlayerState state;
  final bool isGuest;
  final VoidCallback onVote;
  final VoidCallback onLogin;

  const VoteActionBar({
    super.key,
    required this.state,
    required this.isGuest,
    required this.onVote,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s16, offset: Offset(0, -AppSizes.s2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s12),
          child: isGuest ? _GuestPrompt(onLogin: onLogin) : _VoteButton(state: state, onVote: onVote),
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final VoteBestPlayerState state;
  final VoidCallback onVote;

  const _VoteButton({required this.state, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = state.selected;
    final submitting = state is SubmittingVoteBestPlayerState;

    final String title;
    if (selected == null) {
      title = l10n.votingChoosePlayer;
    } else if (state.selectedIsMyVote) {
      title = l10n.votingYouVotedFor(selected.name);
    } else if (state.myVote != null) {
      title = l10n.votingChangeVoteTo(selected.name);
    } else {
      title = l10n.votingVoteFor(selected.name);
    }
    final enabled = submitting || (selected != null && !state.selectedIsMyVote);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.5,
      child: ArenaButton.primary(
        title: title,
        height: AppSizes.buttonHeightLarge,
        isLoading: submitting,
        function: enabled ? onVote : null,
      ),
    );
  }
}

class _GuestPrompt extends StatelessWidget {
  final VoidCallback onLogin;

  const _GuestPrompt({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Container(
          width: AppSizes.s44,
          height: AppSizes.s44,
          decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
          child: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryDark),
        ),
        const SizedBox(width: AppSizes.s12),
        Expanded(
          child: Text(
            l10n.votingGuestTitle,
            style: AppTypography.body().copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: AppSizes.s12),
        ArenaButton.primary(title: l10n.votingGuestAction, width: AppSizes.s100, function: onLogin),
      ],
    );
  }
}
