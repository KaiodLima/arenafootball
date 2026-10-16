import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';

/// Fluxo "cache primeiro" com validade:
/// - com cache: emite o cache na hora; dentro do [ttl] (e sem [force]) para
///   aí, sem ler o Firestore;
/// - cache vencido, ausente ou [force]: busca o remoto. Sucesso grava o cache
///   (renova a validade) e só emite se mudou em relação ao cache ([equals],
///   padrão: igualdade profunda de listas/mapas e `==` dos DTOs);
/// - falha no remoto com cache em tela: mantém (só loga); sem cache, emite o
///   `Left`.
///
/// Ler o cache nunca falha (`Left` conta como sem cache) e falha ao gravar só
/// é logada.
Stream<Either<Failure, T>> cacheFirst<T>({
  required Future<Either<Failure, CachedValue<T>?>> Function() readCache,
  required Future<Either<Failure, T>> Function() fetchRemote,
  required Future<Either<Failure, void>> Function(T data) saveCache,
  required Duration ttl,
  bool force = false,
  bool Function(T previous, T next)? equals,
  DateTime Function()? now,
  String logName = 'cacheFirst',
}) async* {
  final cachedResponse = await readCache();
  final cached = cachedResponse.isRight ? cachedResponse.right : null;
  if (cached != null) {
    yield Right(cached.data);
    if (!force && cached.isFresh(ttl, now: now?.call())) return;
  }

  final remote = await fetchRemote();
  if (remote.isLeft) {
    if (cached == null) {
      yield Left(remote.left);
    } else {
      AppLogger.d('remoto falhou, mantendo o cache: ${remote.left}', name: logName);
    }
    return;
  }

  final data = remote.right;
  final saved = await saveCache(data);
  if (saved.isLeft) AppLogger.e('falha ao salvar o cache', name: logName, error: saved.left);
  if (cached != null && (equals ?? cacheEquals)(cached.data, data)) return;
  yield Right(data);
}

/// Igualdade profunda para comparar o cache com o remoto: listas e mapas
/// elemento a elemento, o resto pelo `==` (DTOs são Equatable).
bool cacheEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!cacheEquals(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !cacheEquals(a[key], b[key])) return false;
    }
    return true;
  }
  return a == b;
}
