import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/elected_player_cubit.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/elected_player_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Melhor jogador eleito da partida (votação encerrada): foto do jogador à
/// esquerda, escudo do time à direita, nome e número de votos.
class ElectedPlayerPage extends StatefulWidget {
  final MatchDTO match;
  final String season;

  const ElectedPlayerPage({super.key, required this.match, required this.season});

  @override
  State<ElectedPlayerPage> createState() => _ElectedPlayerPageState();
}

class _ElectedPlayerPageState extends State<ElectedPlayerPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ElectedPlayerCubit>(context).load(
      homeTeam: widget.match.homeTeam,
      awayTeam: widget.match.awayTeam,
      season: widget.season,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(AppImages.logo, width: AppSizes.logoWidth, height: AppSizes.logoHeight),
      ),
      body: BlocBuilder<ElectedPlayerCubit, ElectedPlayerState>(
        builder: (context, state) {
          if (state is LoadingElectedPlayerState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ErrorElectedPlayerState) return _Message(text: l10n.votingLoadError);
          final elected = state.elected;
          if (elected == null) return _Message(text: l10n.votingNoVotes);
          return _ElectedView(elected: elected);
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.s16),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s18),
        ),
      ),
    );
  }
}

class _ElectedView extends StatelessWidget {
  final ElectedPlayer elected;

  const _ElectedView({required this.elected});

  static const _radius = BorderRadius.all(Radius.circular(AppSizes.s24));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;
    final hasPlayer = elected.playerImageUrl.isNotEmpty;
    final hasTeam = elected.teamImageUrl.isNotEmpty;

    return Stack(
      children: [
        if (hasPlayer)
          Align(
            alignment: Alignment.centerLeft,
            child: _FadedImage(
              url: elected.playerImageUrl,
              width: width * 0.7,
              begin: Alignment.centerRight,
              end: Alignment.center,
            ),
          ),
        if (hasTeam)
          Align(
            alignment: Alignment.centerRight,
            // Só com o escudo, ele ocupa a tela toda, sem esmaecer.
            child: hasPlayer
                ? _FadedImage(
                    url: elected.teamImageUrl,
                    width: width * 0.5,
                    begin: Alignment.center,
                    end: Alignment.centerRight,
                  )
                : _Image(url: elected.teamImageUrl),
          ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.black, AppColors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.center,
            ),
            borderRadius: _radius,
          ),
          padding: const EdgeInsets.only(bottom: AppSizes.s64, left: AppSizes.s8, right: AppSizes.s8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AutoSizeText(
                l10n.votingElectedLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: AppSizes.s18, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              const SizedBox(height: AppSizes.s8),
              AutoSizeText(
                elected.playerName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: AppSizes.s30, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              const SizedBox(height: AppSizes.s10),
              Text(
                l10n.votingVotesCount(elected.votes),
                style: const TextStyle(fontSize: AppSizes.s16, color: AppColors.white),
              ),
              const SizedBox(height: AppSizes.s10),
            ],
          ),
        ),
      ],
    );
  }
}

class _Image extends StatelessWidget {
  final String url;
  final double? width;

  const _Image({required this.url, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(image: CachedNetworkImageProvider(url), fit: BoxFit.cover),
        borderRadius: _ElectedView._radius,
      ),
    );
  }
}

/// Imagem que some em degradê de [begin] para [end].
class _FadedImage extends StatelessWidget {
  final String url;
  final double width;
  final Alignment begin;
  final Alignment end;

  const _FadedImage({required this.url, required this.width, required this.begin, required this.end});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: begin,
        end: end,
        colors: const [AppColors.transparent, AppColors.black],
      ).createShader(bounds),
      child: _Image(url: url, width: width),
    );
  }
}
