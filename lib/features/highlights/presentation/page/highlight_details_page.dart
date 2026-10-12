import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/core/utils/web_link.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_news_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_news_state.dart';
import 'package:arena_soccer/features/highlights/presentation/widgets/highlight_avatar.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Um destaque e as notícias marcadas com ele (tag = título do destaque):
/// topo verde que recolhe com a foto (Hero do carrossel), contagem e link;
/// a lista numa folha clara. O admin publica uma notícia já marcada.
class HighlightDetailsPage extends StatefulWidget {
  final HighlightDTO highlight;

  const HighlightDetailsPage({super.key, required this.highlight});

  @override
  State<HighlightDetailsPage> createState() => _HighlightDetailsPageState();
}

class _HighlightDetailsPageState extends State<HighlightDetailsPage> {
  static const double _expandedHeight = 330;

  final _scroll = ScrollController();
  bool _collapsed = false;

  String get _link => normalizeWebLink(widget.highlight.link);

  @override
  void initState() {
    super.initState();
    BlocProvider.of<HighlightNewsCubit>(context).watch(highlightTitle: widget.highlight.title);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final collapsed = _scroll.offset > _expandedHeight - kToolbarHeight - MediaQuery.paddingOf(context).top;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  Future<void> _openLink() async {
    final uri = Uri.tryParse(_link);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _share(AppLocalizations l10n) {
    final text = l10n.highlightShareText(widget.highlight.title);
    ShareService.shareText(_link.isEmpty ? text : '$text\n$_link', subject: widget.highlight.title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final highlight = widget.highlight;
    final isAdmin = context.watch<SessionCubit>().state.isAdmin;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                // O tema usa círculo (FAB "+" da home); com texto, pílula.
                shape: const StadiumBorder(),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.registerNewsPage,
                  arguments: {'tag': highlight.title},
                ),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.highlightAddNews),
              )
            : null,
        body: BlocBuilder<HighlightNewsCubit, HighlightNewsState>(
          builder: (context, state) {
            final loading = state is LoadingHighlightNewsState && state.news.isEmpty;

            return CustomScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: _expandedHeight,
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.white,
                  surfaceTintColor: AppColors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  title: AnimatedOpacity(
                    opacity: _collapsed ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      highlight.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: l10n.athleteShare,
                      onPressed: () => _share(l10n),
                      icon: const Icon(Icons.share_rounded),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: _Header(
                      highlight: highlight,
                      count: loading ? null : state.news.length,
                      onOpenLink: _link.isEmpty ? null : _openLink,
                    ),
                  ),
                ),
                if (loading)
                  SliverList.builder(itemCount: 3, itemBuilder: (_, __) => const _CardSkeleton())
                else if (state.news.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: state is ErrorHighlightNewsState
                        ? ArenaEmptyState.error(message: l10n.highlightLoadError)
                        : ArenaEmptyState(message: l10n.highlightEmpty, icon: Icons.auto_awesome_outlined),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s8, 0, AppSizes.s8, AppSizes.s80),
                    sliver: SliverList.builder(
                      itemCount: state.news.length,
                      itemBuilder: (context, index) {
                        final news = state.news[index];
                        return NewsCard(
                          news: news,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.newsDetailsPage, arguments: {'news': news}),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Topo: foto com anel (Hero), título e as pílulas de contagem e link. A
/// borda arredondada da folha é desenhada aqui (a barra fixa fica por cima
/// dos slivers seguintes).
class _Header extends StatelessWidget {
  final HighlightDTO highlight;

  /// Nulo enquanto carrega.
  final int? count;
  final VoidCallback? onOpenLink;

  const _Header({required this.highlight, required this.count, required this.onOpenLink});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaHeroBackground(
      watermarkFactor: 0.7,
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.s24 + AppSizes.s8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: highlightHeroTag(highlight.id),
                      child: HighlightRing(imageUrl: highlight.imageUrl, size: AppSizes.s120),
                    ),
                    const SizedBox(height: AppSizes.s12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s24),
                      child: Text(
                        highlight.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s24),
                      ),
                    ),
                    const SizedBox(height: AppSizes.s10),
                    Wrap(
                      spacing: AppSizes.s8,
                      alignment: WrapAlignment.center,
                      children: [
                        _Pill(
                          icon: Icons.article_outlined,
                          label: count == null ? '…' : l10n.highlightNewsCount(count!),
                        ),
                        if (onOpenLink != null)
                          _Pill(icon: Icons.open_in_new_rounded, label: l10n.highlightOpenLink, onTap: onOpenLink),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            height: AppSizes.s24 + 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _Pill({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;

    return Material(
      color: tappable ? AppColors.white : AppColors.whiteMuted,
      borderRadius: BorderRadius.circular(AppSizes.s20),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.s16, color: tappable ? AppColors.primaryDark : AppColors.white),
              const SizedBox(width: AppSizes.s6),
              Text(
                label,
                style: AppTypography.label(color: tappable ? AppColors.primaryDark : AppColors.white)
                    .copyWith(fontSize: AppSizes.s14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card cinza no lugar de uma notícia enquanto a lista carrega.
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s200 + AppSizes.s40,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s8),
      decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
    );
  }
}
