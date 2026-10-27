import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/services/push_target.dart';

void main() {
  test('lê o data do FCM: aba e tela', () {
    final target = PushTarget.fromData({'aba': 'tabelas', 'tela': 'votacao', 'id': 'm1', 'temporada': '2026'});
    expect(target, const PushTarget(tab: 'tabelas', screen: 'votacao', id: 'm1', season: '2026'));
    expect(target.hasScreen, isTrue);
  });

  test('payload da notificação local: ida e volta', () {
    const target = PushTarget(tab: 'home', screen: 'partida', id: 'm1', season: '2026');
    expect(PushTarget.fromPayload(target.toPayload()), target);
  });

  test('payload antigo (só a aba) e vazio', () {
    expect(PushTarget.fromPayload('tabelas'), const PushTarget(tab: 'tabelas'));
    expect(PushTarget.fromPayload(''), isNull);
    expect(PushTarget.fromData(const {}).isEmpty, isTrue);
  });

  test('tela sem id: só a aba', () {
    const target = PushTarget(tab: 'home', screen: 'partida');
    expect(target.hasScreen, isFalse);
    expect(target.isEmpty, isFalse);
  });
}
