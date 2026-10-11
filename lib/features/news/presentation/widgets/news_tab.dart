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
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Aba Início da home: feed de notícias da região selecionada.
/// [header] entra no topo da lista e rola junto (ex.: destaques).
/// A home recria a aba (key) quando a região muda.
class NewsTab extends StatelessWidget {
  final Widget? header;

  const NewsTab({super.key, this.header});

  @override
  Widget build(BuildContext context) {
    final region = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    return BlocProvider<NewsFeedCubit>(
      create: (_) => NewsFeedCubit(sl(), sl())..watch(region: region),
      child: _NewsFeed(header: header),
    );
  }
}

class _NewsFeed extends StatelessWidget {
  final Widget? header;

  const _NewsFeed({this.header});

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
        final Widget? placeholder;
        if (state is LoadingNewsFeedState && state.news.isEmpty) {
          placeholder = const Padding(
            padding: EdgeInsets.only(top: AppSizes.s48),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        } else if (state is ErrorNewsFeedState && state.news.isEmpty) {
          placeholder = ArenaEmptyState.error(message: l10n.newsLoadError);
        } else if (state.news.isEmpty) {
          placeholder = ArenaEmptyState(message: l10n.newsEmpty, icon: Icons.article_outlined);
        } else {
          placeholder = null;
        }

        return ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          // Espaço no fim para o FAB do admin não cobrir o último card.
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s100),
          children: [
            if (header != null) header!,
            if (placeholder != null)
              placeholder
            else
              for (final news in state.news) _NewsItem(news: news, isAdmin: isAdmin),
          ],
        );
      },
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

  Widget? _adminMenu(BuildContext context, {required bool onImage, required bool canEdit}) {
    if (!isAdmin) return null;
    final l10n = AppLocalizations.of(context);
    return CardMenuButton(
      onImage: onImage,
      actions: [
        if (canEdit)
          CardMenuAction(
            icon: Icons.edit_outlined,
            label: l10n.commonEdit,
            onSelected: () => Navigator.pushNamed(context, AppRoutes.registerNewsPage, arguments: {'news': news}),
          ),
        CardMenuAction(
          icon: Icons.delete_outline_rounded,
          label: l10n.commonDelete,
          destructive: true,
          onSelected: () => _confirmDelete(context),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = BlocProvider.of<NewsFeedCubit>(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        content: Text(l10n.newsDeleteConfirm, textAlign: TextAlign.center, style: AppTypography.title()),
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
    if (news.isGoal) {
      return GoalCard(
        news: news,
        trailing: _adminMenu(context, onImage: false, canEdit: false),
        // Admin: lança o próximo gol do mesmo jogo partindo deste placar.
        onTap: isAdmin
            ? () => Navigator.pushNamed(context, AppRoutes.goalNotificationPage, arguments: {'news': news})
            : null,
      );
    }
    if (news.isAd) {
      return AdCard(
        news: news,
        onTap: news.link.isNotEmpty ? _openLink : null,
        trailing: _adminMenu(context, onImage: true, canEdit: false),
      );
    }
    return NewsCard(
      news: news,
      onTap: () => Navigator.pushNamed(context, AppRoutes.newsDetailsPage, arguments: {'news': news}),
      trailing: _adminMenu(context, onImage: true, canEdit: true),
    );
  }
}
