import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/page/choose_team_page.dart';
import 'package:arena_soccer/features/fan_card/domain/fan_card_number.dart';
import 'package:arena_soccer/features/fan_card/presentation/bloc/fan_card_cubit.dart';
import 'package:arena_soccer/features/fan_card/presentation/bloc/fan_card_state.dart';
import 'package:arena_soccer/features/fan_card/presentation/widgets/fan_card.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/image_source_sheet.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Carteirinha de torcedor do usuário logado, com troca de foto e, sem time
/// do coração, o atalho para escolher um.
class FanCardPage extends StatefulWidget {
  const FanCardPage({super.key});

  @override
  State<FanCardPage> createState() => _FanCardPageState();
}

class _FanCardPageState extends State<FanCardPage> {
  late final FanCardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<FanCardCubit>(context);
    _cubit.load(favoriteTeam: BlocProvider.of<SessionCubit>(context).state.user?.favoriteTeam ?? '');
  }

  Future<void> _pickPhoto(String userId) async {
    final source = await showImageSourceSheet(context);
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 800);
    if (picked == null || !mounted) return;
    await _cubit.changePhoto(userId: userId, photo: File(picked.path));
  }

  Future<void> _chooseTeam() async {
    await Navigator.pushNamed(context, AppRoutes.chooseTeamPage, arguments: const ChooseTeamArgs(canGoBack: true));
    if (!mounted) return;
    _cubit.load(favoriteTeam: BlocProvider.of<SessionCubit>(context).state.user?.favoriteTeam ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<SessionCubit>().state.user;
    final region = context.watch<RegionCubit>().state.selectedRegion;
    final player = context.watch<MyPlayerCubit>().state;
    final owned = context.watch<OwnedTeamCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.fanCardTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      body: user == null
          ? const SizedBox.shrink()
          : BlocConsumer<FanCardCubit, FanCardState>(
              listener: (context, state) {
                if (state is PhotoSavedFanCardState) {
                  final session = BlocProvider.of<SessionCubit>(context);
                  final current = session.state.user;
                  if (current != null) session.updateUser(current.copyWith(photoUrl: state.photoUrl));
                  showSnackBar(context: context, message: l10n.fanCardPhotoSaved);
                }
                if (state is ErrorFanCardState) {
                  showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
                }
              },
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s24, AppSizes.s16, AppSizes.s32),
                  children: [
                    AnimatedOpacity(
                      opacity: state.loading ? 0.4 : 1,
                      duration: const Duration(milliseconds: 250),
                      child: FanCard(
                        name: user.name,
                        photoUrl: user.photoUrl,
                        favoriteTeam: user.favoriteTeam,
                        team: state.team,
                        region: state.team?.region.isNotEmpty == true ? state.team!.region : region,
                        memberSince: state.memberSince,
                        number: fanCardNumber(user.id),
                        playerTeam: player.teamName,
                        ownedTeam: owned.teamName,
                      ),
                    ),
                    const SizedBox(height: AppSizes.s16),
                    Text(
                      l10n.fanCardHint,
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                    const SizedBox(height: AppSizes.s24),
                    ArenaButton.outlined(
                      title: user.photoUrl.isEmpty ? l10n.fanCardAddPhoto : l10n.fanCardChangePhoto,
                      isLoading: state.savingPhoto,
                      function: state.savingPhoto ? null : () => _pickPhoto(user.id),
                    ),
                    if (!user.hasFavoriteTeam) ...[
                      const SizedBox(height: AppSizes.s12),
                      ArenaButton.primary(title: l10n.drawerChooseTeam, function: _chooseTeam),
                    ],
                  ],
                );
              },
            ),
    );
  }
}
