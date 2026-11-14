import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/profile_name.dart';
import 'package:arena_soccer/features/auth/domain/team_change_policy.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/profile_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/profile_state.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/auth/presentation/page/choose_team_page.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/team_change_notice.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_gold_avatar.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/image_source_sheet.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Fonte do nome no cabeçalho (a mesma do drawer).
const _display = 'Anton';

/// "Meu perfil": cabeçalho da marca com a foto e o nome, "Dados da conta"
/// (nome editável, e-mail só leitura) e o time do coração.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileCubit _cubit;
  late final TextEditingController _name;
  late final TextEditingController _email;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ProfileCubit>(context);
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _loadTeam();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _loadTeam() {
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    _cubit.loadTeam(name: user?.favoriteTeam ?? '', id: user?.favoriteTeamId ?? '');
  }

  String? _nameError(AppLocalizations l10n) {
    if (!_touched) return null;
    return switch (ProfileName.validate(_name.text)) {
      ProfileNameError.tooShort => l10n.registerNameTooShort,
      ProfileNameError.tooLong => l10n.profileNameTooLong(ProfileName.max),
      null => null,
    };
  }

  void _saveName(UserDTO user) {
    FocusScope.of(context).unfocus();
    setState(() => _touched = true);
    if (ProfileName.validate(_name.text) != null) return;
    _cubit.saveName(userId: user.id, name: _name.text);
  }

  Future<void> _pickPhoto(String userId) async {
    FocusScope.of(context).unfocus();
    final source = await showImageSourceSheet(context);
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 800);
    if (picked == null || !mounted) return;
    await _cubit.changePhoto(userId: userId, photo: File(picked.path));
  }

  /// Troca de time: antes do prazo de 15 dias, só o aviso com a data.
  Future<void> _changeTeam(UserDTO user) async {
    if (user.hasFavoriteTeam && !TeamChangePolicy.canChange(user, DateTime.now())) {
      return showTeamChangeLocked(context, TeamChangePolicy.nextChangeAt(user));
    }
    await Navigator.pushNamed(context, AppRoutes.chooseTeamPage, arguments: const ChooseTeamArgs(canGoBack: true));
    if (mounted) _loadTeam();
  }

  void _onState(BuildContext context, ProfileState state) {
    final l10n = AppLocalizations.of(context);
    final session = BlocProvider.of<SessionCubit>(context);
    final current = session.state.user;
    if (state is NameSavedProfileState) {
      if (current != null) session.updateUser(current.copyWith(name: state.name));
      _name.text = state.name;
      showSnackBar(context: context, message: l10n.profileNameSaved);
    }
    if (state is PhotoSavedProfileState) {
      if (current != null) session.updateUser(current.copyWith(photoUrl: state.photoUrl));
      showSnackBar(context: context, message: l10n.fanCardPhotoSaved);
    }
    if (state is ErrorProfileState) showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, session) {
        final user = session.user;
        return BlocConsumer<ProfileCubit, ProfileState>(
          listener: _onState,
          builder: (context, state) {
            final changed = user != null && _name.text.trim() != user.name.trim();
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.white,
                surfaceTintColor: AppColors.transparent,
                titleSpacing: 0,
                title: Text(
                  l10n.profileTitle,
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
                ),
              ),
              bottomNavigationBar: changed
                  ? ArenaSubmitBar(title: l10n.commonSave, loading: state.savingName, onPressed: () => _saveName(user))
                  : null,
              body: user == null
                  ? const SizedBox.shrink()
                  : ListView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(bottom: changed ? AppSizes.s24 : safeBottom(context, AppSizes.s24)),
                      children: [
                        _ProfileHero(
                          user: user,
                          saving: state.savingPhoto,
                          onPickPhoto: state.savingPhoto ? null : () => _pickPhoto(user.id),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FormSection(
                                title: l10n.profileAccountSection,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      key: const ValueKey('profile-name'),
                                      controller: _name,
                                      maxLength: ProfileName.max,
                                      textCapitalization: TextCapitalization.words,
                                      onChanged: (_) => setState(() => _touched = true),
                                      style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                                      decoration: arenaInputDecoration(
                                        label: l10n.profileNameLabel,
                                        icon: Icons.person_outline_rounded,
                                        errorText: _nameError(l10n),
                                      ),
                                    ),
                                    if (user.email.isNotEmpty) ...[
                                      const SizedBox(height: AppSizes.s4),
                                      TextField(
                                        controller: _email,
                                        enabled: false,
                                        style: AppTypography.body(color: AppColors.textSecondary),
                                        decoration: arenaInputDecoration(
                                          label: l10n.profileEmailLabel,
                                          icon: Icons.mail_outline_rounded,
                                          suffix: const Icon(Icons.lock_outline_rounded,
                                              color: AppColors.textSecondary, size: AppSizes.s18),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s6, AppSizes.s12, 0),
                                        child: Text(
                                          l10n.profileEmailLocked,
                                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              FormSection(
                                title: l10n.profileFavoriteTeam,
                                child: _FavoriteTeam(
                                  user: user,
                                  crestUrl: state.team?.imageUrl,
                                  onChange: () => _changeTeam(user),
                                ),
                              ),
                              Text(
                                l10n.profilePhotoHint,
                                textAlign: TextAlign.center,
                                style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

/// Cabeçalho da marca: foto no anel dourado com o selo de câmera, nome,
/// e-mail e a pílula "Trocar foto".
class _ProfileHero extends StatelessWidget {
  final UserDTO user;
  final bool saving;
  final VoidCallback? onPickPhoto;

  const _ProfileHero({required this.user, required this.saving, this.onPickPhoto});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ArenaHeroBackground(
      watermarkFactor: 0.9,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s24, AppSizes.s20, AppSizes.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Na largura toda: o fundo da marca não estica o filho.
            const SizedBox(width: double.infinity),
            Semantics(
              button: true,
              label: user.photoUrl.isEmpty ? l10n.fanCardAddPhoto : l10n.fanCardChangePhoto,
              child: GestureDetector(
                onTap: onPickPhoto,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ArenaGoldAvatar(
                      key: const ValueKey('profile-photo'),
                      image: user.photoUrl,
                      radius: AppSizes.s48,
                      busy: saving,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.s6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.black.withValues(alpha: 0.25), blurRadius: AppSizes.s6)
                          ],
                        ),
                        child: const Icon(Icons.photo_camera_rounded, color: AppColors.primaryDark, size: AppSizes.s18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.s14),
            Text(
              user.name.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _display,
                fontSize: AppSizes.s28,
                height: 1.1,
                letterSpacing: 0.5,
                color: AppColors.white,
                shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.3), offset: const Offset(0, 2))],
              ),
            ),
            if (user.email.isNotEmpty) ...[
              const SizedBox(height: AppSizes.s4),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
              ),
            ],
            const SizedBox(height: AppSizes.s14),
            Material(
              color: AppColors.white.withValues(alpha: 0.14),
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: onPickPhoto,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_camera_outlined, color: AppColors.white, size: AppSizes.s18),
                      const SizedBox(width: AppSizes.s8),
                      Text(
                        user.photoUrl.isEmpty ? l10n.fanCardAddPhoto : l10n.fanCardChangePhoto,
                        style: AppTypography.label(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Escudo e nome do time do coração, "Trocar" à direita e a data da próxima
/// troca quando o prazo de 15 dias ainda corre.
class _FavoriteTeam extends StatelessWidget {
  final UserDTO user;
  final String? crestUrl;
  final VoidCallback onChange;

  const _FavoriteTeam({required this.user, required this.crestUrl, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasTeam = user.hasFavoriteTeam;
    final nextAt =
        hasTeam && !TeamChangePolicy.canChange(user, DateTime.now()) ? TeamChangePolicy.nextChangeAt(user) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TeamCrest(imageUrl: hasTeam ? crestUrl : null, size: AppSizes.s48),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Text(
                hasTeam ? user.favoriteTeam : l10n.profileNoTeam,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: hasTeam
                    ? AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16)
                    : AppTypography.subtitle(),
              ),
            ),
            const SizedBox(width: AppSizes.s8),
            OutlinedButton(
              onPressed: onChange,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: const StadiumBorder(),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(hasTeam ? l10n.profileChangeTeam : l10n.drawerChooseTeam),
            ),
          ],
        ),
        if (nextAt != null) ...[
          const SizedBox(height: AppSizes.s10),
          Text(
            l10n.fanCardChangeTeamNextAt(teamChangeDate(context, nextAt)),
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
        ],
      ],
    );
  }
}
