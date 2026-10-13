import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/seasons/domain/team_links.dart';

/// Manutenção "Vincular times por id" do painel de temporadas.
class TeamLinksState extends Equatable {
  final bool running;

  /// Relatório da última execução (e de qual temporada).
  final TeamLinkReport? report;
  final String? reportSeason;
  final String? errorMessage;

  const TeamLinksState({this.running = false, this.report, this.reportSeason, this.errorMessage});

  @override
  List<Object?> get props => [running, report, reportSeason, errorMessage];
}
