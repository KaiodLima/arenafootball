import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/team_choice_selector.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Sou eu" do "Sou jogador", no formato do seletor de time: fechado, parece
/// um campo (foto + nome do escolhido, ✕ para desmarcar); ao tocar, abre um
/// carrossel de páginas 3x3 com os atletas sem conta, com busca pelo nome
/// quando são muitos. [onSelected] nulo = desmarcou.
class PlayerClaimSelector extends StatefulWidget {
  final List<PlayerDTO> players;
  final PlayerDTO? selected;
  final bool loading;
  final ValueChanged<PlayerDTO?> onSelected;

  const PlayerClaimSelector({
    super.key,
    required this.players,
    required this.selected,
    required this.onSelected,
    this.loading = false,
  });

  @override
  State<PlayerClaimSelector> createState() => _PlayerClaimSelectorState();
}

class _PlayerClaimSelectorState extends State<PlayerClaimSelector> {
  static const int _columns = 3;
  static const int _pageSize = _columns * 3;
  static const double _cardAspectRatio = 0.78;
  static const double _spacing = AppSizes.s10;
  static const Duration _animation = Duration(milliseconds: 220);

  bool _expanded = false;
  String _query = '';
  PageController? _pageController;
  int _page = 0;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  List<PlayerDTO> get _filtered {
    final query = foldForSearch(_query.trim());
    if (query.isEmpty) return widget.players;
    return widget.players.where((p) => foldForSearch(p.name).contains(query)).toList();
  }

  bool _isSelected(PlayerDTO player) => player.id == widget.selected?.id;

  void _resetPages({int page = 0}) {
    _page = page;
    _pageController?.dispose();
    _pageController = PageController(initialPage: page);
  }

  void _toggle() {
    if (widget.loading || widget.players.isEmpty) return;
    if (!_expanded) {
      // Abre na página do atleta já escolhido, sem filtro.
      _query = '';
      final index = widget.players.indexWhere(_isSelected);
      _resetPages(page: index < 0 ? 0 : index ~/ _pageSize);
    }
    setState(() => _expanded = !_expanded);
  }

  void _search(String query) => setState(() {
        _query = query;
        _resetPages();
      });

  void _select(PlayerDTO player) {
    // Tocar no já escolhido desmarca.
    widget.onSelected(_isSelected(player) ? null : player);
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField(context),
        AnimatedSize(
          duration: _animation,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded ? _buildPanel(context) : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildField(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = widget.selected;
    final decoration = arenaInputDecoration(
      label: l10n.playerRequestClaimPlaceholder,
      icon: player == null ? Icons.how_to_reg_outlined : null,
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player != null)
            IconButton(
              tooltip: l10n.goalClear,
              onPressed: () => widget.onSelected(null),
              icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
            ),
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: _animation,
            child: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSizes.s8),
        ],
      ),
    );

    return Semantics(
      button: true,
      expanded: _expanded,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        onTap: _toggle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputDecorator(
              decoration: player == null
                  ? decoration
                  : decoration.copyWith(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                        child: PlayerAvatar(player: player, size: AppSizes.s32),
                      ),
                    ),
              isFocused: _expanded,
              isEmpty: player == null,
              child:
                  Text(player?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.body()),
            ),
            if (widget.loading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.s12),
                child: LinearProgressIndicator(minHeight: AppSizes.s2, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final players = _filtered;
    final pages = [
      for (var i = 0; i < players.length; i += _pageSize) players.sublist(i, (i + _pageSize).clamp(0, players.length)),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.players.length > _pageSize) ...[
            ArenaSearchField(hint: l10n.playerRequestClaimSearch, onChanged: _search),
            const SizedBox(height: AppSizes.s12),
          ],
          if (pages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s24),
              child:
                  Text(l10n.playerRequestClaimNoResults, textAlign: TextAlign.center, style: AppTypography.subtitle()),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - _spacing * (_columns - 1)) / _columns;
                // Página com menos linhas (busca) não deixa buraco embaixo.
                final rows = pages.length > 1 ? 3 : (pages.first.length / _columns).ceil();
                final pageHeight = (cardWidth / _cardAspectRatio) * rows + _spacing * (rows - 1);
                return Column(
                  children: [
                    SizedBox(
                      height: pageHeight,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: pages.length,
                        onPageChanged: (page) => setState(() => _page = page),
                        itemBuilder: (context, index) => GridView.count(
                          crossAxisCount: _columns,
                          mainAxisSpacing: _spacing,
                          crossAxisSpacing: _spacing,
                          childAspectRatio: _cardAspectRatio,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (final player in pages[index])
                              _PlayerChoiceCard(
                                player: player,
                                selected: _isSelected(player),
                                onTap: () => _select(player),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (pages.length > 1) ...[
                      const SizedBox(height: AppSizes.s12),
                      ChoicePageDots(
                        count: pages.length,
                        current: _page,
                        onTap: (page) =>
                            _pageController?.animateToPage(page, duration: _animation, curve: Curves.easeOutCubic),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Card do atleta no carrossel: foto, nome, gols e check quando escolhido
/// (mesmo visual do `TeamChoiceCard`).
class _PlayerChoiceCard extends StatelessWidget {
  final PlayerDTO player;
  final bool selected;
  final VoidCallback onTap;

  const _PlayerChoiceCard({required this.player, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppSizes.fieldRadius);
    return Semantics(
      button: true,
      selected: selected,
      label: player.name,
      excludeSemantics: true,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : AppColors.surface,
              borderRadius: radius,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.greyLight,
                width: selected ? AppSizes.s2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PlayerAvatar(player: player, size: AppSizes.s48),
                    Positioned(
                      right: -AppSizes.s4,
                      bottom: -AppSizes.s2,
                      child: AnimatedScale(
                        scale: selected ? 1 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Container(
                          decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                          child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: AppSizes.s22),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s6),
                Text(
                  player.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(color: selected ? AppColors.primaryDark : AppColors.textPrimary).copyWith(
                    fontSize: AppSizes.s12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.15,
                  ),
                ),
                Text(
                  l10n.playerRequestClaimGoals(player.goals),
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
