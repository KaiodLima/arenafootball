import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';

/// Valor lido do cache local e quando foi gravado.
class CachedValue<T> {
  final T data;
  final DateTime savedAt;

  const CachedValue(this.data, this.savedAt);

  /// Ainda dentro da validade [ttl]? Relógio voltando no tempo (data futura)
  /// conta como vencido.
  bool isFresh(Duration ttl, {DateTime? now}) {
    final age = (now ?? DateTime.now()).difference(savedAt);
    return !age.isNegative && age < ttl;
  }
}

/// Cache local (Hive), no padrão do Relove: uma caixa só, um JSON por chave,
/// gravado como `{"savedAt": <ms>, "data": <json>}`. Ler nunca falha (sem
/// cache ou entrada corrompida = `Right(null)`), para não impedir a busca
/// remota; gravar devolve `Left` no erro.
class CacheStore {
  static const String boxName = 'arenaCache';

  /// Versão do formato do cache. Mudou (DTO com campo novo/renomeado):
  /// troque aqui e o cache antigo é apagado na abertura do app.
  static const String schemaVersion = 'cache-schema-v1';

  /// Chave (SharedPreferences) com a versão do cache gravada.
  static const String schemaKey = 'cache_schema';

  static const String _logName = 'CacheStore';

  final Box<String> _box;
  final DateTime Function() _now;

  CacheStore(this._box, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// Abre a caixa (já aberta = a mesma). Caixa corrompida no disco: apaga e
  /// abre de novo vazia (é só cache).
  static Future<Box<String>> openBox({String name = boxName}) async {
    try {
      return await Hive.openBox<String>(name);
    } catch (e) {
      AppLogger.e('openBox $name', name: _logName, error: e);
      await Hive.deleteBoxFromDisk(name);
      return Hive.openBox<String>(name);
    }
  }

  Future<Either<Failure, CachedValue<T>?>> read<T>(String key, T Function(Object? json) decode) async {
    try {
      final raw = _box.get(key);
      if (raw == null) return Right<Failure, CachedValue<T>?>(null);
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.fromMillisecondsSinceEpoch((entry['savedAt'] as num).toInt());
      return Right(CachedValue<T>(decode(entry['data']), savedAt));
    } catch (e) {
      // Entrada corrompida (ou de outro formato): descarta e segue sem cache.
      AppLogger.e('read $key', name: _logName, error: e);
      await _deleteQuietly(key);
      return Right<Failure, CachedValue<T>?>(null);
    }
  }

  Future<Either<Failure, void>> save(String key, Object? json) async {
    try {
      await _box.put(key, jsonEncode({'savedAt': _now().millisecondsSinceEpoch, 'data': json}));
      return const Right(null);
    } catch (e) {
      AppLogger.e('save $key', name: _logName, error: e);
      return Left(ErrorWithMessage('Não foi possível salvar o cache.'));
    }
  }

  Future<Either<Failure, void>> delete(String key) async {
    try {
      await _box.delete(key);
      return const Right(null);
    } catch (e) {
      AppLogger.e('delete $key', name: _logName, error: e);
      return Left(ErrorWithMessage('Não foi possível apagar o cache.'));
    }
  }

  /// Apaga as chaves que passam em [test] (ex.: todas as de times).
  Future<void> deleteWhere(bool Function(String key) test) async {
    try {
      final keys = _box.keys.map((key) => key.toString()).where(test).toList();
      if (keys.isNotEmpty) await _box.deleteAll(keys);
    } catch (e) {
      AppLogger.e('deleteWhere', name: _logName, error: e);
    }
  }

  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      AppLogger.e('clear', name: _logName, error: e);
    }
  }

  /// Versão do cache diferente da gravada: apaga tudo e grava a atual.
  Future<void> checkSchema(SharedPreferences prefs, {String version = schemaVersion}) async {
    if (prefs.getString(schemaKey) == version) return;
    AppLogger.d('schema ${prefs.getString(schemaKey)} -> $version: limpando', name: _logName);
    await clear();
    await prefs.setString(schemaKey, version);
  }

  Future<void> _deleteQuietly(String key) async {
    try {
      await _box.delete(key);
    } catch (_) {
      // Já está sendo descartada; nada a fazer.
    }
  }
}

/// Inicializa o Hive e abre a caixa do cache (antes do `di.init()`). Confere
/// a versão do cache e limpa se mudou. Nunca derruba a abertura do app.
Future<void> initCache() async {
  try {
    await Hive.initFlutter();
    final box = await CacheStore.openBox();
    await CacheStore(box).checkSchema(await SharedPreferences.getInstance());
  } catch (e) {
    AppLogger.e('initCache', name: 'CacheStore', error: e);
  }
}
