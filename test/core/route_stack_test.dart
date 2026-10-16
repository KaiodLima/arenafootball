import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/navigation/route_stack.dart';

/// Tela de teste: mostra o nome da rota e os botões que abrem a outra.
class _Page extends StatelessWidget {
  final RouteStackObserver observer;

  const _Page(this.observer);

  @override
  Widget build(BuildContext context) {
    final settings = ModalRoute.of(context)!.settings;
    final id = (settings.arguments as Map?)?['id'];
    Future<void> open(String name, String target) => openOrReturn(
          context,
          name,
          arguments: {'id': target},
          same: (args) => args is Map && args['id'] == target,
          observer: observer,
        );
    return Scaffold(
      body: Column(children: [
        Text('${settings.name}:$id'),
        TextButton(onPressed: () => open('/time', 'T1'), child: const Text('time')),
        TextButton(onPressed: () => open('/atleta', 'A1'), child: const Text('atleta A1')),
        TextButton(onPressed: () => open('/atleta', 'A2'), child: const Text('atleta A2')),
      ]),
    );
  }
}

void main() {
  late RouteStackObserver observer;

  Future<void> pumpApp(WidgetTester tester) async {
    observer = RouteStackObserver();
    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [observer],
      onGenerateRoute: (settings) => MaterialPageRoute(settings: settings, builder: (_) => _Page(observer)),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  List<String?> names() =>
      observer.routes.map((r) => '${r.settings.name}:${(r.settings.arguments as Map?)?['id']}').toList();

  testWidgets('Time → Atleta → time volta ao Time em vez de empilhar', (tester) async {
    await pumpApp(tester);
    await tap(tester, 'time');
    await tap(tester, 'atleta A1');
    expect(names(), ['/:null', '/time:T1', '/atleta:A1']);

    await tap(tester, 'time');
    expect(names(), ['/:null', '/time:T1']);

    // Ida e volta repetida não cresce a pilha.
    for (var i = 0; i < 3; i++) {
      await tap(tester, 'atleta A1');
      await tap(tester, 'time');
    }
    expect(names(), ['/:null', '/time:T1']);
  });

  testWidgets('outro atleta abre normalmente; o mesmo atleta já aberto não duplica', (tester) async {
    await pumpApp(tester);
    await tap(tester, 'time');
    await tap(tester, 'atleta A1');
    await tap(tester, 'atleta A1');
    expect(names(), ['/:null', '/time:T1', '/atleta:A1']);

    await tap(tester, 'atleta A2');
    expect(names(), ['/:null', '/time:T1', '/atleta:A1', '/atleta:A2']);
    // Do A2, voltar ao A1 (já na pilha) tira o A2.
    await tap(tester, 'atleta A1');
    expect(names(), ['/:null', '/time:T1', '/atleta:A1']);
  });
}
