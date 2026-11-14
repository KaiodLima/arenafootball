import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_squads.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/share_art/presentation/bloc/match_athlete_picker_cubit.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Megafone do card de partida (antes do jogo). Admin ou atleta da partida
/// ([myPlayer] joga por um dos times): folha com "Divulgar partida" e "Arte
/// do atleta"; os demais vão direto à divulgação.
Future<void> openMatchArt(
  BuildContext context, {
  required MatchDTO match,
  required String season,
  required bool isAdmin,
  PlayerDTO? myPlayer,
}) async {
  final mySide = playerArtSideOf(match, myPlayer);
  void promote() => Navigator.pushNamed(context, AppRoutes.shareArtPage, arguments: {'match': match, 'season': season});
  if (!isAdmin && mySide == null) {
    promote();
    return;
  }
  final l10n = AppLocalizations.of(context);
  final choice = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s8),
            child: Text(l10n.playerMatchArtSheetTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
          ),
          ListTile(
            leading: const Icon(Icons.campaign_rounded, color: AppColors.primary),
            title: Text(l10n.shareArtPreviewTitle, style: AppTypography.label(color: AppColors.textPrimary)),
            onTap: () => Navigator.of(sheet).pop(false),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
            title: Text(l10n.playerMatchArtAction, style: AppTypography.label(color: AppColors.textPrimary)),
            onTap: () => Navigator.of(sheet).pop(true),
          ),
          const SizedBox(height: AppSizes.s8),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  if (!choice) {
    promote();
    return;
  }
  // O admin escolhe o atleta nos elencos da partida; o atleta usa o dele.
  final picked = isAdmin ? await showMatchAthletePicker(context, match: match, season: season) : (myPlayer!, mySide!);
  if (picked == null || !context.mounted) return;
  await Navigator.pushNamed(
    context,
    AppRoutes.playerMatchArtPage,
    arguments: {'match': match, 'season': season, 'player': picked.$1, 'side': picked.$2},
  );
}

/// Atletas dos dois times da partida (busca + uma seção por time); devolve o
/// escolhido com o lado dele.
Future<(PlayerDTO, MatchSide)?> showMatchAthletePicker(
  BuildContext context, {
  required MatchDTO match,
  required String season,
}) {
  return showModalBottomSheet<(PlayerDTO, MatchSide)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider<MatchAthletePickerCubit>(
      create: (_) => MatchAthletePickerCubit(sl())..load(match, season),
      child: _AthletePicker(match: match),
    ),
  );
}

class _AthletePicker extends StatefulWidget {
  final MatchDTO match;

  const _AthletePicker({required this.match});

  @override
  State<_AthletePicker> createState() => _AthletePickerState();
}

class _AthletePickerState extends State<_AthletePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final term = foldForSearch(_query.trim());
    List<PlayerDTO> filter(List<PlayerDTO> list) =>
        term.isEmpty ? list : list.where((p) => foldForSearch(p.name).contains(term)).toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: BlocBuilder<MatchAthletePickerCubit, MatchAthletePickerState>(
          builder: (context, state) {
            // Os dois times sempre aparecem (elenco geral de cada um).
            final sections = [
              (widget.match.homeTeam, MatchSide.home, filter(state.home), state.homeLoading),
              (widget.match.awayTeam, MatchSide.away, filter(state.away), state.awayLoading),
            ];
            final nobody = !state.loading && sections.every((s) => s.$3.isEmpty) && term.isEmpty;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s12),
                  child: Text(l10n.playerMatchArtPick, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                  child:
                      ArenaSearchField(hint: l10n.playerMatchArtSearch, onChanged: (v) => setState(() => _query = v)),
                ),
                const SizedBox(height: AppSizes.s8),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : nobody
                          ? ArenaEmptyState(message: l10n.playerMatchArtEmpty, icon: Icons.groups_outlined)
                          : ListView(
                              children: [
                                for (final (team, side, players, teamLoading) in sections) ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        AppSizes.s20, AppSizes.s12, AppSizes.s20, AppSizes.s4),
                                    child: Text(
                                      team.toUpperCase(),
                                      style: AppTypography.label(color: AppColors.textSecondary)
                                          .copyWith(fontSize: AppSizes.s12),
                                    ),
                                  ),
                                  if (players.isEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: AppSizes.s20, vertical: AppSizes.s8),
                                      child: teamLoading
                                          ? const LinearProgressIndicator(minHeight: 2, color: AppColors.primary)
                                          : Text(
                                              l10n.playerMatchArtTeamEmpty,
                                              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                                            ),
                                    ),
                                  for (final player in players)
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.background,
                                        backgroundImage: player.imageUrl.trim().isEmpty
                                            ? null
                                            : CachedNetworkImageProvider(player.imageUrl.trim()),
                                        child: player.imageUrl.trim().isEmpty
                                            ? const Icon(Icons.person_rounded, color: AppColors.textSecondary)
                                            : null,
                                      ),
                                      title:
                                          Text(player.name, style: AppTypography.label(color: AppColors.textPrimary)),
                                      onTap: () => Navigator.of(context).pop((player, side)),
                                    ),
                                ],
                                const SizedBox(height: AppSizes.s16),
                              ],
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
