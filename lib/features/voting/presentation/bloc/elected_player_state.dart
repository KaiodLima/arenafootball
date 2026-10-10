import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';

class ElectedPlayerState extends Equatable {
  /// Resultado da apuração; nulo enquanto carrega ou quando não há votos.
  final ElectedPlayer? elected;

  const ElectedPlayerState({this.elected});

  @override
  List<Object?> get props => [elected];
}

class LoadingElectedPlayerState extends ElectedPlayerState {
  const LoadingElectedPlayerState();
}

class SuccessElectedPlayerState extends ElectedPlayerState {
  const SuccessElectedPlayerState({super.elected});
}

class ErrorElectedPlayerState extends ElectedPlayerState {
  final String errorMessage;

  const ErrorElectedPlayerState({required this.errorMessage});

  @override
  List<Object?> get props => [elected, errorMessage];
}
