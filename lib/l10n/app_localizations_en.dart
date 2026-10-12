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
  String get drawerHome => 'Home';

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
    return '⚽ $scorer';
  }

  @override
  String goalScorerAssistLine(String scorer, String assistant) {
    return '⚽ $scorer · assist $assistant';
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
  String get statsLoadError => 'Could not load the ranking.';

  @override
  String get matchesNoChampionship => 'No records at the moment';

  @override
  String get matchesEmpty => 'No matches registered';

  @override
  String get matchesLoadError => 'Could not load the matches.';

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
  String get loginWelcomeTitle => 'Welcome back 👋';

  @override
  String get loginWelcomeSubtitle =>
      'Sign in to follow your team, the matches and the standings.';

  @override
  String get loginForgotPassword => 'Forgot my password';

  @override
  String get loginOr => 'or';

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
  String get chooseTeamSkip => 'Skip for now';

  @override
  String get chooseTeamLoadError => 'Could not load the regions and teams.';

  @override
  String get chooseTeamEmptyTeams => 'No teams registered in this region.';

  @override
  String get drawerNavigation => 'Navigation';

  @override
  String get drawerAdmin => 'Administration';

  @override
  String get drawerLogout => 'Sign out';

  @override
  String get drawerSignIn => 'Sign in or create account';

  @override
  String get drawerGuestSubtitle =>
      'Sign in to save your team and vote for the best player.';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name 👋';
  }

  @override
  String get homeGreetingGuest => 'Welcome to Arena 👋';

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
}
