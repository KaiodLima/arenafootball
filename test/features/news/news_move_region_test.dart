import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/delete_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_page_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/update_news_region_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_feed_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_cubit.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_tab.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_cubit.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_state.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Notícia do parceiro p1 na Floresta.
const _news = NewsDTO(id: 'n1', title: 'Peneira no sábado', region: 'Floresta', authorId: 'p1');

class _Repo implements INewsRepository {
  final moved = <(String, String)>[];

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNews({String? region, int limit = 20}) =>
      Stream.value(const Right([_news]));

  @override
  Future<Either<Failure, void>> updateNewsRegion({required String id, required String region}) async {
    moved.add((id, region));
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session(bool admin) : super(SessionState(user: UserDTO(id: 'u', name: 'Conta', email: 'c@x.com', isAdmin: admin)));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Partner extends Cubit<PartnerState> implements PartnerCubit {
  _Partner(PartnerRequestDTO? request) : super(PartnerState(request: request));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Region extends Cubit<RegionState> implements RegionCubit {
  _Region() : super(const RegionState(regions: ['Floresta', 'Riacho'], selectedRegion: 'Floresta'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Repo repo;

  Future<void> pump(WidgetTester tester, {required bool admin, PartnerRequestDTO? partner}) async {
    repo = _Repo();
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(create: (_) => _Session(admin)),
        BlocProvider<PartnerCubit>(create: (_) => _Partner(partner)),
        BlocProvider<RegionCubit>(create: (_) => _Region()),
        BlocProvider<NewsFeedCubit>(
          create: (_) => NewsFeedCubit(
            WatchNewsFeedUseCase(repo),
            GetNewsPageUseCase(repo),
            DeleteNewsUseCase(repo),
            UpdateNewsRegionUseCase(repo),
          ),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: Scaffold(body: NewsTab()),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings_rounded).first);
    await tester.pumpAndSettle();
  }

  testWidgets('admin: "Mudar região" → escolhe a região → confirma → grava', (tester) async {
    await pump(tester, admin: true);
    await openMenu(tester);
    await tester.tap(find.text('Mudar região'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riacho').last);
    await tester.pumpAndSettle();
    expect(find.text('Mover para Riacho?'), findsOneWidget);
    await tester.tap(find.text('Mudar região').last);
    await tester.pumpAndSettle();
    expect(repo.moved, [('n1', 'Riacho')]);
  });

  testWidgets('parceiro dono da notícia: edita/apaga, mas não muda a região', (tester) async {
    await pump(
      tester,
      admin: false,
      partner: const PartnerRequestDTO(
        userId: 'p1',
        name: 'Loja',
        region: 'Floresta',
        status: PlayerRequestStatus.approved,
      ),
    );
    await openMenu(tester);
    expect(find.text('Excluir'), findsOneWidget);
    expect(find.text('Mudar região'), findsNothing);
  });
}
