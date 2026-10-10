import 'package:equatable/equatable.dart';

/// Abas da home, na ordem da barra inferior.
enum HomeTab { news, championships, teams, tables }

class HomeState extends Equatable {
  final HomeTab tab;

  /// Escudo do time do coração, exibido no drawer.
  final String? favoriteTeamImage;

  const HomeState({this.tab = HomeTab.news, this.favoriteTeamImage});

  HomeState copyWith({HomeTab? tab, String? favoriteTeamImage}) {
    return HomeState(
      tab: tab ?? this.tab,
      favoriteTeamImage: favoriteTeamImage ?? this.favoriteTeamImage,
    );
  }

  @override
  List<Object?> get props => [tab, favoriteTeamImage];
}
