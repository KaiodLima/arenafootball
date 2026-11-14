import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/profile_name.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_user_name_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_user_photo_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/profile_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/profile_state.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/auth/presentation/page/profile_page.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_cache_first_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Prévia em PNG fora do CI: PROFILE_PREVIEW=1 flutter test test/features/auth/profile_page_test.dart
// → build/profile_previews/<caso>.png

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

const _user = UserDTO(id: 'u1', name: 'Kaio', email: 'k@x.com', favoriteTeam: 'Lava Jato');

class _Name implements UpdateUserNameUseCase {
  final saved = <(String, String)>[];

  @override
  Future<Either<Failure, void>> call({required String userId, required String name}) async {
    saved.add((userId, name));
    return const Right(null);
  }
}

class _Photo implements UpdateUserPhotoUseCase {
  @override
  Future<Either<Failure, String>> call({required String userId, required File photo}) async =>
      const Right('https://img/nova.jpg');
}

class _Teams implements GetTeamByNameCacheFirstUseCase {
  @override
  Stream<Either<Failure, TeamDTO?>> call(String name, {String id = '', bool force = false}) =>
      Stream.value(Right(TeamDTO(id: 't1', name: name)));
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session(UserDTO user) : super(AuthenticatedSessionState(user: user));

  @override
  Future<void> updateUser(UserDTO user) async => emit(AuthenticatedSessionState(user: user));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('ProfileName: de 3 a 40 caracteres, sem contar os espaços das pontas', () {
    expect(ProfileName.validate('  Jo '), ProfileNameError.tooShort);
    expect(ProfileName.validate('Ana'), isNull);
    expect(ProfileName.validate('A' * 41), ProfileNameError.tooLong);
  });

  test('cubit: nome salvo sem espaços e foto nova avisam a tela', () async {
    final name = _Name();
    final cubit = ProfileCubit(name, _Photo());
    final states = <ProfileState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.saveName(userId: 'u1', name: '  Kaio Lima ');
    await cubit.changePhoto(userId: 'u1', photo: File('x.jpg'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(name.saved, [('u1', 'Kaio Lima')]);
    expect(states.whereType<NameSavedProfileState>().single.name, 'Kaio Lima');
    expect(states.whereType<PhotoSavedProfileState>().single.photoUrl, 'https://img/nova.jpg');
    await cubit.close();
  });

  Future<(_Name, _Session)> pump(WidgetTester tester, {UserDTO user = _user, Key? boundary}) async {
    final name = _Name();
    final session = _Session(user);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>.value(value: session),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit(name, _Photo(), _Teams())),
      ],
      child: RepaintBoundary(
        key: boundary,
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('pt'),
          home: ProfilePage(),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return (name, session);
  }

  testWidgets('editar o nome → Salvar grava e atualiza a sessão', (tester) async {
    final (name, session) = await pump(tester);
    expect(find.text('k@x.com'), findsNWidgets(2), reason: 'no cabeçalho e no campo só leitura');
    expect(find.text('Lava Jato'), findsOneWidget);
    expect(find.text('SALVAR'), findsNothing, reason: 'sem mudança, sem barra');
    await tester.enterText(find.byKey(const ValueKey('profile-name')), 'Kaio Lima');
    await tester.pumpAndSettle();
    await tester.tap(find.text('SALVAR'));
    await tester.pumpAndSettle();
    expect(name.saved, [('u1', 'Kaio Lima')]);
    expect(session.state.user!.name, 'Kaio Lima');
    expect(find.text('Nome atualizado!'), findsOneWidget);
    expect(find.text('SALVAR'), findsNothing);
  });

  testWidgets('nome curto mostra o erro e não grava', (tester) async {
    final (name, _) = await pump(tester);
    await tester.enterText(find.byKey(const ValueKey('profile-name')), 'K');
    await tester.pumpAndSettle();
    expect(find.text('Seu nome de usuário deve conter no mínimo 3 caracteres'), findsOneWidget);
    await tester.tap(find.text('SALVAR'));
    await tester.pumpAndSettle();
    expect(name.saved, isEmpty);
  });

  testWidgets('prévias do perfil', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    tester.view.physicalSize = const Size(392, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Directory('build/profile_previews').createSync(recursive: true);
    final cases = {
      'com_time': _user,
      'sem_time': const UserDTO(id: 'u2', name: 'Ana Beatriz Souza', email: 'ana@x.com'),
    };
    for (final entry in cases.entries) {
      final key = GlobalKey();
      await pump(tester, user: entry.value, boundary: key);
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('build/profile_previews/${entry.key}.png').writeAsBytesSync(png!);
    }
  }, skip: Platform.environment['PROFILE_PREVIEW'] != '1');
}
