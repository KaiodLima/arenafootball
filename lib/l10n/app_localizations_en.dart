// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Arena Football';

  @override
  String get commonRequiredField => 'Required field';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonSave => 'SAVE';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonGenericError => 'Something went wrong. Please try again.';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginButton => 'SIGN IN';

  @override
  String get loginCreateAccountButton => 'CREATE ACCOUNT';

  @override
  String get loginSuccess => 'Signed in!';

  @override
  String get loginInvalidEmail => 'Invalid e-mail!';

  @override
  String get loginInvalidPassword =>
      'Invalid password! Use at least 8 characters.';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerNameLabel => 'Name';

  @override
  String get registerEmailLabel => 'E-mail';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerRegionLabel => 'Region';

  @override
  String get registerTeamLabel => 'Favorite team';

  @override
  String get registerHaveAccountButton => 'I already have an account!';

  @override
  String get registerSuccess => 'Account created successfully!';

  @override
  String get registerNameTooShort =>
      'Your username must have at least 3 characters';

  @override
  String get registerEmailExample =>
      'Enter a valid e-mail, e.g. name@email.com';

  @override
  String get registerPasswordTooShort =>
      'Your password must have at least 8 characters';

  @override
  String get homeTabHome => 'Home';

  @override
  String get homeTabChampionships => 'Championships';

  @override
  String get homeTabTeams => 'Teams';

  @override
  String get homeTabTables => 'Tables';

  @override
  String get fanRankingTitle => 'Fan ranking';

  @override
  String fanRankingFans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fans',
      one: '1 fan',
      zero: 'no fans',
    );
    return '$_temp0';
  }

  @override
  String get fanRankingYourFans => 'Your team';

  @override
  String fanRankingUpdatedAt(String time) {
    return 'Updated at $time · counts app users by their favorite team';
  }

  @override
  String get fanRankingPreparing =>
      'The fan ranking is being prepared. Check back soon!';

  @override
  String get fanRankingNoTeams => 'No teams in this region yet.';

  @override
  String get fanRankingError => 'Couldn\'t load the fan ranking.';

  @override
  String get drawerResults => 'Results around the world';

  @override
  String get drawerRegisterHighlight => 'Highlights';

  @override
  String get drawerRegisterPlayer => 'Add player';

  @override
  String get drawerRegisterMatch => 'Add match';

  @override
  String get drawerRegisterNews => 'Add news';

  @override
  String get drawerRegisterTeam => 'Add team';

  @override
  String drawerFanOf(String team) {
    return 'Supports $team';
  }

  @override
  String get drawerGuest => 'Guest';

  @override
  String get commonTakePhoto => 'Take photo';

  @override
  String get commonGallery => 'Gallery';

  @override
  String get newsEmpty => 'No news yet';

  @override
  String get newsLoadError => 'Could not load the news.';

  @override
  String get newsDeleteConfirm => 'DO YOU REALLY WANT TO DELETE THIS NEWS?';

  @override
  String get newsAdPlaceholder => 'ADVERTISEMENT';

  @override
  String get newsCreateTitle => 'New article';

  @override
  String get newsEditTitle => 'Edit article';

  @override
  String get newsTitleLabel => 'Title';

  @override
  String get newsCoverAdd => 'Add cover';

  @override
  String get newsCoverHint => 'Tap to take a photo or pick from the gallery';

  @override
  String get newsCoverChange => 'Change';

  @override
  String get newsCoverRemove => 'Remove';

  @override
  String get newsSectionContent => 'Content';

  @override
  String get newsSectionAlbum => 'Photo album';

  @override
  String get newsSectionPublish => 'Publishing';

  @override
  String newsAlbumCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
      zero: 'no photos',
    );
    return '$_temp0';
  }

  @override
  String get newsAlbumAdd => 'Add';

  @override
  String get newsAlbumHint => 'Photos show up in the article gallery.';

  @override
  String get newsRegion => 'Region';

  @override
  String get newsHighlight => 'Highlight';

  @override
  String get newsHighlightNone => 'None';

  @override
  String get newsHighlightHint =>
      'The article also shows up inside the chosen highlight.';

  @override
  String get newsLinkHint => 'External link (optional)';

  @override
  String get newsVisibleHint =>
      'When off, the article is saved but hidden in the app.';

  @override
  String get newsVisibleOnHint => 'The article shows up in the app feed.';

  @override
  String get newsPreview => 'Preview';

  @override
  String get newsPreviewTitle => 'How it will look in the feed';

  @override
  String get newsDiscardTitle => 'Discard changes?';

  @override
  String get newsDiscardMessage => 'What you filled in will be lost.';

  @override
  String get newsDiscardKeep => 'Keep editing';

  @override
  String get newsDiscardConfirm => 'Discard';

  @override
  String get newsPublish => 'Publish article';

  @override
  String get newsSave => 'Save changes';

  @override
  String get newsDescriptionLabel => 'Description';

  @override
  String get newsLinkLabel => 'Link';

  @override
  String get newsVisibleLabel => 'Visible in the app';

  @override
  String get newsTitleRequired => 'Enter the article title';

  @override
  String get newsTitleTooShort =>
      'The news title must have at least 3 characters';

  @override
  String get newsCreated => 'Article published!';

  @override
  String get newsUpdated => 'Article updated!';

  @override
  String get newsRegionLabel => 'Region:';

  @override
  String get newsGoalTitle => 'Goal card';

  @override
  String get newsPublishButton => 'Publish';

  @override
  String get newsGoalCreated => 'Goal published!';

  @override
  String get goalTodayMatches => 'Today\'s matches';

  @override
  String get goalTodayMatchesHint => 'Tap to fill in the teams and the score.';

  @override
  String get goalChampionship => 'Competition';

  @override
  String get goalChampionshipHint =>
      'The goal counts toward the player\'s stats in this competition.';

  @override
  String get goalScoreboard => 'Score';

  @override
  String get goalPickTeam => 'Choose team';

  @override
  String get goalHome => 'Home';

  @override
  String get goalAway => 'Away';

  @override
  String get goalSameTeam => 'Choose two different teams.';

  @override
  String get goalNoTeams => 'No teams registered in this region.';

  @override
  String get goalSearchTeam => 'Search team';

  @override
  String get goalUpdateMatch => 'Update match score';

  @override
  String get goalUpdateMatchHint =>
      'Saves the same score on the match in the table.';

  @override
  String get goalPreview => 'Feed preview';

  @override
  String get goalPublish => 'Publish goal';

  @override
  String get goalConfirmTitle => 'Publish goal card?';

  @override
  String goalConfirmMessage(
      String home, int homeGoals, int awayGoals, String away) {
    return '$home $homeGoals × $awayGoals $away';
  }

  @override
  String get goalMatchUpdated => 'Goal published and match score updated!';

  @override
  String get goalMatchUpdateFailed =>
      'Goal published, but the match score could not be updated.';

  @override
  String goalOfTeam(String team) {
    return '$team goal';
  }

  @override
  String get goalWhoScoredQ => 'Who scored?';

  @override
  String goalWhoAssistedQ(String scorer) {
    return 'Who assisted $scorer?';
  }

  @override
  String get goalSkip => 'Skip';

  @override
  String get goalNoAssist => 'No assist';

  @override
  String get goalBack => 'Back';

  @override
  String get goalEditScorer => 'Edit';

  @override
  String get goalSearchPlayer => 'Search player';

  @override
  String get goalClear => 'Clear';

  @override
  String goalScorerLine(String scorer) {
    return '$scorer';
  }

  @override
  String goalScorerAssistLine(String scorer, String assistant) {
    return '$scorer · assist $assistant';
  }

  @override
  String goalStatsSaved(String scorer) {
    return 'Goal published! $scorer +1 goal.';
  }

  @override
  String goalStatsSavedWithAssist(String scorer, String assistant) {
    return 'Goal published! $scorer +1 goal, $assistant +1 assist.';
  }

  @override
  String get goalStatsFailed =>
      'Goal published, but the players\' numbers could not be updated.';

  @override
  String get goalIncrease => 'Increase';

  @override
  String get goalDecrease => 'Decrease';

  @override
  String get newsAdCreated => 'Ad published!';

  @override
  String get highlightTitleLabel => 'Title';

  @override
  String get highlightLinkLabel => 'Link';

  @override
  String get highlightVisibleLabel => 'Show in carousel';

  @override
  String get highlightTitleRequired => 'Enter the highlight title.';

  @override
  String get highlightCreated => 'Highlight published!';

  @override
  String get teamsEmpty => 'No teams registered yet';

  @override
  String get teamsLoadError => 'Could not load the teams.';

  @override
  String get teamsFormTitle => 'New team';

  @override
  String get teamsNameLabel => 'Team name';

  @override
  String get teamsDescriptionLabel => 'Description (optional)';

  @override
  String get teamsCreated => 'Team created!';

  @override
  String get teamsNameRequired => 'Enter the team name (at least 3 letters).';

  @override
  String get teamsCrestAdd => 'Add crest';

  @override
  String get teamsSectionData => 'Team details';

  @override
  String get teamsDescriptionHint =>
      'E.g.: neighborhood, founding year, nickname';

  @override
  String get teamsPreview => 'Preview in the Teams tab';

  @override
  String teamsInRegion(int count) {
    return 'Teams in the region · $count';
  }

  @override
  String teamsDuplicate(String name) {
    return 'A team named \"$name\" already exists in this region.';
  }

  @override
  String get teamsSubmit => 'Create team';

  @override
  String get playersEmpty => 'No players registered yet!';

  @override
  String get playersLoadError => 'Could not load the players.';

  @override
  String playersGoalsCount(int count) {
    return 'Goals: $count';
  }

  @override
  String playersAssistsCount(int count) {
    return 'Assists: $count';
  }

  @override
  String get playersNameRequired => 'Enter the name (at least 3 letters).';

  @override
  String get playersTeamRequired => 'Choose the player\'s team.';

  @override
  String get playersFormTitle => 'New player';

  @override
  String get playersNameLabel => 'Player name';

  @override
  String get playersGoalsLabel => 'Goals';

  @override
  String get playersAssistsLabel => 'Assists';

  @override
  String get playersCreated => 'Player created!';

  @override
  String get playersPhotoAdd => 'Add photo (optional)';

  @override
  String get playersSectionData => 'Player details';

  @override
  String get playersTeam => 'Team';

  @override
  String get playersPreview => 'Squad preview';

  @override
  String playersSquadOf(String team, int count) {
    return '$team squad · $count';
  }

  @override
  String playersDuplicate(String name, String team) {
    return '\"$name\" already plays for $team.';
  }

  @override
  String get playersSubmit => 'Create player';

  @override
  String get playersPhotoBack => 'Back';

  @override
  String get playersPhotoSave => 'Save';

  @override
  String get statsEmptyGoals => 'No goals scored yet';

  @override
  String get statsEmptyAssists => 'No assists yet';

  @override
  String statsUnitGoals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'goals',
      one: 'goal',
    );
    return '$_temp0';
  }

  @override
  String statsUnitAssists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'assists',
      one: 'assist',
    );
    return '$_temp0';
  }

  @override
  String get statsGeneral => 'Overall';

  @override
  String get statsLoadError => 'Could not load the ranking.';

  @override
  String get matchesNoChampionship => 'No records at the moment';

  @override
  String get matchesEmpty => 'No matches registered';

  @override
  String get matchesLoadError => 'Could not load the matches.';

  @override
  String get matchesAllChampionships => 'All competitions';

  @override
  String get matchesChampionshipFilter => 'Competition';

  @override
  String get matchesFriendly => 'Friendly';

  @override
  String get matchesAllGames => 'All games';

  @override
  String get matchesGroups => 'Groups';

  @override
  String get matchesTopScorers => 'Top scorers';

  @override
  String get matchesAssists => 'Assists';

  @override
  String get matchesAllGamesTitle => 'All games';

  @override
  String matchesSummaryGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'games',
      one: 'game',
    );
    return '$_temp0';
  }

  @override
  String matchesSummaryGoals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'goals',
      one: 'goal',
    );
    return '$_temp0';
  }

  @override
  String get matchesSummaryAverage => 'goals per game';

  @override
  String matchesDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
    );
    return '$_temp0';
  }

  @override
  String get matchesNoDate => 'No date';

  @override
  String get matchesFilterAll => 'All';

  @override
  String get matchesEmptyForTeam => 'No matches for this team';

  @override
  String get matchesVersus => 'X';

  @override
  String get matchGoalsTitle => 'Match goals';

  @override
  String get matchGoalsAdd => 'Goal';

  @override
  String get matchGoalsNone => 'No goals.';

  @override
  String get matchGoalsNoScorer => 'Goal with no scorer';

  @override
  String get matchGoalsRemove => 'Remove goal';

  @override
  String get matchGoalsSave => 'SAVE SCORE';

  @override
  String get matchGoalsSaved => 'Score saved.';

  @override
  String get matchGoalsDiscardTitle => 'Discard the score changes?';

  @override
  String get matchGoalsDiscard => 'Discard';

  @override
  String matchGoalsAssist(String name) {
    return 'assist $name';
  }

  @override
  String get matchCardGoals => 'Goals';

  @override
  String get matchCardHideGoals => 'Hide goals';

  @override
  String get matchCardToday => 'TODAY';

  @override
  String get matchCardTomorrow => 'TOMORROW';

  @override
  String get regionPickerTitle => 'Choose a region';

  @override
  String get regionPickerSearch => 'Search region';

  @override
  String get regionPickerRecent => 'Recent';

  @override
  String get regionPickerAll => 'All regions';

  @override
  String get regionPickerChange => 'Change';

  @override
  String get regionPickerEmpty => 'No region with that name';

  @override
  String albumAdminGenerateTitle(String team) {
    return 'Generate stickers for $team';
  }

  @override
  String get albumAdminGenerateWhich =>
      'From which squad? Athletes who already have a sticker are skipped.';

  @override
  String get albumAdminGenerateAll => 'Full squad';

  @override
  String get albumAdminGenerateConfirm => 'Generate';

  @override
  String playerRequestAlreadyInChampionship(String team, String championship) {
    return 'You are already in the $team squad for $championship. You can only play for one team per competition; choose another competition.';
  }

  @override
  String get playerRequestsMergeTitle => 'Merge the records?';

  @override
  String playerRequestsMergeMessage(String current, String team, int goals,
      String claimed, String claimedTeam) {
    String _temp0 = intl.Intl.pluralLogic(
      goals,
      locale: localeName,
      other: '$goals goals',
      one: '1 goal',
    );
    return 'This account already owns the athlete $current ($team · $_temp0). Merge with $claimed ($claimedTeam)? One athlete remains, with the team and stats of each competition; the $current record is removed.';
  }

  @override
  String get playerRequestsMergeConfirm => 'Merge';

  @override
  String playerRequestsMerged(String name) {
    return 'Records merged: $name is now linked to the account.';
  }

  @override
  String get albumBadgeOpen => 'Open!';

  @override
  String get albumAdminModeOff => 'Off';

  @override
  String get albumAdminModeTest => 'Test (admin only)';

  @override
  String get albumAdminModeAll => 'Everyone';

  @override
  String get albumAdminTesting =>
      'Album in test mode: only you (admin) can see it.';

  @override
  String get albumAdminTestTag => 'TEST';

  @override
  String get albumPackTapToOpen => 'Tap or swipe to open';

  @override
  String get albumPackTapNext => 'Tap to continue';

  @override
  String get albumPackSkipAll => 'Skip';

  @override
  String albumPackCounter(int index, int total) {
    return '$index of $total';
  }

  @override
  String albumPackStickers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stickers',
      one: '1 sticker',
    );
    return '$_temp0';
  }

  @override
  String albumPackNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new',
      one: '1 new',
    );
    return '$_temp0';
  }

  @override
  String albumPackRepeatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicates',
      one: '1 duplicate',
    );
    return '$_temp0';
  }

  @override
  String albumDetailPosition(int index, int total) {
    return '$index of $total collected';
  }

  @override
  String albumDetailPage(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get albumDetailCrest => 'Crest';

  @override
  String get albumDetailAthlete => 'Athlete';

  @override
  String albumDetailYouHave(int count) {
    return 'You have ×$count';
  }

  @override
  String get albumDetailSeeAthlete => 'See athlete';

  @override
  String get albumDetailShare => 'Share';

  @override
  String albumDetailShareText(int number, String name, String event) {
    return 'I got sticker No. $number – $name in the $event album!';
  }

  @override
  String get albumPackReady => 'Your pack is here!';

  @override
  String get albumPackReadyHint => '5 free stickers, every day.';

  @override
  String get albumPackDone => 'Today\'s pack opened';

  @override
  String albumNextPackIn(String time) {
    return 'Next pack in $time';
  }

  @override
  String get albumTabTeams => 'Teams';

  @override
  String albumTabDuplicates(int count) {
    return 'Duplicates ($count)';
  }

  @override
  String get albumNoDuplicates => 'No duplicates yet.';

  @override
  String get albumCompleted => 'complete';

  @override
  String get albumStatCollected => 'collected';

  @override
  String get albumStatMissing => 'missing';

  @override
  String get albumStatDuplicates => 'duplicates';

  @override
  String get albumPageCompleteStamp => 'PAGE COMPLETE';

  @override
  String albumStickerCaption(int number, String team) {
    return 'No. $number · $team';
  }

  @override
  String get albumAdminNewEventMessage =>
      'Name the album. Then you pick the teams and generate the stickers.';

  @override
  String get albumAdminEventTitleShort => 'The name needs at least 3 letters.';

  @override
  String get albumTitle => 'Sticker album';

  @override
  String get albumNoEvent => 'No active album right now.';

  @override
  String get albumEmpty => 'The album has no stickers yet.';

  @override
  String albumProgress(int collected, int total) {
    return '$collected of $total stickers';
  }

  @override
  String albumDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicates',
      one: '1 duplicate',
    );
    return '$_temp0';
  }

  @override
  String get albumOpenPack => 'Open today\'s pack';

  @override
  String get albumComeBackTomorrow => 'New pack tomorrow';

  @override
  String get albumPackOpeningShort => 'Opening…';

  @override
  String get albumPackBadge => '1 pack!';

  @override
  String get albumPackLabel => 'Arena\npack';

  @override
  String get albumPackOpening => 'Opening the pack…';

  @override
  String albumPackResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new stickers!',
      one: '1 new sticker!',
      zero: 'Only duplicates this time!',
    );
    return '$_temp0';
  }

  @override
  String get albumPackStick => 'Stick in the album';

  @override
  String get albumPackSkip => 'Tap to see them all';

  @override
  String get albumPackFailed => 'Could not open the pack. Try again.';

  @override
  String get albumStickerNew => 'NEW!';

  @override
  String get albumStickerRepeated => 'Duplicate';

  @override
  String albumPageProgress(int collected, int total) {
    return '$collected of $total';
  }

  @override
  String get albumPageComplete => 'Complete';

  @override
  String get albumAdminTitle => 'Sticker album';

  @override
  String get albumAdminIntro =>
      'Create the event, pick the teams and generate the stickers from the squads. When on, everyone sees it with a free daily pack. One active event at a time.';

  @override
  String get albumAdminEmpty => 'No events yet.';

  @override
  String get albumAdminNewEvent => 'New event';

  @override
  String get albumAdminCreate => 'Create';

  @override
  String get albumAdminEventTitle => 'Event name';

  @override
  String get albumAdminEventTitleHint => 'E.g. Floresta Cup 2026';

  @override
  String get albumAdminEventDescription => 'Description (optional)';

  @override
  String get albumAdminEventData => 'Event';

  @override
  String albumAdminEventInfo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teams',
      one: '1 team',
      zero: 'No teams',
    );
    return '$_temp0';
  }

  @override
  String get albumAdminTeams => 'Album teams (pages)';

  @override
  String albumAdminTeamStickers(String team, int count) {
    return '$team · $count stickers';
  }

  @override
  String get albumAdminGenerate => 'Generate from squad';

  @override
  String get albumAdminAddSticker => 'New sticker';

  @override
  String albumAdminEditSticker(int number) {
    return 'Sticker $number';
  }

  @override
  String get albumAdminPhoto => 'Photo';

  @override
  String get albumAdminStickerName => 'Name on the sticker';

  @override
  String get albumAdminStickerOrder => 'Order on the page';

  @override
  String get albumAdminSaved => 'Event saved.';

  @override
  String get albumAdminActivated => 'Album on: everyone can see it now.';

  @override
  String get albumAdminDeactivated => 'Album off.';

  @override
  String get albumAdminDeleted => 'Event deleted.';

  @override
  String albumAdminGenerated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stickers created.',
      one: '1 sticker created.',
      zero: 'No new stickers (the squad is already in the album).',
    );
    return '$_temp0';
  }

  @override
  String get albumAdminStickerSaved => 'Sticker saved.';

  @override
  String get albumAdminStickerDeleted => 'Sticker deleted.';

  @override
  String albumAdminDeleteTitle(String title) {
    return 'Delete the event $title?';
  }

  @override
  String get albumAdminDeleteMessage =>
      'The event and its stickers disappear from the app. Fans\' collections are kept, but without the album.';

  @override
  String get achievementMetricAlbumStickers =>
      'Different stickers in the album';

  @override
  String get achievementMetricAlbumPages => 'Complete team pages in the album';

  @override
  String get achievementMetricAlbumComplete => 'Complete album';

  @override
  String get recompressTitle => 'Recompress images';

  @override
  String get recompressIntro =>
      'Recompresses the images uploaded before the optimization (news, highlights, crests, athletes, championships and account photos) with the current upload settings. Links keep working. It runs on the server in batches: you can close this screen.';

  @override
  String get recompressIdle => 'Not run yet.';

  @override
  String get recompressRequested => 'Request sent, starting…';

  @override
  String recompressRunning(String folder) {
    return 'Recompressing the $folder folder…';
  }

  @override
  String get recompressDone => 'Done.';

  @override
  String recompressError(String error) {
    return 'Stopped with an error: $error';
  }

  @override
  String recompressStats(int seen, int rewritten) {
    return '$seen files seen · $rewritten rewritten';
  }

  @override
  String recompressSaved(String saved, String before) {
    return '$saved MB saved (out of $before MB)';
  }

  @override
  String get recompressStart => 'Recompress';

  @override
  String get recompressAgain => 'Run again';

  @override
  String get recompressConfirmTitle => 'Recompress the old images?';

  @override
  String get recompressConfirmMessage =>
      'The server goes through Storage and rewrites the large images smaller, at the same address. It may take a few minutes.';

  @override
  String get athleteRecentMatches => 'Recent matches';

  @override
  String athleteChartTooltip(String opponent, int goals, int assists) {
    return 'Against $opponent: $goals goals, $assists assists';
  }

  @override
  String athleteAwardsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Player of the match · $count times',
      one: 'Player of the match · once',
    );
    return '$_temp0';
  }

  @override
  String get athleteAwardLabel => 'Player of the match';

  @override
  String get athleteHistory => 'History';

  @override
  String athleteHistorySeason(String season, String team) {
    return 'Season $season · $team';
  }

  @override
  String athleteHistoryStats(int goals, int assists, int awards) {
    String _temp0 = intl.Intl.pluralLogic(
      awards,
      locale: localeName,
      other: '$awards trophies',
      one: '1 trophy',
      zero: 'no trophies',
    );
    return '$goals goals · $assists assists · $_temp0';
  }

  @override
  String get athleteStatsUnassigned => 'No competition';

  @override
  String get athleteStatsUnassignedHint => 'Recorded before the competitions';

  @override
  String athleteUnassignedSummary(int goals, int assists) {
    String _temp0 = intl.Intl.pluralLogic(
      goals,
      locale: localeName,
      other: '$goals goals',
      one: '1 goal',
    );
    String _temp1 = intl.Intl.pluralLogic(
      assists,
      locale: localeName,
      other: '$assists assists',
      one: '1 assist',
    );
    return '$_temp0 and $_temp1 without a competition';
  }

  @override
  String get athleteAssign => 'Assign';

  @override
  String get athleteAssignTitle => 'Assign the numbers without a competition';

  @override
  String get athleteAssignNoEnrollment =>
      'The athlete is not enrolled in any competition. To assign to one, enroll them with the trophy in the \"Full squad\".';

  @override
  String get partnerNewsLimitTitle => 'Today\'s news limit';

  @override
  String partnerNewsLimitMessage(int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: 'You have already published today\'s $limit news.',
      one: 'You have already published today\'s news.',
    );
    return '$_temp0 Send this one for the admin to approve?';
  }

  @override
  String get partnerNewsSendForApproval => 'Send for approval';

  @override
  String get partnerNewsSentForApproval =>
      'News sent for the admin to approve.';

  @override
  String partnerUsageNews(int used, int limit) {
    return '$used of $limit news today';
  }

  @override
  String partnerLimitNews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count news per day',
      one: '1 news per day',
    );
    return '$_temp0';
  }

  @override
  String get partnerPendingNewsTitle => 'Waiting for the admin';

  @override
  String get partnerPendingNewsWaiting => 'Waiting for approval';

  @override
  String get partnerPendingNewsRejected => 'Not approved';

  @override
  String get partnerPendingNewsDeleted => 'News deleted.';

  @override
  String get partnerTabNews => 'News';

  @override
  String get partnerPanelEmptyNews => 'No news waiting for approval.';

  @override
  String get partnerNewsPublish => 'Publish';

  @override
  String get partnerNewsApproved => 'News published in the feed.';

  @override
  String get partnerNewsRejected => 'News rejected.';

  @override
  String get partnerNewsRejectTitle => 'Reject the news?';

  @override
  String get partnerNewsPerDayLabel => 'News per day (the rest go through you)';

  @override
  String get pushActionPartnerNews => 'Partner news to approve';

  @override
  String get pushActionPartnerNewsHint =>
      'To admins · a partner went over the day\'s news limit';

  @override
  String get pushActionPartnerNewsAnswer => 'Partner news answered';

  @override
  String get pushActionPartnerNewsAnswerHint =>
      'To the partner · news published or rejected';

  @override
  String get partnerClaimTitle => 'Is any of these highlights yours?';

  @override
  String get partnerClaimHint =>
      'These highlights have no owner in the app. Check yours: the admin confirms and they become yours, in your region.';

  @override
  String get partnerClaimPending => 'Link requested · waiting for the admin';

  @override
  String get partnerUnlinkedTitle => 'Highlights without an owner';

  @override
  String get partnerLinkRequested => 'Link request sent to the admin.';

  @override
  String partnerLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count highlights linked.',
      one: '1 highlight linked.',
      zero: 'No highlight linked (they already had an owner).',
    );
    return '$_temp0';
  }

  @override
  String get partnerLinksCleared => 'Link request refused.';

  @override
  String partnerLinkTitle(String name) {
    return 'Link the highlights to $name?';
  }

  @override
  String partnerLinkMessage(String region) {
    return 'They will belong to the partner, only in $region, and count toward their limit (the limit goes up if needed). Old shared links to these highlights will stop opening.';
  }

  @override
  String get partnerLinkConfirm => 'Link';

  @override
  String get partnerLinkRefuse => 'Refuse';

  @override
  String partnerClaimedList(String titles) {
    return 'Link requested: $titles';
  }

  @override
  String partnerClaimedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Link requested for $count highlights',
      one: 'Link requested for 1 highlight',
    );
    return '$_temp0';
  }

  @override
  String get partnerClaimOnApprove => 'Approving also links them.';

  @override
  String get partnerClaimActiveHint =>
      'Check that the highlights really are theirs.';

  @override
  String get partnerMenu => 'Become a partner';

  @override
  String get partnerMenuApproved => 'Partner area';

  @override
  String get partnerRequestTitle => 'Become a partner';

  @override
  String get partnerRequestIntro =>
      'Do you run a sports page, store or outlet in the region? Ask to become a partner and publish news, highlights and ads in the app.';

  @override
  String get partnerNameLabel => 'Partner name (page, store, outlet)';

  @override
  String get partnerNameRequired => 'Enter the name (at least 3 letters)';

  @override
  String get partnerContactInfo =>
      'Only the admin sees your WhatsApp, to arrange the partnership.';

  @override
  String get partnerRequestSubmit => 'Send request';

  @override
  String get partnerRequestSent => 'Request sent! The admin will review it.';

  @override
  String get partnerRequestCancelled => 'Request cancelled.';

  @override
  String get partnerPendingInfo =>
      'Your request is with the admin. You will be notified when they answer.';

  @override
  String get partnerRejectedInfo =>
      'The admin did not approve the request. You can fix it and send it again.';

  @override
  String get partnerRemovedInfo =>
      'The admin ended your partnership. You can ask again.';

  @override
  String get partnerResubmit => 'Send again';

  @override
  String get partnerEdit => 'Edit request';

  @override
  String get partnerCancel => 'Cancel request';

  @override
  String get partnerCancelTitle => 'Cancel the request?';

  @override
  String partnerCancelMessage(String name) {
    return 'The request for $name will be deleted.';
  }

  @override
  String get partnerLoadError => 'Could not load the partner requests.';

  @override
  String partnerApprovedTitle(String region) {
    return 'Partner in $region';
  }

  @override
  String get partnerCanPublish => 'You can publish';

  @override
  String get partnerNothingAllowed =>
      'The admin has not enabled any publishing for you right now.';

  @override
  String get partnerNothingAllowedShort => 'Nothing enabled';

  @override
  String partnerNewsDetail(String region) {
    return 'News in the $region feed';
  }

  @override
  String partnerLimitHighlights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count highlights',
      one: '1 highlight',
    );
    return '$_temp0';
  }

  @override
  String partnerLimitAds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ads per day',
      one: '1 ad per day',
    );
    return '$_temp0';
  }

  @override
  String partnerUsageHighlights(int used, int limit) {
    return '$used of $limit highlights in use';
  }

  @override
  String partnerUsageAds(int used, int limit) {
    return '$used of $limit ads today';
  }

  @override
  String get partnerMyHighlights => 'My highlights';

  @override
  String get partnerNoHighlights =>
      'You have not published any highlights yet.';

  @override
  String get partnerHighlightHidden => 'Hidden';

  @override
  String partnerHighlightDeleteTitle(String title) {
    return 'Delete the highlight $title?';
  }

  @override
  String get partnerHighlightDeleted => 'Highlight deleted.';

  @override
  String get partnerHighlightLimit =>
      'You are using all your highlights. Delete one to publish another.';

  @override
  String get partnerAdLimit => 'You have already published today\'s ad.';

  @override
  String get partnerPanelTitle => 'Partners';

  @override
  String get partnerTabActive => 'Active';

  @override
  String get partnerPanelEmptyPending => 'No pending partner requests.';

  @override
  String get partnerPanelEmptyActive => 'No active partners.';

  @override
  String get partnerPanelEmptyAnswered => 'No answered requests.';

  @override
  String partnerApproveTitle(String name) {
    return 'Approve $name?';
  }

  @override
  String partnerApproveMessage(String region) {
    return 'They will publish in $region: 3 news per day (the rest go through you), up to 2 highlights and 1 ad per day. You can adjust it later in Permissions.';
  }

  @override
  String partnerApproved(String name) {
    return '$name is now a partner.';
  }

  @override
  String partnerRejectTitle(String name) {
    return 'Reject $name?';
  }

  @override
  String get partnerRevoke => 'Remove partner';

  @override
  String partnerRevokeTitle(String name) {
    return 'Remove $name from the partners?';
  }

  @override
  String get partnerRevoked => 'Partnership ended.';

  @override
  String partnerRequestedBy(String name) {
    return 'Requested by $name';
  }

  @override
  String get partnerPermissions => 'Permissions';

  @override
  String get partnerPermNews => 'News';

  @override
  String get partnerPermHighlights => 'Highlights';

  @override
  String get partnerPermAds => 'Ads';

  @override
  String get partnerHighlightLimitLabel => 'Highlights at the same time';

  @override
  String get partnerAdsPerDayLabel => 'Ads per day';

  @override
  String get partnerPermissionsSaved => 'Permissions saved.';

  @override
  String standingsAutomaticLegend(String criteria) {
    return 'Updated automatically after each match. Tiebreakers: $criteria.';
  }

  @override
  String get standingsCriterionWins => 'wins';

  @override
  String get standingsCriterionGoalDifference => 'goal difference';

  @override
  String get standingsCriterionGoalsFor => 'goals scored';

  @override
  String get standingsCriterionHeadToHead => 'head-to-head';

  @override
  String get standingsCriterionFewestGoalsAgainst => 'fewest goals conceded';

  @override
  String get championshipTiebreakTitle => 'Tiebreakers';

  @override
  String get championshipTiebreakHint =>
      'After points, in this order. Drag to reorder and uncheck what doesn\'t apply.';

  @override
  String get championshipTiebreakReset => 'Use the default';

  @override
  String get championshipRecomputeTables => 'Recalculate tables';

  @override
  String get championshipRecomputeRequested =>
      'Recalculation requested: the tables update in a moment.';

  @override
  String get achievementCategoryPredictions => 'Prediction pool';

  @override
  String get achievementMetricPredictions => 'Scored predictions';

  @override
  String get achievementMetricExactPredictions => 'Exact scores';

  @override
  String get drawerPredictions => 'Prediction pool';

  @override
  String get predictionAction => 'Predict';

  @override
  String get predictionSheetTitle => 'Your prediction';

  @override
  String get predictionRules =>
      'Exact score: 10 pts · winner and margin: 7 · winner: 5';

  @override
  String get predictionDeadline => 'Open until kickoff.';

  @override
  String get predictionSave => 'Save prediction';

  @override
  String get predictionSaved => 'Prediction saved!';

  @override
  String get predictionClosed => 'Predictions closed: the match has started.';

  @override
  String get predictionLoginRequired => 'Log in to make a prediction.';

  @override
  String get predictionLogin => 'Log in';

  @override
  String get predictionSectionTitle => 'Prediction';

  @override
  String get predictionNone => 'You haven\'t predicted this match yet.';

  @override
  String get predictionMissed => 'You didn\'t predict this match.';

  @override
  String get predictionEdit => 'Change prediction';

  @override
  String get predictionLocked => 'Locked: the match has started.';

  @override
  String get predictionPending => 'Waiting for scoring.';

  @override
  String predictionPoints(int points) {
    return '+$points pts';
  }

  @override
  String get predictionExact => 'Exact score!';

  @override
  String get predictionMiss => 'No points this time.';

  @override
  String get predictionLate => 'Made after the deadline: no points.';

  @override
  String predictionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predictions for this match',
      one: '1 prediction for this match',
      zero: 'No predictions yet',
    );
    return '$_temp0';
  }

  @override
  String get predictionRankingTitle => 'Prediction pool';

  @override
  String get predictionRankingEmpty =>
      'Nobody has scored in this region yet. Predict the next matches!';

  @override
  String get predictionRankingError => 'Couldn\'t load the prediction ranking.';

  @override
  String get predictionRankingYou => 'Your position';

  @override
  String get predictionRankingNotRanked =>
      'You haven\'t scored yet. Predict the matches!';

  @override
  String predictionRankingPoints(int points) {
    return '$points pts';
  }

  @override
  String predictionRankingStats(int exact, int count) {
    return '$exact exact · $count predictions';
  }

  @override
  String get drawerFanSection => 'Fans';

  @override
  String get drawerOnFieldSection => 'On the field';

  @override
  String get pushActionAchievement => 'Achievement unlocked';

  @override
  String get pushActionAchievementHint => 'To whoever earned it · medal and XP';

  @override
  String get pushActionAlbumPack => 'Sticker pack ready';

  @override
  String get pushActionAlbumPackHint =>
      'To collectors · 24 h after their last pack';

  @override
  String get achievementUnlockedTitle => 'ACHIEVEMENT UNLOCKED!';

  @override
  String get achievementSeeAll => 'See achievements';

  @override
  String get achievementCelebrationClose => 'Continue';

  @override
  String get matchClockFirstHalf => '1ST HALF';

  @override
  String get matchClockSecondHalf => '2ND HALF';

  @override
  String get matchClockHalfTime => 'HALF TIME';

  @override
  String get matchHalfTime => 'Half time';

  @override
  String get matchStartSecondHalf => 'Start 2nd half';

  @override
  String get voteCallBadge => 'VOTE FOR THE STAR';

  @override
  String get voteCallClosedBadge => 'VOTING CLOSED';

  @override
  String get voteCallAction => 'Vote now';

  @override
  String get voteCallResult => 'See result';

  @override
  String get resultCardFullTime => 'FULL TIME';

  @override
  String get resultCardFriendly => 'Friendly';

  @override
  String get resultCardSeeMatch => 'See match';

  @override
  String get athleteStatsFriendly => 'Friendlies';

  @override
  String get athleteStatsFriendlyHint =>
      'Adjusts friendlies (counted apart, outside the overall).';

  @override
  String get athleteStatsTotalSumHint =>
      'The overall is the sum of the competitions: adjust in the competition tab.';

  @override
  String get teamPlayersFriendly => 'Friendlies';

  @override
  String get seasonsRepairTotals => 'Fix athletes\' numbers';

  @override
  String get seasonsRepairTotalsHint =>
      'Each athlete\'s overall goes back to the sum of the competitions, and friendly goals (matches without competition) are counted apart. Can run again.';

  @override
  String seasonsRepairTotalsDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count athletes fixed',
      one: '1 athlete fixed',
      zero: 'No athlete needed fixing',
    );
    return '$_temp0';
  }

  @override
  String get matchCardFinished => 'FULL TIME';

  @override
  String get achievementsAlmostThere => 'ALMOST THERE';

  @override
  String get achievementsSeeAll => 'See all';

  @override
  String get achievementsStatMedals => 'medals';

  @override
  String get achievementsStatXp => 'XP';

  @override
  String get achievementsStatStreak => 'day streak';

  @override
  String get drawerAchievements => 'My achievements';

  @override
  String get achievementsTitle => 'My achievements';

  @override
  String achievementsXp(int xp) {
    return '$xp XP';
  }

  @override
  String achievementsNextLevel(int left, String level) {
    return '$left XP to $level';
  }

  @override
  String get achievementsMaxLevel => 'Max level reached!';

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked of $total achievements';
  }

  @override
  String get achievementsRecent => 'Recent';

  @override
  String get achievementsAll => 'All';

  @override
  String get achievementsEmpty => 'No achievements here yet';

  @override
  String get achievementsSecret => 'Secret achievement';

  @override
  String get achievementsSecretHint => 'Keep using the app to find out.';

  @override
  String achievementsUnlockedOn(String date) {
    return 'Unlocked on $date';
  }

  @override
  String get achievementsUnlocked => 'Unlocked!';

  @override
  String achievementsProgress(int current, int goal) {
    return '$current of $goal';
  }

  @override
  String achievementsPoints(int points) {
    return '+$points XP';
  }

  @override
  String get achievementCategoryFan => 'Fan';

  @override
  String get achievementCategoryVoting => 'Voting';

  @override
  String get achievementCategorySharing => 'Sharing';

  @override
  String get achievementCategoryNews => 'News';

  @override
  String get achievementCategoryAthlete => 'Athlete';

  @override
  String get achievementTierBronze => 'Bronze';

  @override
  String get achievementTierSilver => 'Silver';

  @override
  String get achievementTierGold => 'Gold';

  @override
  String get achievementTierLegend => 'Legend';

  @override
  String get fanLevelFan => 'Fan';

  @override
  String get fanLevelLoyal => 'Loyal';

  @override
  String get fanLevelRoots => 'Hardcore';

  @override
  String get fanLevelUltra => 'Ultra';

  @override
  String get fanLevelLegend => 'Legend';

  @override
  String get achievementMetricVotes => 'Match votes';

  @override
  String get achievementMetricShares => 'Shares';

  @override
  String get achievementMetricNewsRead => 'News read';

  @override
  String get achievementMetricActiveDays => 'Days using the app';

  @override
  String get achievementMetricBestStreak => 'Days in a row (best streak)';

  @override
  String get achievementMetricFavoriteTeam => 'Picked a favorite team';

  @override
  String get achievementMetricCardPhoto => 'Photo on the fan card';

  @override
  String get achievementMetricAthlete => 'Account linked to an athlete';

  @override
  String get achievementMetricAthleteGoals => 'Athlete\'s goals (season)';

  @override
  String get achievementMetricAthleteAssists => 'Athlete\'s assists (season)';

  @override
  String get achievementMetricTeamOwner => 'Approved team owner';

  @override
  String get achievementsManageTitle => 'Achievements';

  @override
  String get achievementsNew => 'New achievement';

  @override
  String get achievementsEdit => 'Edit achievement';

  @override
  String get achievementsCreateSuggested => 'Create suggested achievements';

  @override
  String get achievementsSuggestedCreated => 'Suggested achievements created';

  @override
  String get achievementsManageEmpty => 'No achievements yet';

  @override
  String get achievementFieldTitle => 'Title';

  @override
  String get achievementFieldDescription => 'Description (how to earn)';

  @override
  String get achievementFieldCategory => 'Category';

  @override
  String get achievementFieldTier => 'Medal tier';

  @override
  String get achievementFieldIcon => 'Icon';

  @override
  String get achievementFieldMetric => 'What counts';

  @override
  String get achievementFieldGoal => 'Goal';

  @override
  String get achievementFieldPoints => 'Points (XP)';

  @override
  String get achievementFieldSecret => 'Secret (shows ? while locked)';

  @override
  String get achievementFieldActive => 'Active';

  @override
  String get achievementSave => 'Save achievement';

  @override
  String get achievementSaved => 'Achievement saved';

  @override
  String achievementDeleteConfirm(String title) {
    return 'Delete the achievement \"$title\"?';
  }

  @override
  String get achievementDeleted => 'Achievement deleted';

  @override
  String get achievementTitleRequired => 'Enter the title';

  @override
  String get achievementInactive => 'Inactive';

  @override
  String get achievementPreview => 'Preview';

  @override
  String get matchDetailsVotingEnded => 'Voting closed';

  @override
  String get votingNoWinnerTitle => 'No player of the match';

  @override
  String votingNoWinnerNotEnough(int min, int total) {
    return 'Minimum of $min votes not reached ($total votes).';
  }

  @override
  String votingNoWinnerNoMajority(int percent, int leader) {
    return 'Nobody reached $percent% of the votes (the leader had $leader%).';
  }

  @override
  String get votingNoWinnerTie => 'Tie for first place.';

  @override
  String votingRulesHint(int min, int percent) {
    return 'To elect the player of the match: at least $min votes and the leader with $percent% or more, ahead of second place.';
  }

  @override
  String get votingSelfBlocked => 'You can\'t vote for yourself';

  @override
  String get votingSeeResult => 'See result';

  @override
  String get votingRulesTitle => 'Voting rules';

  @override
  String get votingRulesSubtitle => 'Minimum votes and leader percentage';

  @override
  String get votingRulesMinVotes => 'Minimum votes';

  @override
  String get votingRulesMinPercent => 'Leader\'s minimum percentage';

  @override
  String get votingRulesSave => 'Save rules';

  @override
  String get votingRulesSaved => 'Voting rules saved';

  @override
  String get matchCardLive => 'LIVE';

  @override
  String get matchStart => 'Start match';

  @override
  String get matchFinish => 'End match';

  @override
  String get matchFormDuration => 'Duration';

  @override
  String matchFormDurationMinutes(int n) {
    return '$n min';
  }

  @override
  String get matchDetailsTitle => 'Match';

  @override
  String get matchDetailsFinished => 'FULL TIME';

  @override
  String get matchDetailsNoScorers => 'Goal scorers not informed';

  @override
  String get matchDetailsNotStarted => 'Kick-off hasn\'t happened yet';

  @override
  String get matchDetailsNoGoals => 'No goals';

  @override
  String get matchDetailsUnknownScorer => 'Goal';

  @override
  String get matchDetailsBestPlayer => 'Player of the match';

  @override
  String matchDetailsVotes(String count) {
    return '$count votes';
  }

  @override
  String get matchDetailsVotingOpen =>
      'Voting open: pick the star of the match';

  @override
  String get matchDetailsVotingClosed => 'Voting not open yet';

  @override
  String get matchDetailsSquads => 'Squads';

  @override
  String get matchDetailsNoSquad => 'No players registered';

  @override
  String get matchDetailsGoalCard => 'Post goal card';

  @override
  String get matchDetailsDeleted => 'This match was deleted';

  @override
  String get matchesEditScore => 'Edit Score';

  @override
  String get matchesDeleteMatch => 'Delete Match';

  @override
  String get matchesDeleteConfirm => 'DO YOU REALLY WANT TO DELETE THIS MATCH?';

  @override
  String get matchesEditScoreTitle => 'Change Score:';

  @override
  String get matchesHomeLabel => 'Home';

  @override
  String get matchesAwayLabel => 'Away';

  @override
  String get matchesFormTitle => 'New match';

  @override
  String get matchesCreated => 'Match created!';

  @override
  String get matchFormMatchup => 'Matchup';

  @override
  String get matchFormSwap => 'Swap home and away';

  @override
  String get matchFormWhen => 'When';

  @override
  String get matchFormWhere => 'Where';

  @override
  String get matchFormToday => 'Today';

  @override
  String get matchFormTomorrow => 'Tomorrow';

  @override
  String get matchFormOtherDate => 'Other date';

  @override
  String get matchFormOtherTime => 'Other time';

  @override
  String get matchFormNewVenue => 'New venue';

  @override
  String get matchFormVenueHint => 'Venue name';

  @override
  String get matchFormPreview => 'Preview';

  @override
  String get matchFormSubmit => 'Create match';

  @override
  String get matchFormMissingTeams => 'Choose both teams.';

  @override
  String get matchFormMissingDate => 'Choose the match date.';

  @override
  String get matchFormMissingTime => 'Choose the match time.';

  @override
  String matchFormConflictTeam(String team, String times) {
    return '$team already plays on this date ($times).';
  }

  @override
  String matchFormConflictVenue(String venue, String time) {
    return '$venue already has a match on this date at $time.';
  }

  @override
  String get matchFormSaved =>
      'Match created! Choose the teams for the next one.';

  @override
  String get championshipsEmpty => 'No competitions registered';

  @override
  String get championshipsLoadError => 'Could not load the competitions.';

  @override
  String get championshipsDetailsTitle => 'About the Competition:';

  @override
  String championshipsPrizes(String first, String second, String third,
      String topScorer, String goalkeeper) {
    return 'PRIZES:\n\n1st Place: $first\n2nd Place: $second\n3rd Place: $third\n\nTop Scorer: $topScorer\nBest Goalkeeper: $goalkeeper';
  }

  @override
  String championshipsRules(String rules) {
    return 'RULES:\n\n$rules';
  }

  @override
  String get championshipsGroupsButton => 'GROUPS';

  @override
  String championshipsGroupTitle(String name) {
    return 'Group $name';
  }

  @override
  String get championshipsGroupsEmpty => 'No groups registered this season.';

  @override
  String get championshipsGroupsLoadError => 'Could not load the groups.';

  @override
  String get championshipsStandingsEmpty => 'Standings not available yet.';

  @override
  String get championshipsStandingsLoadError => 'Could not load the standings.';

  @override
  String get championshipsStandingsWins => 'W';

  @override
  String get championshipsStandingsLosses => 'L';

  @override
  String get championshipsStandingsDraws => 'D';

  @override
  String get championshipsStandingsPoints => 'Pts';

  @override
  String get championshipsStandingsGoalDifference => 'GD';

  @override
  String get votingTitle => 'Best Player of the Match';

  @override
  String get votingBlankVote => 'Blank vote! Try again.';

  @override
  String get votingHint =>
      'You can change your vote anytime; only the last one counts.';

  @override
  String get votingSearchHint => 'Search player';

  @override
  String get votingChoosePlayer => 'Choose a player';

  @override
  String votingVoteFor(String name) {
    return 'Vote for $name';
  }

  @override
  String votingChangeVoteTo(String name) {
    return 'Change vote to $name';
  }

  @override
  String votingYouVotedFor(String name) {
    return 'You voted for $name';
  }

  @override
  String get votingYourVote => 'Your vote';

  @override
  String get votingGuestTitle => 'Log in to vote for the player of the match';

  @override
  String get votingGuestAction => 'Log in';

  @override
  String get votingSuccessTitle => 'Vote registered!';

  @override
  String get votingEmptySquad => 'Squad not registered';

  @override
  String get votingNoSearchResults => 'No players found';

  @override
  String get commonClose => 'Close';

  @override
  String get votingLoginRequired => 'Log in to vote.';

  @override
  String get votingElectedTitle => 'Player of the match';

  @override
  String votingMatchSubtitle(String home, String away) {
    return '$home vs $away';
  }

  @override
  String votingVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String votingShareOfVotes(int percent) {
    return '$percent% of the votes';
  }

  @override
  String get votingRankingTitle => 'Voting';

  @override
  String get votingNoVotesYet => 'Nobody has voted for this match yet';

  @override
  String votingShareText(String player, String match, String votes) {
    return '$player was voted player of the match in $match with $votes! ⚽ via Arena Football';
  }

  @override
  String get votingLoadError => 'Could not count the votes.';

  @override
  String get globalResultsTitle => 'Results around the world';

  @override
  String get globalResultsYesterday => 'Yesterday';

  @override
  String get globalResultsToday => 'Today';

  @override
  String get globalResultsTomorrow => 'Tomorrow';

  @override
  String get globalResultsSubtitle =>
      'Scores from top leagues around the world';

  @override
  String get globalResultsLive => 'Live';

  @override
  String get globalResultsHalfTime => 'Half time';

  @override
  String get globalResultsFinished => 'Finished';

  @override
  String get globalResultsPostponed => 'Postponed';

  @override
  String globalResultsLiveFilter(int count) {
    return 'Live ($count)';
  }

  @override
  String get globalResultsSearchHint => 'Search team or league';

  @override
  String get globalResultsNoMatches => 'No matches found';

  @override
  String get globalResultsPenalty => 'penalty';

  @override
  String get globalResultsOwnGoal => 'own goal';

  @override
  String get globalResultsGoalsError =>
      'Could not load the goals. Tap to try again.';

  @override
  String get loginWelcomeTitle => 'Welcome back';

  @override
  String get loginWelcomeSubtitle =>
      'Sign in to follow your team, the matches and the standings.';

  @override
  String get loginForgotPassword => 'Forgot my password';

  @override
  String get loginOr => 'or';

  @override
  String get loginWithGoogleButton => 'SIGN IN WITH GOOGLE';

  @override
  String get loginWithAppleButton => 'SIGN IN WITH APPLE';

  @override
  String get loginContinueAsGuest => 'Continue without an account';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordDescription =>
      'Enter your account e-mail and we will send you a link to create a new password.';

  @override
  String get forgotPasswordSend => 'SEND LINK';

  @override
  String get forgotPasswordSent => 'We sent a recovery link to your e-mail.';

  @override
  String get registerStepOne => 'Step 1 of 2 · your sign-in details';

  @override
  String get registerCreateAccountButton => 'CREATE ACCOUNT';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String get passwordStrengthWeak => 'Weak password';

  @override
  String get passwordStrengthMedium => 'Medium password';

  @override
  String get passwordStrengthStrong => 'Strong password';

  @override
  String get chooseTeamTitle => 'Your favorite team';

  @override
  String get chooseTeamSubtitle => 'Step 2 of 2 · personalize the app';

  @override
  String get chooseTeamDescription =>
      'Choose your region and the team you follow. You can change it later.';

  @override
  String get chooseTeamConfirm => 'FINISH';

  @override
  String get chooseTeamKeepCurrent => 'Keep my current team';

  @override
  String get chooseTeamSkip => 'Skip for now';

  @override
  String get chooseTeamLoadError => 'Could not load the regions and teams.';

  @override
  String get chooseTeamEmptyTeams => 'No teams registered in this region.';

  @override
  String get drawerNavigation => 'Navigation';

  @override
  String get adminPanelTitle => 'Admin panel';

  @override
  String get adminPanelContent => 'Content';

  @override
  String get adminPanelCompetition => 'Competition';

  @override
  String get adminPanelSettings => 'Settings';

  @override
  String get drawerClose => 'Close menu';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get drawerAdmin => 'Administration';

  @override
  String get drawerLogout => 'Sign out';

  @override
  String get drawerDeleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountMessage =>
      'We delete your login account, your profile (name, email, photo and favorite team), your votes and your player or team owner requests. If you play for a team, your goals and assists stay in the squad, no longer linked to the account. This can\'t be undone.';

  @override
  String get deleteAccountConfirmPassword => 'Enter your password to confirm.';

  @override
  String get deleteAccountConfirmGoogle =>
      'To confirm, sign in again with your Google account.';

  @override
  String get deleteAccountConfirmApple =>
      'To confirm, sign in again with your Apple account.';

  @override
  String get deleteAccountPasswordRequired => 'Enter your password.';

  @override
  String get deleteAccountButton => 'DELETE ACCOUNT';

  @override
  String get deleteAccountSuccess => 'Your account was deleted.';

  @override
  String get drawerChooseTeam => 'Choose my team';

  @override
  String get drawerSignIn => 'Sign in or create account';

  @override
  String get drawerGuestSubtitle =>
      'Sign in to save your team and vote for the best player.';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeGreetingGuest => 'Welcome to Arena';

  @override
  String homeSubtitle(String region) {
    return 'Amateur football in $region';
  }

  @override
  String get homeHighlights => 'Highlights';

  @override
  String get homeLatestNews => 'Latest news';

  @override
  String get homeTodayMatches => 'Today\'s matches';

  @override
  String homeSeasonChip(String season) {
    return 'Season $season';
  }

  @override
  String get homePublishTitle => 'Publish';

  @override
  String get homePublishNews => 'News';

  @override
  String get homePublishGoal => 'Goal';

  @override
  String get homePublishAd => 'Ad';

  @override
  String get homePublishHighlight => 'Highlight';

  @override
  String get homePublishMatch => 'Match';

  @override
  String get homePublishTeam => 'Team';

  @override
  String get homePublishPlayer => 'Player';

  @override
  String get homeOpenMenu => 'Open menu';

  @override
  String get matchesVoteAction => 'Vote for the best';

  @override
  String get matchesSeeElected => 'See elected';

  @override
  String get matchesOpenVoting => 'Open voting';

  @override
  String get matchesCloseVoting => 'Close voting';

  @override
  String get championshipsSeeDetails => 'See details';

  @override
  String get newsAdLabel => 'Ad';

  @override
  String get newsGoalLabel => 'GOAL';

  @override
  String get commonMoreActions => 'More actions';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get timeYesterday => 'yesterday';

  @override
  String get newsShare => 'Share';

  @override
  String get newsShareFooter => 'via Arena Football';

  @override
  String get newsReadMore => 'Read more';

  @override
  String get galleryClose => 'Close';

  @override
  String galleryCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playersSummaryPlayers => 'Players';

  @override
  String get playersSummaryGoals => 'Goals';

  @override
  String get playersSummaryAssists => 'Assists';

  @override
  String get playersSortGoals => 'Goals';

  @override
  String get playersSortAssists => 'Assists';

  @override
  String get enrollTeamMenu => 'Enter a competition';

  @override
  String get enrollTeamTitle => 'Team\'s competitions';

  @override
  String enrollTeamSubtitle(String team) {
    return 'Check the competitions of the season $team plays in. Players are entered one by one.';
  }

  @override
  String get enrollNoChampionships => 'No competitions this season.';

  @override
  String get enrollSaved => 'Entries saved.';

  @override
  String get enrollLoadError => 'Could not load the competitions.';

  @override
  String get enrollPlayerTitle => 'Player\'s competitions';

  @override
  String enrollPlayerSubtitle(String name, String team) {
    return 'Which competitions does $name play for $team?';
  }

  @override
  String enrollPlayerOtherTeam(String team) {
    return 'Plays for $team in this competition';
  }

  @override
  String enrollPlayerSaved(String name) {
    return '$name\'s entries saved.';
  }

  @override
  String get playersGeneralSquad => 'Full squad';

  @override
  String get playersEmptyChampionship =>
      'No players from this team in this competition.';

  @override
  String get playersSortName => 'A–Z';

  @override
  String get playersSearchHint => 'Search player';

  @override
  String get playersNoResults => 'No players found.';

  @override
  String get playersTopScorer => 'Team top scorer';

  @override
  String get playersChangePhoto => 'Change photo';

  @override
  String get playersEditName => 'Edit name';

  @override
  String get playersSaveName => 'Save name';

  @override
  String get commonClear => 'Clear';

  @override
  String get groupsTitle => 'Groups';

  @override
  String groupsSubtitle(String region, String season) {
    return '$region · Season $season';
  }

  @override
  String get groupsSeeStandings => 'See standings';

  @override
  String get standingsColPosition => '#';

  @override
  String get standingsColTeam => 'Team';

  @override
  String get standingsColGames => 'G';

  @override
  String get standingsQualifiedLegend => 'Qualified for the next stage';

  @override
  String get standingsGoalsFor => 'Goals for';

  @override
  String get standingsGoalsAgainst => 'Goals against';

  @override
  String get standingsPerformance => 'Performance';

  @override
  String get standingsYourTeam => 'Your team';

  @override
  String get athletePlaysFor => 'Plays for';

  @override
  String athleteChampionshipFallback(int id) {
    return 'Competition $id';
  }

  @override
  String athleteEnrollmentStats(int goals, int assists) {
    return '$goals G · $assists A';
  }

  @override
  String get athleteStatsTotal => 'Total';

  @override
  String get athleteStatsTotalHint =>
      'Adjusts only the total (numbers from before competitions).';

  @override
  String get athleteStatsChampionshipHint =>
      'Adjusts the competition; the total follows.';

  @override
  String get athleteTitle => 'Athlete';

  @override
  String get athleteScored => 'Scored';

  @override
  String get athleteAssisted => 'Assisted';

  @override
  String athleteRankGoals(int position) {
    return '#$position top scorer';
  }

  @override
  String athleteRankAssists(int position) {
    return '#$position in assists';
  }

  @override
  String get athleteNoRank => 'Not ranked';

  @override
  String get athleteParticipations => 'Goal involvements';

  @override
  String get athleteNoParticipations => 'No goals registered in the feed yet.';

  @override
  String get athleteNotFound => 'Player not found.';

  @override
  String get athleteLoadError => 'Could not load the player.';

  @override
  String get athleteEdit => 'Edit (admin)';

  @override
  String get athleteShare => 'Share';

  @override
  String athleteShareText(String name, String team, int goals, int assists) {
    return '$name ($team): $goals goals and $assists assists · via Arena Football';
  }

  @override
  String athleteSeason(String season) {
    return 'Season $season';
  }

  @override
  String get adCreateTitle => 'New ad';

  @override
  String get adEditTitle => 'Edit ad';

  @override
  String get adPublish => 'Publish ad';

  @override
  String get adUpdated => 'Ad updated!';

  @override
  String get adBannerAdd => 'Add banner';

  @override
  String get adBannerHint =>
      'Use a 2:1 horizontal image (e.g. 1200×600). This is how it shows in the feed.';

  @override
  String get adSectionAd => 'Ad';

  @override
  String get adNameLabel => 'Advertiser (optional)';

  @override
  String get adNameHint => 'Only for you to identify the ad';

  @override
  String get adLinkHint => 'Advertiser\'s website, Instagram or WhatsApp';

  @override
  String get adLinkInvalid => 'Invalid link. E.g. https://store.com';

  @override
  String get adTestLink => 'Test';

  @override
  String get adImageRequired => 'Choose the ad image.';

  @override
  String get highlightCreateTitle => 'New highlight';

  @override
  String get highlightPhotoAdd => 'Add photo';

  @override
  String get highlightPhotoHint =>
      'Shown in the carousel circle. A square image works best.';

  @override
  String get highlightPreview => 'Carousel preview';

  @override
  String get highlightSection => 'Highlight';

  @override
  String get highlightTitleHint =>
      'News tagged with this highlight show up in it';

  @override
  String get highlightTitleTooShort => 'Use at least 3 letters.';

  @override
  String get highlightDuplicate => 'A highlight with this name already exists.';

  @override
  String get highlightVisibleOnHint =>
      'Shown at the top of the home for everyone.';

  @override
  String get highlightVisibleHint => 'Hidden until you turn it on.';

  @override
  String get highlightPublish => 'Publish highlight';

  @override
  String highlightNewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count news',
      one: '1 news',
      zero: 'No news',
    );
    return '$_temp0';
  }

  @override
  String get highlightOpenLink => 'Open link';

  @override
  String get highlightEmpty => 'No news in this highlight yet.';

  @override
  String get highlightLoadError => 'Could not load the news.';

  @override
  String get highlightAddNews => 'News';

  @override
  String highlightShareText(String title) {
    return '$title · Arena Football';
  }

  @override
  String get highlightsManageTitle => 'Highlights';

  @override
  String get highlightsReorderHint =>
      'Drag by the handle to set the carousel order.';

  @override
  String get highlightsEmpty => 'No highlights yet. Tap + to create one.';

  @override
  String get highlightHidden => 'Hidden';

  @override
  String get highlightView => 'View';

  @override
  String get highlightEditTitle => 'Edit highlight';

  @override
  String get highlightUpdated => 'Highlight updated!';

  @override
  String highlightRenameHint(String old) {
    return 'News tagged \"$old\" move to the new name.';
  }

  @override
  String highlightDeleteTitle(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get highlightDeleteMessage =>
      'Tagged news stay in the feed, they just lose this highlight.';

  @override
  String highlightDeleted(String title) {
    return '\"$title\" deleted.';
  }

  @override
  String get pushPanelTitle => 'Notifications';

  @override
  String get pushTabActions => 'Actions';

  @override
  String get pushTabHistory => 'History';

  @override
  String get pushTabSend => 'Send notice';

  @override
  String get pushActionsIntro =>
      'Choose which actions send a push. Users get the ones from the region chosen in the app; games also reach the fans of both teams.';

  @override
  String get pushActionGoal => 'Goal';

  @override
  String get pushActionGoalHint =>
      'Goal card published · \"⚽ GOAL! Lava Jato 2 × 1 Volta\"';

  @override
  String get pushActionNews => 'News published';

  @override
  String get pushActionNewsHint =>
      'News visible in the feed (no ads) · news title';

  @override
  String get pushActionMatch => 'New match';

  @override
  String get pushActionMatchHint => 'Match registered · date, time and place';

  @override
  String get pushActionVotingOpen => 'Voting open';

  @override
  String get pushActionVotingOpenHint => 'Best player voting opened';

  @override
  String get pushActionVotingClosed => 'Voting closed';

  @override
  String get pushActionVotingClosedHint =>
      'Voting closed · invites to see the winner';

  @override
  String get pushActionDailyGame => 'Your team plays today';

  @override
  String get pushActionDailyGameHint =>
      'Every day at 9am, to fans of teams playing today';

  @override
  String get pushActionNotice => 'Manual notice';

  @override
  String get pushActionNoticeHint =>
      'Notices sent from the \"Send notice\" tab';

  @override
  String get pushHistoryEmpty => 'No notifications sent yet.';

  @override
  String get pushStatusSent => 'Sent';

  @override
  String get pushStatusDisabled => 'Disabled';

  @override
  String get pushStatusError => 'Error';

  @override
  String get pushAllRegions => 'All regions';

  @override
  String get pushAudienceTeams => 'Teams\' fans';

  @override
  String get pushNoticeSection => 'Notice';

  @override
  String get pushNoticeTitle => 'Title';

  @override
  String get pushNoticeBody => 'Message';

  @override
  String get pushNoticeAudience => 'Audience';

  @override
  String get pushNoticePreview => 'Preview';

  @override
  String get pushNoticeHint =>
      'Sending takes a few seconds and shows up in History.';

  @override
  String get pushSend => 'Send';

  @override
  String get pushSendConfirmTitle => 'Send notification?';

  @override
  String pushSendConfirmMessage(String audience) {
    return 'Every user in \"$audience\" will get this notice now.';
  }

  @override
  String get pushSent => 'Notice sent!';

  @override
  String get playerRequestMenu => 'I\'m a player';

  @override
  String get playerRequestTitle => 'I\'m a player';

  @override
  String get playerRequestClaimTitle => 'Already on the squad?';

  @override
  String get playerRequestClaimHint =>
      'These team players don\'t have an account yet. If one of them is you, tap it to request the link and keep your stats.';

  @override
  String get playerRequestClaimNotListed =>
      'Not on the list? Fill in below as a new player.';

  @override
  String playerRequestClaimSelected(String name) {
    return 'You will request the link with player $name.';
  }

  @override
  String playerRequestClaimStatus(String name) {
    return 'Link request with player $name';
  }

  @override
  String playerRequestsClaimBadge(String name, int goals) {
    return 'Says they are $name · $goals goals';
  }

  @override
  String playerRequestsApproveClaimMessage(String name) {
    return 'The account will be linked to player $name, keeping their goals and assists.';
  }

  @override
  String get playerRequestClaimPlaceholder =>
      'I\'m one of these players (optional)';

  @override
  String get playerRequestClaimSearch => 'Search by name';

  @override
  String get playerRequestClaimNoResults => 'No player with that name';

  @override
  String playerRequestClaimGoals(int goals) {
    return '$goals goals';
  }

  @override
  String get playerRequestChampionshipLabel => 'Competition';

  @override
  String get playerRequestChampionshipRequired =>
      'Choose the competition you play in for this team.';

  @override
  String get playerRequestAnotherChampionship => 'Play in another competition';

  @override
  String get playerRequestIntro =>
      'Play for a team in your region: send a request and an admin will review it.';

  @override
  String get playerRequestTeamRequired => 'Choose the team you play for.';

  @override
  String get playerRequestNameLabel => 'Player name';

  @override
  String get playerRequestPositionLabel => 'Position';

  @override
  String get playerRequestPositionRequired => 'Choose your position.';

  @override
  String get playerRequestMessageLabel => 'Message to the admin (optional)';

  @override
  String get playerRequestMessageHint =>
      'E.g.: I\'ve played full-back for the team since 2022';

  @override
  String get playerRequestSubmit => 'SEND REQUEST';

  @override
  String get playerRequestResubmit => 'Send a new request';

  @override
  String get playerRequestSent =>
      'Request sent! You\'ll be notified when an admin replies.';

  @override
  String get playerRequestCancelled => 'Request cancelled.';

  @override
  String get playerRequestStatusPending => 'Awaiting approval';

  @override
  String get playerRequestStatusApproved => 'Approved';

  @override
  String get playerRequestStatusRejected => 'Rejected';

  @override
  String get playerRequestPendingInfo =>
      'An admin will review your request. Meanwhile, you can still edit it.';

  @override
  String playerRequestApprovedInfo(String team) {
    return 'You play for $team!';
  }

  @override
  String get playerRequestRejectedInfo =>
      'Your request wasn\'t approved. You can send a new one.';

  @override
  String playerRequestReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String playerRequestSentOn(String date) {
    return 'Sent on $date';
  }

  @override
  String get playerRequestEdit => 'Edit request';

  @override
  String get playerRequestCancel => 'Cancel request';

  @override
  String get playerRequestCancelTitle => 'Cancel request?';

  @override
  String playerRequestCancelMessage(String team) {
    return 'Your request to join $team will be deleted.';
  }

  @override
  String get playerRequestKeep => 'Keep';

  @override
  String get playerRequestDiscardEdit => 'Discard changes';

  @override
  String get playerRequestViewProfile => 'View my player profile';

  @override
  String get playerRequestLoadError => 'Couldn\'t load your request.';

  @override
  String get playerPositionGoalkeeper => 'Goalkeeper';

  @override
  String get playerPositionDefender => 'Defender';

  @override
  String get playerPositionFullBack => 'Full-back';

  @override
  String get playerPositionDefensiveMidfielder => 'Defensive midfielder';

  @override
  String get playerPositionMidfielder => 'Midfielder';

  @override
  String get playerPositionForward => 'Forward';

  @override
  String get playerRequestsPanelTitle => 'Player requests';

  @override
  String get playerRequestsTabPending => 'Pending';

  @override
  String get playerRequestsTabAnswered => 'Answered';

  @override
  String get playerRequestsEmptyPending => 'No pending requests.';

  @override
  String get playerRequestsEmptyAnswered => 'No answered requests yet.';

  @override
  String get playerRequestsLoadError => 'Couldn\'t load the requests.';

  @override
  String get playerRequestsApprove => 'Approve';

  @override
  String get playerRequestsReject => 'Reject';

  @override
  String playerRequestsApproveTitle(String name) {
    return 'Approve $name?';
  }

  @override
  String playerRequestsApproveMessage(String name, String team) {
    return '$name joins the $team squad.';
  }

  @override
  String playerRequestsRejectTitle(String name) {
    return 'Reject $name\'s request?';
  }

  @override
  String get playerRequestsRejectReason => 'Reason (optional)';

  @override
  String playerRequestsApproved(String name, String team) {
    return '$name now plays for $team.';
  }

  @override
  String get playerRequestsRejected => 'Request rejected.';

  @override
  String get playerRequestsUpdated => 'Request updated.';

  @override
  String playerRequestsAccount(String name) {
    return 'Account: $name';
  }

  @override
  String get pushActionPlayerRequest => 'New player request';

  @override
  String get pushActionPlayerRequestHint =>
      'To admins · \"John wants to play for Lava Jato\"';

  @override
  String get pushActionPlayerRequestAnswer => 'Request answered';

  @override
  String get pushActionPlayerRequestAnswerHint =>
      'To the requester · approved or rejected';

  @override
  String get athleteDelete => 'Delete player';

  @override
  String athleteDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String athleteDeleteMessage(String name, String team) {
    return '$name leaves the $team squad. Their goals and assists no longer count in the rankings. This can’t be undone.';
  }

  @override
  String athleteDeleted(String name, String team) {
    return '$name was removed from $team.';
  }

  @override
  String get athleteRemoveFromSquad => 'Remove from squad';

  @override
  String athleteRemoveTitle(String name) {
    return 'Remove $name from the squad?';
  }

  @override
  String athleteRemoveMessage(String name, String team) {
    return '$name leaves the $team squad. Their goals and assists stay on their account, and they can ask to join another team.';
  }

  @override
  String athleteRemoved(String name, String team) {
    return '$name left the $team squad.';
  }

  @override
  String get playerRequestStatusRemoved => 'Out of the squad';

  @override
  String playerRequestRemovedInfo(String team) {
    return 'You left the $team squad. Your stats are kept and you can ask to join another team.';
  }

  @override
  String get playerRequestJoinAnother => 'Ask to join another team';

  @override
  String get matchesYesterday => 'Yesterday';

  @override
  String get matchesToday => 'Today';

  @override
  String get matchesTomorrow => 'Tomorrow';

  @override
  String get matchesYesterdayTitle => 'Yesterday\'s games';

  @override
  String get matchesTomorrowTitle => 'Tomorrow\'s games';

  @override
  String get matchesNoGamesYesterday => 'No games yesterday';

  @override
  String get matchesNoGamesToday => 'No games today';

  @override
  String get matchesNoGamesTomorrow => 'No games tomorrow';

  @override
  String get championshipsManageTitle => 'Championships';

  @override
  String get championshipsManageEmpty => 'No championships in this region yet.';

  @override
  String championshipsManageTeamsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teams',
      one: '1 team',
      zero: 'No teams',
    );
    return '$_temp0';
  }

  @override
  String championshipsManageDeleteTitle(String title) {
    return 'Delete $title?';
  }

  @override
  String get championshipsManageDeleteMessage =>
      'The championship leaves the list. Matches, groups and standings are kept.';

  @override
  String get championshipsManageDeleted => 'Championship deleted.';

  @override
  String championshipsSeasonLabel(String region, String season) {
    return '$region · $season season';
  }

  @override
  String get championshipFormNewTitle => 'New championship';

  @override
  String get championshipFormEditTitle => 'Edit championship';

  @override
  String get championshipFormSectionData => 'Details';

  @override
  String get championshipFormTitleLabel => 'Championship name';

  @override
  String get championshipFormTitleRequired =>
      'Enter the name (at least 3 letters).';

  @override
  String get championshipFormDescriptionLabel => 'Description (optional)';

  @override
  String get championshipFormSeasonLabel => 'Season';

  @override
  String get championshipScopeMunicipal => 'Municipal';

  @override
  String get championshipScopeIntermunicipal => 'Intermunicipal';

  @override
  String championshipScopeMunicipalHint(String region) {
    return 'Only teams from $region.';
  }

  @override
  String get championshipScopeIntermunicipalHint =>
      'Teams from any region. The championship shows up in every team\'s region.';

  @override
  String championshipScopeRemoved(int count, String region) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teams from outside $region were unselected.',
      one: '1 team from outside $region was unselected.',
    );
    return '$_temp0';
  }

  @override
  String championshipScopeOutsideError(String region) {
    return 'A municipal championship only accepts teams from $region.';
  }

  @override
  String get championshipScopeNoRegion => 'No region';

  @override
  String get championshipFormSectionTeams => 'Participating teams';

  @override
  String get championshipFormTeamsAll => 'All';

  @override
  String get championshipFormTeamsClear => 'Clear';

  @override
  String get championshipFormTeamsRequired => 'Choose at least one team.';

  @override
  String get championshipFormTeamsEmpty => 'No teams in this region yet.';

  @override
  String championshipFormTeamsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: 'None selected',
    );
    return '$_temp0';
  }

  @override
  String get championshipFormSectionRules => 'Rules';

  @override
  String get championshipFormRulesHint =>
      'Attach the rules as a PDF: users open it on the championship page.';

  @override
  String get championshipFormRulesAttach => 'Attach PDF';

  @override
  String get championshipFormRulesReplace => 'Replace';

  @override
  String get championshipFormRulesRemove => 'Remove';

  @override
  String get championshipFormRulesTooBig => 'The PDF is larger than 10 MB.';

  @override
  String get championshipFormRulesSummary => 'Rules summary (optional)';

  @override
  String get championshipFormSectionPrizes => 'Prizes';

  @override
  String get championshipFormPrize1 => '1st place';

  @override
  String get championshipFormPrize2 => '2nd place';

  @override
  String get championshipFormPrize3 => '3rd place';

  @override
  String get championshipFormPrizeTopScorer => 'Top scorer';

  @override
  String get championshipFormPrizeGoalkeeper => 'Best goalkeeper';

  @override
  String get championshipFormSubmitCreate => 'CREATE CHAMPIONSHIP';

  @override
  String get championshipFormCreated => 'Championship created!';

  @override
  String get championshipFormSaved => 'Championship updated!';

  @override
  String get championshipFormLoadError => 'Couldn\'t load regions and teams.';

  @override
  String get championshipRulesOpen => 'Open rules';

  @override
  String get championshipRulesOpenError => 'Couldn\'t open the rules.';

  @override
  String get homePublishChampionship => 'Championship';

  @override
  String get championshipsCurrentBadge => 'IN PROGRESS';

  @override
  String get championshipsPrevious => 'Previous';

  @override
  String get championshipTabOverview => 'Overview';

  @override
  String get championshipTabTeams => 'Teams';

  @override
  String get championshipTabRules => 'Rules';

  @override
  String get championshipRulesEmpty => 'Rules not published yet';

  @override
  String get championshipTeamsEmpty => 'Teams not defined yet';

  @override
  String get championshipGroupsAndStandings => 'Groups and standings';

  @override
  String championshipSeasonShort(String season) {
    return '$season season';
  }

  @override
  String get championshipOverviewEmpty =>
      'Prizes and details not published yet';

  @override
  String get championshipAbout => 'About';

  @override
  String get seasonsPanelTitle => 'Seasons';

  @override
  String get seasonsCurrentLabel => 'Current season';

  @override
  String get seasonsCurrentInfo =>
      'New teams, matches, players and championships are saved to this season.';

  @override
  String get seasonsAvailable => 'Available seasons';

  @override
  String get seasonsCurrentTag => 'Current';

  @override
  String seasonsStartTitle(String season) {
    return 'Start $season season';
  }

  @override
  String seasonsStartInfo(String current) {
    return 'The $current season stays available in the season picker. Nothing is deleted.';
  }

  @override
  String get seasonsCopyTeams => 'Copy the current season\'s teams';

  @override
  String get seasonsCopyTeamsHint =>
      'Teams join the new season with zeroed standings. Squads start empty.';

  @override
  String seasonsStartButton(String season) {
    return 'START $season SEASON';
  }

  @override
  String seasonsConfirmTitle(String season) {
    return 'Start the $season season?';
  }

  @override
  String seasonsConfirmMessage(String season) {
    return 'Every user will see $season as the current season and new records go to it. This can\'t be undone in the app.';
  }

  @override
  String get seasonsConfirmAction => 'Start';

  @override
  String seasonsStarted(String season) {
    return '$season season started!';
  }

  @override
  String get matchFormNoChampionship => 'No championship (friendly)';

  @override
  String get matchFormNoChampionshipHint =>
      'No championship in this region this season; add one in Admin panel → Championships.';

  @override
  String get matchFormPickChampionship => 'Match championship';

  @override
  String get matchFormChampionshipSearch => 'Search championship';

  @override
  String get matchFormChampionshipNoResults => 'No championship with that name';

  @override
  String get matchFormChampionship => 'Championship';

  @override
  String get teamRequestMenu => 'I own a team';

  @override
  String get teamRequestTitle => 'I own a team';

  @override
  String get teamRequestIntro =>
      'Register your team: an admin reviews it and, once approved, you manage the squad.';

  @override
  String get teamRequestNameLabel => 'Team name';

  @override
  String get teamRequestNameRequired =>
      'Enter the team name (at least 3 letters).';

  @override
  String teamRequestNameTaken(String name) {
    return 'There\'s already a team called $name in this region.';
  }

  @override
  String get teamRequestCrestAdd => 'Add crest (optional)';

  @override
  String get teamRequestDescriptionLabel => 'Description / history (optional)';

  @override
  String get teamRequestContactLabel => 'Owner\'s WhatsApp';

  @override
  String get teamRequestContactHint => '(89) 99999-9999';

  @override
  String get teamRequestContactRequired =>
      'Enter a WhatsApp number with area code.';

  @override
  String get teamRequestContactInfo => 'Only the admin sees your contact.';

  @override
  String get teamRequestSubmit => 'SEND REQUEST';

  @override
  String get teamRequestSent =>
      'Request sent! You\'ll be notified when an admin replies.';

  @override
  String get teamRequestCancelled => 'Request cancelled.';

  @override
  String get teamRequestPendingInfo =>
      'An admin will review your team. Meanwhile, you can still edit it.';

  @override
  String get teamRequestRejectedInfo =>
      'Your request wasn\'t approved. You can send a new one.';

  @override
  String get teamRequestEdit => 'Edit request';

  @override
  String get teamRequestCancel => 'Cancel request';

  @override
  String get teamRequestCancelTitle => 'Cancel request?';

  @override
  String teamRequestCancelMessage(String team) {
    return 'The request for $team will be deleted.';
  }

  @override
  String get teamRequestResubmit => 'Send a new request';

  @override
  String get teamRequestLoadError => 'Couldn\'t load your request.';

  @override
  String get myTeamTitle => 'My team';

  @override
  String get myTeamOwnerBadge => 'You\'re the owner';

  @override
  String get myTeamTabSquad => 'Squad';

  @override
  String get myTeamTabRequests => 'Requests';

  @override
  String get myTeamTabEdit => 'Edit';

  @override
  String get myTeamAddPlayer => 'Add player';

  @override
  String get myTeamSquadEmpty => 'No players in the squad yet.';

  @override
  String get myTeamRequestsEmpty => 'No requests to join the team.';

  @override
  String myTeamPlayerAdded(String name) {
    return '$name joined the squad.';
  }

  @override
  String get myTeamSaved => 'Team updated!';

  @override
  String get myTeamNameLocked => 'To rename the team, contact the admin.';

  @override
  String get myTeamLoadError => 'Couldn\'t load your team.';

  @override
  String get teamRequestsPanelTitle => 'Team requests';

  @override
  String get teamRequestsEmptyPending => 'No pending team requests.';

  @override
  String get teamRequestsEmptyAnswered => 'No answered team requests yet.';

  @override
  String get teamRequestsLoadError => 'Couldn\'t load the team requests.';

  @override
  String teamRequestsApproveTitle(String name) {
    return 'Approve $name?';
  }

  @override
  String teamRequestsApproveMessage(String region, String owner) {
    return 'The team joins $region in the current season, with $owner as owner.';
  }

  @override
  String teamRequestsApproved(String name) {
    return 'Team $name created!';
  }

  @override
  String teamRequestsRejectTitle(String name) {
    return 'Reject $name?';
  }

  @override
  String teamRequestsOwner(String name) {
    return 'Owner: $name';
  }

  @override
  String get teamRequestsWhatsApp => 'Message on WhatsApp';

  @override
  String get teamRequestsWhatsAppError => 'Couldn\'t open WhatsApp.';

  @override
  String get pushActionTeamRequest => 'New team request';

  @override
  String get pushActionTeamRequestHint =>
      'To admins · \"John wants to register team X\"';

  @override
  String get pushActionTeamRequestAnswer => 'Team request answered';

  @override
  String get pushActionTeamRequestAnswerHint =>
      'To the requester · approved or rejected';

  @override
  String get pushActionPartnerRequest => 'New partner request';

  @override
  String get pushActionPartnerRequestHint =>
      'To admins · \"John wants to be a partner: Store X\"';

  @override
  String get pushActionPartnerRequestAnswer => 'Partner request answered';

  @override
  String get pushActionPartnerRequestAnswerHint =>
      'To the requester · approved, rejected or partnership ended';

  @override
  String get teamDelete => 'Delete team';

  @override
  String teamDeleteTitle(String team) {
    return 'Delete $team?';
  }

  @override
  String teamDeleteMessage(String season) {
    return 'The team leaves the $season season. Players with an app account become free agents and keep their stats; the other squad players are deleted. Matches already registered stay in the history. This can\'t be undone.';
  }

  @override
  String teamDeleted(String team) {
    return '$team was deleted.';
  }

  @override
  String drawerPlayerOf(String team) {
    return 'Plays for $team';
  }

  @override
  String drawerOwnerOf(String team) {
    return 'Owner/coach of $team';
  }

  @override
  String get drawerMyPlayerProfile => 'My player profile';

  @override
  String get teamColorsSection => 'Team colors';

  @override
  String get teamColorPrimary => 'Primary color';

  @override
  String get teamColorSecondary => 'Secondary color';

  @override
  String get teamColorNone => 'No color';

  @override
  String get teamColorPreview => 'This is how the kit looks';

  @override
  String get colorWhite => 'White';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorGrey => 'Grey';

  @override
  String get colorRed => 'Red';

  @override
  String get colorWine => 'Wine';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorNavy => 'Navy';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorPink => 'Pink';

  @override
  String get fanCardMenu => 'My fan card';

  @override
  String get fanCardTitle => 'Fan card';

  @override
  String get fanCardLabel => 'FAN CARD';

  @override
  String fanCardFanOf(String team) {
    return 'Supports $team';
  }

  @override
  String get fanCardNoTeam => 'No favorite team';

  @override
  String fanCardSince(String year) {
    return 'Fan since $year';
  }

  @override
  String fanCardNumber(String number) {
    return 'No. $number';
  }

  @override
  String get fanCardChangePhoto => 'Change photo';

  @override
  String get fanCardAddPhoto => 'Add photo';

  @override
  String get fanCardPhotoSaved => 'Photo updated!';

  @override
  String get fanCardHint => 'Show your fan card at your team\'s games.';

  @override
  String get fanCardShare => 'SHARE FAN CARD';

  @override
  String get fanCardShareTitle => 'Share fan card';

  @override
  String get shareInstagramStories => 'Instagram Stories';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareMoreOptions => 'More options';

  @override
  String fanCardShareText(String team) {
    return 'I support $team on Arena Football! ⚽';
  }

  @override
  String get fanCardShareTextNoTeam => 'My fan card on Arena Football! ⚽';

  @override
  String get fanCardChangeTeam => 'Change team';

  @override
  String fanCardChangeTeamNextAt(String date) {
    return 'Next team change available from $date';
  }

  @override
  String get teamChangeLockedTitle => 'Team change locked';

  @override
  String teamChangeLockedMessage(String date) {
    return 'You can only change teams once every 15 days. Your next change unlocks on $date.';
  }

  @override
  String get teamChangeLockedMessageNoDate =>
      'You can only change teams once every 15 days. Please try again later.';

  @override
  String chooseTeamConfirmChangeTitle(String team) {
    return 'Switch to $team?';
  }

  @override
  String get chooseTeamConfirmChangeMessage =>
      'After switching, your next team change unlocks in 15 days.';

  @override
  String get chooseTeamConfirmChange => 'Switch';

  @override
  String get shareFooter => 'Arena Football · amateur football in your region';

  @override
  String get athleteShareTitle => 'Share athlete';

  @override
  String get athleteCardLabel => 'ATHLETE';

  @override
  String athleteCardSeason(String season) {
    return '$season season';
  }

  @override
  String athleteCardParticipations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goal involvements',
      one: '1 goal involvement',
      zero: 'No goal involvements',
    );
    return '$_temp0';
  }

  @override
  String get teamEdit => 'Edit team';

  @override
  String get teamEditTitle => 'Edit team';

  @override
  String get teamEditSaved => 'Team updated.';

  @override
  String get teamEditRegionLabel => 'Region';

  @override
  String get teamEditRegionChangeTitle => 'Change the region?';

  @override
  String teamEditRegionChangeMessage(String team, String region) {
    return '$team will show up in the Teams tab and standings of $region. Groups from the old region don\'t change.';
  }

  @override
  String get teamEditNameLocked =>
      'The team name can\'t be changed (it\'s used in matches, squad and voting).';

  @override
  String get votingShareTitle => 'Share player of the match';

  @override
  String get votingCardLabel => 'PLAYER OF THE MATCH';

  @override
  String get votingCardTopVotes => 'Most voted';

  @override
  String get votingCardSeasonStats => 'This season';

  @override
  String get teamLinksTitle => 'Link teams by id';

  @override
  String get teamLinksInfo =>
      'Saves the team id next to the name in the season\'s players, matches, groups, championships, \"I\'m a player\" requests and goal cards (in the current season, also in users\' favorite team) and copies old votes into the matches. Only fills what is missing: safe to run again.';

  @override
  String teamLinksRun(String season) {
    return 'Link $season';
  }

  @override
  String teamLinksDone(String season, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents updated',
      one: '1 document updated',
      zero: 'nothing to update',
    );
    return '$season: $_temp0';
  }

  @override
  String teamLinksVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes copied to the matches',
      one: '1 vote copied to the match',
    );
    return '$_temp0';
  }

  @override
  String get teamLinksUnmatched =>
      'Names with no team in the season (not linked):';

  @override
  String get teamLinksAmbiguous =>
      'Names used by more than one team (not linked):';

  @override
  String get teamLinksSkippedVotes =>
      'Votes not copied (same fixture repeated in the season):';

  @override
  String get teamLinksPlayers => 'Players';

  @override
  String get teamLinksMatches => 'Matches';

  @override
  String get teamLinksGroups => 'Groups';

  @override
  String get teamLinksChampionships => 'Championships';

  @override
  String get teamLinksPlayerRequests => '\"I\'m a player\" requests';

  @override
  String get teamLinksGoalCards => 'Goal cards';

  @override
  String get teamLinksUsers => 'Favorite team';

  @override
  String get regionsManageTitle => 'Regions';

  @override
  String regionsTeamsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teams this season',
      one: '1 team this season',
      zero: 'No teams this season',
    );
    return '$_temp0';
  }

  @override
  String get regionsCreate => 'New region';

  @override
  String get regionsNameLabel => 'Region name';

  @override
  String get regionsNameHint =>
      'The region shows up for everyone right away, on the home and in the forms.';

  @override
  String regionsCreated(String name) {
    return 'Region \"$name\" created!';
  }

  @override
  String get regionsDuplicate => 'A region with this name already exists.';

  @override
  String get regionsNameTooShort => 'Use at least 3 letters.';

  @override
  String get regionsEmpty => 'No regions yet. Tap + to create one.';

  @override
  String get regionsLoadError => 'Could not load the regions.';

  @override
  String get commonOk => 'Ok';

  @override
  String get regionsRename => 'Rename';

  @override
  String get regionsRenameTitle => 'Rename region';

  @override
  String get regionsRenameHint =>
      'Teams, matches, news and championships stay in the region and show the new name.';

  @override
  String regionsRenamed(String previous, String name) {
    return '\"$previous\" is now \"$name\".';
  }

  @override
  String regionsDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get regionsDeleteMessage =>
      'The region is empty and leaves the list for everyone.';

  @override
  String regionsDeleted(String name) {
    return 'Region \"$name\" deleted.';
  }

  @override
  String get regionsDeleteBlockedTitle => 'Region in use';

  @override
  String regionsDeleteBlockedMessage(String name, String usage) {
    return '\"$name\" still has $usage. Only an empty region can be deleted; to change its name, use \"Rename\".';
  }

  @override
  String get regionsLastRegion =>
      'This is the only region: it cannot be deleted.';

  @override
  String regionsUsageTeams(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teams',
      one: '1 team',
    );
    return '$_temp0';
  }

  @override
  String regionsUsageMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String regionsUsageNews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count news',
      one: '1 news',
    );
    return '$_temp0';
  }

  @override
  String regionsUsageChampionships(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count championships',
      one: '1 championship',
    );
    return '$_temp0';
  }

  @override
  String regionsUsageGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
    );
    return '$_temp0';
  }

  @override
  String get regionsLinkTitle => 'Link regions by id';

  @override
  String get regionsLinkHint =>
      'Writes the region id on old teams, matches, news, championships, groups and requests, in every season. Run it once after updating the app; it can run again and only fills what is missing.';

  @override
  String get regionsLinkRun => 'Link now';

  @override
  String get regionsLinkConfirm =>
      'This goes through the whole database and may take a few minutes. Continue?';

  @override
  String regionsLinkDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents linked.',
      one: '1 document linked.',
    );
    return '$_temp0';
  }

  @override
  String get regionsLinkNothing => 'Everything was already linked.';

  @override
  String regionsLinkUnmatched(String names) {
    return 'Names that match no region (left without id): $names';
  }

  @override
  String get statsShortcut => 'Top scorers & assists';

  @override
  String get alertHeaderConfirm => 'Confirm';

  @override
  String get alertHeaderNotice => 'Notice';

  @override
  String get newsShareTitle => 'Share news';

  @override
  String get newsShareCardFooter =>
      'Read it in the app · arenasoccerflutter.web.app';

  @override
  String get newsNotFound => 'This news item is no longer available.';

  @override
  String get deepLinkHighlightNotFound =>
      'This highlight is no longer available.';
}
