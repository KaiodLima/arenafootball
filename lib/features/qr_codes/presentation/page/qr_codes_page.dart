import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_event_cubit.dart';
import 'package:arena_soccer/features/qr_codes/domain/qr_target.dart';
import 'package:arena_soccer/features/qr_codes/presentation/bloc/qr_codes_cubit.dart';
import 'package:arena_soccer/features/qr_codes/presentation/page/qr_poster_page.dart';
import 'package:arena_soccer/features/qr_codes/presentation/widgets/qr_poster.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_picker_sheet.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';

/// Central "QR codes" do admin: o que está ativo agora na região (bolão,
/// álbum, eventos de votação, votações do craque e próximas partidas); o
/// toque abre o cartaz do QR code.
class QrCodesPage extends StatefulWidget {
  const QrCodesPage({super.key});

  @override
  State<QrCodesPage> createState() => _QrCodesPageState();
}

class _QrCodesPageState extends State<QrCodesPage> {
  late final QrCodesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<QrCodesCubit>(context);
    _load(BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  Future<void> _load(String region) => _cubit.load(region: region, season: SeasonCollection.currentSeason);

  Future<void> _pickRegion(String current) async {
    final regions = BlocProvider.of<RegionCubit>(context).state;
    final picked = await showRegionPicker(
      context,
      regions: regions.regions,
      selected: current,
      recent: regions.recentRegions,
    );
    if (picked != null && picked != current) await _load(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final album = context.watch<AlbumEventCubit>().state.event;

    return BlocBuilder<QrCodesCubit, QrCodesState>(
      builder: (context, state) {
        final regionId = RegionRegistry.idOf(state.region);
        final always = [
          // QR fixo da região: imprime uma vez, sempre leva ao que está ativo.
          if (regionId.isNotEmpty)
            QrTarget.now(
              regionId: regionId,
              title: l10n.qrNowPosterTitle(state.region),
              subtitle: l10n.qrNowSubtitle,
            ),
          QrTarget.pool(title: l10n.qrPoolTitle, subtitle: l10n.qrPoolSubtitle),
          if (album != null) QrTarget.album(title: album.title, subtitle: l10n.qrAlbumSubtitle),
        ];
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              l10n.qrCodesTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.s12),
                child: _RegionPill(region: state.region, onTap: () => _pickRegion(state.region)),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _load(state.region),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, safeBottom(context, AppSizes.s32)),
              children: [
                Text(l10n.qrCodesIntro, style: AppTypography.subtitle()),
                _Section(title: l10n.qrSectionAlways, targets: always, loading: false),
                _Section(title: l10n.qrSectionEvents, targets: state.events, loading: state.loading),
                _Section(title: l10n.qrSectionVotes, targets: state.votes, loading: state.loading),
                _Section(title: l10n.qrSectionMatches, targets: state.matches, loading: state.loading),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<QrTarget> targets;
  final bool loading;

  const _Section({required this.title, required this.targets, required this.loading});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s20, AppSizes.s4, AppSizes.s8),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.label(color: AppColors.textSecondary)
                .copyWith(fontSize: AppSizes.s12, letterSpacing: 1.1),
          ),
        ),
        if (loading && targets.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.s12),
            child: Center(
              child: SizedBox(
                width: AppSizes.s20,
                height: AppSizes.s20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          )
        else if (targets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
            child: Text(l10n.qrSectionEmpty, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          )
        else
          for (final target in targets) _QrTile(target: target),
      ],
    );
  }
}

/// Uma linha: ícone do tipo (ou os escudos), título, detalhe e o QR em miniatura.
class _QrTile extends StatelessWidget {
  final QrTarget target;

  const _QrTile({required this.target});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, label) = qrKindLabel(l10n, target.kind);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        child: InkWell(
          key: ValueKey('qr-${target.link}'),
          borderRadius: BorderRadius.circular(AppSizes.s16),
          onTap: () => openQrPoster(context, target),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.s16),
              border: Border.all(color: AppColors.greyLight),
            ),
            child: Row(
              children: [
                Container(
                  width: AppSizes.s44,
                  height: AppSizes.s44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(AppSizes.s12),
                  ),
                  child: Icon(icon, color: AppColors.gold, size: AppSizes.s22),
                ),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: AppTypography.label(color: AppColors.primary).copyWith(
                          fontSize: AppSizes.s10,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        target.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(color: AppColors.textPrimary),
                      ),
                      if (target.subtitle.isNotEmpty)
                        Text(
                          target.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.s8),
                ArtQrCode(data: target.link, size: AppSizes.s44),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionPill extends StatelessWidget {
  final String region;
  final VoidCallback onTap;

  const _RegionPill({required this.region, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.14),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.s120),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place_rounded, size: AppSizes.s16, color: AppColors.white),
                const SizedBox(width: AppSizes.s4),
                Flexible(
                  child: Text(
                    region,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                  ),
                ),
                const Icon(Icons.expand_more_rounded, size: AppSizes.s18, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
