import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/link_teams_by_id_usecase.dart';
import 'package:arena_soccer/features/seasons/presentation/bloc/team_links_state.dart';

/// Roda a manutenção "Vincular times por id" e guarda o relatório.
class TeamLinksCubit extends Cubit<TeamLinksState> {
  final LinkTeamsByIdUseCase linkTeamsByIdUseCase;

  TeamLinksCubit(this.linkTeamsByIdUseCase) : super(const TeamLinksState());

  Future<void> run(String season) async {
    if (state.running) return;
    emit(TeamLinksState(running: true, report: state.report, reportSeason: state.reportSeason));
    final response = await linkTeamsByIdUseCase(season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(TeamLinksState(
        report: state.report,
        reportSeason: state.reportSeason,
        errorMessage: failure.toString(),
      )),
      (report) => emit(TeamLinksState(report: report, reportSeason: season)),
    );
  }
}
