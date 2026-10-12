import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/datasources/highlights_datasource.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

class HighlightsRepositoryImpl implements IHighlightsRepository {
  final HighlightsDataSource _dataSource;

  HighlightsRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, List<HighlightDTO>>> watchVisibleHighlights() => _dataSource.watchVisibleHighlights();

  @override
  Future<Either<Failure, List<HighlightDTO>>> getHighlights() => _dataSource.getHighlights();

  @override
  Future<Either<Failure, void>> createHighlight(HighlightDTO highlight) => _dataSource.createHighlight(highlight);

  @override
  Stream<Either<Failure, List<HighlightDTO>>> watchAllHighlights() => _dataSource.watchAllHighlights();

  @override
  Future<Either<Failure, void>> updateHighlight(HighlightDTO highlight, {String? oldTitle}) =>
      _dataSource.updateHighlight(highlight, oldTitle: oldTitle);

  @override
  Future<Either<Failure, void>> deleteHighlight(HighlightDTO highlight) => _dataSource.deleteHighlight(highlight);

  @override
  Future<Either<Failure, void>> reorderHighlights(List<String> ids) => _dataSource.reorderHighlights(ids);

  @override
  Future<Either<Failure, void>> setHighlightVisible({required String id, required bool visible}) =>
      _dataSource.setHighlightVisible(id: id, visible: visible);
}
