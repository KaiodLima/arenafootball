/// Modos da home pelo toggle do topo: torcedor/admin, organizador e (só o
/// admin) jogador — o admin vendo o app como o atleta da própria conta — e
/// torcedor — o admin vendo o app como um usuário comum.
enum HomeMode { standard, organizer, player, fan }

/// Próximo modo ao tocar no toggle. Admin: admin → organizador → jogador →
/// torcedor → admin. Organizador comum: torcedor ↔ organizador. Os outros não
/// trocam.
HomeMode nextHomeMode(HomeMode current, {required bool isAccountAdmin, required bool isOrganizer}) {
  if (isAccountAdmin) {
    return switch (current) {
      HomeMode.standard => HomeMode.organizer,
      HomeMode.organizer => HomeMode.player,
      HomeMode.player => HomeMode.fan,
      HomeMode.fan => HomeMode.standard,
    };
  }
  if (!isOrganizer) return HomeMode.standard;
  return current == HomeMode.organizer ? HomeMode.standard : HomeMode.organizer;
}
