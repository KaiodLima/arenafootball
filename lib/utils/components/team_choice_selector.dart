import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Seletor do time do coração. Fechado, parece um campo (escudo + nome do
/// escolhido); ao tocar, abre um carrossel de páginas 3x3 com os escudos.
/// Escolher um time fecha o painel. O marcado é o de [selectedId] (ou, sem
/// id, o de nome [selected]).
class TeamChoiceSelector extends StatefulWidget {
  final List<TeamDTO> teams;
  final String? selected;
  final String selectedId;
  final ValueChanged<TeamDTO> onSelected;
  final String placeholder;
  final bool loading;

  const TeamChoiceSelector({
    super.key,
    required this.teams,
    required this.selected,
    this.selectedId = '',
    required this.onSelected,
    required this.placeholder,
    this.loading = false,
  });

  @override
  State<TeamChoiceSelector> createState() => _TeamChoiceSelectorState();
}

class _TeamChoiceSelectorState extends State<TeamChoiceSelector> {
  static const int _columns = 3;
  static const int _pageSize = _columns * 3;
  static const double _cardAspectRatio = 0.82;
  static const double _spacing = AppSizes.s10;
  static const Duration _animation = Duration(milliseconds: 220);

  bool _expanded = false;
  PageController? _pageController;
  int _page = 0;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  List<List<TeamDTO>> get _pages => [
        for (var i = 0; i < widget.teams.length; i += _pageSize)
          widget.teams.sublist(i, (i + _pageSize).clamp(0, widget.teams.length)),
      ];

  bool _isSelected(TeamDTO team) =>
      sameTeam(idA: team.id, nameA: team.name, idB: widget.selectedId, nameB: widget.selected ?? '');

  TeamDTO? get _selectedTeam {
    for (final team in widget.teams) {
      if (_isSelected(team)) return team;
    }
    return null;
  }

  void _toggle() {
    if (widget.loading || widget.teams.isEmpty) return;
    if (!_expanded) {
      // Abre na página do time já escolhido.
      final index = widget.teams.indexWhere(_isSelected);
      _page = index < 0 ? 0 : index ~/ _pageSize;
      _pageController?.dispose();
      _pageController = PageController(initialPage: _page);
    }
    setState(() => _expanded = !_expanded);
  }

  void _select(TeamDTO team) {
    widget.onSelected(team);
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField(),
        AnimatedSize(
          duration: _animation,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded ? _buildPanel() : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildField() {
    final team = _selectedTeam;
    final decoration = arenaInputDecoration(
      label: widget.placeholder,
      icon: team == null ? Icons.shield_outlined : null,
      suffix: AnimatedRotation(
        turns: _expanded ? 0.5 : 0,
        duration: _animation,
        child: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
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
              decoration: team == null
                  ? decoration
                  : decoration.copyWith(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                        child: TeamCrest(imageUrl: team.imageUrl, size: AppSizes.s32),
                      ),
                    ),
              isFocused: _expanded,
              isEmpty: team == null,
              child: Text(
                team?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(),
              ),
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

  Widget _buildPanel() {
    final pages = _pages;
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - _spacing * (_columns - 1)) / _columns;
          final pageHeight = (cardWidth / _cardAspectRatio) * 3 + _spacing * 2;
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
                      for (final team in pages[index])
                        TeamChoiceCard(
                          team: team,
                          selected: _isSelected(team),
                          onTap: () => _select(team),
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
                  onTap: (page) => _pageController?.animateToPage(
                    page,
                    duration: _animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Indicador de página dos carrosséis de escolha; tocar num ponto vai à página.
class ChoicePageDots extends StatelessWidget {
  final int count;
  final int current;
  final ValueChanged<int> onTap;

  const ChoicePageDots({super.key, required this.count, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.s4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == current ? AppSizes.s20 : AppSizes.s8,
                height: AppSizes.s8,
                decoration: BoxDecoration(
                  color: i == current ? AppColors.primary : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppSizes.s4),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Card de time com escudo, nome e check quando escolhido (usado também na
/// seleção múltipla de times do campeonato).
class TeamChoiceCard extends StatelessWidget {
  final TeamDTO team;
  final bool selected;
  final VoidCallback onTap;

  const TeamChoiceCard({super.key, required this.team, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.fieldRadius);
    return Semantics(
      button: true,
      selected: selected,
      label: team.name,
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
                    TeamCrest(imageUrl: team.imageUrl, size: AppSizes.s56),
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
                const SizedBox(height: AppSizes.s8),
                Text(
                  team.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(color: selected ? AppColors.primaryDark : AppColors.textPrimary).copyWith(
                    fontSize: AppSizes.s12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
