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
