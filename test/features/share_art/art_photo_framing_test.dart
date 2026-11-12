import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/share_art/domain/art_photo_framing.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_controls.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';

// PNG 1x1 transparente.
final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  test('enquadramento: padrão no alto, limites de −1 a 1 e zoom de 1 a 3', () {
    const f = ArtPhotoFraming.centered;
    expect((f.x, f.y, f.zoom), (0.0, -1.0, 1.0));
    expect(f.isCentered, isTrue);
    final moved = f.moved(0.4, 0.5);
    expect((moved.x, moved.y), (0.4, -0.5));
    expect(moved.isCentered, isFalse);
    expect(f.moved(5, -5).x, 1);
    expect(f.moved(-5, -5).y, -1);
    expect(f.zoomed(10).zoom, ArtPhotoFraming.maxZoom);
    expect(f.zoomed(0.1).zoom, ArtPhotoFraming.minZoom);
    expect(f.moved(0.3, 0.3).zoomed(2).zoom, 2);
  });

  testWidgets('arrastar na prévia move a foto (ela acompanha o dedo)', (tester) async {
    final moves = <(double, double)>[];
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: ArtFramingGesture(
          enabled: true,
          onMove: (dx, dy) => moves.add((dx, dy)),
          onZoom: (_) {},
          child: const SizedBox(key: Key('art'), width: 200, height: 250, child: ColoredBox(color: Colors.red)),
        ),
      ),
    ));
    await tester.drag(find.byKey(const Key('art')), const Offset(60, 0));
    final dx = moves.fold(0.0, (sum, m) => sum + m.$1);
    // Para a direita: mostra mais do lado esquerdo (x diminui).
    expect(dx, lessThan(0));
  });

  testWidgets('desligado (sem foto), o arrasto não faz nada', (tester) async {
    var called = false;
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: ArtFramingGesture(
          enabled: false,
          onMove: (_, __) => called = true,
          onZoom: (_) {},
          child: const SizedBox(key: Key('art'), width: 200, height: 250, child: ColoredBox(color: Colors.red)),
        ),
      ),
    ));
    await tester.drag(find.byKey(const Key('art')), const Offset(60, 0));
    expect(called, isFalse);
  });

  testWidgets('a foto usa o enquadramento do escopo (ponto à vista e zoom)', (tester) async {
    final previous = ArtPlayerPhoto.providerFor;
    ArtPlayerPhoto.providerFor = (_) => MemoryImage(_png);
    addTearDown(() => ArtPlayerPhoto.providerFor = previous);
    await tester.pumpWidget(const MaterialApp(
      home: Center(
        child: SizedBox(
          width: 100,
          height: 140,
          child: ArtPhotoFramingScope(
            framing: ArtPhotoFraming(x: 0.5, y: 0.2, zoom: 2),
            child: ArtPlayerPhoto(url: 'memoria://foto', initials: 'RN', color: Colors.blue),
          ),
        ),
      ),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.alignment, const Alignment(0.5, 0.2));
    final scale = tester.widget<Transform>(
      find.descendant(of: find.byType(ArtPlayerPhoto), matching: find.byType(Transform)).first,
    );
    expect(scale.transform.getMaxScaleOnAxis(), closeTo(2, 0.001));
  });
}
