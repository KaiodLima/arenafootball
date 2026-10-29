import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

String achievementCategoryLabel(AppLocalizations l10n, AchievementCategory category) => switch (category) {
      AchievementCategory.fan => l10n.achievementCategoryFan,
      AchievementCategory.voting => l10n.achievementCategoryVoting,
      AchievementCategory.sharing => l10n.achievementCategorySharing,
      AchievementCategory.news => l10n.achievementCategoryNews,
      AchievementCategory.athlete => l10n.achievementCategoryAthlete,
      AchievementCategory.predictions => l10n.achievementCategoryPredictions,
    };

String achievementTierLabel(AppLocalizations l10n, AchievementTier tier) => switch (tier) {
      AchievementTier.bronze => l10n.achievementTierBronze,
      AchievementTier.silver => l10n.achievementTierSilver,
      AchievementTier.gold => l10n.achievementTierGold,
      AchievementTier.legend => l10n.achievementTierLegend,
    };

String fanLevelLabel(AppLocalizations l10n, FanLevel level) => switch (level) {
      FanLevel.fan => l10n.fanLevelFan,
      FanLevel.loyal => l10n.fanLevelLoyal,
      FanLevel.roots => l10n.fanLevelRoots,
      FanLevel.ultra => l10n.fanLevelUltra,
      FanLevel.legend => l10n.fanLevelLegend,
    };

String achievementMetricLabel(AppLocalizations l10n, AchievementMetric metric) => switch (metric) {
      AchievementMetric.votes => l10n.achievementMetricVotes,
      AchievementMetric.shares => l10n.achievementMetricShares,
      AchievementMetric.newsRead => l10n.achievementMetricNewsRead,
      AchievementMetric.activeDays => l10n.achievementMetricActiveDays,
      AchievementMetric.bestStreak => l10n.achievementMetricBestStreak,
      AchievementMetric.favoriteTeam => l10n.achievementMetricFavoriteTeam,
      AchievementMetric.cardPhoto => l10n.achievementMetricCardPhoto,
      AchievementMetric.athlete => l10n.achievementMetricAthlete,
      AchievementMetric.athleteGoals => l10n.achievementMetricAthleteGoals,
      AchievementMetric.athleteAssists => l10n.achievementMetricAthleteAssists,
      AchievementMetric.teamOwner => l10n.achievementMetricTeamOwner,
      AchievementMetric.predictions => l10n.achievementMetricPredictions,
      AchievementMetric.exactPredictions => l10n.achievementMetricExactPredictions,
      AchievementMetric.albumStickers => l10n.achievementMetricAlbumStickers,
      AchievementMetric.albumPages => l10n.achievementMetricAlbumPages,
      AchievementMetric.albumComplete => l10n.achievementMetricAlbumComplete,
    };
