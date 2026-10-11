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
  String get drawerRegisterHighlight => 'Add highlight';

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
  String get newsGoalTitle => 'New Goal Card:';

  @override
  String get newsHomeTeamLabel => 'Home team:';

  @override
  String get newsAwayTeamLabel => 'Away team:';

  @override
  String get newsScoreLabel => 'Score:';

  @override
  String get newsPublishButton => 'Publish';

  @override
  String get newsGoalCreated => 'Goal posted successfully!';

  @override
  String get newsGoalTeamsRequired => 'Select both teams!';

  @override
  String get newsAdTitle => 'New Advertisement Card:';

  @override
  String get newsAdCreated => 'Advertisement posted successfully!';

  @override
  String get highlightFormTitle => 'ADD HIGHLIGHT';

  @override
  String get highlightTitleLabel => 'Title';

  @override
  String get highlightLinkLabel => 'Link';

  @override
  String get highlightVisibleLabel => 'Show highlight';

  @override
  String get highlightRegisterButton => 'SAVE';

  @override
  String get highlightTitleRequired => 'Fill in the TITLE field!';

  @override
  String get highlightCreated => 'Highlight created!';

  @override
  String get highlightNoNews => 'No news available!';

  @override
  String get teamsEmpty => 'No teams registered yet';

  @override
  String get teamsLoadError => 'Could not load the teams.';

  @override
  String get teamsFormTitle => 'ADD TEAM';

  @override
  String get teamsRegionLabel => 'Region:';

  @override
  String get teamsNameLabel => 'Team';

  @override
  String get teamsDescriptionLabel => 'Description';

  @override
  String get teamsRegisterButton => 'SAVE';

  @override
  String get teamsCreated => 'Team created!';

  @override
  String get teamsNameRequired => 'Fill in the required fields!';

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
  String get playersNameRequired => 'Fill in the NAME field!';

  @override
  String get playersTeamRequired => 'Choose a team!';

  @override
  String get playersFormTitle => 'ADD PLAYER';

  @override
  String get playersNameLabel => 'Name';

  @override
  String get playersGoalsLabel => 'Goals';

  @override
  String get playersAssistsLabel => 'Assists';

  @override
  String get playersTeamLabel => 'Team:';

  @override
  String get playersRegisterButton => 'SAVE';

  @override
  String get playersCreated => 'Player created!';

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
  String get matchesFormTitle => 'REGISTER MATCH';

  @override
  String get matchesRegionLabel => 'Region:';

  @override
  String get matchesHomeTeamLabel => 'Home Team:';

  @override
  String get matchesAwayTeamLabel => 'Away Team:';

  @override
  String get matchesDateLabel => 'Date';

  @override
  String get matchesTimeLabel => 'Time';

  @override
  String get matchesVenueLabel => 'Venue';

  @override
  String get matchesRegisterButton => 'REGISTER';

  @override
  String get matchesCreated => 'Match registered successfully!';

  @override
  String get matchesFieldsRequired => 'Fill in all the fields!';

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
}
