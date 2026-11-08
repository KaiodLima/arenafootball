import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Fontes esportivas empacotadas (as mesmas das artes de compartilhar).
const _display = 'Anton';
const _condensed = 'BarlowCondensed';

/// Card automático de resultado no feed (`tag: "resultado"`), sempre no verde
/// da marca (sem as cores dos times): fundo com as linhas do campo, selo
/// "FIM DE JOGO" dourado, escudos em quadros brancos, placar grande (o
/// perdedor esmaecido), título e texto da postagem e "Ver partida".
class ResultCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;

  /// Toque no card (abre os detalhes da partida).
  final VoidCallback? onTap;

  const ResultCard({super.key, required this.news, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeGoals = int.tryParse(news.homeGoals) ?? 0;
    final awayGoals = int.tryParse(news.awayGoals) ?? 0;
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    final championship = news.championshipTitle.isNotEmpty
        ? news.championshipTitle
        : (news.championshipId ?? 0) > 0
            ? ''
            : l10n.resultCardFriendly;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s14, offset: Offset(0, AppSizes.s4)),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primaryStrong],
          ),
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                const Positioned.fill(child: CustomPaint(painter: _PitchPainter())),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s8, 0),
                      child: Row(
                        children: [
                          _FullTimeBadge(label: l10n.resultCardFullTime),
                          const SizedBox(width: AppSizes.s10),
                          Expanded(
                            child: Text(
                              championship.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: _condensed,
                                fontWeight: FontWeight.w700,
                                fontSize: AppSizes.s14,
                                letterSpacing: 1.4,
                                color: AppColors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s18, AppSizes.s12, AppSizes.s4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _Team(
                              name: news.homeTeam,
                              crest: news.homeCrest,
                              won: homeGoals > awayGoals,
                              lost: homeGoals < awayGoals,
                            ),
                          ),
                          _Score(home: homeGoals, away: awayGoals),
                          Expanded(
                            child: _Team(
                              name: news.awayTeam,
                              crest: news.awayCrest,
                              won: awayGoals > homeGoals,
                              lost: awayGoals < homeGoals,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: AppSizes.s32, height: AppSizes.s4, color: AppColors.gold),
                          const SizedBox(height: AppSizes.s10),
                          Text(
                            news.title,
                            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                          ),
                          if (news.description.isNotEmpty) ...[
                            const SizedBox(height: AppSizes.s6),
                            Text(
                              news.description,
                              style: AppTypography.body(color: AppColors.white.withValues(alpha: 0.88))
                                  .copyWith(fontSize: AppSizes.s14, height: 1.35),
                            ),
                          ],
                          if (onTap != null) ...[
                            const SizedBox(height: AppSizes.s14),
                            _SeeMatchPill(label: l10n.resultCardSeeMatch),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Linhas do campo bem apagadas (meio-campo, círculo central e as duas
/// grandes áreas) e um brilho diagonal.
class _PitchPainter extends CustomPainter {
  const _PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final line = Paint()
      ..color = AppColors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = Offset(w / 2, h * 0.42);
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), line);
    canvas.drawCircle(center, h * 0.2, line);
    canvas.drawCircle(center, 2.5, line..style = PaintingStyle.fill);
    line.style = PaintingStyle.stroke;
    final boxH = h * 0.5;
    final boxW = w * 0.12;
    canvas.drawRect(Rect.fromLTWH(-1, center.dy - boxH / 2, boxW, boxH), line);
    canvas.drawRect(Rect.fromLTWH(w - boxW + 1, center.dy - boxH / 2, boxW, boxH), line);

    final beam = Path()
      ..moveTo(w * 0.55, 0)
      ..lineTo(w * 0.8, 0)
      ..lineTo(w * 0.45, h)
      ..lineTo(w * 0.2, h)
      ..close();
    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.white.withValues(alpha: 0),
            AppColors.white.withValues(alpha: 0.06),
            AppColors.white.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) => false;
}

/// "FIM DE JOGO" dourado num selo escuro com o canto cortado.
class _FullTimeBadge extends StatelessWidget {
  final String label;

  const _FullTimeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _CutCornerClipper(),
      child: Container(
        color: AppColors.black.withValues(alpha: 0.32),
        padding: const EdgeInsets.fromLTRB(AppSizes.s10, AppSizes.s4, AppSizes.s14, AppSizes.s4),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: _display,
            fontSize: AppSizes.s14,
            letterSpacing: 1.2,
            height: 1.3,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }
}

class _CutCornerClipper extends CustomClipper<Path> {
  const _CutCornerClipper();

  @override
  Path getClip(Size size) {
    final cut = size.height * 0.5;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Placar grande: o perdedor esmaecido (empate: os dois cheios).
class _Score extends StatelessWidget {
  final int home;
  final int away;

  const _Score({required this.home, required this.away});

  TextStyle _digit(bool lost) => TextStyle(
        fontFamily: _display,
        fontSize: AppSizes.s52,
        height: 1.1,
        color: AppColors.white.withValues(alpha: lost ? 0.45 : 1),
        fontFeatures: const [FontFeature.tabularFigures()],
        shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.3), offset: const Offset(0, AppSizes.s2))],
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$home', style: _digit(home < away)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
            child: Text(
              '×',
              style: TextStyle(
                fontFamily: _condensed,
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.s24,
                color: AppColors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          Text('$away', style: _digit(away < home)),
        ],
      ),
    );
  }
}

/// Escudo num quadro branco e o nome; fio dourado sob o vencedor.
class _Team extends StatelessWidget {
  final String name;
  final String crest;
  final bool won;
  final bool lost;

  const _Team({required this.name, required this.crest, this.won = false, this.lost = false});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: lost ? 0.7 : 1,
        child: Column(
          children: [
            Container(
              width: AppSizes.s56,
              height: AppSizes.s56,
              padding: const EdgeInsets.all(AppSizes.s6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.s14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.25),
                    blurRadius: AppSizes.s8,
                    offset: const Offset(0, AppSizes.s2),
                  ),
                ],
              ),
              child: TeamCrest(imageUrl: crest.isEmpty ? null : crest, size: AppSizes.s44),
            ),
            const SizedBox(height: AppSizes.s8),
            Text(
              name.toUpperCase(),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _condensed,
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.s16,
                height: 1.1,
                letterSpacing: 0.4,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSizes.s6),
            Container(
              width: AppSizes.s24,
              height: 3,
              color: won ? AppColors.gold : AppColors.transparent,
            ),
          ],
        ),
      );
}

/// "Ver partida" numa pílula translúcida.
class _SeeMatchPill extends StatelessWidget {
  final String label;

  const _SeeMatchPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s6, AppSizes.s8, AppSizes.s6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.s20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.white, size: AppSizes.s20),
        ],
      ),
    );
  }
}
