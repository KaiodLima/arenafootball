import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/referrals/data/dtos/referral_dto.dart';
import 'package:arena_soccer/features/referrals/domain/referral_code.dart';
import 'package:arena_soccer/features/referrals/domain/usecases/referral_usecases.dart';
import 'package:arena_soccer/features/referrals/presentation/bloc/referral_config_cubit.dart';
import 'package:arena_soccer/features/referrals/presentation/bloc/referral_cubit.dart';
import 'package:arena_soccer/features/referrals/presentation/bloc/referral_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Indique amigos": o código e o link de convite da conta, o saldo de
/// pacotinhos extras, os indicados e o "Fui indicado" (conta nova). O código
/// do link de convite chega em `arguments: {'code': X}` e preenche o campo.
class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  late final ReferralCubit _cubit;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ReferralCubit>(context);
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (user != null) _cubit.load(user.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final code = args is Map ? (args['code'] ?? '').toString() : '';
    if (code.isNotEmpty && _codeController.text.isEmpty) _codeController.text = code;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _share(String code) {
    final l10n = AppLocalizations.of(context);
    ShareService.shareText(l10n.referralShareText(code, inviteLink(code)), subject: l10n.referralTitle);
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    showSnackBar(context: context, message: AppLocalizations.of(context).referralCodeCopied);
  }

  String _claimError(AppLocalizations l10n, ClaimReferralError error) => switch (error) {
        ClaimReferralError.invalid => l10n.referralClaimInvalid,
        ClaimReferralError.own => l10n.referralClaimOwn,
        ClaimReferralError.oldAccount => l10n.referralClaimOldAccount,
        ClaimReferralError.alreadyClaimed => l10n.referralClaimAlready,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.referralTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      body: BlocConsumer<ReferralCubit, ReferralState>(
        listener: (context, state) {
          if (state is ErrorReferralState) {
            showSnackBar(context: context, message: state.message, isSuccess: false);
          } else if (state is ClaimErrorReferralState) {
            showSnackBar(context: context, message: _claimError(l10n, state.error), isSuccess: false);
          } else if (state is ClaimedReferralState) {
            showSnackBar(context: context, message: l10n.referralClaimSaved);
          }
        },
        builder: (context, state) {
          if (!BlocProvider.of<ReferralConfigCubit>(context).state.enabled) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.s32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pause_circle_outline_rounded, color: AppColors.textSecondary, size: AppSizes.s48),
                    const SizedBox(height: AppSizes.s12),
                    Text(l10n.referralPaused, textAlign: TextAlign.center, style: AppTypography.subtitle()),
                  ],
                ),
              ),
            );
          }
          if (state.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s32),
            children: [
              _InviteCard(
                code: state.code,
                onCopy: state.code.isEmpty ? null : () => _copy(state.code),
                onShare: state.code.isEmpty ? null : () => _share(state.code),
              ),
              const SizedBox(height: AppSizes.s16),
              _Stats(referral: state.referral),
              if (state.canClaim || state.claimedCode.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s16),
                _ClaimCard(
                  state: state,
                  controller: _codeController,
                  onClaim: () => _cubit.claim(_codeController.text),
                ),
              ],
              const SizedBox(height: AppSizes.s20),
              _SectionTitle(l10n.referralHowTitle),
              _Step(number: 1, text: l10n.referralHowStep1),
              _Step(number: 2, text: l10n.referralHowStep2),
              _Step(number: 3, text: l10n.referralHowStep3(ReferralCode.maxExtraPacks)),
              const SizedBox(height: AppSizes.s20),
              _SectionTitle(l10n.referralFriendsTitle),
              if (state.friends.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
                  child: Text(l10n.referralFriendsEmpty, style: AppTypography.subtitle()),
                )
              else
                for (final friend in state.friends) _FriendTile(friend: friend),
            ],
          );
        },
      ),
    );
  }
}

/// Cartão verde com o código grande, "Copiar" e "Compartilhar convite".
class _InviteCard extends StatelessWidget {
  final String code;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const _InviteCard({required this.code, required this.onCopy, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.s20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.card_giftcard_rounded, color: AppColors.gold, size: AppSizes.s40),
          const SizedBox(height: AppSizes.s10),
          Text(
            l10n.referralHeadline,
            textAlign: TextAlign.center,
            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
          ),
          const SizedBox(height: AppSizes.s6),
          Text(
            l10n.referralSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.body(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s14),
          ),
          const SizedBox(height: AppSizes.s16),
          Material(
            color: AppColors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppSizes.s12),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.s12),
              onTap: onCopy,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.referralYourCode,
                            style: AppTypography.label(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                          ),
                          Text(
                            code.isEmpty ? '--------' : code,
                            style: AppTypography.display(color: AppColors.white)
                                .copyWith(fontSize: AppSizes.s28, letterSpacing: 3),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.copy_rounded, color: AppColors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.s16),
          ArenaButton(
            title: l10n.referralShare,
            height: AppSizes.buttonHeightLarge,
            borderRadius: AppSizes.fieldRadius,
            fontSize: AppSizes.s16,
            textColor: AppColors.primaryDark,
            buttonColor: AppColors.gold,
            leading: const Icon(Icons.share_rounded, color: AppColors.primaryDark),
            function: onShare,
          ),
        ],
      ),
    );
  }
}

/// Amigos indicados, pacotinhos guardados e pacotinhos ganhos.
class _Stats extends StatelessWidget {
  final ReferralDTO referral;

  const _Stats({required this.referral});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget tile(IconData icon, int value, String label) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.s12, horizontal: AppSizes.s8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.s12),
              border: Border.all(color: AppColors.greyLight),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: AppSizes.s22),
                const SizedBox(height: AppSizes.s4),
                Text('$value', style: AppTypography.title().copyWith(fontSize: AppSizes.s20)),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
        );
    return Row(
      children: [
        tile(Icons.group_add_rounded, referral.invited, l10n.referralStatInvited),
        const SizedBox(width: AppSizes.s8),
        tile(Icons.card_giftcard_rounded, referral.extraPacks, l10n.referralStatExtraPacks),
        const SizedBox(width: AppSizes.s8),
        tile(Icons.redeem_rounded, referral.extraPacksEarned, l10n.referralStatEarned),
      ],
    );
  }
}

/// "Fui indicado": o campo (conta nova sem código) ou a situação do código usado.
class _ClaimCard extends StatelessWidget {
  final ReferralState state;
  final TextEditingController controller;
  final VoidCallback onClaim;

  const _ClaimCard({required this.state, required this.controller, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final referral = state.referral;
    final Widget body;
    if (state.claimedCode.isEmpty) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.referralClaimHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          const SizedBox(height: AppSizes.s10),
          ArenaTextField(
            controller: controller,
            hintText: l10n.referralClaimField,
            icon: const Icon(Icons.confirmation_number_outlined),
          ),
          const SizedBox(height: AppSizes.s10),
          ArenaButton.primary(title: l10n.referralClaimButton, isLoading: state.claiming, function: onClaim),
        ],
      );
    } else {
      final (IconData icon, Color color, String text) = referral.validated
          ? (Icons.check_circle_rounded, AppColors.success, l10n.referralClaimValid)
          : referral.refusal != null
              ? (Icons.error_outline_rounded, AppColors.danger, _refusal(l10n, referral.refusal!))
              : (Icons.hourglass_top_rounded, AppColors.warning, l10n.referralClaimPending);
      body = Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.referralClaimUsed(state.claimedCode),
                  style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                ),
                Text(text, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ],
            ),
          ),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.referralClaimTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
          const SizedBox(height: AppSizes.s8),
          body,
        ],
      ),
    );
  }

  static String _refusal(AppLocalizations l10n, ReferralRefusal refusal) => switch (refusal) {
        ReferralRefusal.code => l10n.referralRefusedCode,
        ReferralRefusal.own => l10n.referralClaimOwn,
        ReferralRefusal.oldAccount => l10n.referralClaimOldAccount,
      };
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s8),
      child: Text(text, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: AppSizes.s12,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              '$number',
              style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
            ),
          ),
          const SizedBox(width: AppSizes.s10),
          Expanded(child: Text(text, style: AppTypography.body().copyWith(fontSize: AppSizes.s14))),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final ReferredFriendDTO friend;

  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final at = friend.at;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: AppColors.primarySoft,
        child: Icon(Icons.person_rounded, color: AppColors.primaryDark),
      ),
      title: Text(friend.name.isEmpty ? l10n.referralFriendNoName : friend.name, style: AppTypography.body()),
      subtitle: at == null
          ? null
          : Text(
              MaterialLocalizations.of(context).formatShortDate(at),
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
            ),
      trailing: const Icon(Icons.card_giftcard_rounded, color: AppColors.gold),
    );
  }
}
