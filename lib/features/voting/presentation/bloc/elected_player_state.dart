import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';

class ElectedPlayerState extends Equatable {
  /// Apuração; nula enquanto carrega ou após erro. Sem votos, vem com
  /// `elected == null` e o ranking vazio.
  final VotingResult? result;

  const ElectedPlayerState({this.result});

  @override
  List<Object?> get props => [result];
}

class LoadingElectedPlayerState extends ElectedPlayerState {
  const LoadingElectedPlayerState();
}

class SuccessElectedPlayerState extends ElectedPlayerState {
  const SuccessElectedPlayerState({required VotingResult super.result});
}

class ErrorElectedPlayerState extends ElectedPlayerState {
  final String errorMessage;

  const ErrorElectedPlayerState({required this.errorMessage});

  @override
  List<Object?> get props => [result, errorMessage];
}
