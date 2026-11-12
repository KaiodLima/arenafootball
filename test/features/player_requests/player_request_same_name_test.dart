import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/cancel_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/submit_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_my_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_state.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_state.dart';
import 'package:arena_soccer/features/player_requests/presentation/page/player_request_page.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Edu Lima já está no elenco do Lava Jato, sem conta.
const _edu = PlayerDTO(id: 'p9', name: 'Édu  Lima', team: 'Lava Jato', teamId: '1', goals: 4, position: 'atacante');

class _WatchMine implements WatchMyPlayerRequestUseCase {
  @override
  Stream<Either<Failure, PlayerRequestDTO?>> call(String userId) => Stream.value(const Right(null));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Submit implements SubmitPlayerRequestUseCase {
  final sent = <PlayerRequestDTO>[];

  @override
  Future<Either<Failure, void>> call(PlayerRequestDTO request, {File? photo}) async {
    sent.add(request);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cancel implements CancelPlayerRequestUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Regions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta']);
}

class _Teams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.value(const Right([TeamDTO(id: '1', name: 'Lava Jato', region: 'Floresta')]));
}

class _Squad implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(const Right([_edu]));
}

class _Championships implements GetRegionChampionshipsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> call(
          {required String region, required String season, bool force = false}) =>
      Stream.value(const Right([]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session() : super(const SessionState(user: UserDTO(id: 'u1', name: 'Edu Lima', email: 'e@x.com')));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Region extends Cubit<RegionState> implements RegionCubit {
  _Region() : super(const RegionState(regions: ['Floresta'], selectedRegion: 'Floresta'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MyPlayer extends Cubit<MyPlayerState> implements MyPlayerCubit {
  _MyPlayer(PlayerDTO? player) : super(MyPlayerState(player: player));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('form', () {
    const form = PlayerRequestForm(name: 'edu lima', unlinkedPlayers: [_edu]);

    test('mesmo nome (sem acento, maiúscula e espaços) acha o atleta sem conta', () {
      expect(form.sameNameUnlinked?.id, 'p9');
      expect(form.copyWith(name: '  EDU   LIMA ').sameNameUnlinked?.id, 'p9');
    });

    test('nome só parecido ou vínculo: não pergunta', () {
      expect(form.copyWith(name: 'Edu Lima Souza').sameNameUnlinked, isNull);
      expect(form.copyWith(claimedPlayer: () => _edu).sameNameUnlinked, isNull);
    });

    test('conta com cadastro antigo: o de mesmo nome sem conta no elenco também é achado', () {
      const own = PlayerDTO(id: 'me', name: 'Edu Lima', team: '', userId: 'u1');
      final withOwn = form.copyWith(accountPlayer: () => own);
      expect(withOwn.hasOwnPlayer, isTrue);
      expect(withOwn.sameNameUnlinked?.id, 'p9');
    });
  });

  group('página', () {
    late _Submit submit;
    late PlayerRequestCubit cubit;

    Future<void> pump(WidgetTester tester, {PlayerDTO? accountPlayer}) async {
      submit = _Submit();
      cubit = PlayerRequestCubit(_WatchMine(), submit, _Cancel(), _Regions(), _Teams(), _Squad(), _Championships());
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>(create: (_) => _Session()),
          BlocProvider<RegionCubit>(create: (_) => _Region()),
          BlocProvider<MyPlayerCubit>(create: (_) => _MyPlayer(accountPlayer)),
          BlocProvider<PlayerRequestCubit>.value(value: cubit),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('pt'),
          home: PlayerRequestPage(),
        ),
      ));
      await tester.pumpAndSettle();
      await cubit.selectTeam('Lava Jato');
      cubit.selectPosition(PlayerPosition.forward);
      await tester.pumpAndSettle();
    }

    Future<void> send(WidgetTester tester) async {
      await tester.tap(find.text('ENVIAR SOLICITAÇÃO'));
      await tester.pumpAndSettle();
    }

    testWidgets('"Sou eu": o pedido vai como vínculo ao atleta encontrado', (tester) async {
      await pump(tester);
      await send(tester);
      expect(find.text('Você é o Édu  Lima do Lava Jato?'), findsOneWidget);
      await tester.tap(find.text('Sou eu'));
      await tester.pumpAndSettle();
      expect(submit.sent.single.claimedPlayerId, 'p9');
      await cubit.close();
    });

    testWidgets('"Não sou eu": segue como cadastro novo', (tester) async {
      await pump(tester);
      await send(tester);
      await tester.tap(find.text('Não sou eu'));
      await tester.pumpAndSettle();
      expect(submit.sent.single.claimedPlayerId, '');
      await cubit.close();
    });

    testWidgets('fechar no ✕ não envia', (tester) async {
      await pump(tester);
      await send(tester);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(submit.sent, isEmpty);
      await cubit.close();
    });

    testWidgets('nome diferente: envia direto, sem o modal', (tester) async {
      await pump(tester);
      cubit.changeName('Outro Nome');
      await tester.pumpAndSettle();
      await send(tester);
      expect(find.text('Sou eu'), findsNothing);
      expect(submit.sent, hasLength(1));
      await cubit.close();
    });

    testWidgets('saiu do elenco e o admin criou outro com o mesmo nome: pergunta e "Sou eu" liga a ele',
        (tester) async {
      const own = PlayerDTO(id: 'me', name: 'Edu Lima', team: '', goals: 12, position: 'atacante', userId: 'u1');
      await pump(tester, accountPlayer: own);
      expect(find.text('Seu cadastro de atleta'), findsOneWidget);
      await send(tester);
      expect(find.textContaining('o admin junta esse cadastro com o seu'), findsOneWidget);
      await tester.tap(find.text('Sou eu'));
      await tester.pumpAndSettle();
      expect(submit.sent.single.claimedPlayerId, 'p9');
      await cubit.close();
    });

    testWidgets('saiu do elenco: "Não sou eu" segue com o próprio cadastro', (tester) async {
      const own = PlayerDTO(id: 'me', name: 'Edu Lima', team: '', goals: 12, position: 'atacante', userId: 'u1');
      await pump(tester, accountPlayer: own);
      await send(tester);
      await tester.tap(find.text('Não sou eu'));
      await tester.pumpAndSettle();
      expect(submit.sent.single.claimedPlayerId, '');
      await cubit.close();
    });

    testWidgets('atualização do cadastro da conta não desfaz o "Sou eu"', (tester) async {
      const own = PlayerDTO(id: 'me', name: 'Edu Lima', team: '', userId: 'u1');
      await pump(tester, accountPlayer: own);
      cubit.claimPlayer(_edu);
      cubit.setAccountPlayer(own.copyWith(goals: 13));
      expect(cubit.state.form.claimedPlayer?.id, 'p9');
      await cubit.close();
    });
  });
}
