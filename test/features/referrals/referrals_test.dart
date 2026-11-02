import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/referrals/data/dtos/referral_dto.dart';
import 'package:arena_soccer/features/referrals/domain/referral_code.dart';
import 'package:arena_soccer/features/referrals/domain/repositories/referrals_repository_interface.dart';
import 'package:arena_soccer/features/referrals/domain/usecases/referral_usecases.dart';
import 'package:arena_soccer/features/referrals/presentation/bloc/referral_config_cubit.dart';
import 'package:arena_soccer/features/referrals/presentation/bloc/referral_cubit.dart';
import 'package:arena_soccer/features/referrals/presentation/bloc/referral_state.dart';
import 'package:arena_soccer/features/referrals/presentation/page/referral_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

class _Repo implements IReferralsRepository {
  DateTime? createdAt;
  final String claimed;
  final bool enabled;
  final claims = <String>[];
  final toggles = <bool>[];

  _Repo({this.createdAt, this.enabled = true}) : claimed = '';

  @override
  Future<Either<Failure, String>> ensureCode(String uid) async => Right(ReferralCode.of(uid));

  @override
  Stream<Either<Failure, ReferralDTO>> watchReferral(String uid) =>
      Stream.value(const Right(ReferralDTO(invited: 2, extraPacks: 1, extraPacksEarned: 2)));

  @override
  Stream<Either<Failure, List<ReferredFriendDTO>>> watchFriends(String uid) =>
      Stream.value(const Right([ReferredFriendDTO(id: 'f1', name: 'Ana')]));

  @override
  Future<Either<Failure, String>> getClaim(String uid) async => Right(claimed);

  @override
  Future<Either<Failure, void>> claim(String uid, String code) async {
    claims.add(code);
    return const Right(null);
  }

  @override
  DateTime? accountCreatedAt() => createdAt;

  @override
  Stream<Either<Failure, ReferralConfigDTO>> watchConfig() => Stream.value(Right(ReferralConfigDTO(enabled: enabled)));

  @override
  Future<Either<Failure, void>> setEnabled(bool enabled) async {
    toggles.add(enabled);
    return const Right(null);
  }
}

/// Monta a tela com a config [enabled] já lida.
Future<void> _pumpPage(WidgetTester tester, _Repo repo) async {
  final session = _Session(const UserDTO(id: 'meuUid1234', name: 'Kai', email: 'k@x.com'));
  final config = ReferralConfigCubit(WatchReferralConfigUseCase(repo), SetReferralEnabledUseCase(repo))..start();
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    onGenerateRoute: (settings) => MaterialPageRoute(
      settings: const RouteSettings(arguments: {'code': 'AMIG0ABC'}),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: session),
          BlocProvider<ReferralConfigCubit>.value(value: config),
          BlocProvider<ReferralCubit>.value(value: _cubit(repo)),
        ],
        child: const ReferralPage(),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session(UserDTO user) : super(SessionState(user: user));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ReferralCubit _cubit(_Repo repo) => ReferralCubit(
      EnsureReferralCodeUseCase(repo),
      WatchReferralUseCase(repo),
      WatchReferredFriendsUseCase(repo),
      GetReferralClaimUseCase(repo),
      ClaimReferralUseCase(repo),
    );

void main() {
  test('código derivado do uid e conferências', () {
    expect(ReferralCode.of('aB3dEf9hIjk'), 'AB3DEF9H');
    expect(ReferralCode.of('aB3dEf9hIjk', length: 10), 'AB3DEF9HIJ');
    expect(ReferralCode.normalize(' ab3d ef9h '), 'AB3DEF9H');
    expect(ReferralCode.isValid('AB3DEF9H'), isTrue);
    expect(ReferralCode.isValid('AB3'), isFalse);
    expect(ReferralCode.isOwn('aB3dEf9hIjk', 'AB3DEF9H'), isTrue);
    final now = DateTime(2026, 11, 1);
    expect(ReferralCode.isNewAccount(DateTime(2026, 10, 28), now), isTrue);
    expect(ReferralCode.isNewAccount(DateTime(2026, 10, 20), now), isFalse);
    expect(ReferralCode.isNewAccount(null, now), isFalse);
  });

  test('link de convite vai e volta', () {
    expect(inviteLink('AB3DEF9H'), 'https://arenasoccerflutter.web.app/convite/AB3DEF9H');
    expect(parseDeepLink(Uri.parse(inviteLink('AB3DEF9H'))), const InviteLinkTarget('AB3DEF9H'));
    expect(parseDeepLink(Uri.parse('arenafootball://convite/ab3def9h')), const InviteLinkTarget('AB3DEF9H'));
    expect(parseDeepLink(Uri.parse('https://arenasoccerflutter.web.app/convite/x')), isNull);
  });

  test('cubit: carrega o código e grava o "Fui indicado" só em conta nova', () async {
    final repo = _Repo(createdAt: DateTime.now().subtract(const Duration(days: 1)));
    final cubit = _cubit(repo);
    await cubit.load('meuUid1234');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.code, 'MEUUID12');
    expect(cubit.state.referral.extraPacks, 1);
    expect(cubit.state.friends.single.name, 'Ana');
    expect(cubit.state.canClaim, isTrue);

    await cubit.claim('meuuid12');
    expect(cubit.state, isA<ClaimErrorReferralState>());
    expect((cubit.state as ClaimErrorReferralState).error, ClaimReferralError.own);

    await cubit.claim(' amig0abc ');
    expect(cubit.state, isA<ClaimedReferralState>());
    expect(repo.claims, ['AMIG0ABC']);
    expect(cubit.state.canClaim, isFalse);
    await cubit.close();

    final old = _cubit(_Repo(createdAt: DateTime.now().subtract(const Duration(days: 30))));
    await old.load('outroUid99');
    expect(old.state.canClaim, isFalse);
    await old.claim('AMIG0ABC');
    expect((old.state as ClaimErrorReferralState).error, ClaimReferralError.oldAccount);
    await old.close();
  });

  test('config: sem o doc = desligada; admin liga', () async {
    expect(ReferralConfigDTO.fromMap(null).enabled, isFalse);
    expect(ReferralConfigDTO.fromMap(const {'ativo': true}).enabled, isTrue);
    final repo = _Repo(enabled: false);
    final config = ReferralConfigCubit(WatchReferralConfigUseCase(repo), SetReferralEnabledUseCase(repo))..start();
    await Future<void>.delayed(Duration.zero);
    expect(config.state.enabled, isFalse);
    await config.setEnabled(true);
    expect(config.state.enabled, isTrue);
    expect(repo.toggles, [true]);
    await config.close();
  });

  testWidgets('tela: código, números e o "Fui indicado" com o código do link', (tester) async {
    await _pumpPage(tester, _Repo(createdAt: DateTime.now()));
    expect(find.text('MEUUID12'), findsOneWidget);
    expect(find.text('Amigos indicados'), findsOneWidget);
    expect(find.text('Fui indicado'), findsOneWidget);
    expect(find.text('AMIG0ABC'), findsOneWidget);
    // A lista dos indicados fica no fim da tela.
    await tester.scrollUntilVisible(find.text('Ana'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Ana'), findsOneWidget);
  });

  testWidgets('tela: desligada pelo admin mostra o aviso', (tester) async {
    await _pumpPage(tester, _Repo(createdAt: DateTime.now(), enabled: false));
    expect(find.text('As indicações estão pausadas no momento.'), findsOneWidget);
    expect(find.text('MEUUID12'), findsNothing);
  });
}
