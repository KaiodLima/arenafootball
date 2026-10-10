import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';

extension EitherStream<S> on Stream<S> {
  /// Converte um stream do Firestore em `Stream<Either<Failure, T>>`:
  /// cada evento vira `Right(map(evento))` e cada erro vira `Left`, sem
  /// encerrar o stream. Mantém a regra "nunca throw" também em streams.
  Stream<Either<Failure, T>> toEither<T>(
    T Function(S data) map, {
    required String fallbackMessage,
    required String logName,
  }) {
    return transform(
      StreamTransformer<S, Either<Failure, T>>.fromHandlers(
        handleData: (data, sink) {
          try {
            sink.add(Right(map(data)));
          } catch (e, st) {
            AppLogger.e('parse error', name: logName, error: e, stackTrace: st);
            sink.add(Left(ErrorWithMessage(fallbackMessage)));
          }
        },
        handleError: (Object e, StackTrace st, sink) {
          AppLogger.e('stream error', name: logName, error: e, stackTrace: st);
          sink.add(Left(mapFirebaseError(e, fallbackMessage: fallbackMessage)));
        },
      ),
    );
  }
}
