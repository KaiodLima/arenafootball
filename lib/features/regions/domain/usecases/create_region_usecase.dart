import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

enum RegionNameError { tooShort, duplicate }

/// Nome de região recusado (a tela mostra a mensagem no campo).
class RegionNameFailure implements Failure {
  final RegionNameError error;

  RegionNameFailure(this.error);
}

/// Cria uma região (doc em `competicao`): nome com pelo menos 3 letras e sem
/// repetir uma existente (ignora acento e caixa). Devolve o nome gravado.
class CreateRegionUseCase {
  static const int minLength = 3;

  final IRegionsRepository _repository;

  CreateRegionUseCase(this._repository);

  /// Validação pura (usada também pela tela antes de enviar).
  static RegionNameError? validate(String name, List<String> existing) {
    final value = name.trim();
    if (value.length < minLength) return RegionNameError.tooShort;
    final key = foldForSearch(value);
    if (existing.any((region) => foldForSearch(region.trim()) == key)) return RegionNameError.duplicate;
    return null;
  }

  Future<Either<Failure, String>> call(String name) async {
    final value = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    final existing = await _repository.getRegions();
    if (existing.isLeft) return Left(existing.left);
    final error = validate(value, existing.right);
    if (error != null) return Left(RegionNameFailure(error));
    final response = await _repository.createRegion(value);
    return response.map((_) => value);
  }
}
