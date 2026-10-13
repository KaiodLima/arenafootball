import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/edit_team_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/edit_team_state.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/team_details_form.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Edição do time pelo admin (escudo, descrição, cores e região). Salvou,
/// fecha devolvendo o time atualizado para quem abriu.
class EditTeamPage extends StatelessWidget {
  const EditTeamPage({super.key});

  /// Trocar de região tira o time da aba Times da região atual: confirma antes.
  Future<void> _save(
    BuildContext context, {
    required String description,
    required String primaryColor,
    required String secondaryColor,
    File? crest,
    String? region,
  }) async {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<EditTeamCubit>(context);
    final team = cubit.state.team;
    if (region != null && region.isNotEmpty && region != team.region) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.teamEditRegionChangeTitle),
          content: Text(l10n.teamEditRegionChangeMessage(team.name, region)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.commonCancel)),
            TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.commonSave)),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await cubit.save(
      description: description,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      crest: crest,
      region: region,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final regions = context.watch<RegionCubit>().state.regions;

    return BlocConsumer<EditTeamCubit, EditTeamState>(
      listener: (context, state) {
        if (state is SavedEditTeamState) {
          showSnackBar(context: context, message: l10n.teamEditSaved);
          Navigator.pop(context, state.team);
        }
        if (state is ErrorEditTeamState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.teamEditTitle,
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                ),
                Text(
                  state.team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle(color: AppColors.whiteMuted).copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
          body: TeamDetailsForm(
            team: state.team,
            saving: state.saving || state is SavedEditTeamState,
            regions: regions,
            note: l10n.teamEditNameLocked,
            onSave: ({required description, required primaryColor, required secondaryColor, crest, region}) => _save(
              context,
              description: description,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              crest: crest,
              region: region,
            ),
          ),
        );
      },
    );
  }
}
