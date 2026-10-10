import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_usecase.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetTeamByNameUseCase getTeamByNameUseCase;

  HomeCubit(this.getTeamByNameUseCase) : super(const HomeState());

  void selectTab(HomeTab tab) => emit(state.copyWith(tab: tab));

  Future<void> loadFavoriteTeam(String teamName) async {
    if (teamName.isEmpty) return;
    final response = await getTeamByNameUseCase(teamName);
    response.fold(
      // O escudo é só decorativo; sem ele o drawer mostra o avatar vazio.
      (_) => null,
      (team) {
        if (team != null && team.imageUrl.isNotEmpty) emit(state.copyWith(favoriteTeamImage: team.imageUrl));
      },
    );
  }
}
