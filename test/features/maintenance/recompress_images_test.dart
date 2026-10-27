import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/maintenance/data/dtos/recompress_status_dto.dart';
import 'package:arena_soccer/features/maintenance/domain/usecases/recompress_images_usecase.dart';
import 'package:arena_soccer/features/maintenance/presentation/bloc/recompress_images_cubit.dart';

class _UseCase implements RecompressImagesUseCase {
  final controller = StreamController<Either<Failure, RecompressStatusDTO>>();
  var requests = 0;

  @override
  Stream<Either<Failure, RecompressStatusDTO>> watch() => controller.stream;

  @override
  Future<Either<Failure, void>> request() async {
    requests++;
    return const Right(null);
  }
}

void main() {
  test('progresso do doc: fase, números e bytes economizados', () {
    final status = RecompressStatusDTO.fromMap(const {
      'status': 'rodando',
      'pasta': 'times',
      'vistos': 40,
      'regravados': 12,
      'bytesAntes': 3000000,
      'bytesDepois': 1000000,
    });
    expect(status.phase, RecompressPhase.running);
    expect(status.isRunning, isTrue);
    expect(status.savedBytes, 2000000);
    expect(RecompressStatusDTO.fromMap(const {}).phase, RecompressPhase.idle);
  });

  test('não pede de novo enquanto roda', () async {
    final useCase = _UseCase();
    final cubit = RecompressImagesCubit(useCase)..watch();
    useCase.controller.add(const Right(RecompressStatusDTO(phase: RecompressPhase.running)));
    await Future<void>.delayed(Duration.zero);
    await cubit.request();
    expect(useCase.requests, 0);

    useCase.controller.add(const Right(RecompressStatusDTO(phase: RecompressPhase.done)));
    await Future<void>.delayed(Duration.zero);
    await cubit.request();
    expect(useCase.requests, 1);
    await cubit.close();
  });
}
