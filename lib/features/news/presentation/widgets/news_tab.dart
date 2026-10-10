import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_state.dart';
import 'package:arena_soccer/features/news/presentation/widgets/ad_card.dart';
import 'package:arena_soccer/features/news/presentation/widgets/goal_card.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_card.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Aba de notícias da home: feed da região selecionada.
/// A home recria a aba (key) quando a região muda.
class NewsTab extends StatelessWidget {
  const NewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final region = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    return BlocProvider<NewsFeedCubit>(
      create: (_) => NewsFeedCubit(sl(), sl())..watch(region: region),
      child: const _NewsFeed(),
    );
  }
}

class _NewsFeed extends StatelessWidget {
  const _NewsFeed();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = context.watch<SessionCubit>().state.isAdmin;

    return BlocConsumer<NewsFeedCubit, NewsFeedState>(
      listener: (context, state) {
        // Com o feed vazio o erro já aparece na tela; aqui só o de ação
        // (ex.: falha ao excluir).
        if (state is ErrorNewsFeedState && state.news.isNotEmpty) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        if (state is LoadingNewsFeedState && state.news.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ErrorNewsFeedState && state.news.isEmpty) {
          return _Message(text: l10n.newsLoadError);
        }
        if (state.news.isEmpty) return _Message(text: l10n.newsEmpty);

        return ListView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: state.news.length,
          itemBuilder: (context, index) => _NewsItem(news: state.news[index], isAdmin: isAdmin),
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s18),
      ),
    );
  }
}

class _NewsItem extends StatelessWidget {
  final NewsDTO news;
  final bool isAdmin;

  const _NewsItem({required this.news, required this.isAdmin});

  Future<void> _openLink() async {
    final uri = Uri.tryParse(news.link);
    if (uri != null) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final Widget card;
    final List<Widget> actions;

    if (news.isGoal) {
      card = GoalCard(news: news);
      actions = [_DeleteAction(news: news)];
    } else if (news.isAd) {
      card = InkWell(onTap: news.link.isNotEmpty ? _openLink : null, child: AdCard(news: news));
      actions = [_DeleteAction(news: news)];
    } else {
      card = GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.newsDetailsPage, arguments: {'news': news}),
        child: NewsCard(news: news),
      );
      actions = [_EditAction(news: news), _DeleteAction(news: news)];
    }

    return Padding(
      padding: const EdgeInsets.all(AppSizes.s8),
      child: Stack(
        children: [
          card,
          if (isAdmin)
            Positioned(
              top: AppSizes.s8,
              right: AppSizes.s8,
              child: Column(children: actions),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s8),
      child: Material(
        color: AppColors.white,
        shape: const CircleBorder(side: BorderSide(color: AppColors.black)),
        child: IconButton(icon: Icon(icon, color: AppColors.black), onPressed: onTap),
      ),
    );
  }
}

class _EditAction extends StatelessWidget {
  final NewsDTO news;

  const _EditAction({required this.news});

  @override
  Widget build(BuildContext context) {
    return _ActionButton(
      icon: Icons.edit,
      onTap: () => Navigator.pushNamed(context, AppRoutes.registerNewsPage, arguments: {'news': news}),
    );
  }
}

class _DeleteAction extends StatelessWidget {
  final NewsDTO news;

  const _DeleteAction({required this.news});

  Future<void> _confirm(BuildContext context) async {
    final cubit = BlocProvider.of<NewsFeedCubit>(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(
          l10n.newsDeleteConfirm,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: AppSizes.s20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ArenaButton.outlined(
                  title: l10n.commonCancel,
                  function: () => Navigator.pop(dialogContext, false),
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: ArenaButton.primary(
                  title: l10n.commonDelete,
                  function: () => Navigator.pop(dialogContext, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.delete(news.id);
  }

  @override
  Widget build(BuildContext context) {
    return _ActionButton(icon: Icons.delete, onTap: () => _confirm(context));
  }
}
