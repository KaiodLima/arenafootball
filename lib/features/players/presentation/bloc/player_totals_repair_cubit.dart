import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/domain/usecases/repair_player_totals_usecase.dart';

class PlayerTotalsRepairState extends Equatable {
  final bool running;

  /// Atletas corrigidos na última execução (nulo = ainda não rodou).
  final int? fixed;
  final String? errorMessage;

  const PlayerTotalsRepairState({this.running = false, this.fixed, this.errorMessage});

  @override
  List<Object?> get props => [running, fixed, errorMessage];
}

/// Roda a manutenção "Corrigir números dos atletas" (painel de Temporadas).
class PlayerTotalsRepairCubit extends Cubit<PlayerTotalsRepairState> {
  final RepairPlayerTotalsUseCase repairPlayerTotalsUseCase;

  PlayerTotalsRepairCubit(this.repairPlayerTotalsUseCase) : super(const PlayerTotalsRepairState());

  Future<void> run(String season) async {
    if (state.running) return;
    emit(PlayerTotalsRepairState(running: true, fixed: state.fixed));
    final response = await repairPlayerTotalsUseCase(season: season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(PlayerTotalsRepairState(fixed: state.fixed, errorMessage: failure.toString())),
      (fixed) => emit(PlayerTotalsRepairState(fixed: fixed)),
    );
  }
}
