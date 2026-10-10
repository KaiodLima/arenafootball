import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_news_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_news_state.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Detalhes de um destaque + notícias com a tag igual ao título dele.
/// A imagem encolhe quando a tela começa a rolar.
class HighlightDetailsPage extends StatefulWidget {
  final HighlightDTO highlight;

  const HighlightDetailsPage({super.key, required this.highlight});

  @override
  State<HighlightDetailsPage> createState() => _HighlightDetailsPageState();
}

class _HighlightDetailsPageState extends State<HighlightDetailsPage> with SingleTickerProviderStateMixin {
  static const Size _imageExpanded = Size(500, 500);
  static const Size _imageCollapsed = Size(150, 150);

  late final AnimationController _animation;
  late final Animation<Size> _imageSize;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _imageSize = Tween(begin: _imageExpanded, end: _imageCollapsed).animate(
      CurvedAnimation(parent: _animation, curve: Curves.linear),
    );
    _scrollController.addListener(_animation.forward);
    BlocProvider.of<HighlightNewsCubit>(context).watch(highlightTitle: widget.highlight.title);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animation.dispose();
    super.dispose();
  }

  Future<void> _openLink() async {
    final uri = Uri.tryParse(widget.highlight.link);
    if (uri != null) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final highlight = widget.highlight;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(AppImages.logo, width: AppSizes.logoWidth, height: AppSizes.logoHeight),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.s8),
              child: AnimatedBuilder(
                animation: _imageSize,
                builder: (context, _) => Container(
                  height: _imageSize.value.height,
                  width: _imageSize.value.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        highlight.imageUrl.isNotEmpty ? highlight.imageUrl : newsPlaceholderImageUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(AppSizes.s20)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
              child: AutoSizeText(
                highlight.title,
                style: const TextStyle(fontSize: AppSizes.s24, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSizes.s20),
            if (highlight.link.isNotEmpty)
              InkWell(
                onTap: _openLink,
                child: Text(
                  highlight.link,
                  style: const TextStyle(decoration: TextDecoration.underline, color: AppColors.whiteSoft),
                ),
              ),
            const SizedBox(height: AppSizes.s24),
            const _HighlightNewsList(),
          ],
        ),
      ),
    );
  }
}

class _HighlightNewsList extends StatelessWidget {
  const _HighlightNewsList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<HighlightNewsCubit, HighlightNewsState>(
      builder: (context, state) {
        if (state is LoadingHighlightNewsState && state.news.isEmpty) {
          return const CircularProgressIndicator(color: AppColors.primary);
        }
        // Erro de leitura ou lista vazia: mesma mensagem do app antigo.
        if (state.news.isEmpty) {
          return Center(
            child: Text(l10n.highlightNoNews, style: const TextStyle(color: AppColors.white)),
          );
        }
        return Column(
          children: state.news
              .map(
                (news) => GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.newsDetailsPage, arguments: {'news': news}),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.s8),
                    child: NewsCard(news: news),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
