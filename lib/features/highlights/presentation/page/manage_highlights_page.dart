import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/manage_highlights_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/manage_highlights_state.dart';
import 'package:arena_soccer/features/highlights/presentation/widgets/highlight_avatar.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel de destaques (admin): ordem do carrossel arrastando, mostrar/
/// ocultar, editar, ver e excluir.
class ManageHighlightsPage extends StatefulWidget {
  const ManageHighlightsPage({super.key});

  @override
  State<ManageHighlightsPage> createState() => _ManageHighlightsPageState();
}

class _ManageHighlightsPageState extends State<ManageHighlightsPage> {
  late final ManageHighlightsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ManageHighlightsCubit>(context)..watch();
  }

  void _create() => Navigator.pushNamed(context, AppRoutes.registerHighlightPage);

  void _edit(HighlightDTO highlight) =>
      Navigator.pushNamed(context, AppRoutes.registerHighlightPage, arguments: {'highlight': highlight});

  void _view(HighlightDTO highlight) =>
      Navigator.pushNamed(context, AppRoutes.highlightDetailsPage, arguments: {'highlight': highlight});

  Future<void> _confirmDelete(HighlightDTO highlight, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.highlightDeleteTitle(highlight.title)),
        content: Text(l10n.highlightDeleteMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.commonDelete, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _cubit.delete(highlight);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.highlightsManageTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.highlightCreateTitle,
        onPressed: _create,
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocConsumer<ManageHighlightsCubit, ManageHighlightsState>(
        listener: (context, state) {
          if (state is ErrorManageHighlightsState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
          if (state is DeletedManageHighlightsState) {
            showSnackBar(context: context, message: l10n.highlightDeleted(state.title));
          }
        },
        builder: (context, state) {
          final highlights = state.highlights;
          if (state is LoadingManageHighlightsState && highlights.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (highlights.isEmpty) {
            return state is ErrorManageHighlightsState
                ? ArenaEmptyState.error(message: l10n.highlightLoadError)
                : ArenaEmptyState(message: l10n.highlightsEmpty, icon: Icons.auto_awesome_outlined);
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s80),
            buildDefaultDragHandles: false,
            header: Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s16, AppSizes.s4, AppSizes.s10),
              child: Row(
                children: [
                  const Icon(Icons.swap_vert_rounded, size: AppSizes.s18, color: AppColors.textSecondary),
                  const SizedBox(width: AppSizes.s6),
                  Expanded(
                    child: Text(
                      l10n.highlightsReorderHint,
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                  ),
                ],
              ),
            ),
            itemCount: highlights.length,
            onReorder: _cubit.reorder,
            itemBuilder: (context, index) {
              final highlight = highlights[index];
              return _HighlightTile(
                key: ValueKey(highlight.id),
                index: index,
                highlight: highlight,
                onToggle: (visible) => _cubit.toggleVisible(highlight, visible),
                onTap: () => _edit(highlight),
                actions: [
                  CardMenuAction(icon: Icons.edit_outlined, label: l10n.commonEdit, onSelected: () => _edit(highlight)),
                  CardMenuAction(
                    icon: Icons.visibility_outlined,
                    label: l10n.highlightView,
                    onSelected: () => _view(highlight),
                  ),
                  CardMenuAction(
                    icon: Icons.delete_outline_rounded,
                    label: l10n.commonDelete,
                    destructive: true,
                    onSelected: () => _confirmDelete(highlight, l10n),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Linha do painel: alça de arrastar, círculo, título (+ link ou "Oculto"),
/// switch e menu.
class _HighlightTile extends StatelessWidget {
  final int index;
  final HighlightDTO highlight;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final List<CardMenuAction> actions;

  const _HighlightTile({
    super.key,
    required this.index,
    required this.highlight,
    required this.onToggle,
    required this.onTap,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = !highlight.isVisible
        ? l10n.highlightHidden
        : highlight.link.isNotEmpty
            ? highlight.link.replaceFirst(RegExp(r'^https?://'), '')
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s8, AppSizes.s4, AppSizes.s8),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(AppSizes.s8),
                    child: Icon(Icons.drag_indicator_rounded, color: AppColors.textSecondary),
                  ),
                ),
                Opacity(
                  opacity: highlight.isVisible ? 1 : 0.45,
                  child: HighlightRing(imageUrl: highlight.imageUrl, size: AppSizes.s48),
                ),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        highlight.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSizes.s2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(value: highlight.isVisible, onChanged: onToggle, activeTrackColor: AppColors.primary),
                CardMenuButton(actions: actions),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
