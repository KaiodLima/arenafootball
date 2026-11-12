import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/home/presentation/widgets/home_drawer.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Prévia em PNG fora do CI: DRAWER_PREVIEW=1 flutter test test/features/home/home_drawer_test.dart
// → build/drawer_previews/<caso>.png

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

const _fan = UserDTO(id: 'u1', name: 'Kaio Lima', email: 'k@x.com', favoriteTeam: 'Lava Jato');
const _admin = UserDTO(id: 'u2', name: 'Admin Arena', email: 'a@x.com', favoriteTeam: 'Volta', isAdmin: true);

HomeDrawer _drawer({
  UserDTO? user,
  int? xp,
  bool referrals = true,
  String? playerTeam,
  String? ownedTeam,
  int pending = 0,
  HomeDrawerTourKeys? keys,
  String? playerPhoto,
}) =>
    HomeDrawer(
      user: user,
      fanXp: xp,
      referralsEnabled: referrals,
      playerTeam: playerTeam,
      playerId: playerTeam == null ? null : 'p1',
      playerPhotoUrl: playerPhoto,
      ownedTeam: ownedTeam,
      pendingPlayerRequests: pending,
      pendingTeamRequests: pending,
      onChooseTeam: () {},
      onLogout: () {},
      tourKeys: keys,
    );

void main() {
  final preview = Platform.environment['DRAWER_PREVIEW'] == '1';

  Future<void> pump(WidgetTester tester, HomeDrawer drawer, {GlobalKey? key}) async {
    tester.view.physicalSize = const Size(392, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        backgroundColor: const Color(0xFF555555),
        body: Align(alignment: Alignment.topLeft, child: RepaintBoundary(key: key, child: drawer)),
      ),
    ));
    await tester.pump();
  }

  testWidgets('jogador com foto: o cabeçalho mostra a foto do atleta; sem foto, o escudo', (tester) async {
    await pump(tester, _drawer(user: _fan, playerTeam: 'Lava Jato', playerPhoto: 'https://img/atleta.jpg'));
    final photo = find.byKey(const ValueKey('drawer-player-photo'));
    expect(photo, findsOneWidget);
    final avatar = tester.widget<CircleAvatar>(find.descendant(of: photo, matching: find.byType(CircleAvatar)));
    expect((avatar.backgroundImage as dynamic).url, 'https://img/atleta.jpg');
    // Atleta sem foto, ou conta que não é jogador: o escudo de sempre.
    await pump(tester, _drawer(user: _fan, playerTeam: 'Lava Jato', playerPhoto: ''));
    expect(find.byKey(const ValueKey('drawer-player-photo')), findsNothing);
    await pump(tester, _drawer(user: _fan, playerPhoto: 'https://img/atleta.jpg'));
    expect(find.byKey(const ValueKey('drawer-player-photo')), findsNothing);
    tester.takeException();
  });

  testWidgets('convidado: atalhos públicos, sem "Em campo", admin nem rodapé', (tester) async {
    await pump(tester, _drawer());
    expect(find.text('BOLÃO'), findsOneWidget);
    expect(find.text('RANKING DE TORCIDAS'), findsOneWidget);
    expect(find.text('RESULTADOS PELO MUNDO'), findsOneWidget);
    expect(find.text('MINHAS CONQUISTAS'), findsNothing);
    expect(find.text('Sou jogador'), findsNothing);
    expect(find.text('Sair'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('torcedor: nível, atalhos da conta e indicação pelo liga/desliga', (tester) async {
    await pump(tester, _drawer(user: _fan, xp: 140));
    expect(find.textContaining('140 XP'), findsOneWidget);
    expect(find.text('MINHAS CONQUISTAS'), findsOneWidget);
    expect(find.text('INDIQUE AMIGOS'), findsOneWidget);
    expect(find.text('Peça para jogar num time'), findsOneWidget);
    await pump(tester, _drawer(user: _fan, referrals: false));
    expect(find.text('INDIQUE AMIGOS'), findsNothing);
    expect(find.textContaining('XP'), findsNothing, reason: 'sem XP carregado, sem a barra');
  });

  testWidgets('admin: bloco com os contadores; âncoras do tour no lugar', (tester) async {
    final keys = HomeDrawerTourKeys();
    await pump(tester, _drawer(user: _admin, xp: 900, pending: 3, playerTeam: 'Volta', ownedTeam: 'Volta', keys: keys));
    expect(find.text('ADMINISTRAÇÃO'), findsOneWidget);
    expect(find.text('3'), findsNWidgets(2));
    for (final key in [keys.header, keys.predictions, keys.achievements, keys.player]) {
      expect(key.currentContext, isNotNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('prévias do menu', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('BarlowCondensed', [
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-SemiBold.ttf',
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-Bold.ttf',
      ]);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/drawer_previews').createSync(recursive: true);
    final cases = {
      'convidado': _drawer(),
      'torcedor': _drawer(user: _fan, xp: 140),
      'admin_jogador_dono': _drawer(user: _admin, xp: 900, pending: 3, playerTeam: 'Volta', ownedTeam: 'Volta'),
    };
    for (final entry in cases.entries) {
      final key = GlobalKey();
      await pump(tester, entry.value, key: key);
      expect(tester.takeException(), isNull, reason: entry.key);
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.5);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('build/drawer_previews/${entry.key}.png').writeAsBytesSync(png!);
    }
  }, skip: !preview);
}
