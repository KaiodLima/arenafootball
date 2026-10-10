import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';

class ChampionshipsState extends Equatable {
  final List<ChampionshipDTO> championships;

  const ChampionshipsState({this.championships = const []});

  @override
  List<Object?> get props => [championships];
}

class LoadingChampionshipsState extends ChampionshipsState {
  const LoadingChampionshipsState({super.championships});
}

class SuccessChampionshipsState extends ChampionshipsState {
  const SuccessChampionshipsState({required super.championships});
}

class ErrorChampionshipsState extends ChampionshipsState {
  final String errorMessage;

  const ErrorChampionshipsState({required this.errorMessage, super.championships});

  @override
  List<Object?> get props => [championships, errorMessage];
}
