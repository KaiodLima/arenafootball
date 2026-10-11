import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlights_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlights_state.dart';
import 'package:arena_soccer/features/highlights/presentation/widgets/highlight_avatar.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Destaques no topo do feed, no formato "stories". Sem destaques, ou se a
/// leitura falhar, não ocupa espaço.
class HighlightsCarousel extends StatelessWidget {
  const HighlightsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HighlightsCubit>(
      create: (_) => HighlightsCubit(sl())..watch(),
      child: const _HighlightsRow(),
    );
  }
}

class _HighlightsRow extends StatelessWidget {
  const _HighlightsRow();

  static const double _rowHeight = AppSizes.storySize + AppSizes.s30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<HighlightsCubit, HighlightsState>(
      builder: (context, state) {
        final loading = state is LoadingHighlightsState && state.highlights.isEmpty;
        if (!loading && state.highlights.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: l10n.homeHighlights),
            SizedBox(
              height: _rowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemCount: loading ? 4 : state.highlights.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s8),
                itemBuilder: (context, index) {
                  if (loading) return const HighlightAvatar.skeleton();
                  final highlight = state.highlights[index];
                  return HighlightAvatar(
                    imageUrl: highlight.imageUrl,
                    title: highlight.title,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.highlightDetailsPage,
                      arguments: {'highlight': highlight},
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.s12),
          ],
        );
      },
    );
  }
}
