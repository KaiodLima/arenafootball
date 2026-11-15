import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/event_polls/presentation/bloc/event_poll_cubit.dart';
import 'package:arena_soccer/features/event_polls/presentation/page/event_poll_page.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_by_id_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_by_id_state.dart';
import 'package:arena_soccer/features/news/presentation/page/news_details_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Notícia aberta por um link (só o id): carrega e mostra o detalhe; se ela
/// foi apagada, o aviso de "não está mais disponível".
class NewsByIdPage extends StatefulWidget {
  final String newsId;

  const NewsByIdPage({super.key, required this.newsId});

  @override
  State<NewsByIdPage> createState() => _NewsByIdPageState();
}

class _NewsByIdPageState extends State<NewsByIdPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<NewsByIdCubit>(context).load(widget.newsId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<NewsByIdCubit, NewsByIdState>(
      builder: (context, state) {
        if (state is SuccessNewsByIdState) {
          // Link/push de um evento de votação: abre a página do evento.
          if (state.news.isEvent) {
            return BlocProvider<EventPollCubit>(
              create: (_) => EventPollCubit(sl()),
              child: EventPollPage(eventId: state.news.id, initial: state.news),
            );
          }
          return NewsDetailsPage(news: state.news);
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(backgroundColor: AppColors.primaryDark, foregroundColor: AppColors.white),
          body: switch (state) {
            NotFoundNewsByIdState() => ArenaEmptyState(message: l10n.newsNotFound, icon: Icons.article_outlined),
            ErrorNewsByIdState(:final errorMessage) => ArenaEmptyState.error(message: errorMessage),
            _ => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          },
        );
      },
    );
  }
}
