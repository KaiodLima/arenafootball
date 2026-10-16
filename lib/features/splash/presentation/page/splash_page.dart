import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Restaura a sessão (auto-login) e decide entre home e login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<SessionCubit>(context).restore();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      // Só a primeira decisão navega: a sessão do cache pode ser revalidada
      // logo depois (mais um estado) enquanto a home já está abrindo.
      listenWhen: (previous, current) => previous is CheckingSessionState,
      listener: (context, state) {
        if (state is AuthenticatedSessionState) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (state is GuestSessionState) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginPage);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: ArenaHeroBackground(
            watermarkFactor: 0.55,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  Hero(
                    tag: arenaLogoHeroTag,
                    child: Image.asset(AppImages.logo, height: AppSizes.s150),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: AppSizes.s120,
                    child: LinearProgressIndicator(
                      minHeight: AppSizes.s2,
                      color: AppColors.white,
                      backgroundColor: AppColors.whiteMuted,
                    ),
                  ),
                  const SizedBox(height: AppSizes.s48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
