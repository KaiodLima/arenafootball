import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/regions/domain/region_usage.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';
import 'package:arena_soccer/features/regions/domain/usecases/create_region_usecase.dart';

/// A região ainda tem conteúdo: não pode ser excluída.
class RegionInUseFailure implements Failure {
  final RegionUsage usage;

  RegionInUseFailure(this.usage);
}

/// É a única região: o app ficaria sem nenhuma.
class LastRegionFailure implements Failure {}

/// Renomeia a região: só o `nome` em `competicao` (o conteúdo aponta para o
/// id). Mesmas regras do cadastro, ignorando a própria região.
class RenameRegionUseCase {
  final IRegionsRepository _repository;

  RenameRegionUseCase(this._repository);

  Future<Either<Failure, String>> call({required String current, required String name}) async {
    final value = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (value == current) return Right(value);
    final existing = await _repository.getRegions();
    if (existing.isLeft) return Left(existing.left);
    final others = existing.right.where((region) => region != current).toList();
    final error = CreateRegionUseCase.validate(value, others);
    if (error != null) return Left(RegionNameFailure(error));
    final id = RegionRegistry.idOf(current);
    if (id.isEmpty) return Left(ErrorWithMessage('Região não encontrada.'));
    final response = await _repository.renameRegion(id: id, name: value);
    return response.map((_) => value);
  }
}

/// Exclui a região só se estiver vazia (sem times, partidas, notícias,
/// campeonatos e grupos em nenhuma temporada) e se não for a última.
class DeleteRegionUseCase {
  final IRegionsRepository _repository;

  DeleteRegionUseCase(this._repository);

  /// Conteúdo da região (para a tela decidir entre confirmar ou bloquear).
  Future<Either<Failure, RegionUsage>> usage(String name) =>
      _repository.regionUsage(id: RegionRegistry.idOf(name), name: name);

  Future<Either<Failure, void>> call(String name) async {
    final regions = await _repository.getRegions();
    if (regions.isLeft) return Left(regions.left);
    if (regions.right.length <= 1) return Left(LastRegionFailure());
    final id = RegionRegistry.idOf(name);
    if (id.isEmpty) return Left(ErrorWithMessage('Região não encontrada.'));
    final current = await _repository.regionUsage(id: id, name: name);
    if (current.isLeft) return Left(current.left);
    if (!current.right.isEmpty) return Left(RegionInUseFailure(current.right));
    return _repository.deleteRegion(id);
  }
}

/// Manutenção "Vincular regiões por id" (ver `RegionsDataSource.linkRegions`).
/// Recarrega as regiões antes, para casar os nomes com a lista atual.
class LinkRegionsByIdUseCase {
  final IRegionsRepository _repository;

  LinkRegionsByIdUseCase(this._repository);

  Future<Either<Failure, RegionLinkReport>> call() async {
    final regions = await _repository.getRegions();
    if (regions.isLeft) return Left(regions.left);
    return _repository.linkRegions();
  }
}
