import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlights_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlights_state.dart';
import 'package:arena_soccer/features/highlights/presentation/widgets/highlight_avatar.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Carrossel de destaques do topo da home. Sem destaques, ou se a leitura
/// falhar (ex.: visitante sem permissão no Firestore), não ocupa espaço.
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.12;

    return BlocBuilder<HighlightsCubit, HighlightsState>(
      builder: (context, state) {
        if (state is LoadingHighlightsState && state.highlights.isEmpty) {
          return SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (state.highlights.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
            itemCount: state.highlights.length,
            itemBuilder: (context, index) {
              final highlight = state.highlights[index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.highlightDetailsPage,
                  arguments: {'highlight': highlight},
                ),
                child: HighlightAvatar(imageUrl: highlight.imageUrl),
              );
            },
          ),
        );
      },
    );
  }
}
