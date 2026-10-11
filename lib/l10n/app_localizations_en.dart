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
  String get newsCreateTitle => 'ADD NEWS';

  @override
  String get newsEditTitle => 'EDIT NEWS';

  @override
  String get newsTitleLabel => 'Title';

  @override
  String get newsDescriptionLabel => 'Description';

  @override
  String get newsTagLabel => 'Tag';

  @override
  String get newsLinkLabel => 'Link';

  @override
  String get newsVisibleLabel => 'Show news';

  @override
  String get newsAttachPhotos => 'ATTACH PHOTOS';

  @override
  String get newsRegisterButton => 'SAVE';

  @override
  String get newsUpdateButton => 'UPDATE';

  @override
  String get newsTitleRequired => 'The news needs a title!';

  @override
  String get newsTitleTooShort =>
      'The news title must have at least 3 characters';

  @override
  String get newsCreated => 'News created successfully!';

  @override
  String get newsUpdated => 'News updated successfully!';

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
  String playersTeamInfo(String team) {
    return 'Team: $team';
  }

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
  String get statsGoalsTitle => 'TOP SCORERS';

  @override
  String get statsAssistsTitle => 'ASSISTS';

  @override
  String get statsEmpty => 'No players in the ranking yet.';

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
  String get championshipsGroupsEmpty => 'Empty';

  @override
  String get championshipsGroupsLoadError => 'Could not load the groups.';

  @override
  String get championshipsStandingsEmpty => 'Empty';

  @override
  String get championshipsStandingsLoadError => 'Could not load the standings.';

  @override
  String championshipsStandingsPosition(int position) {
    return '#$position';
  }

  @override
  String get championshipsStandingsWins => 'W';

  @override
  String get championshipsStandingsLosses => 'L';

  @override
  String get championshipsStandingsDraws => 'D';

  @override
  String get championshipsStandingsPoints => 'Pts';

  @override
  String get championshipsStandingsGoalsFor => 'GF';

  @override
  String get championshipsStandingsGoalsAgainst => 'GA';

  @override
  String get championshipsStandingsGoalDifference => 'GD';

  @override
  String get votingTitle => 'Best Player of the Match';

  @override
  String get votingNotice =>
      'Attention: ONE VOTE PER PERSON! You can change your vote as many times as you want, but only the last vote counts!';

  @override
  String get votingVoteButton => 'VOTE';

  @override
  String get votingBlankVote => 'Blank vote! Try again.';

  @override
  String votingVoteRegistered(String player) {
    return 'Vote registered! You voted for $player. Thank you for voting.';
  }

  @override
  String get votingLoginRequired => 'Log in to vote.';

  @override
  String get votingElectedLabel => 'Elected best player of the match: ';

  @override
  String votingVotesCount(int count) {
    return 'Number of votes: $count';
  }

  @override
  String get votingNoVotes => 'No votes registered for this match.';

  @override
  String get votingLoadError => 'Could not count the votes.';

  @override
  String get globalResultsTitle => 'RESULTS AROUND THE WORLD';

  @override
  String get globalResultsYesterday => 'Yesterday';

  @override
  String get globalResultsToday => 'Today';

  @override
  String get globalResultsTomorrow => 'Tomorrow';

  @override
  String get globalResultsEmpty => 'No matches found.';

  @override
  String get globalResultsTomorrowUnavailable =>
      'Tomorrow\'s matches are not available yet.';

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
}
