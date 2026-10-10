import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championships_tab.dart';
import 'package:arena_soccer/features/highlights/presentation/widgets/highlights_carousel.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_cubit.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_state.dart';
import 'package:arena_soccer/features/home/presentation/widgets/home_bottom_bar.dart';
import 'package:arena_soccer/features/home/presentation/widgets/home_drawer.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_tab.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_tab.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_selector.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/teams_tab.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = BlocProvider.of<HomeCubit>(context);
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (user != null) _homeCubit.loadFavoriteTeam(user.favoriteTeam);
  }

  Future<void> _logout() async {
    await BlocProvider.of<SessionCubit>(context).signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginPage, (_) => false);
  }

  Widget _tabContent(HomeTab tab, RegionState region) {
    final key = ValueKey('${tab.name}-${region.selectedRegion}-${region.selectedSeason}');
    switch (tab) {
      case HomeTab.news:
        return NewsTab(key: key);
      case HomeTab.championships:
        return ChampionshipsTab(key: key);
      case HomeTab.teams:
        return TeamsTab(key: key);
      case HomeTab.tables:
        return MatchesTab(key: key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final session = context.watch<SessionCubit>().state;
    final region = context.watch<RegionCubit>().state;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, home) {
        final showRegion = home.tab == HomeTab.news || home.tab == HomeTab.championships;

        return Scaffold(
          backgroundColor: AppColors.primaryDark,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            elevation: 0,
            centerTitle: true,
            title: Image.asset(AppImages.logo, width: AppSizes.logoWidth, height: AppSizes.logoHeight),
            actions: [
              IconButton(
                color: AppColors.white,
                iconSize: AppSizes.s24,
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          drawer: HomeDrawer(user: session.user, favoriteTeamImage: home.favoriteTeamImage),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const HighlightsCarousel(),
                const SizedBox(height: AppSizes.s10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                  child: RegionSelector(mode: showRegion ? RegionSelectorMode.region : RegionSelectorMode.season),
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.55,
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s16, AppSizes.s4),
                  child: _tabContent(home.tab, region),
                ),
              ],
            ),
          ),
          bottomNavigationBar: HomeBottomBar(selected: home.tab, onSelected: _homeCubit.selectTab),
          floatingActionButton: session.isAdmin ? const _AdminActions() : null,
        );
      },
    );
  }
}

/// Atalhos do admin: publicar anúncio e notificar gol.
class _AdminActions extends StatelessWidget {
  const _AdminActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'btnAnuncio',
          backgroundColor: AppColors.primary,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.publishAdPage),
          child: const Icon(Icons.stacked_line_chart),
        ),
        const SizedBox(height: AppSizes.s4),
        FloatingActionButton.small(
          heroTag: 'btnGol',
          backgroundColor: AppColors.primary,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.goalNotificationPage),
          child: const Icon(Icons.sports_soccer),
        ),
      ],
    );
  }
}

