import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/voting_rules_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Admin: regras da votação de melhor jogador (mínimo de votos e porcentagem
/// do mais votado), com a frase de como fica a regra.
class VotingRulesPage extends StatelessWidget {
  const VotingRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<VotingRulesCubit>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.votingRulesTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      body: BlocConsumer<VotingRulesCubit, VotingRulesState>(
        listener: (context, state) {
          if (state.saved) {
            showSnackBar(context: context, message: l10n.votingRulesSaved);
            Navigator.pop(context);
          } else if (state.errorMessage != null) {
            showSnackBar(context: context, message: state.errorMessage!, isSuccess: false);
          }
        },
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          final rules = state.rules;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.s16),
                  children: [
                    _Stepper(
                      label: l10n.votingRulesMinVotes,
                      value: '${rules.minVotes}',
                      onMinus: () => cubit.changeMinVotes(rules.minVotes - 1),
                      onPlus: () => cubit.changeMinVotes(rules.minVotes + 1),
                    ),
                    _Stepper(
                      label: l10n.votingRulesMinPercent,
                      value: '${rules.minPercent}%',
                      onMinus: () => cubit.changeMinPercent(rules.minPercent - 5),
                      onPlus: () => cubit.changeMinPercent(rules.minPercent + 5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                      child: Text(
                        l10n.votingRulesHint(rules.minVotes, rules.minPercent),
                        style: AppTypography.subtitle(),
                      ),
                    ),
                  ],
                ),
              ),
              ArenaSubmitBar(title: l10n.votingRulesSave, loading: state.saving, onPressed: cubit.save),
            ],
          );
        },
      ),
    );
  }
}

/// Valor com − e + dos lados.
class _Stepper extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _Stepper({required this.label, required this.value, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, VoidCallback onTap) => IconButton.filledTonal(
          onPressed: onTap,
          icon: Icon(icon),
          color: AppColors.primaryDark,
        );
    return ArenaCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
      child: Row(
        children: [
          Expanded(
            child:
                Text(label, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
          ),
          button(Icons.remove_rounded, onMinus),
          SizedBox(
            width: AppSizes.s64,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: AppTypography.title().copyWith(fontSize: AppSizes.s22),
            ),
          ),
          button(Icons.add_rounded, onPlus),
        ],
      ),
    );
  }
}
