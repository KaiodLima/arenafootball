/// Modos da home pelo toggle do topo: torcedor/admin, organizador e (só o
/// admin) jogador — o admin vendo o app como o atleta da própria conta.
enum HomeMode { standard, organizer, player }

/// Próximo modo ao tocar no toggle. Admin: admin → organizador → jogador →
/// admin. Organizador comum: torcedor ↔ organizador. Os outros não trocam.
HomeMode nextHomeMode(HomeMode current, {required bool isAccountAdmin, required bool isOrganizer}) {
  if (isAccountAdmin) {
    return switch (current) {
      HomeMode.standard => HomeMode.organizer,
      HomeMode.organizer => HomeMode.player,
      HomeMode.player => HomeMode.standard,
    };
  }
  if (!isOrganizer) return HomeMode.standard;
  return current == HomeMode.organizer ? HomeMode.standard : HomeMode.organizer;
}
