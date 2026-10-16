import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/manage_championships_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/manage_championships_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Painel do admin: campeonatos por região, com criar, editar e excluir.
class ManageChampionshipsPage extends StatefulWidget {
  const ManageChampionshipsPage({super.key});

  @override
  State<ManageChampionshipsPage> createState() => _ManageChampionshipsPageState();
}

class _ManageChampionshipsPageState extends State<ManageChampionshipsPage> {
  late final ManageChampionshipsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ManageChampionshipsCubit>(context)
      ..watch(region: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  void _open([ChampionshipDTO? championship]) => Navigator.pushNamed(
        context,
        AppRoutes.championshipFormPage,
        arguments: {'championship': championship},
      );

  Future<void> _confirmDelete(ChampionshipDTO championship, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.championshipsManageDeleteTitle(championship.title),
      message: l10n.championshipsManageDeleteMessage,
      confirmLabel: l10n.commonDelete,
      icon: Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await _cubit.delete(championship);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final regions = BlocProvider.of<RegionCubit>(context).state.regions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.championshipsManageTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.championshipFormNewTitle,
        onPressed: _open,
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocConsumer<ManageChampionshipsCubit, ManageChampionshipsState>(
        listener: (context, state) {
          if (state is ErrorManageChampionshipsState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
          if (state is DeletedManageChampionshipsState) {
            showSnackBar(context: context, message: l10n.championshipsManageDeleted);
          }
        },
        builder: (context, state) {
          final championships = state.visible;
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s80),
            children: [
              Wrap(
                spacing: AppSizes.s8,
                runSpacing: AppSizes.s8,
                children: [
                  for (final region in regions)
                    ArenaChoiceChip(
                      label: region,
                      icon: Icons.place_outlined,
                      selected: region == state.region,
                      onTap: () => _cubit.selectRegion(region),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.s16),
              if (state.loading)
                const Padding(
                  padding: EdgeInsets.only(top: AppSizes.s48),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (championships.isEmpty)
                ArenaEmptyState(message: l10n.championshipsManageEmpty, icon: Icons.emoji_events_outlined)
              else
                for (final championship in championships)
                  _ChampionshipTile(
                    championship: championship,
                    onTap: () => _open(championship),
                    actions: [
                      CardMenuAction(
                        icon: Icons.edit_outlined,
                        label: l10n.commonEdit,
                        onSelected: () => _open(championship),
                      ),
                      CardMenuAction(
                        icon: Icons.delete_outline_rounded,
                        label: l10n.commonDelete,
                        destructive: true,
                        onSelected: () => _confirmDelete(championship, l10n),
                      ),
                    ],
                  ),
            ],
          );
        },
      ),
    );
  }
}

/// Card do campeonato: banner, título, região · temporada, nº de times e
/// selo de PDF quando tem regulamento.
class _ChampionshipTile extends StatelessWidget {
  final ChampionshipDTO championship;
  final VoidCallback onTap;
  final List<CardMenuAction> actions;

  const _ChampionshipTile({required this.championship, required this.onTap, required this.actions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s12),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: radius, side: const BorderSide(color: AppColors.greyLight)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 6,
                child: championship.imageUrl.isEmpty
                    ? Container(
                        color: AppColors.primarySoft,
                        child: const Icon(Icons.emoji_events_rounded, color: AppColors.primaryDark, size: AppSizes.s40),
                      )
                    : CachedNetworkImage(
                        imageUrl: championship.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: AppColors.primarySoft),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s4, AppSizes.s12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            championship.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body().copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSizes.s4),
                          Text(
                            [
                              l10n.championshipsSeasonLabel(championship.region, championship.season),
                              l10n.championshipsManageTeamsCount(championship.teams.length),
                            ].join(' · '),
                            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                          ),
                        ],
                      ),
                    ),
                    if (championship.rulesUrl.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.s4),
                        child: Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: AppSizes.s22),
                      ),
                    CardMenuButton(actions: actions),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
