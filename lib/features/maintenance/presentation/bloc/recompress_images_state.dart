import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/maintenance/data/dtos/recompress_status_dto.dart';

class RecompressImagesState extends Equatable {
  final RecompressStatusDTO status;
  final bool loading;

  /// Gravando o pedido.
  final bool requesting;

  const RecompressImagesState({this.status = const RecompressStatusDTO(), this.loading = true, this.requesting = false});

  RecompressImagesState copyWith({RecompressStatusDTO? status, bool? loading, bool? requesting}) {
    return RecompressImagesState(
      status: status ?? this.status,
      loading: loading ?? this.loading,
      requesting: requesting ?? this.requesting,
    );
  }

  @override
  List<Object?> get props => [status, loading, requesting];
}

class ErrorRecompressImagesState extends RecompressImagesState {
  final String errorMessage;

  ErrorRecompressImagesState(RecompressImagesState base, this.errorMessage)
      : super(status: base.status, loading: false, requesting: base.requesting);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
