import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/core/utils/relative_time.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_image_header.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Detalhe de uma notícia: foto (ou álbum) no topo que encolhe ao rolar,
/// conteúdo numa folha clara e "Saiba mais" fixo no rodapé quando há link.
class NewsDetailsPage extends StatefulWidget {
  final NewsDTO news;

  const NewsDetailsPage({super.key, required this.news});

  @override
  State<NewsDetailsPage> createState() => _NewsDetailsPageState();
}

class _NewsDetailsPageState extends State<NewsDetailsPage> {
  final _scroll = ScrollController();

  /// A barra colapsou (mostra o título e fica verde).
  bool _collapsed = false;

  NewsDTO get news => widget.news;

  Uri? get _link => news.link.trim().isEmpty ? null : Uri.tryParse(news.link.trim());

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  double _expandedHeight(BuildContext context) => MediaQuery.sizeOf(context).height * 0.5;

  void _onScroll() {
    final collapsed = _scroll.offset > _expandedHeight(context) - kToolbarHeight - MediaQuery.paddingOf(context).top;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  Future<void> _openLink() async {
    final link = _link;
    if (link != null) await launchUrl(link, mode: LaunchMode.externalApplication);
  }

  void _share(AppLocalizations l10n) {
    final link = news.link.trim();
    final text = link.isEmpty ? '${news.title}\n\n${l10n.newsShareFooter}' : '${news.title}\n$link';
    ShareService.shareText(text, subject: news.title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: _expandedHeight(context),
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              surfaceTintColor: AppColors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: _CircleAction(
                visible: !_collapsed,
                icon: Icons.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onTap: () => Navigator.maybePop(context),
              ),
              title: AnimatedOpacity(
                opacity: _collapsed ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  news.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                ),
              ),
              actions: [
                _CircleAction(
                  visible: !_collapsed,
                  icon: Icons.share_rounded,
                  tooltip: l10n.newsShare,
                  onTap: () => _share(l10n),
                ),
                const SizedBox(width: AppSizes.s8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
                background: NewsImageHeader(news: news),
              ),
            ),
            SliverToBoxAdapter(child: _Content(news: news)),
          ],
        ),
        bottomNavigationBar: _link == null ? null : _ReadMoreBar(host: _link!.host, onTap: _openLink),
      ),
    );
  }
}

/// Botão da barra: círculo escuro translúcido sobre a foto; ícone simples
/// quando a barra colapsa (fundo verde).
class _CircleAction extends StatelessWidget {
  final bool visible;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleAction({required this.visible, required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: AppSizes.s40,
        height: AppSizes.s40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: visible ? AppColors.black.withValues(alpha: 0.4) : AppColors.transparent,
        ),
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.white, size: AppSizes.s22),
        ),
      ),
    );
  }
}

/// Folha clara com região/data, título e texto (a borda arredondada fica no
/// [NewsImageHeader]).
class _Content extends StatelessWidget {
  final NewsDTO news;

  const _Content({required this.news});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s4, AppSizes.s20, AppSizes.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSizes.s8,
            runSpacing: AppSizes.s8,
            children: [
              if (news.region.isNotEmpty) _MetaChip(icon: Icons.place_outlined, label: news.region),
              if (news.date != null)
                _MetaChip(icon: Icons.schedule_rounded, label: RelativeTime.format(news.date!, l10n)),
            ],
          ),
          const SizedBox(height: AppSizes.s16),
          SelectableText(news.title, style: AppTypography.display().copyWith(fontSize: AppSizes.s24)),
          if (news.description.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s16),
            SelectableText(
              news.description,
              style: AppTypography.body().copyWith(height: 1.6, color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s6),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s14, color: AppColors.primaryDark),
          const SizedBox(width: AppSizes.s4),
          Text(label, style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}

/// Rodapé fixo com o link da notícia ("Saiba mais · dominio.com").
class _ReadMoreBar extends StatelessWidget {
  final String host;
  final VoidCallback onTap;

  const _ReadMoreBar({required this.host, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final domain = host.startsWith('www.') ? host.substring(4) : host;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s20, offset: Offset(0, -AppSizes.s2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s12),
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
              onTap: onTap,
              child: SizedBox(
                height: AppSizes.buttonHeightLarge,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, color: AppColors.white),
                      const SizedBox(width: AppSizes.s10),
                      Text(l10n.newsReadMore,
                          style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s16)),
                      const SizedBox(width: AppSizes.s8),
                      Expanded(
                        child: Text(
                          domain,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.subtitle(color: AppColors.whiteSoft),
                        ),
                      ),
                      const Icon(Icons.open_in_new_rounded, color: AppColors.white, size: AppSizes.s20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
