import 'package:equatable/equatable.dart';

/// Abas da home, na ordem da barra inferior.
enum HomeTab { news, championships, teams, tables }

class HomeState extends Equatable {
  final HomeTab tab;

  /// Escudo do time do coração, exibido no drawer.
  final String? favoriteTeamImage;

  /// Pedidos "Sou jogador" aguardando resposta (só para o admin).
  final int pendingPlayerRequests;

  const HomeState({this.tab = HomeTab.news, this.favoriteTeamImage, this.pendingPlayerRequests = 0});

  HomeState copyWith({HomeTab? tab, String? favoriteTeamImage, int? pendingPlayerRequests}) {
    return HomeState(
      tab: tab ?? this.tab,
      favoriteTeamImage: favoriteTeamImage ?? this.favoriteTeamImage,
      pendingPlayerRequests: pendingPlayerRequests ?? this.pendingPlayerRequests,
    );
  }

  @override
  List<Object?> get props => [tab, favoriteTeamImage, pendingPlayerRequests];
}
