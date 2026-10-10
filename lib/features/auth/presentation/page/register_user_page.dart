import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_state.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  late final RegisterUserCubit _cubit;

  // Os erros só aparecem depois que o usuário mexe no campo.
  final Set<String> _touched = {};

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<RegisterUserCubit>(context);
    _cubit.load(initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  String? _errorText(String field, RegisterFieldError? error, AppLocalizations l10n) {
    if (!_touched.contains(field) || error == null) return null;
    switch (error) {
      case RegisterFieldError.required:
        return l10n.commonRequiredField;
      case RegisterFieldError.nameTooShort:
        return l10n.registerNameTooShort;
      case RegisterFieldError.invalidEmail:
        return l10n.registerEmailExample;
      case RegisterFieldError.passwordTooShort:
        return l10n.registerPasswordTooShort;
    }
  }

  Icon _fieldIcon(IconData icon, RegisterFieldError? error) {
    return Icon(icon, size: AppSizes.s24, color: error == null ? AppColors.primary : AppColors.danger);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: BlocConsumer<RegisterUserCubit, RegisterUserState>(
        listener: (context, state) {
          if (state is SuccessRegisterUserState) {
            showSnackBar(context: context, message: l10n.registerSuccess);
            BlocProvider.of<SessionCubit>(context).signedIn(state.user);
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
          }
          if (state is ErrorRegisterUserState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(AppImages.logo, height: AppSizes.loginLogoHeight),
                const SizedBox(height: AppSizes.s32),
                ArenaTextField(
                  labelText: l10n.registerNameLabel,
                  onChaged: (value) {
                    _touched.add('name');
                    _cubit.changeName(value);
                  },
                  errorText: () => _errorText('name', state.nameError, l10n),
                  icon: _fieldIcon(Icons.account_box_outlined, state.nameError),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.registerEmailLabel,
                  keyboardType: TextInputType.emailAddress,
                  onChaged: (value) {
                    _touched.add('email');
                    _cubit.changeEmail(value);
                  },
                  errorText: () => _errorText('email', state.emailError, l10n),
                  icon: _fieldIcon(Icons.email, state.emailError),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.registerPasswordLabel,
                  obscureText: true,
                  onChaged: (value) {
                    _touched.add('password');
                    _cubit.changePassword(value);
                  },
                  errorText: () => _errorText('password', state.passwordError, l10n),
                  icon: _fieldIcon(Icons.key, state.passwordError),
                ),
                const SizedBox(height: AppSizes.s16),
                Text(l10n.registerRegionLabel, style: const TextStyle(fontSize: AppSizes.s16)),
                _OutlinedDropdown(
                  value: state.selectedRegion,
                  items: state.regions,
                  onChanged: _cubit.selectRegion,
                ),
                const SizedBox(height: AppSizes.s8),
                Text(l10n.registerTeamLabel, style: const TextStyle(fontSize: AppSizes.s16)),
                _OutlinedDropdown(
                  value: state.selectedTeam,
                  items: state.teams,
                  onChanged: _cubit.selectTeam,
                ),
                const SizedBox(height: AppSizes.s24),
                ArenaButton(
                  title: l10n.registerButton,
                  fontSize: AppSizes.s18,
                  textColor: AppColors.white,
                  buttonColor: state.canSubmit ? AppColors.primary : AppColors.grey,
                  borderRadius: AppSizes.radius,
                  isLoading: state is SubmittingRegisterUserState,
                  function: state.canSubmit ? _cubit.submit : null,
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.registerHaveAccountButton),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OutlinedDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _OutlinedDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.s4),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(AppSizes.s4),
      ),
      child: DropdownButton<String>(
        value: items.contains(value) ? value : null,
        icon: const Icon(Icons.arrow_downward),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: AppColors.black, fontSize: AppSizes.s18),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
      ),
    );
  }
}
