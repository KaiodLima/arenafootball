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
  String get qrCodesTitle => 'QR codes';

  @override
  String get qrKindNow => 'Happening now';

  @override
  String qrNowTitle(String region) {
    return 'Fixed QR for $region';
  }

  @override
  String get qrNowSubtitle =>
      'Always opens what is happening now: votes, live games, events and predictions';

  @override
  String qrNowPosterTitle(String region) {
    return 'Happening now in $region';
  }

  @override
  String get nowTitle => 'Happening now';

  @override
  String nowIn(String region) {
    return 'in $region';
  }

  @override
  String get nowRegionGone => 'This region no longer exists in the app.';

  @override
  String nowQuiet(String region) {
    return 'Nothing happening in $region right now. How about predicting the next game?';
  }

  @override
  String get nowSectionVotes => 'Open best-player votes';

  @override
  String get nowSectionLive => 'Live';

  @override
  String get nowSectionEvents => 'Voting events';

  @override
  String get nowSectionUpcoming => 'Upcoming games';

  @override
  String get nowSectionMore => 'Also join';

  @override
  String get nowVote => 'VOTE NOW';

  @override
  String get nowWatch => 'SEE THE MATCH';

  @override
  String get nowEventVote => 'VOTE IN THE EVENT';

  @override
  String get nowPredict => 'MAKE A PREDICTION';

  @override
  String get nowPool => 'OPEN THE POOL';

  @override
  String get nowLiveBadge => 'LIVE';

  @override
  String get qrCodesIntro =>
      'Create a QR code for what is happening now: print it, show it on screen or post it.';

  @override
  String get qrSectionAlways => 'Always on';

  @override
  String get qrSectionEvents => 'Open voting events';

  @override
  String get qrSectionVotes => 'Open best-player votes';

  @override
  String get qrSectionMatches => 'Upcoming games (predictions)';

  @override
  String get qrSectionEmpty => 'Nothing open right now.';

  @override
  String get qrKindVote => 'Vote for the best player';

  @override
  String get qrKindMatch => 'Make your prediction';

  @override
  String get qrKindPool => 'Prediction pool';

  @override
  String get qrKindAlbum => 'Sticker album';

  @override
  String get qrKindEvent => 'Voting event';

  @override
  String get qrPoolTitle => 'Arena Football pool';

  @override
  String get qrPoolSubtitle =>
      'Predict the games and climb your region\'s ranking';

  @override
  String get qrAlbumSubtitle => 'Open packs and complete the album';

  @override
  String get qrScanCta => 'Point your camera and join in!';

  @override
  String get qrPosterTitle => 'QR code poster';

  @override
  String get qrCopyLink => 'Copy link';

  @override
  String get qrLinkCopied => 'Link copied!';

  @override
  String qrShareText(String title, String link) {
    return '$title — scan or tap the link and join in! ⚽\n$link';
  }

  @override
  String get qrMatchVote => 'Voting QR code';

  @override
  String get qrMatchMatch => 'Match QR code';

  @override
  String get qrMenu => 'QR code';

  @override
  String get fanRankingScopeRegion => 'Region';

  @override
  String get fanRankingScopeOverall => 'Overall';

  @override
  String fanRankingBiggestIn(String region) {
    return 'Biggest crowd in $region';
  }

  @override
  String get fanRankingBiggestOverall => 'Biggest crowd in the app';

  @override
  String get fanRankingTopTie => 'Tied at the top';

  @override
  String fanRankingShareOf(int percent) {
    return '$percent% of the fans';
  }

  @override
  String get fanRankingSplit => 'Crowd split';

  @override
  String get fanRankingOthers => 'Others';

  @override
  String fanRankingGap(int count, String team) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fans to pass $team',
      one: '1 fan to pass $team',
    );
    return '$_temp0';
  }

  @override
  String get fanRankingYouLead => 'Your crowd leads!';

  @override
  String get fanRankingRally => 'Rally the fans';

  @override
  String fanRankingRallyText(String team, String link) {
    return 'Help $team climb the Arena Football crowd ranking! Get the app and pick $team as your team ⚽\n$link';
  }

  @override
  String get fanRankingChooseTitle => 'Join the battle!';

  @override
  String get fanRankingChooseText =>
      'Pick your team and help your crowd climb the ranking.';

  @override
  String get fanRankingFullRanking => 'Full ranking';

  @override
  String get fanRankingBattle => 'Crowd battle';

  @override
  String fanRankingFansLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fans',
      one: 'fan',
    );
    return '$_temp0';
  }

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
  String get newsMoveRegion => 'Change region';

  @override
  String newsMoveRegionTitle(String region) {
    return 'Move to $region?';
  }

  @override
  String newsMoveRegionMessage(String region) {
    return 'The card will only show in the $region feed. The push already sent is not undone.';
  }

  @override
  String get newsMoveRegionLiveNote =>
      'Live match card: also fix the match\'s region/competition, or the next event brings it back.';

  @override
  String newsMovedRegion(String region) {
    return 'News moved to $region';
  }

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
  String get playersPhotoHeader => 'Athlete photo';

  @override
  String get playersPhotoTitle => 'Change photo';

  @override
  String get playersPhotoMessage => 'Pick a photo from the camera or gallery';

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
  String get shareArtTemplateVibrant => 'Colors';

  @override
  String get playerArtAction => 'Create player art';

  @override
  String get playerArtTitle => 'Player art';

  @override
  String get playerArtTemplateSigning => 'Signing';

  @override
  String get playerArtTemplateDeal => 'Done deal';

  @override
  String get playerArtTemplatePoster => 'Poster';

  @override
  String get playerArtHeadline => 'New signing';

  @override
  String playerArtWelcome(String team) {
    return '$team announces';
  }

  @override
  String playerArtDeal(String team) {
    return 'Now with $team!';
  }

  @override
  String get playerArtOfficial => 'Official announcement';

  @override
  String get playerChangeOwnPhoto => 'Change my photo';

  @override
  String get playerPhotoUpdated => 'Photo updated!';

  @override
  String get shareArtFramingHint =>
      'Drag the photo to frame it · pinch to zoom';

  @override
  String get shareArtFramingReset => 'Reset';

  @override
  String get shareArtUseGalleryPhoto => 'Use a gallery photo';

  @override
  String get shareArtUseAthletePhoto => 'Back to the athlete\'s photo';

  @override
  String get shareArtNoPhotoHint =>
      'No athlete photo: use one from the gallery just for this art';

  @override
  String get playerMatchArtAction => 'Athlete art';

  @override
  String get playerMatchArtSheetTitle => 'Create art';

  @override
  String get playerMatchArtPick => 'Choose athlete';

  @override
  String get playerMatchArtSearch => 'Search athlete';

  @override
  String get playerMatchArtEmpty => 'No athletes in this match squads';

  @override
  String get playerMatchArtTeamEmpty => 'No athletes in this team squad';

  @override
  String get playerMatchArtTitle => 'Athlete in the match';

  @override
  String get playerMatchArtTemplateCover => 'Cover';

  @override
  String get playerMatchArtTemplateCountdown => 'Countdown';

  @override
  String get playerMatchArtTemplateAgenda => 'Schedule';

  @override
  String get playerMatchArtTemplateDuel => 'Duel';

  @override
  String get playerMatchArtTemplateLineup => 'Line-up';

  @override
  String get playerMatchArtTemplateSpotlight => 'Spotlight';

  @override
  String get playerMatchArtLineup => 'In the line-up!';

  @override
  String get playerMatchArtMatchday => 'Match day';

  @override
  String playerMatchArtDaysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days to go',
      one: 'day to go',
    );
    return '$_temp0';
  }

  @override
  String playerMatchArtWaiting(String name) {
    return '$name is waiting for you';
  }

  @override
  String get playerMatchArtComeWatch => 'Come to the game!';

  @override
  String playerMatchArtShareText(
      String name, String home, String away, String when, String link) {
    return '$name on the pitch: $home x $away · $when $link';
  }

  @override
  String get playerArtTemplateImpact => 'Impact';

  @override
  String get playerArtTemplateCard => 'Card';

  @override
  String playerArtPresents(String team) {
    return '$team presents';
  }

  @override
  String get playerArtNewSigning => 'New signing';

  @override
  String get playerArtDebut => 'Debut';

  @override
  String get playerArtAbbrGoalkeeper => 'GK';

  @override
  String get playerArtAbbrDefender => 'CB';

  @override
  String get playerArtAbbrFullBack => 'FB';

  @override
  String get playerArtAbbrDefensiveMidfielder => 'DM';

  @override
  String get playerArtAbbrMidfielder => 'CM';

  @override
  String get playerArtAbbrForward => 'FW';

  @override
  String playerArtShareText(String name, String team, String link) {
    return '$name is now with $team! $link';
  }

  @override
  String get shareArtPreviewTitle => 'Promote match';

  @override
  String get shareArtTemplateMatchday => 'Match day';

  @override
  String get shareArtTemplateVersus => 'Head to head';

  @override
  String get shareArtTemplateCalendar => 'Calendar';

  @override
  String get shareArtTemplateChampionship => 'Championship';

  @override
  String get shareArtTemplateTicket => 'Ticket';

  @override
  String get shareArtTemplateScoreboard => 'Scoreboard';

  @override
  String get shareArtToday2 => 'Today';

  @override
  String get shareArtTicketLabel => 'Official ticket';

  @override
  String get shareArtColors => 'Colors';

  @override
  String get shareArtPaletteTeams => 'Teams';

  @override
  String get shareArtPaletteArena => 'Arena';

  @override
  String get shareArtPaletteNight => 'Night';

  @override
  String get shareArtPaletteCrimson => 'Crimson';

  @override
  String get shareArtPaletteOcean => 'Ocean';

  @override
  String get shareArtPaletteGraphite => 'Graphite';

  @override
  String get shareArtDateLabel => 'Date';

  @override
  String get shareArtTimeLabel => 'Kick-off';

  @override
  String get shareArtVenueLabel => 'Venue';

  @override
  String shareArtDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to go',
      one: '1 day to go',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get shareArtToday => 'It\'s today!';

  @override
  String get shareArtNextMatch => 'Next match';

  @override
  String get shareArtVenueTbd => 'Venue TBD';

  @override
  String get shareArtMissingTime => 'kick-off time';

  @override
  String shareArtWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(
      day,
      {
        '1': 'Monday',
        '2': 'Tuesday',
        '3': 'Wednesday',
        '4': 'Thursday',
        '5': 'Friday',
        '6': 'Saturday',
        '7': 'Sunday',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String shareArtWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(
      day,
      {
        '1': 'Mon',
        '2': 'Tue',
        '3': 'Wed',
        '4': 'Thu',
        '5': 'Fri',
        '6': 'Sat',
        '7': 'Sun',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String shareArtMonth(String month) {
    String _temp0 = intl.Intl.selectLogic(
      month,
      {
        '1': 'Jan',
        '2': 'Feb',
        '3': 'Mar',
        '4': 'Apr',
        '5': 'May',
        '6': 'Jun',
        '7': 'Jul',
        '8': 'Aug',
        '9': 'Sep',
        '10': 'Oct',
        '11': 'Nov',
        '12': 'Dec',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get shareArtTemplatePoster => 'Full time';

  @override
  String get shareArtTemplateFaceOff => 'Face-off';

  @override
  String get shareArtTemplateEditorial => 'Editorial';

  @override
  String get shareArtTitle => 'Create artwork';

  @override
  String get shareArtTemplate => 'Template';

  @override
  String get shareArtFormat => 'Format';

  @override
  String get shareArtFormatFeed => 'Feed 4:5';

  @override
  String get shareArtFormatStory => 'Story 9:16';

  @override
  String get shareArtFormatSquare => 'Square';

  @override
  String get shareArtFormatLandscape => 'Landscape';

  @override
  String get shareArtQr => 'Include QR code';

  @override
  String get shareArtSave => 'Save';

  @override
  String get shareArtInstagram => 'Instagram';

  @override
  String get shareArtSaved => 'Artwork saved to the gallery.';

  @override
  String get shareArtSaveError => 'Could not save to the gallery.';

  @override
  String get shareArtError => 'Could not create the artwork.';

  @override
  String get shareArtCallToAction => 'See more on Arena Football';

  @override
  String shareArtHalfTime(String score) {
    return 'Half time $score';
  }

  @override
  String shareArtMissing(String items) {
    return 'Not registered: $items. The artwork goes without them.';
  }

  @override
  String shareArtMissingCrest(String team) {
    return '$team crest';
  }

  @override
  String get shareArtMissingVenue => 'venue';

  @override
  String get shareArtMissingDate => 'date';

  @override
  String shareArtShareText(String home, String away, String link) {
    return '$home x $away on Arena Football: $link';
  }

  @override
  String get pdfTitle => 'MATCH REPORT';

  @override
  String get pdfDraft => 'DRAFT - unsaved changes';

  @override
  String get pdfMatchInfo => 'Match details';

  @override
  String get pdfDate => 'Date';

  @override
  String get pdfTime => 'Time';

  @override
  String get pdfVenue => 'Venue';

  @override
  String get pdfRegion => 'Region';

  @override
  String get pdfDuration => 'Duration';

  @override
  String get pdfStatus => 'Status';

  @override
  String get pdfLineups => 'Lineups';

  @override
  String get pdfStarters => 'Starters';

  @override
  String get pdfReserves => 'Substitutes';

  @override
  String get pdfGoals => 'Goals';

  @override
  String get pdfBookings => 'Cards';

  @override
  String get pdfSubstitutions => 'Substitutions';

  @override
  String get pdfMinute => 'Min.';

  @override
  String get pdfTeam => 'Team';

  @override
  String get pdfPlayer => 'Player';

  @override
  String get pdfScorer => 'Scorer';

  @override
  String get pdfAssist => 'Assist';

  @override
  String get pdfType => 'Type';

  @override
  String get pdfIn => 'On';

  @override
  String get pdfOut => 'Off';

  @override
  String get pdfYellow => 'Yellow';

  @override
  String get pdfRed => 'Red';

  @override
  String get pdfBestPlayer => 'Player of the match';

  @override
  String get pdfNotes => 'Notes';

  @override
  String get pdfSignatures => 'Signatures';

  @override
  String get pdfSignReferee => 'Referee';

  @override
  String get pdfSignOrganizer => 'Organizer';

  @override
  String pdfSignCaptain(String team) {
    return 'Captain - $team';
  }

  @override
  String get pdfNone => 'No records';

  @override
  String get pdfChampionship => 'Competition';

  @override
  String pdfGeneratedAt(String date) {
    return 'Generated by Arena Football on $date';
  }

  @override
  String pdfPage(int page, int total) {
    return 'page $page/$total';
  }

  @override
  String pdfMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String pdfCameIn(String minute) {
    return 'on$minute';
  }

  @override
  String pdfWentOut(String minute) {
    return 'off$minute';
  }

  @override
  String get matchReportExportPdf => 'Export PDF';

  @override
  String get matchReportExport => 'Export match report';

  @override
  String get matchReportExportError =>
      'Could not generate the match report PDF.';

  @override
  String get votingOnlyParticipants =>
      'Only players who took part in the match are shown.';

  @override
  String get liveFullTime => 'Full time';

  @override
  String get liveEventsTitle => 'Match events';

  @override
  String get liveSeeMatch => 'See match';

  @override
  String get liveYellowCard => 'Yellow card';

  @override
  String get liveLabel => 'Live';

  @override
  String get liveNoEvents => 'No events yet.';

  @override
  String get liveSentOff => 'Sent off';

  @override
  String get pushActionRedCard => 'Red card';

  @override
  String get pushActionRedCardHint =>
      'Sending-off recorded in the match report (\"Sent off!\")';

  @override
  String get reportSubstitution => 'Substitution';

  @override
  String get reportWhoLeaves => 'Who comes off?';

  @override
  String get reportWhoEnters => 'Who comes on?';

  @override
  String reportLeaving(String name) {
    return 'Off: $name';
  }

  @override
  String reportEntering(String name) {
    return 'On: $name';
  }

  @override
  String get reportLineupNeeded =>
      'No lineup: the whole squad is shown. Set the lineup to see only who is on the pitch.';

  @override
  String get reportNobodyToPick => 'Nobody available in this step.';

  @override
  String organizerMatchTeamNotEnrolled(String team) {
    return '$team is not registered in this competition. Register the team in the Teams tab.';
  }

  @override
  String get organizerPermissionDenied =>
      'No permission to save in this competition. Ask the admin to open the \"Championship organizers\" panel and try again.';

  @override
  String get organizerNewMatch => 'New match';

  @override
  String get organizerMatchNeedsTeams =>
      'Register at least 2 teams in the competition (Teams tab) to add matches.';

  @override
  String get squadGoalkeepers => 'Goalkeepers';

  @override
  String get squadDefenders => 'Defenders';

  @override
  String get squadFullBacks => 'Full-backs';

  @override
  String get squadDefensiveMidfielders => 'Defensive midfielders';

  @override
  String get squadMidfielders => 'Midfielders';

  @override
  String get squadForwards => 'Forwards';

  @override
  String get squadNoPosition => 'No position';

  @override
  String get squadAllPlayers => 'Players';

  @override
  String get squadTopScorer => 'Top scorer';

  @override
  String get squadTopAssister => 'Top assister';

  @override
  String get squadSortBy => 'Sort by';

  @override
  String get squadSortPosition => 'Position';

  @override
  String get squadGoalsShort => 'G';

  @override
  String get squadAssistsShort => 'A';

  @override
  String get squadSearch => 'Search player';

  @override
  String get squadPlayerActions => 'Player actions';

  @override
  String get organizerSquadPermission =>
      'No permission to change this squad. Ask the admin to open the \"Championship organizers\" panel and try again.';

  @override
  String get organizerSquadAdd => 'From full squad';

  @override
  String get organizerSquadNew => 'New player';

  @override
  String get organizerSquadAddTitle => 'Add to the competition';

  @override
  String organizerSquadAddHint(String championship) {
    return 'Players from the team\'s full squad not yet in $championship.';
  }

  @override
  String organizerSquadAddConfirm(int count) {
    return 'Add ($count)';
  }

  @override
  String get organizerSquadNone =>
      'Every player in the full squad is already in the competition.';

  @override
  String organizerSquadAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players added',
      one: '1 player added',
    );
    return '$_temp0.';
  }

  @override
  String organizerSquadNewHint(String championship) {
    return 'Joins the team, registered only in $championship.';
  }

  @override
  String organizerSquadCreated(String name) {
    return '$name registered in the competition.';
  }

  @override
  String get organizerSquadRemove => 'Remove from competition';

  @override
  String organizerSquadRemoveTitle(String name) {
    return 'Remove $name from the competition?';
  }

  @override
  String get organizerSquadRemoveMessage =>
      'They stay in the team\'s full squad. Numbers already recorded in this competition leave it.';

  @override
  String organizerSquadRemoved(String name) {
    return '$name left the competition.';
  }

  @override
  String get organizerSquadLegacy =>
      'Older player: the admin or the team owner adjusts their competitions.';

  @override
  String organizerSquadOtherTeam(String team) {
    return 'Plays for $team in this competition.';
  }

  @override
  String get organizerSquadError => 'Could not save. Try again.';

  @override
  String get organizerEnrollTeam => 'Register team';

  @override
  String get organizerFormGroups => 'Form groups';

  @override
  String get organizerEditChampionship => 'Edit championship';

  @override
  String get organizerPickChampionship => 'Which championship?';

  @override
  String get organizerEnrollNoCandidates =>
      'All available teams are already registered.';

  @override
  String organizerEnrolled(String team, String championship) {
    return '$team registered in $championship.';
  }

  @override
  String get organizerOutsideRegion =>
      'A municipal championship only accepts teams from its own region.';

  @override
  String get organizerRemoveTeam => 'Remove from championship';

  @override
  String organizerRemoveTeamTitle(String team) {
    return 'Remove $team?';
  }

  @override
  String organizerRemoveTeamMessage(String championship) {
    return 'The team leaves $championship. Matches already registered stay.';
  }

  @override
  String organizerRemoved(String team) {
    return '$team left the championship.';
  }

  @override
  String organizerGroupsTitle(String championship) {
    return 'Groups · $championship';
  }

  @override
  String get organizerGroupsEmpty => 'No groups yet. Create one or draw them.';

  @override
  String get organizerGroupsLoadError => 'Could not load the groups.';

  @override
  String get organizerGroupNew => 'New group';

  @override
  String get organizerGroupEdit => 'Edit group';

  @override
  String get groupRulesTitle => 'Group rules';

  @override
  String get groupRulesQualified => 'Qualified';

  @override
  String get groupRulesQualifiedHint => 'Top teams that advance';

  @override
  String get groupRulesNextPhase => 'Next stage name (optional)';

  @override
  String get groupRulesPlayoff => 'Playoff';

  @override
  String get groupRulesPlayoffHint => 'The next ones, who go to a playoff';

  @override
  String get groupRulesEliminated => 'Eliminated';

  @override
  String get groupRulesEliminatedHint => 'The bottom teams';

  @override
  String get groupRulesHomeAndAway => 'Home and away';

  @override
  String get groupRulesHomeAndAwayHint => 'Each team plays the others twice';

  @override
  String get groupRulesApplyAll => 'Apply to all groups';

  @override
  String groupRulesExceeds(int total) {
    return 'The zones add up to more than the group\'s teams ($total).';
  }

  @override
  String get groupRulesSaved => 'Rules saved';

  @override
  String groupRulesSummaryQualified(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count qualify',
      one: '1 qualifies',
    );
    return '$_temp0';
  }

  @override
  String groupRulesSummaryPlayoff(int count) {
    return '$count in the playoff';
  }

  @override
  String groupRulesSummaryEliminated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eliminated',
      one: '1 eliminated',
    );
    return '$_temp0';
  }

  @override
  String standingsQualifiedFor(String phase) {
    return 'Qualified for the $phase';
  }

  @override
  String get standingsPlayoffLegend => 'Playoff';

  @override
  String get standingsEliminatedLegend => 'Eliminated';

  @override
  String get organizerGroupName => 'Group name';

  @override
  String get organizerGroupNameRequired => 'Enter the group name.';

  @override
  String organizerGroupLabel(String name) {
    return 'Group $name';
  }

  @override
  String get organizerGroupAddTeam => 'Add team';

  @override
  String get organizerGroupFull => 'The group already has 4 teams.';

  @override
  String get organizerGroupNoTeamsLeft =>
      'All registered teams are already in groups.';

  @override
  String get organizerGroupSaved => 'Group saved.';

  @override
  String get organizerGroupDelete => 'Delete group';

  @override
  String organizerGroupDeleteTitle(String name) {
    return 'Delete group $name?';
  }

  @override
  String get organizerGroupDeleteMessage =>
      'Its teams go back to no group and the group table is rebuilt.';

  @override
  String get organizerGroupsDraw => 'Draw groups';

  @override
  String get organizerGroupsDrawCount => 'How many groups?';

  @override
  String organizerGroupsDrawOption(int count, int perGroup) {
    return '$count groups · up to $perGroup teams each';
  }

  @override
  String get organizerGroupsDrawNeedTeams =>
      'Register at least 2 teams to draw.';

  @override
  String organizerGroupsDrawConfirmTitle(int count) {
    return 'Draw $count groups?';
  }

  @override
  String get organizerGroupsDrawConfirmMessage =>
      'Current groups are deleted and the registered teams are shuffled into new ones.';

  @override
  String get organizerGroupsDrawn => 'Groups drawn.';

  @override
  String get organizerModeFan => 'Fan mode';

  @override
  String get organizerModeOrganizer => 'Organizer mode';

  @override
  String get homeModeAdmin => 'Admin mode';

  @override
  String get homeModePlayer => 'Player mode';

  @override
  String get homeModePlayerBanner => 'Player mode: you see the app as a player';

  @override
  String get homeModePlayerExit => 'Exit';

  @override
  String get organizerModeToggle => 'Switch between fan and organizer';

  @override
  String get homeTabMyChampionships => 'My leagues';

  @override
  String get organizerModeSubtitle => 'Organizer mode · your championships';

  @override
  String get organizerNoChampionships =>
      'You don\'t organize any championship yet.';

  @override
  String get organizerTeamsEmpty => 'No teams registered in this championship.';

  @override
  String get organizerRequestMenu => 'I organize a competition';

  @override
  String get organizerRequestTitle => 'I organize a competition';

  @override
  String get organizerRequestIntro =>
      'Running a competition? Ask to add it to Arena. Once approved, the competition is created and you manage the details (description, rules, prizes and teams).';

  @override
  String get organizerRequestLogoAdd => 'Logo (optional)';

  @override
  String get organizerRequestSectionCompetition => 'Competition';

  @override
  String get organizerRequestNameLabel => 'Competition name';

  @override
  String get organizerRequestNameRequired =>
      'Enter the competition name (at least 3 letters).';

  @override
  String get organizerRequestScopeLabel => 'Category';

  @override
  String get organizerRequestDescriptionLabel =>
      'About the competition (dates, format, number of teams)';

  @override
  String get organizerRequestSubmit => 'Send request';

  @override
  String get organizerRequestSent => 'Request sent! The admin will review it.';

  @override
  String get organizerRequestCancelled => 'Request cancelled.';

  @override
  String get organizerRequestLoadError => 'Could not load your request.';

  @override
  String get organizerRequestPendingInfo =>
      'Your request is with the admin. You will be notified when they answer.';

  @override
  String get organizerRequestRejectedInfo =>
      'Your request was not approved. Fix the details and send it again.';

  @override
  String get organizerRequestApprovedInfo =>
      'Your competition was created! Edit the details in \"My competitions\".';

  @override
  String get organizerRequestEdit => 'Fix request';

  @override
  String get organizerRequestCancel => 'Cancel request';

  @override
  String get organizerRequestCancelTitle => 'Cancel the request?';

  @override
  String organizerRequestCancelMessage(String name) {
    return 'The request for $name will be deleted.';
  }

  @override
  String get organizerRequestResubmit => 'Send again';

  @override
  String get organizerRequestNew => 'Request another competition';

  @override
  String get organizerMyChampionships => 'My competitions';

  @override
  String get organizerRequestsPanelTitle => 'Competition organizers';

  @override
  String get organizerRequestsEmptyPending => 'No organizer requests waiting.';

  @override
  String get organizerRequestsEmptyAnswered => 'No answered requests yet.';

  @override
  String get organizerRequestsLoadError =>
      'Could not load the organizer requests.';

  @override
  String organizerRequestsApproveTitle(String name) {
    return 'Approve $name?';
  }

  @override
  String organizerRequestsApproveMessage(
      String region, String scope, String user) {
    return 'Creates the competition in $region ($scope) in the current season, organized by $user.';
  }

  @override
  String organizerRequestsApproved(String name) {
    return 'Competition $name created.';
  }

  @override
  String organizerRequestsRejectTitle(String name) {
    return 'Reject $name?';
  }

  @override
  String organizerRequestsOrganizer(String user) {
    return 'Organizer: $user';
  }

  @override
  String get championshipFormOrganizerLocked =>
      'Name, region, category and season were set on approval. Ask the admin to change them.';

  @override
  String get pushActionOrganizerRequest => 'Organizer request';

  @override
  String get pushActionOrganizerRequestHint =>
      'To admins · someone wants to add a competition';

  @override
  String get pushActionOrganizerAnswer => 'Answer to organizer';

  @override
  String get pushActionOrganizerAnswerHint =>
      'To the requester · competition approved or declined';

  @override
  String get pushActionChampion => 'Champion';

  @override
  String get pushActionChampionHint =>
      'Region and fans · competition finished with the champion';

  @override
  String get referralTitle => 'Invite friends';

  @override
  String get referralPaused => 'Invites are paused at the moment.';

  @override
  String get referralSettingsSwitch => 'Invites enabled';

  @override
  String get referralSettingsOn =>
      '\"Invite friends\" shows in the menu and in the album, and invites count.';

  @override
  String get referralSettingsOff =>
      'Disabled: the item disappears from the menu and the album. Invites made now are kept and count when you turn it back on (if the friend\'s account is still up to 7 days old). Extra packs already earned still open.';

  @override
  String referralSettingsRules(int max) {
    return 'Rules: the friend signs up, enters the code (up to 7 days) and picks a favourite team; both get 1 extra pack (up to $max saved) and the inviter counts towards the \"Friends invited\" achievement.';
  }

  @override
  String get referralSettingsSaved => 'Settings saved';

  @override
  String get referralHeadline => 'Invite friends and get stickers';

  @override
  String get referralSubtitle =>
      'Every friend who joins with your invite and picks a team gives 1 extra pack to you and another to them.';

  @override
  String get referralYourCode => 'YOUR CODE';

  @override
  String get referralShare => 'Share invite';

  @override
  String referralShareText(String code, String link) {
    return 'Follow our local football on Arena Football! Join with my code $code and we both get sticker packs: $link';
  }

  @override
  String get referralCodeCopied => 'Code copied';

  @override
  String get referralStatInvited => 'Friends invited';

  @override
  String get referralStatExtraPacks => 'Packs saved';

  @override
  String get referralStatEarned => 'Packs earned';

  @override
  String get referralHowTitle => 'How it works';

  @override
  String get referralHowStep1 =>
      'Share your invite (or the code) with friends.';

  @override
  String get referralHowStep2 =>
      'Your friend signs up, enters your code and picks a favourite team.';

  @override
  String referralHowStep3(int max) {
    return 'You both get 1 extra pack to open in the album right away, skipping the 24 h wait (up to $max saved).';
  }

  @override
  String get referralFriendsTitle => 'Your friends';

  @override
  String get referralFriendsEmpty => 'Nobody has joined with your invite yet.';

  @override
  String get referralFriendNoName => 'Friend';

  @override
  String get referralClaimTitle => 'I was invited';

  @override
  String get referralClaimHint =>
      'New account? Enter the code of who invited you (valid for the first 7 days).';

  @override
  String get referralClaimField => 'Friend\'s code';

  @override
  String get referralClaimButton => 'Use code';

  @override
  String get referralClaimSaved =>
      'Code saved! The pack arrives once you pick your favourite team.';

  @override
  String get referralClaimInvalid =>
      'Invalid code: 8 or 10 letters and numbers.';

  @override
  String get referralClaimOwn => 'That is your own code.';

  @override
  String get referralClaimOldAccount =>
      'Invite codes only work in the account\'s first 7 days.';

  @override
  String get referralClaimAlready => 'Your account has already used a code.';

  @override
  String referralClaimUsed(String code) {
    return 'You joined with code $code';
  }

  @override
  String get referralClaimValid => 'Invite confirmed: the extra pack is yours!';

  @override
  String get referralClaimPending => 'Pick your favourite team to confirm.';

  @override
  String get referralRefusedCode => 'That code does not exist.';

  @override
  String albumExtraPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count extra packs saved',
      one: '+1 extra pack saved',
    );
    return '$_temp0';
  }

  @override
  String get albumOpenExtraPack => 'Open extra pack';

  @override
  String get albumInviteForPacks => 'Get packs by inviting friends';

  @override
  String get pushActionReferral => 'Invite confirmed';

  @override
  String get pushActionReferralHint =>
      'To the inviter · their friend joined and the extra pack arrived';

  @override
  String get achievementMetricReferrals => 'Friends invited';

  @override
  String get teamPickerOtherRegion => 'Other regions';

  @override
  String get matchFormRegionFilter => 'Find competitions and teams in';

  @override
  String get matchFormRegionFilterHint =>
      'Intercity competitions show up in every region.';

  @override
  String matchFormAppearsIn(String regions) {
    return 'Shows up in $regions';
  }

  @override
  String matchFormAppearsHostTeams(String championship) {
    return '$championship host and the teams\' regions';
  }

  @override
  String matchFormAppearsHost(String championship) {
    return '$championship host';
  }

  @override
  String get matchFormAppearsTeams => 'The teams\' regions';

  @override
  String get matchFormAppearsFilter => 'Region selected above';

  @override
  String get matchFormAnd => 'and';

  @override
  String get matchDelay => 'Delayed';

  @override
  String get matchDelayTitle => 'New kick-off time';

  @override
  String matchDelayCurrent(String time) {
    return 'Scheduled for $time';
  }

  @override
  String matchDelayPlus(int minutes) {
    return '+$minutes min';
  }

  @override
  String get matchDelayHint =>
      'The card shows the match as delayed, and the clock, predictions and voting count from the new time.';

  @override
  String get matchDelayStartedNow => 'It just started';

  @override
  String matchDelayedTo(String time) {
    return 'Kick-off moved to $time';
  }

  @override
  String get matchStartNow => 'Start now';

  @override
  String get matchCardDelayed => 'DELAYED';

  @override
  String get matchCardWaiting => 'ON HOLD';

  @override
  String get matchDelayPause => 'Hold until kick-off';

  @override
  String get matchPausedNotice => 'Match on hold until kick-off';

  @override
  String matchCardWas(String time) {
    return 'was $time';
  }

  @override
  String get reportLive => 'Live';

  @override
  String get reportHalfTime => 'Half-time';

  @override
  String get reportFinished => 'Full time';

  @override
  String get reportNotStarted => 'Not started';

  @override
  String get reportStageBefore => 'Before';

  @override
  String get reportStageFirstHalf => '1st H';

  @override
  String get reportStageHalfTime => 'Break';

  @override
  String get reportStageSecondHalf => '2nd H';

  @override
  String get reportStageEnd => 'End';

  @override
  String get reportGoal => 'Goal';

  @override
  String reportGoalOf(String team) {
    return '$team goal';
  }

  @override
  String reportGoalBy(String name) {
    return 'Goal by $name';
  }

  @override
  String get reportWhoAssisted => 'Who gave the assist?';

  @override
  String get reportNoAssist => 'No assist';

  @override
  String get reportGoalNoScorer => 'No scorer';

  @override
  String get reportNoEvents =>
      'No events yet. Use the buttons above to log goals and cards.';

  @override
  String get reportNoMinute => 'No minute';

  @override
  String get reportFirstHalf => '1st half';

  @override
  String get reportSecondHalf => '2nd half';

  @override
  String get reportEditEvent => 'Edit event';

  @override
  String get reportDeleteEvent => 'Delete event';

  @override
  String get reportUndo => 'Undo';

  @override
  String get reportNotRelated => 'Not selected';

  @override
  String reportStarters(int count) {
    return 'Starters $count/11';
  }

  @override
  String reportSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count substitutes',
      one: '1 substitute',
      zero: 'No substitutes',
    );
    return '$_temp0';
  }

  @override
  String get reportStarter => 'Starter';

  @override
  String get reportSub => 'Bench';

  @override
  String get reportWhen => 'When';

  @override
  String get reportWhere => 'Where';

  @override
  String get matchEditInfo => 'Edit match';

  @override
  String get matchEditInfoTitle => 'Edit match';

  @override
  String get matchEditInfoSubtitle => 'Date, time, duration and venue';

  @override
  String get matchEditInfoSaved => 'Match updated';

  @override
  String get reportRefereeing => 'Refereeing';

  @override
  String get reportVoting => 'Man of the match vote';

  @override
  String get reportVotingOpen => 'Open now';

  @override
  String get reportVotingClosed => 'Closed';

  @override
  String get reportNotesHint => 'Incidents, send-offs, delays, walkovers...';

  @override
  String reportChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes',
      one: '1 change',
    );
    return '$_temp0';
  }

  @override
  String get reportPublishCards => 'Publish to the feed (live match card)';

  @override
  String get reportSave => 'Save';

  @override
  String get athleteBookings => 'Cards this season';

  @override
  String get matchDetailsStarters => 'Starters';

  @override
  String get matchDetailsSubs => 'Substitutes';

  @override
  String matchDetailsReferee(String name) {
    return 'Referee: $name';
  }

  @override
  String get matchReportManage => 'Manage match';

  @override
  String get matchReportTitle => 'Match report';

  @override
  String get matchReportTabEvents => 'Events';

  @override
  String get matchReportTabLineup => 'Lineup';

  @override
  String get matchReportTabGame => 'Game';

  @override
  String get matchReportSave => 'Save report';

  @override
  String get matchReportSaved => 'Report saved.';

  @override
  String matchReportSavedWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Report saved · $count goal cards published',
      one: 'Report saved · 1 goal card published',
    );
    return '$_temp0';
  }

  @override
  String get matchReportDiscardTitle => 'Leave without saving?';

  @override
  String get matchReportDiscardMessage =>
      'The report changes (events, lineup and game data) will be lost.';

  @override
  String get matchReportDiscard => 'Leave without saving';

  @override
  String get matchReportAddGoal => '+ Goal';

  @override
  String get matchReportAddBooking => '+ Card';

  @override
  String get matchReportNoEvents => 'No events yet. Add goals and cards here.';

  @override
  String get matchReportSwipeHint =>
      'Tap a goal to edit; swipe an event aside to delete it.';

  @override
  String get matchReportGoalNoScorer => 'Goal (no scorer)';

  @override
  String matchReportAssist(String name) {
    return 'assist $name';
  }

  @override
  String get matchReportSecondYellow => '2nd yellow';

  @override
  String get matchReportGoalTitle => 'Goal';

  @override
  String get matchReportBookingTitle => 'Card';

  @override
  String get matchReportScorer => 'Scorer';

  @override
  String get matchReportPlayer => 'Player';

  @override
  String get matchReportAssistant => 'Assist (optional)';

  @override
  String get matchReportNone => 'None';

  @override
  String get matchReportYellow => 'Yellow';

  @override
  String get matchReportRed => 'Red';

  @override
  String get matchReportMinute => 'Minute';

  @override
  String get matchReportAdd => 'Add';

  @override
  String get matchReportNoSquad =>
      'No players in this team\'s squad for this competition. Add them in the Lineup tab.';

  @override
  String matchReportLineupCount(int starters, int subs) {
    return '$starters starters · $subs substitutes';
  }

  @override
  String get matchReportLineupHint =>
      'Mark S (starter) or B (bench); tap the number to change the shirt.';

  @override
  String get matchReportStarterShort => 'S';

  @override
  String get matchReportSubShort => 'B';

  @override
  String get matchReportAddPlayer => 'Add player';

  @override
  String get matchReportAddPlayerHint =>
      'They join the team\'s squad in this competition and the lineup.';

  @override
  String get matchReportPlayerAdded => 'Player added and selected.';

  @override
  String get matchReportPlayerName => 'Player name';

  @override
  String get matchReportPhoto => 'Photo';

  @override
  String matchReportShirtNumber(String name) {
    return '$name\'s shirt number';
  }

  @override
  String get matchReportDate => 'Date';

  @override
  String get matchReportTime => 'Time';

  @override
  String get matchReportDuration => 'Duration (minutes)';

  @override
  String get matchReportVenue => 'Venue';

  @override
  String get matchReportReferee => 'Referee';

  @override
  String get matchReportNotes => 'Report notes';

  @override
  String get matchReportVoting => 'Man of the match voting open';

  @override
  String get matchReportVotingHint =>
      'Opens or closes right away for everyone.';

  @override
  String get commonCardSettings => 'Settings';

  @override
  String matchGoalsPublishCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Publish cards for the $count new goals',
      one: 'Publish a card for the new goal',
    );
    return '$_temp0';
  }

  @override
  String get matchGoalsPublishCardsHint =>
      'Shows up in the feed and sends the \"GOAL!\" push. Turn it off to log an old game quietly.';

  @override
  String matchGoalsSavedWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score saved · $count goal cards published',
      one: 'Score saved · 1 goal card published',
    );
    return '$_temp0';
  }

  @override
  String get matchGoalsSavedCardsFailed =>
      'Score saved, but the goal card could not be published.';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourNext => 'Next';

  @override
  String get tourDone => 'Got it';

  @override
  String tourWelcomeTitle(String name) {
    return 'Welcome to Arena, $name! ⚽';
  }

  @override
  String get tourWelcomeSubtitle =>
      'Your region\'s football, all in one place.';

  @override
  String get tourWelcomeItemNews => 'News, games and scores from your region';

  @override
  String get tourWelcomeItemPlay =>
      'Predictions, man of the match votes and achievements';

  @override
  String get tourWelcomeItemAlbum => 'Sticker album with a free pack';

  @override
  String get tourWelcomeStart => 'Take a quick tour (30 s)';

  @override
  String get tourWelcomeLater => 'Not now';

  @override
  String get tourHomeRegionTitle => 'Your region';

  @override
  String get tourHomeRegionBody =>
      'Pick the city here. News, games, teams and competitions show only what is from there.';

  @override
  String get tourHomeTabsTitle => 'Everything in 4 tabs';

  @override
  String get tourHomeTabsBody =>
      'News, competitions, teams with their squads and the fixtures with scores.';

  @override
  String get tourHomeMenuTitle => 'Your menu';

  @override
  String get tourHomeMenuBody =>
      'Fan card, achievements, predictions, fan ranking and \"I\'m a player\" to join your team\'s squad.';

  @override
  String get tourHomeAlbumTitle => 'Sticker album';

  @override
  String get tourHomeAlbumBody =>
      'A free pack every 24 h. Drag the badge wherever you like.';

  @override
  String get tourDrawerProfileTitle => 'Your profile';

  @override
  String get tourDrawerProfileBody => 'Your favorite team and your fan card.';

  @override
  String get tourDrawerPredictionsTitle => 'Predictions';

  @override
  String get tourDrawerPredictionsBody =>
      'Make free score predictions and climb your region\'s ranking.';

  @override
  String get tourDrawerAchievementsTitle => 'Achievements';

  @override
  String get tourDrawerAchievementsBody =>
      'Earn medals and XP by using the app.';

  @override
  String get tourDrawerPlayerTitle => 'I\'m a player';

  @override
  String get tourDrawerPlayerBody =>
      'Play for a local team? Ask to join the squad and get your athlete profile.';

  @override
  String get tourTablesFilterTitle => 'Pick the competition';

  @override
  String get tourTablesFilterBody =>
      'See the games of one competition or all of them at once.';

  @override
  String get tourTablesShortcutsTitle => 'Shortcuts';

  @override
  String get tourTablesShortcutsBody =>
      'All games, the groups with the standings and the top scorers.';

  @override
  String get tourTablesDayTitle => 'Games of the day';

  @override
  String get tourTablesDayBody =>
      'Yesterday, today and tomorrow. Tap a game to see the goals, vote and make your prediction.';

  @override
  String get tourTeamsTitle => 'Your region\'s teams';

  @override
  String get tourTeamsBody =>
      'Tap a team to see the squad, the athletes and their stats in each competition.';

  @override
  String get tourChampionshipsTitle => 'Competitions';

  @override
  String get tourChampionshipsBody =>
      'Tap to see rules, prizes, groups and the standings, which update by themselves.';

  @override
  String get tourChampionshipsShortcutsTitle => 'Competition shortcuts';

  @override
  String get tourChampionshipsShortcutsBody =>
      'Groups, top scorers and rules of the featured competition.';

  @override
  String get tourAlbumPackTitle => 'Free pack';

  @override
  String get tourAlbumPackBody =>
      'One every 24 h, with new stickers. We\'ll let you know when the next one is ready.';

  @override
  String get tourAlbumPagesTitle => 'Team pages';

  @override
  String get tourAlbumPagesBody =>
      'Tap a team to see your stickers and what\'s missing to complete the page.';

  @override
  String get tourAlbumTabsTitle => 'Duplicates and ranking';

  @override
  String get tourAlbumTabsBody =>
      'See your duplicates and compete in the collectors\' ranking.';

  @override
  String get tourPredictionsHeroTitle => 'Your pool';

  @override
  String get tourPredictionsHeroBody =>
      'Your position, points and how many you need to pass the next one. Exact score is worth 10, winner and goal difference 7, winner only 5.';

  @override
  String get tourPredictionsMatchTitle => 'Predict before kickoff';

  @override
  String get tourPredictionsMatchBody =>
      'Tap \"Predict\" and pick the score. You can change it until the match starts.';

  @override
  String get tourPredictionsTabsTitle => 'Predict and ranking';

  @override
  String get tourPredictionsTabsBody =>
      'Switch tabs to see the region ranking and challenge your friends.';

  @override
  String get tourFanCardCardTitle => 'Your fan card';

  @override
  String get tourFanCardCardBody =>
      'Tilt your phone to see it shine and tap to flip the card.';

  @override
  String get tourFanCardActionsTitle => 'Share, photo and team';

  @override
  String get tourFanCardActionsBody =>
      'Send your card to friends, change your photo or your favorite team.';

  @override
  String get tourFanCardLevelTitle => 'Your fan level';

  @override
  String get tourFanCardLevelBody =>
      'Level up by earning achievements in the app.';

  @override
  String get tourFanRankingScopeTitle => 'Region or overall';

  @override
  String get tourFanRankingScopeBody =>
      'See the biggest crowds in your region or across the whole app.';

  @override
  String get tourFanRankingLeaderTitle => 'The biggest crowd';

  @override
  String get tourFanRankingLeaderBody =>
      'Who leads, with how many fans and each team\'s share.';

  @override
  String get tourFanRankingMineTitle => 'Your crowd';

  @override
  String get tourFanRankingMineBody =>
      'See your team\'s position and call more fans to climb.';

  @override
  String get tourAchievementsLevelTitle => 'Level and XP';

  @override
  String get tourAchievementsLevelBody =>
      'Each achievement gives XP and raises your fan level.';

  @override
  String get tourAchievementsAlmostTitle => 'Almost there';

  @override
  String get tourAchievementsAlmostBody =>
      'The next medal you are close to earning.';

  @override
  String get tourAchievementsShelfTitle => 'Medals by category';

  @override
  String get tourAchievementsShelfBody => 'Tap a medal to see how to earn it.';

  @override
  String get tourMatchArtTitle => 'Create artwork';

  @override
  String get tourMatchArtBody =>
      'Make artwork of the match to post on Instagram or send on WhatsApp.';

  @override
  String get tourMatchBestPlayerTitle => 'Man of the match';

  @override
  String get tourMatchBestPlayerBody =>
      'When voting opens, vote here for the best player of the match.';

  @override
  String get tourMatchPredictionTitle => 'Your prediction';

  @override
  String get tourMatchPredictionBody =>
      'Predict the score before the match and earn pool points.';

  @override
  String get tourEventPollHeaderTitle => 'Voting event';

  @override
  String get tourEventPollHeaderBody =>
      'It stays open until the deadline. The result comes out when it closes.';

  @override
  String get tourEventPollOptionTitle => 'Pick yours';

  @override
  String get tourEventPollOptionBody =>
      'Tap an option and confirm. You vote only once; the video button opens the play on social media.';

  @override
  String get tourArtPreviewTitle => 'Your artwork';

  @override
  String get tourArtPreviewBody =>
      'The preview shows the artwork exactly as it will be saved.';

  @override
  String get tourArtFramingTitle => 'Adjust the photo';

  @override
  String get tourArtFramingBody =>
      'Drag to move and pinch to zoom. You can also use a photo from your gallery.';

  @override
  String get tourArtTemplatesTitle => 'Templates';

  @override
  String get tourArtTemplatesBody =>
      'Change the template to switch the artwork\'s look.';

  @override
  String get tourArtFormatTitle => 'Format';

  @override
  String get tourArtFormatBody =>
      'Feed, story, square or landscape: the right size for each network.';

  @override
  String get tourArtShareTitle => 'Save and share';

  @override
  String get tourArtShareBody =>
      'Save to your gallery or send it straight to Instagram and WhatsApp.';

  @override
  String get tourReferralInviteTitle => 'Your invite';

  @override
  String get tourReferralInviteBody =>
      'Send your link. When your friend joins and picks a team, you both get an extra pack.';

  @override
  String get tourReferralStatsTitle => 'Your referrals';

  @override
  String get tourReferralStatsBody =>
      'How many friends joined and the extra packs you have saved.';

  @override
  String get tourReferralClaimTitle => 'Were you invited?';

  @override
  String get tourReferralClaimBody =>
      'Enter the code of whoever invited you here.';

  @override
  String get tourPlayerClaimTitle => 'Is this you?';

  @override
  String get tourPlayerClaimBody =>
      'If this athlete is you, ask to link it to your account and get your profile.';

  @override
  String get tourProfilePhotoTitle => 'Your photo';

  @override
  String get tourProfilePhotoBody =>
      'Tap to change your account photo. It shows on your fan card.';

  @override
  String get tourProfileNameTitle => 'Your name';

  @override
  String get tourProfileNameBody => 'The name shown in rankings and votes.';

  @override
  String get tourProfileTeamTitle => 'Favorite team';

  @override
  String get tourProfileTeamBody => 'You can change it once every 15 days.';

  @override
  String get tourDrawerFanCardTitle => 'My fan card';

  @override
  String get tourDrawerFanCardBody => 'Your fan card in your team\'s colors.';

  @override
  String get tourDrawerFanRankingTitle => 'Battle of the crowds';

  @override
  String get tourDrawerFanRankingBody =>
      'Which team has the most fans in the app.';

  @override
  String get tourDrawerReferralTitle => 'Invite friends';

  @override
  String get tourDrawerReferralBody =>
      'Invite friends and get extra album packs.';

  @override
  String get tourFantasyRoundTitle => 'Your round';

  @override
  String get tourFantasyRoundBody =>
      'Each championship with Fantasy shows the round, the lineup deadline and your points.';

  @override
  String get tourFantasyPlayTitle => 'Build your team';

  @override
  String get tourFantasyPlayBody =>
      'Pick 5 athletes from the championship and a captain. They score for what they do in the real matches.';

  @override
  String get tourFantasyRankingTitle => 'Ranking';

  @override
  String get tourFantasyRankingBody =>
      'See who\'s ahead in the round and overall.';

  @override
  String get tourFantasyLineupDeadlineTitle => 'Round deadline';

  @override
  String get tourFantasyLineupDeadlineBody =>
      'You can change it until the round\'s first match starts. After that, the lineup is locked.';

  @override
  String get tourFantasyLineupPitchTitle => 'Your pitch';

  @override
  String get tourFantasyLineupPitchBody =>
      'Tap a slot to pick the athlete: goalkeeper, defender, midfielder, forward and one free slot for any position.';

  @override
  String get tourFantasyLineupCaptainTitle => 'Captain';

  @override
  String tourFantasyLineupCaptainBody(String mult) {
    return 'Tap an athlete\'s \"C\" to make them captain: they score $mult.';
  }

  @override
  String get tourFantasyLineupSaveTitle => 'Confirm your lineup';

  @override
  String get tourFantasyLineupSaveBody =>
      'Save before the deadline. If you don\'t change anything, your previous lineup carries over to the next round.';

  @override
  String get tourFantasyRankTabsTitle => 'Four rankings';

  @override
  String get tourFantasyRankTabsBody =>
      'Round, the top-scoring athletes, overall and the history of your lineups.';

  @override
  String get tourFantasyRankRoundTitle => 'Change round';

  @override
  String get tourFantasyRankRoundBody =>
      'Use the arrows to see previous rounds.';

  @override
  String get tourFantasyRankMineTitle => 'Your position';

  @override
  String get tourFantasyRankMineBody =>
      'Where you are and how many points you scored.';

  @override
  String get tourDrawerFantasyTitle => 'Arena Fantasy';

  @override
  String get tourDrawerFantasyBody =>
      'Build your team with the championship\'s athletes and compete with your region.';

  @override
  String get settingsHelpSection => 'Help';

  @override
  String get settingsReplayTours => 'Replay tutorials';

  @override
  String get settingsReplayToursHint => 'Each screen\'s tips show up again';

  @override
  String get settingsReplayToursDone => 'Done! The tips will show up again.';

  @override
  String get albumTabRanking => 'Ranking';

  @override
  String get albumRankingHint =>
      'Who has the most different stickers. Tie: who got there first.';

  @override
  String get albumRankingRefresh => 'Refresh';

  @override
  String get albumRankingEmpty => 'Nobody has opened a pack yet. Be the first!';

  @override
  String get albumRankingYou => 'You';

  @override
  String get albumRankingComplete => 'Complete ✓';

  @override
  String get albumRankingMyPosition => 'Your position';

  @override
  String get albumRankingNotYet => 'Open your first pack to join the ranking.';

  @override
  String get albumRareTag => 'RARE';

  @override
  String get albumRareLabel => 'Rare';

  @override
  String get albumStickerRareNew => 'RARE!';

  @override
  String albumStatRares(int total) {
    return 'rare of $total';
  }

  @override
  String get albumAdminStickerRare => 'Rare sticker';

  @override
  String get albumAdminStickerRareHint =>
      'Much less likely in a pack, with a golden frame.';

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
  String get albumAdminSelectAll => 'Select all';

  @override
  String get albumAdminUnselectAll => 'Unselect all';

  @override
  String albumAdminSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String albumAdminDeleteStickersTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count stickers?',
      one: 'Delete 1 sticker?',
    );
    return '$_temp0';
  }

  @override
  String get albumAdminDeleteStickersMessage =>
      'People who already stuck these stickers won\'t see them in the album anymore. Numbers are redone in sequence.';

  @override
  String albumAdminStickersDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stickers deleted.',
      one: '1 sticker deleted.',
    );
    return '$_temp0';
  }

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
  String get predictionHubHeroTitle => 'YOUR POOL';

  @override
  String get predictionHubStatPoints => 'pts';

  @override
  String get predictionHubStatExact => 'exact';

  @override
  String get predictionHubStatPicks => 'picks';

  @override
  String predictionHubPlace(String region) {
    return 'place in $region';
  }

  @override
  String predictionHubChase(int points, String name) {
    return '$points pts to pass $name';
  }

  @override
  String get predictionHubLeader => 'You lead the pool!';

  @override
  String get predictionHubNoPoints =>
      'Predict the games and compete with your region!';

  @override
  String get predictionHubGuest =>
      'Sign in to predict and climb your region\'s ranking.';

  @override
  String get predictionHubSignIn => 'SIGN IN';

  @override
  String get predictionHubHowTitle => 'How scoring works';

  @override
  String get predictionHubExact => 'Exact score';

  @override
  String get predictionHubWinnerDiff => 'Winner + margin';

  @override
  String get predictionHubWinner => 'Winner only';

  @override
  String get predictionHubTabPlay => 'Predict';

  @override
  String get predictionHubTabRanking => 'Ranking';

  @override
  String get predictionHubUpcoming => 'Upcoming games';

  @override
  String get predictionHubNoUpcoming =>
      'No games open for predictions in this region right now.';

  @override
  String predictionHubClosesIn(String time) {
    return 'Closes in $time';
  }

  @override
  String get predictionHubPredict => 'PREDICT';

  @override
  String get predictionHubYourPick => 'Your pick';

  @override
  String get predictionHubChange => 'Change';

  @override
  String get predictionHubLive => 'LIVE';

  @override
  String get predictionHubHalfTime => 'HALF-TIME';

  @override
  String get predictionHubWaiting => 'WAITING';

  @override
  String get predictionHubClosed => 'Predictions closed';

  @override
  String get predictionHubRecent => 'Your latest predictions';

  @override
  String get predictionHubRecentEmpty =>
      'Your predictions for finished games show up here.';

  @override
  String get predictionHubPending => 'Waiting for scoring';

  @override
  String get predictionHubExactChip => 'Exact';

  @override
  String predictionHubYouSaid(int home, int away) {
    return 'You: $home × $away';
  }

  @override
  String predictionHubHitRate(int percent) {
    return '$percent% hit rate';
  }

  @override
  String get predictionHubChallenge => 'Challenge friends';

  @override
  String predictionHubChallengeText(int position, String region, String link) {
    return 'I\'m #$position in the Arena Football pool in $region! Come predict and try to beat me ⚽\n$link';
  }

  @override
  String predictionHubChallengeTextNoRank(String region, String link) {
    return 'Come predict with me in the Arena Football pool in $region! ⚽\n$link';
  }

  @override
  String get predictionHubPredictors => 'Predictors';

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
  String get drawerPlayerHint => 'Ask to play for a team';

  @override
  String get drawerPlayerHintApproved => 'Your profile and stats';

  @override
  String get drawerOwnerHint => 'Register and manage your team';

  @override
  String get drawerOwnerHintApproved => 'Squad, requests and crest';

  @override
  String get drawerPartnerHint => 'Publish in your region';

  @override
  String get drawerPartnerHintApproved => 'Your posts and slots';

  @override
  String get drawerOrganizerHint => 'Run your own championship';

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
  String get voteClosedTitle => 'Result is in';

  @override
  String voteClosedText(String home, String away) {
    return 'See who was voted player of the match in $home × $away.';
  }

  @override
  String get voteClosedBestPlayer => 'PLAYER OF THE MATCH';

  @override
  String voteClosedVotes(int votes, int percent) {
    return '$votes votes · $percent%';
  }

  @override
  String get voteClosedNoWinner => 'No player elected';

  @override
  String get voteClosedNoWinnerText =>
      'The vote didn\'t reach the minimum to elect a player.';

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
  String get matchCardLiveShort => 'LIVE';

  @override
  String get matchCardHalfTimeShort => 'HT';

  @override
  String get matchCardFinishedShort => 'FT';

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
  String get matchFormSavedOffline =>
      'No connection: the match was saved on this device and will be sent when you\'re back online.';

  @override
  String get matchFormDuplicateTitle => 'Duplicate match?';

  @override
  String matchFormDuplicateMessage(
      String home, String away, String date, String time) {
    return '$home × $away on $date at $time already exists. Register anyway?';
  }

  @override
  String get matchFormDuplicateConfirm => 'Register anyway';

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
  String get profileTitle => 'My profile';

  @override
  String get profileMenu => 'Edit profile';

  @override
  String get profileNameLabel => 'Name';

  @override
  String profileNameTooLong(int max) {
    return 'The name can have at most $max characters';
  }

  @override
  String get profileNameSaved => 'Name updated!';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileFavoriteTeam => 'Favorite team';

  @override
  String get profileNoTeam => 'No team chosen';

  @override
  String get profilePhotoHint =>
      'Your photo shows in the menu and on your fan card.';

  @override
  String get profileAccountSection => 'Account details';

  @override
  String get profileEmailLocked => 'The email cannot be changed';

  @override
  String get profileChangeTeam => 'Change';

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
  String get linkPlayerMenu => 'Link player';

  @override
  String get linkPlayerToTeamMenu => 'Link to team/competition';

  @override
  String linkPlayerSearchTitle(String team) {
    return 'Link a player to $team';
  }

  @override
  String get linkPlayerSearchHint => 'Search player by name';

  @override
  String get linkPlayerNoTeam => 'No team';

  @override
  String get linkPlayerHasAccount => 'has account';

  @override
  String get linkPlayerEmpty => 'No players found.';

  @override
  String linkPlayerFilterAll(int count) {
    return 'All ($count)';
  }

  @override
  String linkPlayerFilterAccount(int count) {
    return 'With account ($count)';
  }

  @override
  String linkPlayerFilterNoAccount(int count) {
    return 'No account ($count)';
  }

  @override
  String linkPlayerShowing(int shown, int total) {
    return 'Showing $shown of $total';
  }

  @override
  String linkPlayerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players',
      one: '1 player',
    );
    return '$_temp0';
  }

  @override
  String get linkPlayerLoadMore => 'Load more';

  @override
  String linkPlayerOptionsTitle(String player, String team) {
    return 'Link $player to $team';
  }

  @override
  String get linkPlayerOptionsHint =>
      'Pick the competitions he will play for the team. With none, he joins the general squad with this as his main team.';

  @override
  String get linkPlayerMakeMain => 'Make main team';

  @override
  String get linkPlayerMakeMainHint =>
      'The team shown on the player profile and in the overall ranking.';

  @override
  String get linkPlayerAlready => 'Already plays for this team';

  @override
  String get linkPlayerTransfer => 'Transfer';

  @override
  String get linkPlayerTransferTitle => 'Confirm transfer?';

  @override
  String linkPlayerTransferMessage(String player, String championships) {
    return '$player stops playing for the old team in: $championships. His numbers in those competitions stay.';
  }

  @override
  String get linkPlayerSave => 'LINK';

  @override
  String linkPlayerDone(String player, String team) {
    return '$player linked to $team!';
  }

  @override
  String get linkPlayerPickTeam => 'Pick the team';

  @override
  String get linkPlayerNoChampionships =>
      'The team is not enrolled in any competition this season: the player joins the general squad.';

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
  String get standingsColGoalDiff => 'GD';

  @override
  String get standingsColPoints => 'PTS';

  @override
  String groupsTeamsCount(int count) {
    return '$count teams';
  }

  @override
  String groupsGamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
      zero: '0 games',
    );
    return '$_temp0';
  }

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
  String get standingsLeader => 'Leader';

  @override
  String get standingsNoGamesYet => 'No games played in this group yet';

  @override
  String standingsGoalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goals',
      one: '1 goal',
      zero: '0 goals',
    );
    return '$_temp0';
  }

  @override
  String standingsRecord(int wins, int draws, int losses) {
    return '${wins}W ${draws}D ${losses}L';
  }

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
  String athleteClaimTitle(String name) {
    return 'Is this you, $name?';
  }

  @override
  String get athleteClaimHint =>
      'Ask to link this player to your account: his goals and assists become yours.';

  @override
  String get athleteClaimAction => 'It\'s me, request link';

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
  String get playerRequestChampionshipChoose => 'Choose the competition';

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
  String get playerRequestOwnPlayerTitle => 'Your athlete profile';

  @override
  String get playerRequestOwnPlayerMessage =>
      'The request uses your profile: your numbers stay.';

  @override
  String get playerRequestSameNameHeader => 'Athlete found';

  @override
  String playerRequestSameNameTitle(String name, String team) {
    return 'Are you $name from $team?';
  }

  @override
  String get playerRequestSameNameMessage =>
      'There is already an athlete with your name in this squad, without an account. If it is you, the request links your account to them and their numbers stay.';

  @override
  String get playerRequestSameNameMergeMessage =>
      'There is already an athlete with your name in this squad, without an account. If it is you, the admin merges that profile with yours and the numbers add up.';

  @override
  String playerRequestOwnPlayerClaimed(String name) {
    return 'You said you are $name from the squad: the admin merges both profiles on approval.';
  }

  @override
  String get playerRequestSameNameYes => 'It\'s me';

  @override
  String get playerRequestSameNameNo => 'It\'s not me';

  @override
  String playerRequestPlayerNumbers(int goals, int assists) {
    return '$goals goals · $assists assists';
  }

  @override
  String get playerRequestNameTooLong => 'Use up to 40 letters in the name';

  @override
  String get playerRequestNoTeams =>
      'No team available in this region for the chosen competition';

  @override
  String get playerRequestChampionshipsError =>
      'Couldn\'t load the region\'s competitions';

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
  String get rejectReasonMessage =>
      'The reason is optional and is shown to whoever made the request.';

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
  String get championshipClosedBadge => 'FINISHED';

  @override
  String get championshipClose => 'Finish competition';

  @override
  String get championshipReopen => 'Reopen competition';

  @override
  String championshipCloseTitle(String title) {
    return 'Finish $title';
  }

  @override
  String get championshipCloseHint =>
      'Pick the champion (and the runner-up, if you want). Once finished, no one can add matches or enroll teams or players; existing matches can still be edited.';

  @override
  String get championshipCloseNoTeams =>
      'The competition has no enrolled teams.';

  @override
  String get championshipChampionLabel => 'Champion';

  @override
  String get championshipRunnerUpLabel => 'Runner-up';

  @override
  String get championshipCloseConfirm => 'FINISH';

  @override
  String championshipClosedDone(String team) {
    return 'Competition finished! $team is the champion.';
  }

  @override
  String get championshipReopenTitle => 'Reopen the competition?';

  @override
  String get championshipReopenMessage =>
      'The champion is removed and the champion card leaves the feed. Matches and enrollments are allowed again.';

  @override
  String get championshipReopenDone => 'Competition reopened.';

  @override
  String get championshipChampionTitle => 'CHAMPION';

  @override
  String championshipRunnerUp(String team) {
    return 'Runner-up: $team';
  }

  @override
  String championshipClosedChip(String team) {
    return 'Finished · $team';
  }

  @override
  String get championshipClosedShort => 'Finished';

  @override
  String championCardSeason(String season) {
    return 'Season $season';
  }

  @override
  String get championCardAction => 'See competition';

  @override
  String get championshipsPrevious => 'Previous';

  @override
  String get championshipTabOverview => 'Overview';

  @override
  String get championshipTabMatches => 'Matches';

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
  String get matchRoundTitle => 'Stage';

  @override
  String get matchRoundPick => 'Match stage';

  @override
  String get matchRoundNone => 'No stage set';

  @override
  String get matchRoundGroupsSection =>
      'Group stage · counts in the group table';

  @override
  String get matchRoundKnockoutSection =>
      'Knockout · does not count in the table';

  @override
  String matchRoundGroup(String name) {
    return 'Group $name';
  }

  @override
  String get matchRoundSuggested =>
      'Suggested by the teams: both are in this group.';

  @override
  String matchRoundMismatch(String group) {
    return 'The teams are not in $group: the match will not count in the table.';
  }

  @override
  String get matchStageRoundOf16 => 'Round of 16';

  @override
  String get matchStageQuarterFinal => 'Quarter-final';

  @override
  String get matchStageSemiFinal => 'Semi-final';

  @override
  String get matchStageThirdPlace => 'Third-place match';

  @override
  String get matchStageFinal => 'Final';

  @override
  String get matchStageOther => 'Other stage (knockout)';

  @override
  String get matchStageBadgeRoundOf16 => 'ROUND OF 16';

  @override
  String get matchStageBadgeQuarterFinal => 'QUARTER-FINAL';

  @override
  String get matchStageBadgeSemiFinal => 'SEMI-FINAL';

  @override
  String get matchStageBadgeThirdPlace => '3RD PLACE';

  @override
  String get matchStageBadgeFinal => 'FINAL';

  @override
  String get matchStageBadgeOther => 'KNOCKOUT';

  @override
  String get matchdayTitle => 'Matchday';

  @override
  String get matchdayNone => 'No matchday';

  @override
  String matchdayValue(int number) {
    return 'Matchday $number';
  }

  @override
  String matchdayBadge(int number) {
    return 'MATCHDAY $number';
  }

  @override
  String get matchdaySuggested =>
      'Matchday suggested by the competition games near this date.';

  @override
  String get matchdayLess => 'Previous matchday';

  @override
  String get matchdayMore => 'Next matchday';

  @override
  String get fantasyTitle => 'Arena Fantasy';

  @override
  String get fantasyActive => 'Fantasy enabled';

  @override
  String get fantasyActiveOn =>
      'Fans can join and pick their team in the open matchdays of this championship.';

  @override
  String get fantasyActiveOff =>
      'Off: nobody joins or changes lineups. Nothing is deleted (history and points stay).';

  @override
  String fantasyParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String get fantasyParams => 'Scoring';

  @override
  String get fantasyMinMinutes => 'Minimum to score';

  @override
  String get fantasyMinMinutesHint => 'Below this the player scores nothing.';

  @override
  String get fantasyDefenseMinutes => 'Minimum for the clean-sheet bonus';

  @override
  String get fantasyDefenseMinutesHint =>
      'Clean sheet only counts with this time on the pitch.';

  @override
  String get fantasyCaptain => 'Captain multiplier';

  @override
  String get fantasyCaptainHint => 'Also applies to negative scores.';

  @override
  String fantasyMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get fantasyRestoreDefaults =>
      'Restore defaults (20 min · 45 min · 1.5×)';

  @override
  String get fantasyParamsNote =>
      'Settings apply to upcoming matchdays: each matchday keeps its own when it closes, and closed matchdays never change.';

  @override
  String get fantasySave => 'Save';

  @override
  String get fantasySaved => 'Arena Fantasy saved.';

  @override
  String get fantasySaveError => 'Could not save Arena Fantasy.';

  @override
  String get fantasyErrorRange => 'Minutes go from 0 to 120.';

  @override
  String get fantasyErrorDefenseBelowMin =>
      'The clean-sheet minimum cannot be lower than the minimum to score.';

  @override
  String get fantasyErrorCaptain => 'The captain goes from 1× to 3×.';

  @override
  String get fantasySlotGoalkeeper => 'GK';

  @override
  String get fantasySlotDefender => 'DEF';

  @override
  String get fantasySlotMidfielder => 'MID';

  @override
  String get fantasySlotForward => 'FWD';

  @override
  String get fantasySlotFlex => 'FLEX';

  @override
  String get fantasyPickGoalkeeper => 'Pick the goalkeeper';

  @override
  String get fantasyPickDefender => 'Pick the defender';

  @override
  String get fantasyPickMidfielder => 'Pick the midfielder';

  @override
  String get fantasyPickForward => 'Pick the forward';

  @override
  String get fantasyPickFlex => 'Pick the flex player';

  @override
  String get fantasyRoundLocked => 'Locked';

  @override
  String fantasyClosesIn(String time) {
    return 'Closes in $time';
  }

  @override
  String get fantasyCaptainShort => 'C';

  @override
  String get fantasyFilterTeam => 'Filter by team';

  @override
  String get fantasySearchAthlete => 'Search player';

  @override
  String get fantasyFilterAll => 'All';

  @override
  String get fantasyFilterAllTeams => 'All teams';

  @override
  String get fantasyNoAthletes => 'No registered player for this position.';

  @override
  String get fantasyInLineup => 'in lineup';

  @override
  String fantasyAthleteStats(int goals, int assists) {
    return '$goals G · $assists A';
  }

  @override
  String get fantasySwapAthlete => 'Swap player';

  @override
  String get fantasyMakeCaptain => 'Make captain';

  @override
  String get fantasyRemoveAthlete => 'Remove from lineup';

  @override
  String get fantasyErrorIncomplete => 'Fill the 5 spots.';

  @override
  String get fantasyErrorCaptainMissing =>
      'Pick the captain: tap a player\'s \"C\".';

  @override
  String get fantasyErrorDuplicate => 'The same player cannot take two spots.';

  @override
  String get fantasyErrorPosition => 'A player is out of the spot position.';

  @override
  String get fantasyJoined => 'You joined Arena Fantasy!';

  @override
  String get fantasyLineupSaved => 'Lineup confirmed.';

  @override
  String get fantasyLineupSaveError => 'Could not save the lineup.';

  @override
  String get fantasyConfirmLineup => 'Confirm lineup';

  @override
  String get fantasyInactive => 'Arena Fantasy is off for this championship.';

  @override
  String get fantasyGuest => 'Sign in to play Arena Fantasy.';

  @override
  String get fantasyNoOpenRound =>
      'No open matchday now. The next one opens when its matches are scheduled.';

  @override
  String get fantasyNoOpenRoundShort => 'No matchday';

  @override
  String get fantasyCopiedLineup =>
      'Lineup copied from the previous matchday. Change anything until the deadline.';

  @override
  String get fantasyLockedNotice =>
      'Deadline passed: this matchday lineup is locked.';

  @override
  String fantasyCaptainTip(String mult) {
    return 'Tap \"C\" to pick the captain: they score $mult.';
  }

  @override
  String get fantasyDiscard => 'Undo changes';

  @override
  String fantasyRoundTitle(int number) {
    return 'Matchday $number';
  }

  @override
  String get fantasyJoinTitle => 'Build your Arena Fantasy team';

  @override
  String get fantasyJoinText =>
      'Pick 5 players of the championship and a captain. They score by their real performance. You play from the next open matchday.';

  @override
  String get fantasyJoin => 'Join Arena Fantasy';

  @override
  String get fantasyEntrySubtitle =>
      'Build your team with the championship players';

  @override
  String fantasyEntryRound(int number) {
    return 'Matchday $number open · build your team';
  }

  @override
  String get fantasyEntryAction => 'Play';

  @override
  String get fantasyBadgePlay => 'Pick!';

  @override
  String get fantasyBadgeIdle => 'Fantasy';

  @override
  String fantasyBadgeRoundOpen(int number) {
    return 'Matchday $number open';
  }

  @override
  String get fantasyBadgeNoRound => 'No open matchday';

  @override
  String get fantasyRankingTitle => 'Fantasy ranking';

  @override
  String get fantasyTabRound => 'Matchday';

  @override
  String get fantasyTabOverall => 'Overall';

  @override
  String get fantasyTabHistory => 'History';

  @override
  String get fantasyNoClosedRound =>
      'No closed matchday yet. The matchday ranking shows after the deadline.';

  @override
  String get fantasyRoundPartial => 'Partial: matchday games still to finish';

  @override
  String get fantasyAwaitingScore => 'Awaiting scoring';

  @override
  String get fantasyRankingEmpty => 'Nobody scored yet.';

  @override
  String get fantasyNotPlayedRound => 'You did not pick a team this matchday.';

  @override
  String get fantasyNotJoined => 'You have not joined this Arena Fantasy yet.';

  @override
  String get fantasyHistoryEmpty => 'You have not played any matchday yet.';

  @override
  String get fantasyMyPosition => 'Your position';

  @override
  String get fantasyChampionTitle => 'ARENA FANTASY CHAMPION';

  @override
  String get fantasyChampionsTitle => 'ARENA FANTASY CHAMPIONS';

  @override
  String fantasyPointsValue(String points) {
    return '$points pts';
  }

  @override
  String get fantasyUnknownAthlete => 'Player';

  @override
  String get fantasyMyTotal => 'Your Fantasy total';

  @override
  String get fantasySeeRanking => 'See ranking';

  @override
  String get fantasyFollowTitle => 'Follow up';

  @override
  String get fantasyFollowRounds => 'Matchdays and scoring';

  @override
  String get fantasyFollowParticipants => 'Participants';

  @override
  String get fantasyAdminRounds => 'Matchdays';

  @override
  String get fantasyAdminParticipants => 'Participants';

  @override
  String get fantasyAdminNoRounds =>
      'No matchday yet. Set the matchday on the championship matches.';

  @override
  String get fantasyAdminNoParticipants => 'Nobody joined yet.';

  @override
  String get fantasyAdminNoLineups => 'No lineup in a closed matchday.';

  @override
  String get fantasyStatusOpen => 'OPEN';

  @override
  String get fantasyStatusClosed => 'CLOSED';

  @override
  String get fantasyStatusEmpty => 'NO MATCHES';

  @override
  String get fantasyStatusFinished => 'FINISHED';

  @override
  String fantasyAdminDeadline(String when) {
    return 'Deadline: $when';
  }

  @override
  String fantasyAdminMatches(int finished, int total) {
    return 'Finished matches: $finished of $total';
  }

  @override
  String fantasyAdminLineups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lineups scored',
      one: '1 lineup scored',
    );
    return '$_temp0';
  }

  @override
  String fantasyAdminScoredAt(String when) {
    return 'Scored at $when';
  }

  @override
  String get fantasyAdminNotScored => 'Not scored yet';

  @override
  String fantasyAdminParams(int min, int defense, String captain) {
    return 'Settings: $min min · $defense min · $captain';
  }

  @override
  String fantasyAdminSince(int round) {
    return 'Since matchday $round';
  }

  @override
  String get fantasyAdminSinceStart => 'Since the start';

  @override
  String get fantasyLoadMore => 'Load more';

  @override
  String get fantasyRescore => 'Rescore matchdays';

  @override
  String get fantasyRescoreTitle => 'Rescore the matchdays?';

  @override
  String get fantasyRescoreText =>
      'All closed matchdays are recalculated from the current match reports. Points only change where something changed; nothing is added twice.';

  @override
  String get fantasyRescoreRequested =>
      'Rescore requested. It may take a few seconds.';

  @override
  String get fantasyRescoreError => 'Could not request the rescore.';

  @override
  String get fantasyCancel => 'Cancel';

  @override
  String get fantasyRuleBase => 'Base score';

  @override
  String get fantasyRuleGoal => 'Goals';

  @override
  String get fantasyRuleAssist => 'Assists';

  @override
  String get fantasyRuleWin => 'Win';

  @override
  String get fantasyRuleLoss => 'Loss';

  @override
  String get fantasyRuleDraw => 'Draw';

  @override
  String get fantasyRuleYellow => 'Yellow card';

  @override
  String get fantasyRuleRed => 'Red card';

  @override
  String get fantasyRuleConceded => 'Goals conceded';

  @override
  String get fantasyRuleTeamGoals => 'Team goals';

  @override
  String get fantasyRuleCleanSheet => 'Clean sheet';

  @override
  String get fantasyRulesTitle => 'Rules and scoring';

  @override
  String get fantasyRulesSeeRules => 'See the rules';

  @override
  String get fantasyRulesDefaultsNote =>
      'The minutes and the captain multiplier below are the defaults and may vary by championship.';

  @override
  String get fantasyRulesHowToPlay => 'How to play';

  @override
  String get fantasyRulesHowToPlayText =>
      'Pick 5 athletes, one per slot, and choose 1 captain. Only athletes registered in the championship can be picked.';

  @override
  String get fantasyRulesSlotGoalkeeper => 'Goalkeeper';

  @override
  String get fantasyRulesSlotDefender => 'Centre-back or full-back';

  @override
  String get fantasyRulesSlotMidfielder => 'Defensive or attacking midfielder';

  @override
  String get fantasyRulesSlotForward => 'Forward';

  @override
  String get fantasyRulesSlotFlex => 'Any position';

  @override
  String get fantasyRulesFlexNote =>
      'In the FLEX slot, the athlete scores by their registered position.';

  @override
  String get fantasyRulesRound => 'Matchday and deadline';

  @override
  String get fantasyRulesRoundLock =>
      'The lineup locks when the matchday\'s 1st match starts.';

  @override
  String get fantasyRulesRoundCopy =>
      'Didn\'t change your lineup? It is copied to the next matchday.';

  @override
  String get fantasyRulesRoundPoints =>
      'Points come after the games, from the official match report.';

  @override
  String get fantasyRulesScoring => 'Scoring';

  @override
  String get fantasyRulesPlay => 'Play';

  @override
  String get fantasyRulesPoints => 'Points';

  @override
  String get fantasyRulesScoringNote =>
      'Each goal and assist counts. A 2nd yellow becomes the red and the yellow isn\'t counted again.';

  @override
  String get fantasyRulesByPosition => 'By position';

  @override
  String get fantasyRulesPosition => 'Position';

  @override
  String get fantasyRulesConcededEach => 'Goals conceded (per goal)';

  @override
  String get fantasyRulesPositionNote =>
      'Goals conceded and team goals only count while the athlete is on the pitch. Team goals: MID only, per team goal.';

  @override
  String get fantasyRulesMinutes => 'Minutes on the pitch';

  @override
  String fantasyRulesMinutesShort(int min) {
    return 'Under $min min, only goals, assists and cards count.';
  }

  @override
  String fantasyRulesMinutesDefense(int min) {
    return 'Clean sheet only with $min min or more on the pitch.';
  }

  @override
  String get fantasyRulesCaptain => 'Captain';

  @override
  String fantasyRulesCaptainText(String mult) {
    return 'The captain scores $mult, negative points included.';
  }

  @override
  String get fantasyRulesRanking => 'Ranking';

  @override
  String get fantasyRulesRankingText =>
      'There is a ranking for each matchday and an overall one, with the sum of the matchdays.';

  @override
  String get fantasyRulesRankingTies => 'Same total = same position.';

  @override
  String get fantasyRulesRankingChampion =>
      'Champion: the highest overall total when the competition ends; ties = all champions.';

  @override
  String fantasyReasonShort(int min, int played) {
    return 'Below the $min-minute minimum (played $played): only goals, assists and cards count.';
  }

  @override
  String fantasyReasonNoBonus(int min) {
    return 'Under $min minutes on the pitch: no clean-sheet bonus.';
  }

  @override
  String get fantasyReasonNotOnField => 'Did not play.';

  @override
  String get fantasyReasonNoLineup =>
      'The match report has no lineup for the team.';

  @override
  String get fantasyReasonSubNoMinute =>
      'Substitution without the minute in the report.';

  @override
  String get fantasyReasonEstimated =>
      'Minutes estimated from the report (whole match).';

  @override
  String get fantasyReasonNoPosition => 'Player without a position.';

  @override
  String get fantasyReasonDidNotPlay => 'Did not play this matchday.';

  @override
  String get fantasyReasonNoMatches => 'No matchday game has finished yet.';

  @override
  String fantasyMinutesPlayed(int minutes) {
    return '$minutes min on the pitch';
  }

  @override
  String fantasyMinutesEstimated(int minutes) {
    return '$minutes min on the pitch (estimated)';
  }

  @override
  String get fantasyScoreTotal => 'Individual total';

  @override
  String fantasyScoreCaptain(String mult) {
    return 'Captain ($mult)';
  }

  @override
  String get fantasyScoreNotes => 'Notes';

  @override
  String get fantasyHomeEmpty => 'No active Arena Fantasy in your region.';

  @override
  String get fantasyHomeIntro =>
      'Build your team with the championship players and score by their real performance.';

  @override
  String get fantasyHomeJoin => 'Join and build your team';

  @override
  String get fantasyHomePickTeam => 'Pick your team for this matchday';

  @override
  String get fantasyHomeCopied => 'Lineup copied from the previous matchday';

  @override
  String get fantasyHomeConfirmed => 'Lineup confirmed';

  @override
  String fantasyHomePosition(int position) {
    return 'pts · #$position';
  }

  @override
  String get fantasyHomePlay => 'Pick';

  @override
  String get fantasyHomeEnter => 'Join';

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
  String get eventPollTag => 'EVENT';

  @override
  String get eventPollMenu => 'Voting event';

  @override
  String get eventPollFormTitleNew => 'New voting event';

  @override
  String get eventPollFormTitleEdit => 'Edit event';

  @override
  String get eventPollFormIntro =>
      'Create a vote for the fans: goal of the round, save of the month, best crowd…';

  @override
  String get eventPollSectionEvent => 'Event';

  @override
  String get eventPollSectionVoting => 'Voting';

  @override
  String get eventPollSectionOptions => 'Options';

  @override
  String get eventPollFieldTitle => 'Event title';

  @override
  String get eventPollFieldTitleHint => 'E.g.: Goal of the round';

  @override
  String get eventPollFieldDescription => 'Description (optional)';

  @override
  String get eventPollCoverAdd => 'Add a cover (optional)';

  @override
  String get eventPollCoverChange => 'Change cover';

  @override
  String get eventPollCoverRemove => 'Remove cover';

  @override
  String get eventPollClosesDate => 'Closing date';

  @override
  String get eventPollClosesTime => 'Closing time';

  @override
  String get eventPollShowPartial => 'Show partial results';

  @override
  String get eventPollShowPartialHint =>
      'Those who voted see the partial count. Off, results only show when it closes.';

  @override
  String eventPollOptionLabel(int number) {
    return 'Option $number';
  }

  @override
  String get eventPollOptionTitle => 'Option title';

  @override
  String get eventPollOptionTitleHint => 'E.g.: Dudu\'s goal';

  @override
  String get eventPollOptionSubtitle => 'Detail (optional)';

  @override
  String get eventPollOptionSubtitleHint => 'E.g.: Lava Jato x Volta, 2nd half';

  @override
  String get eventPollOptionLink => 'Video link (optional)';

  @override
  String get eventPollOptionLinkHint => 'Instagram, YouTube, TikTok…';

  @override
  String get eventPollOptionPhoto => 'Photo';

  @override
  String get eventPollAddOption => 'Add option';

  @override
  String get eventPollOptionsLocked =>
      'There are votes already: the options can no longer change.';

  @override
  String get eventPollErrorTitle => 'Enter the event title.';

  @override
  String get eventPollErrorRegion => 'Choose the region.';

  @override
  String get eventPollErrorClosesAt =>
      'The closing time must be in the future.';

  @override
  String get eventPollErrorFewOptions => 'The event needs at least 2 options.';

  @override
  String eventPollErrorOptionTitle(int number) {
    return 'Give option $number a title.';
  }

  @override
  String eventPollErrorOptionLink(int number) {
    return 'Option $number has an invalid link.';
  }

  @override
  String get eventPollPublish => 'PUBLISH EVENT';

  @override
  String get eventPollSaveChanges => 'SAVE CHANGES';

  @override
  String get eventPollPublished => 'Event published!';

  @override
  String get eventPollSaved => 'Event updated!';

  @override
  String eventPollEndsIn(String time) {
    return 'Ends in $time';
  }

  @override
  String get eventPollEnded => 'Closed';

  @override
  String get eventPollVoteNow => 'VOTE';

  @override
  String get eventPollSeeResult => 'SEE RESULTS';

  @override
  String get eventPollSeeOptions => 'SEE OPTIONS';

  @override
  String eventPollOptionsCount(int count) {
    return '$count options';
  }

  @override
  String eventPollVotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
      zero: 'no votes',
    );
    return '$_temp0';
  }

  @override
  String eventPollWatchOn(String network) {
    return 'Watch on $network';
  }

  @override
  String get eventPollOpenLink => 'Watch video';

  @override
  String eventPollVoteFor(String option) {
    return 'VOTE FOR $option';
  }

  @override
  String eventPollConfirmTitle(String option) {
    return 'Vote for $option?';
  }

  @override
  String get eventPollConfirmMessage =>
      'You only get one vote and it can\'t be changed.';

  @override
  String get eventPollConfirm => 'Vote';

  @override
  String get eventPollVoted => 'Vote recorded!';

  @override
  String get eventPollYourVote => 'Your vote';

  @override
  String get eventPollHiddenResult =>
      'Vote recorded. Results come out when it closes.';

  @override
  String get eventPollWinner => 'WINNER';

  @override
  String get eventPollTie => 'TIE';

  @override
  String get eventPollNoVotes => 'No votes recorded.';

  @override
  String get eventPollSignIn => 'Sign in to vote.';

  @override
  String get eventPollTapToVote => 'Pick an option and confirm your vote.';

  @override
  String get eventPollClosedNotice => 'Voting closed.';

  @override
  String get eventPollCloseNow => 'Close now';

  @override
  String get eventPollCloseConfirm => 'Close the vote now?';

  @override
  String get eventPollCloseMessage =>
      'Nobody else can vote and the results show for everyone.';

  @override
  String get eventPollNotFound => 'This event is no longer available.';

  @override
  String get eventPollPartial => 'Partial';

  @override
  String get eventPollFinal => 'Final result';

  @override
  String get eventPollShareResult => 'Share result';

  @override
  String get eventArtTitle => 'Result art';

  @override
  String get eventArtResultSeal => 'RESULT';

  @override
  String eventArtClosedOn(String date) {
    return 'Closed on $date';
  }

  @override
  String get eventArtTemplateChampion => 'Champion';

  @override
  String get eventArtTemplatePodium => 'Podium';

  @override
  String get eventArtTemplateRanking => 'Ranking';

  @override
  String eventArtShareText(
      String event, String winner, int percent, String link) {
    return '🏆 Result: $event — $winner won with $percent%!\n$link';
  }

  @override
  String eventArtShareTie(String event, String names, String link) {
    return '🏆 Result: $event — a tie between $names!\n$link';
  }

  @override
  String get fanCardMember => 'FAN MEMBER';

  @override
  String get fanCardFlipHint => 'Tap the card to flip it';

  @override
  String fanCardValidSeason(String season) {
    return 'Valid for the $season season';
  }

  @override
  String get fanCardBackCta => 'Get Arena and cheer together';

  @override
  String get fanCardSignature => 'Fan signature';

  @override
  String get fanCardLevelSection => 'Your fan level';

  @override
  String get fanCardSeeAchievements => 'See achievements';

  @override
  String get fanCardActionShare => 'Share';

  @override
  String get fanCardActionPhoto => 'Photo';

  @override
  String get fanCardActionTeam => 'Team';

  @override
  String fanCardBackStats(String level, int xp, int count) {
    return '$level · $xp XP · $count achievements';
  }

  @override
  String get fanCardMaxLevel => 'Top level reached!';

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
  String get statsShortcutGoalsHint => 'Top scorers';

  @override
  String get statsShortcutAssistsHint => 'Top playmakers';

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
  String get deepLinkAlbumClosed => 'The sticker album is not open right now.';

  @override
  String get deepLinkMatchNotFound => 'This match is no longer available.';

  @override
  String get deepLinkHighlightNotFound =>
      'This highlight is no longer available.';

  @override
  String fantasyTopAthletesTitle(int round) {
    return 'Top players of round $round';
  }

  @override
  String get fantasyTopAthletesEmpty => 'No player scored in this round.';

  @override
  String get fantasySeeAll => 'See all';

  @override
  String get fantasyTabAthletes => 'Players';

  @override
  String fantasyCardBadge(int round) {
    return 'ARENA FANTASY · ROUND $round';
  }

  @override
  String get fantasyCardTitle => 'Top players of the round';

  @override
  String get fantasyCardAction => 'Pick my team';

  @override
  String fantasyCardPoints(String points) {
    return '$points pts';
  }

  @override
  String get pushActionFantasyRound => 'Arena Fantasy';

  @override
  String get pushActionFantasyRoundHint =>
      'Region · top players when the round is scored';

  @override
  String get reportStartersFull =>
      'There are already 11 starters. Remove one to add another.';

  @override
  String fantasyRoundInProgress(int round) {
    return 'Round $round in progress. The next round opens when all matches are over.';
  }

  @override
  String get fantasyRoundInProgressShort => 'In progress';

  @override
  String fantasyRoundScoreTitle(int round) {
    return 'Your score in round $round';
  }

  @override
  String fantasyRoundPartialCount(int done, int total) {
    return 'Partial · $done of $total matches';
  }

  @override
  String get fantasyRoundFinal => 'Final';

  @override
  String get fantasySwitchResult => 'Result';

  @override
  String get fantasySwitchPick => 'Pick team';

  @override
  String get fantasyResetMenu => 'Reset scores (testing)';

  @override
  String get fantasyResetTitle => 'Reset the scores of this Fantasy?';

  @override
  String get fantasyResetText =>
      'For the testing phase: every participant total goes back to 0, lineups lose their points, each player round score is deleted, the champion is cleared and the \"Top players of the round\" cards leave the feed. Participants, lineups and rounds stay. Points only come back with \"Rescore rounds\" or when a round match finishes again.';

  @override
  String get fantasyResetContinue => 'Continue';

  @override
  String get fantasyResetSureTitle => 'Are you sure?';

  @override
  String get fantasyResetSureText => 'This cannot be undone.';

  @override
  String get fantasyResetAction => 'Reset scores';

  @override
  String get fantasyResetRequested =>
      'Request sent: scores will be reset in a moment.';

  @override
  String get fantasyResetError => 'Could not request the score reset.';

  @override
  String get matchFormTest => 'Test match';

  @override
  String get matchFormTestHint =>
      'Only admins see it · pushes go to admins only · does not count in standings or player stats';

  @override
  String get matchTestBadge => 'TEST';

  @override
  String get homeModeFan => 'Fan mode';

  @override
  String get homeModeFanBanner => 'Fan mode: you see the app as a regular user';

  @override
  String get fantasyRoundClose => 'Close now';

  @override
  String get fantasyRoundReopen => 'Reopen';

  @override
  String fantasyRoundCloseTitle(int round) {
    return 'Close round $round now?';
  }

  @override
  String get fantasyRoundCloseText =>
      'Lineups lock right away (this round parameters are frozen) and are copied to the next round. To undo, use \"Reopen\".';

  @override
  String get fantasyRoundCloseRequested =>
      'Request sent: the round will close in a moment.';

  @override
  String get fantasyRoundOpenRequested =>
      'Request sent: the round will reopen in a moment.';

  @override
  String get fantasyRoundActionError => 'Could not change the round.';

  @override
  String get fantasyRoundDeadlinePast => 'Pick a deadline in the future.';

  @override
  String get fantasyRoundManualDeadline => 'Deadline set by the admin';

  @override
  String get fantasyRoundManualClosed => 'Closed by the admin';

  @override
  String get athleteInviteAction => 'I know this player';

  @override
  String athleteInviteTitle(String name) {
    return '⚽ $name, you are already on Arena Football!';
  }

  @override
  String athleteInviteTeam(String team) {
    return 'from $team';
  }

  @override
  String athleteInviteTeamIn(String team, String championship) {
    return 'from $team in $championship';
  }

  @override
  String athleteInviteStats(int goals, int assists) {
    return 'and your numbers are already there: $goals goals and $assists assists. 🔥';
  }

  @override
  String get athleteInviteNoStats =>
      'and your player page is already waiting for you. 🔥';

  @override
  String athleteInviteBody(String name, String where, String numbers) {
    return 'The player $name $where looks like you — $numbers';
  }

  @override
  String get athleteInviteBenefits =>
      'Create your free account, tap \"That\'s me\" and carry your career in your pocket:\n📊 your goals and assists in every competition\n🏆 run for player of the match\n🎴 your sticker in the album\n🖼️ player artwork to post';

  @override
  String get athleteInviteCta =>
      '👉 Tap the link, get the app and confirm it\'s you:';

  @override
  String get athleteInviteCardTitle => 'You are on Arena Football!';

  @override
  String get athleteInviteCardGoals => 'GOALS';

  @override
  String get athleteInviteCardAssists => 'ASSISTS';

  @override
  String get athleteInviteCardCta =>
      'Create your account and say: \"That\'s me!\"';

  @override
  String get athleteInviteSheetTitle => 'Invite player';

  @override
  String get fantasyStatusPartial => 'PARTIAL';

  @override
  String get fantasyStatusFinal => 'FINAL';

  @override
  String get fantasyStatusAwaiting => 'AWAITING SCORE';

  @override
  String get fantasyYou => 'YOU';

  @override
  String fantasyChase(String points, String name) {
    return '$points pts to pass $name';
  }

  @override
  String get fantasyLeading => 'You\'re leading!';

  @override
  String get fantasyHeroPoints => 'your pts';

  @override
  String get fantasyHeroPosition => 'your place';

  @override
  String get fantasyHeroParticipants => 'players';

  @override
  String get fantasyOverallTitle => 'OVERALL STANDINGS';

  @override
  String get fantasyTopAthletesHeader => 'Top scorers of the round';

  @override
  String get fantasyTiedShort => 'tie';

  @override
  String fantasyGapBehind(String points, int position) {
    return '$points pts behind #$position';
  }

  @override
  String get appUpdateRequiredTitle => 'Update Arena Football';

  @override
  String get appUpdateRequiredText =>
      'This app version is no longer supported. Update to keep using it.';

  @override
  String get appUpdateRecommendedTitle => 'New version available!';

  @override
  String get appUpdateRecommendedText =>
      'Update the app to get the latest features and fixes.';

  @override
  String get appUpdateNow => 'Update now';

  @override
  String get appUpdateAction => 'Update';

  @override
  String get appUpdateLater => 'Later';

  @override
  String get appVersionTitle => 'App version';

  @override
  String get appVersionIntro =>
      'Users below the recommended build see \"New version available\" (they can postpone). Below the minimum, the app is blocked until they update.';

  @override
  String appVersionInstalled(String platform, String name, int build) {
    return 'This device: $platform $name (build $build)';
  }

  @override
  String get appVersionUseInstalled => 'Use as recommended';

  @override
  String get appVersionRecommended => 'Recommended build';

  @override
  String get appVersionRecommendedHint => 'Suggests updating (can postpone)';

  @override
  String get appVersionMinimum => 'Minimum build';

  @override
  String get appVersionMinimumHint => 'Below it, the app is blocked';

  @override
  String get appVersionMessage => 'Notice message (optional)';

  @override
  String get appVersionMessageHint => 'E.g.: Arena Fantasy is here!';

  @override
  String get appVersionHelp =>
      'The build is the number after \"+\" in the pubspec (2.0.18+43 → 43), the same on Android and iOS. Android: shown in the Play Console as 43 (2.0.18). iOS: in App Store Connect/TestFlight as 1.0.18 (43) — the public App Store shows only the name. Publish the version in the store before raising these numbers.';

  @override
  String get appVersionSave => 'Save';

  @override
  String get appVersionSaved => 'Versions saved.';

  @override
  String get appVersionSaveError => 'Could not save the versions.';

  @override
  String get appVersionRaiseTitle => 'Raise the minimum version?';

  @override
  String appVersionRaiseText(int android, int ios) {
    return 'Users below build $android (Android) or $ios (iOS) are blocked until they update the app.';
  }

  @override
  String get achievementFieldPacks => 'Reward: sticker packs';

  @override
  String achievementPacksPill(int count) {
    return '🎁 +$count';
  }

  @override
  String achievementPacksWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🎁 You won $count sticker packs! Open them in the album.',
      one: '🎁 You won 1 sticker pack! Open it in the album.',
    );
    return '$_temp0';
  }

  @override
  String get achievementOpenAlbum => 'Open the album';

  @override
  String get fantasyResetTeamsMenu => 'Reset team points…';

  @override
  String get fantasyResetTeamsTitle => 'Reset team points';

  @override
  String get fantasyResetTeamsText =>
      'Players from these teams lose their points in every round of this Fantasy, and the totals of whoever picked them are recalculated. If the test matches still exist, the points come back on the next round scoring: delete them (or remove their round) first.';

  @override
  String get fantasyResetTeamsPick => 'Pick the team';

  @override
  String get fantasyResetTeamsAdd => 'Add team';

  @override
  String get fantasyResetTeamsAction => 'Reset points';
}
