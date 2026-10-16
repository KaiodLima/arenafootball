import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';

/// Cache e remoto em memória, contando as buscas remotas.
class _Harness {
  CachedValue<List<String>>? cached;
  Either<Failure, List<String>> remote = const Right(['a', 'b']);
  int remoteCalls = 0;
  List<String>? saved;
  final DateTime now = DateTime(2026, 1, 1, 12);

  Stream<Either<Failure, List<String>>> run({bool force = false}) => cacheFirst<List<String>>(
        readCache: () async => Right(cached),
        fetchRemote: () async {
          remoteCalls++;
          return remote;
        },
        saveCache: (data) async {
          saved = data;
          return const Right(null);
        },
        ttl: const Duration(minutes: 30),
        force: force,
        now: () => now,
      );

  void cache(List<String> data, {required Duration age}) => cached = CachedValue(data, now.subtract(age));
}

void main() {
  late _Harness h;

  setUp(() => h = _Harness());

  test('cache dentro da validade: emite o cache e não busca o remoto', () async {
    h.cache(['x'], age: const Duration(minutes: 5));
    final values = await h.run().toList();
    expect(values.map((r) => r.right), [
      ['x'],
    ]);
    expect(h.remoteCalls, 0);
    expect(h.saved, isNull);
  });

  test('force ignora a validade', () async {
    h.cache(['x'], age: const Duration(minutes: 5));
    final values = await h.run(force: true).toList();
    expect(values.map((r) => r.right), [
      ['x'],
      ['a', 'b'],
    ]);
    expect(h.remoteCalls, 1);
  });

  test('cache vencido: emite o cache, depois o remoto e salva', () async {
    h.cache(['x'], age: const Duration(hours: 1));
    final values = await h.run().toList();
    expect(values.map((r) => r.right), [
      ['x'],
      ['a', 'b'],
    ]);
    expect(h.saved, ['a', 'b']);
  });

  test('remoto igual ao cache: não emite de novo, mas renova o cache', () async {
    h.cache(['a', 'b'], age: const Duration(hours: 1));
    final values = await h.run().toList();
    expect(values, hasLength(1));
    expect(h.remoteCalls, 1);
    expect(h.saved, ['a', 'b']);
  });

  test('remoto falha com cache: mantém o cache, sem erro', () async {
    h.cache(['x'], age: const Duration(hours: 1));
    h.remote = Left(ErrorWithMessage('offline'));
    final values = await h.run().toList();
    expect(values.map((r) => r.right), [
      ['x'],
    ]);
    expect(h.saved, isNull);
  });

  test('sem cache: busca o remoto; falha vira erro', () async {
    expect((await h.run().toList()).single.right, ['a', 'b']);
    expect(h.saved, ['a', 'b']);

    h = _Harness()..remote = Left(ErrorWithMessage('offline'));
    final values = await h.run().toList();
    expect(values.single.isLeft, isTrue);
    expect(values.single.left.toString(), 'offline');
  });

  test('igualdade profunda de listas e mapas', () {
    final a = [
      1,
      <String, Object>{
        'a': [2]
      }
    ];
    final b = [
      1,
      <String, Object>{
        'a': [2]
      }
    ];
    expect(cacheEquals(a, b), isTrue);
    expect(cacheEquals([1, 2], [1, 3]), isFalse);
    expect(cacheEquals({'a': 1}, {'b': 1}), isFalse);
    expect(cacheEquals(null, null), isTrue);
  });
}
