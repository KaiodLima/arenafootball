import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';

void main() {
  late Directory dir;
  late Box<String> box;
  late CacheStore store;
  var now = DateTime(2026, 1, 1, 12);
  var boxes = 0;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('arena_cache_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  setUp(() async {
    now = DateTime(2026, 1, 1, 12);
    box = await Hive.openBox<String>('cache_test_${boxes++}');
    store = CacheStore(box, now: () => now);
  });

  tearDown(() => box.deleteFromDisk());

  List<int> decodeInts(Object? json) => (json as List).map((e) => e as int).toList();

  test('salva e lê com a data de gravação', () async {
    expect((await store.save('k', [1, 2, 3])).isRight, isTrue);
    final cached = (await store.read('k', decodeInts)).right;
    expect(cached?.data, [1, 2, 3]);
    expect(cached?.savedAt, now);
  });

  test('sem cache = Right(null)', () async {
    final response = await store.read('nada', decodeInts);
    expect(response.isRight, isTrue);
    expect(response.right, isNull);
  });

  test('entrada corrompida = Right(null) e a chave é apagada', () async {
    await box.put('k', '{não é json');
    expect((await store.read('k', decodeInts)).right, isNull);
    expect(box.containsKey('k'), isFalse);

    // JSON válido mas no formato errado (decode falha) também.
    await store.save('k2', {'a': 1});
    expect((await store.read('k2', decodeInts)).right, isNull);
    expect(box.containsKey('k2'), isFalse);
  });

  test('delete, deleteWhere e clear', () async {
    await store.save('teams_2024_all_cache', []);
    await store.save('team_2024_1_cache', {});
    await store.save('regions_cache', []);
    await store.save('user_u1_cache', {});

    await store.delete('user_u1_cache');
    expect(box.containsKey('user_u1_cache'), isFalse);

    await store.deleteWhere(CacheKeys.isTeamKey);
    expect(box.keys, ['regions_cache']);

    await store.clear();
    expect(box.isEmpty, isTrue);
  });

  test('validade: fresco dentro do ttl, vencido depois e com data futura', () {
    final value = CachedValue(1, DateTime(2026, 1, 1, 12));
    const ttl = Duration(minutes: 30);
    expect(value.isFresh(ttl, now: DateTime(2026, 1, 1, 12, 29)), isTrue);
    expect(value.isFresh(ttl, now: DateTime(2026, 1, 1, 12, 30)), isFalse);
    expect(value.isFresh(ttl, now: DateTime(2026, 1, 1, 11)), isFalse);
    expect(value.isFresh(Duration.zero, now: DateTime(2026, 1, 1, 12)), isFalse);
  });

  test('versão do cache diferente: limpa e grava a nova; igual: mantém', () async {
    SharedPreferences.setMockInitialValues({CacheStore.schemaKey: 'cache-schema-v0'});
    final prefs = await SharedPreferences.getInstance();
    await store.save('k', 1);
    await store.checkSchema(prefs);
    expect(box.isEmpty, isTrue);
    expect(prefs.getString(CacheStore.schemaKey), CacheStore.schemaVersion);

    await store.save('k', 1);
    await store.checkSchema(prefs);
    expect(box.containsKey('k'), isTrue);
  });
}
