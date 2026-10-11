import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Arena Football'**
  String get appTitle;

  /// No description provided for @commonRequiredField.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get commonRequiredField;

  /// No description provided for @commonTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get commonTryAgain;

  /// No description provided for @commonLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get commonLoading;

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonGenericError.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente novamente.'**
  String get commonGenericError;

  /// No description provided for @loginEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'ENTRAR'**
  String get loginButton;

  /// No description provided for @loginCreateAccountButton.
  ///
  /// In pt, this message translates to:
  /// **'CRIAR CONTA'**
  String get loginCreateAccountButton;

  /// No description provided for @loginSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Usuário Logado!'**
  String get loginSuccess;

  /// No description provided for @loginInvalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido!'**
  String get loginInvalidEmail;

  /// No description provided for @loginInvalidPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha inválida! Utilize no mínimo 8 caracteres.'**
  String get loginInvalidPassword;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get registerTitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get registerNameLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get registerPasswordLabel;

  /// No description provided for @registerRegionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Região'**
  String get registerRegionLabel;

  /// No description provided for @registerTeamLabel.
  ///
  /// In pt, this message translates to:
  /// **'Time do coração'**
  String get registerTeamLabel;

  /// No description provided for @registerHaveAccountButton.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho uma conta!'**
  String get registerHaveAccountButton;

  /// No description provided for @registerSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Usuário Cadastrado com Sucesso!'**
  String get registerSuccess;

  /// No description provided for @registerNameTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome de usuário deve conter no mínimo 3 caracteres'**
  String get registerNameTooShort;

  /// No description provided for @registerEmailExample.
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido, ex.: nome@email.com'**
  String get registerEmailExample;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Sua senha deve conter no mínimo 8 caracteres'**
  String get registerPasswordTooShort;

  /// No description provided for @homeTabHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get homeTabHome;

  /// No description provided for @homeTabChampionships.
  ///
  /// In pt, this message translates to:
  /// **'Campeonatos'**
  String get homeTabChampionships;

  /// No description provided for @homeTabTeams.
  ///
  /// In pt, this message translates to:
  /// **'Times'**
  String get homeTabTeams;

  /// No description provided for @homeTabTables.
  ///
  /// In pt, this message translates to:
  /// **'Tabelas'**
  String get homeTabTables;

  /// No description provided for @drawerHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get drawerHome;

  /// No description provided for @drawerResults.
  ///
  /// In pt, this message translates to:
  /// **'Resultados pelo mundo'**
  String get drawerResults;

  /// No description provided for @drawerRegisterHighlight.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar destaque'**
  String get drawerRegisterHighlight;

  /// No description provided for @drawerRegisterPlayer.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar jogador'**
  String get drawerRegisterPlayer;

  /// No description provided for @drawerRegisterMatch.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar partida'**
  String get drawerRegisterMatch;

  /// No description provided for @drawerRegisterNews.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar notícia'**
  String get drawerRegisterNews;

  /// No description provided for @drawerRegisterTeam.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar time'**
  String get drawerRegisterTeam;

  /// No description provided for @drawerFanOf.
  ///
  /// In pt, this message translates to:
  /// **'Torcedor do {team}'**
  String drawerFanOf(String team);

  /// No description provided for @drawerGuest.
  ///
  /// In pt, this message translates to:
  /// **'Visitante'**
  String get drawerGuest;

  /// No description provided for @commonTakePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get commonTakePhoto;

  /// No description provided for @commonGallery.
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get commonGallery;

  /// No description provided for @newsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma notícia registrada'**
  String get newsEmpty;

  /// No description provided for @newsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as notícias.'**
  String get newsLoadError;

  /// No description provided for @newsDeleteConfirm.
  ///
  /// In pt, this message translates to:
  /// **'DESEJA REALMENTE EXCLUIR ESSA NOTÍCIA ?'**
  String get newsDeleteConfirm;

  /// No description provided for @newsAdPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'PUBLICIDADE'**
  String get newsAdPlaceholder;

  /// No description provided for @newsCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR NOTICIA'**
  String get newsCreateTitle;

  /// No description provided for @newsEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'EDITAR NOTÍCIA'**
  String get newsEditTitle;

  /// No description provided for @newsTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get newsTitleLabel;

  /// No description provided for @newsDescriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get newsDescriptionLabel;

  /// No description provided for @newsTagLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tag'**
  String get newsTagLabel;

  /// No description provided for @newsLinkLabel.
  ///
  /// In pt, this message translates to:
  /// **'Link'**
  String get newsLinkLabel;

  /// No description provided for @newsVisibleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Exibir notícia'**
  String get newsVisibleLabel;

  /// No description provided for @newsAttachPhotos.
  ///
  /// In pt, this message translates to:
  /// **'ANEXAR FOTOS'**
  String get newsAttachPhotos;

  /// No description provided for @newsRegisterButton.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR'**
  String get newsRegisterButton;

  /// No description provided for @newsUpdateButton.
  ///
  /// In pt, this message translates to:
  /// **'ATUALIZAR'**
  String get newsUpdateButton;

  /// No description provided for @newsTitleRequired.
  ///
  /// In pt, this message translates to:
  /// **'A notícia precisa de um título!!!'**
  String get newsTitleRequired;

  /// No description provided for @newsTitleTooShort.
  ///
  /// In pt, this message translates to:
  /// **'O título da notícia deve conter no mínimo 3 caracteres'**
  String get newsTitleTooShort;

  /// No description provided for @newsCreated.
  ///
  /// In pt, this message translates to:
  /// **'Notícia Cadastrada com Sucesso!!!'**
  String get newsCreated;

  /// No description provided for @newsUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Notícia Atualizada com Sucesso!!!'**
  String get newsUpdated;

  /// No description provided for @newsRegionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Região:'**
  String get newsRegionLabel;

  /// No description provided for @newsGoalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Card de Gol:'**
  String get newsGoalTitle;

  /// No description provided for @newsHomeTeamLabel.
  ///
  /// In pt, this message translates to:
  /// **'Time da Casa:'**
  String get newsHomeTeamLabel;

  /// No description provided for @newsAwayTeamLabel.
  ///
  /// In pt, this message translates to:
  /// **'Time Visitante:'**
  String get newsAwayTeamLabel;

  /// No description provided for @newsScoreLabel.
  ///
  /// In pt, this message translates to:
  /// **'Placar:'**
  String get newsScoreLabel;

  /// No description provided for @newsPublishButton.
  ///
  /// In pt, this message translates to:
  /// **'Publicar'**
  String get newsPublishButton;

  /// No description provided for @newsGoalCreated.
  ///
  /// In pt, this message translates to:
  /// **'Gol registrado com Sucesso!!!'**
  String get newsGoalCreated;

  /// No description provided for @newsGoalTeamsRequired.
  ///
  /// In pt, this message translates to:
  /// **'Selecione os dois times!'**
  String get newsGoalTeamsRequired;

  /// No description provided for @newsAdTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Card de Publicidade:'**
  String get newsAdTitle;

  /// No description provided for @newsAdCreated.
  ///
  /// In pt, this message translates to:
  /// **'Publicidade registrada com Sucesso!!!'**
  String get newsAdCreated;

  /// No description provided for @highlightFormTitle.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR DESTAQUE'**
  String get highlightFormTitle;

  /// No description provided for @highlightTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get highlightTitleLabel;

  /// No description provided for @highlightLinkLabel.
  ///
  /// In pt, this message translates to:
  /// **'Link'**
  String get highlightLinkLabel;

  /// No description provided for @highlightVisibleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Exibir destaque'**
  String get highlightVisibleLabel;

  /// No description provided for @highlightRegisterButton.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR'**
  String get highlightRegisterButton;

  /// No description provided for @highlightTitleRequired.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o campo TÍTULO!!!'**
  String get highlightTitleRequired;

  /// No description provided for @highlightCreated.
  ///
  /// In pt, this message translates to:
  /// **'Destaque Cadastrado!!!'**
  String get highlightCreated;

  /// No description provided for @highlightNoNews.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma notícia disponível!'**
  String get highlightNoNews;

  /// No description provided for @teamsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Equipes ainda não registradas'**
  String get teamsEmpty;

  /// No description provided for @teamsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os times.'**
  String get teamsLoadError;

  /// No description provided for @teamsFormTitle.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR TIME'**
  String get teamsFormTitle;

  /// No description provided for @teamsRegionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Região:'**
  String get teamsRegionLabel;

  /// No description provided for @teamsNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Time'**
  String get teamsNameLabel;

  /// No description provided for @teamsDescriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get teamsDescriptionLabel;

  /// No description provided for @teamsRegisterButton.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR'**
  String get teamsRegisterButton;

  /// No description provided for @teamsCreated.
  ///
  /// In pt, this message translates to:
  /// **'Time registrado com Sucesso!!!'**
  String get teamsCreated;

  /// No description provided for @teamsNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Preencha os campos obrigatórios!!!'**
  String get teamsNameRequired;

  /// No description provided for @playersEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Jogadores ainda não registrados!'**
  String get playersEmpty;

  /// No description provided for @playersLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os jogadores.'**
  String get playersLoadError;

  /// No description provided for @playersTeamInfo.
  ///
  /// In pt, this message translates to:
  /// **'Time: {team}'**
  String playersTeamInfo(String team);

  /// No description provided for @playersGoalsCount.
  ///
  /// In pt, this message translates to:
  /// **'Gols: {count}'**
  String playersGoalsCount(int count);

  /// No description provided for @playersAssistsCount.
  ///
  /// In pt, this message translates to:
  /// **'Assistências: {count}'**
  String playersAssistsCount(int count);

  /// No description provided for @playersNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o campo NOME!!!'**
  String get playersNameRequired;

  /// No description provided for @playersTeamRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe um Time!!!'**
  String get playersTeamRequired;

  /// No description provided for @playersFormTitle.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR JOGADOR'**
  String get playersFormTitle;

  /// No description provided for @playersNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get playersNameLabel;

  /// No description provided for @playersGoalsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Gols'**
  String get playersGoalsLabel;

  /// No description provided for @playersAssistsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Assistencias'**
  String get playersAssistsLabel;

  /// No description provided for @playersTeamLabel.
  ///
  /// In pt, this message translates to:
  /// **'Time:'**
  String get playersTeamLabel;

  /// No description provided for @playersRegisterButton.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR'**
  String get playersRegisterButton;

  /// No description provided for @playersCreated.
  ///
  /// In pt, this message translates to:
  /// **'Jogador Cadastrado!!!'**
  String get playersCreated;

  /// No description provided for @playersPhotoBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get playersPhotoBack;

  /// No description provided for @playersPhotoSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get playersPhotoSave;

  /// No description provided for @statsGoalsTitle.
  ///
  /// In pt, this message translates to:
  /// **'ARTILHARIA'**
  String get statsGoalsTitle;

  /// No description provided for @statsAssistsTitle.
  ///
  /// In pt, this message translates to:
  /// **'ASSISTENCIAS'**
  String get statsAssistsTitle;

  /// No description provided for @statsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum jogador no ranking ainda.'**
  String get statsEmpty;

  /// No description provided for @statsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o ranking.'**
  String get statsLoadError;

  /// No description provided for @matchesNoChampionship.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum registro no momento'**
  String get matchesNoChampionship;

  /// No description provided for @matchesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma partida cadastrada'**
  String get matchesEmpty;

  /// No description provided for @matchesLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as partidas.'**
  String get matchesLoadError;

  /// No description provided for @matchesAllGames.
  ///
  /// In pt, this message translates to:
  /// **'Todos os jogos'**
  String get matchesAllGames;

  /// No description provided for @matchesGroups.
  ///
  /// In pt, this message translates to:
  /// **'Grupos'**
  String get matchesGroups;

  /// No description provided for @matchesTopScorers.
  ///
  /// In pt, this message translates to:
  /// **'Artilharia'**
  String get matchesTopScorers;

  /// No description provided for @matchesAssists.
  ///
  /// In pt, this message translates to:
  /// **'Assistências'**
  String get matchesAssists;

  /// No description provided for @matchesAllGamesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Todos os jogos'**
  String get matchesAllGamesTitle;

  /// No description provided for @matchesVersus.
  ///
  /// In pt, this message translates to:
  /// **'X'**
  String get matchesVersus;

  /// No description provided for @matchesEditScore.
  ///
  /// In pt, this message translates to:
  /// **'Editar Placar'**
  String get matchesEditScore;

  /// No description provided for @matchesDeleteMatch.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Partida'**
  String get matchesDeleteMatch;

  /// No description provided for @matchesDeleteConfirm.
  ///
  /// In pt, this message translates to:
  /// **'DESEJA REALMENTE EXCLUIR ESSA PARTIDA ?'**
  String get matchesDeleteConfirm;

  /// No description provided for @matchesEditScoreTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterar Placar:'**
  String get matchesEditScoreTitle;

  /// No description provided for @matchesHomeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Casa'**
  String get matchesHomeLabel;

  /// No description provided for @matchesAwayLabel.
  ///
  /// In pt, this message translates to:
  /// **'Fora'**
  String get matchesAwayLabel;

  /// No description provided for @matchesFormTitle.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR PARTIDA'**
  String get matchesFormTitle;

  /// No description provided for @matchesRegionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Região:'**
  String get matchesRegionLabel;

  /// No description provided for @matchesHomeTeamLabel.
  ///
  /// In pt, this message translates to:
  /// **'Time Casa:'**
  String get matchesHomeTeamLabel;

  /// No description provided for @matchesAwayTeamLabel.
  ///
  /// In pt, this message translates to:
  /// **'Time Fora:'**
  String get matchesAwayTeamLabel;

  /// No description provided for @matchesDateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get matchesDateLabel;

  /// No description provided for @matchesTimeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Hora'**
  String get matchesTimeLabel;

  /// No description provided for @matchesVenueLabel.
  ///
  /// In pt, this message translates to:
  /// **'Local'**
  String get matchesVenueLabel;

  /// No description provided for @matchesRegisterButton.
  ///
  /// In pt, this message translates to:
  /// **'CADASTRAR'**
  String get matchesRegisterButton;

  /// No description provided for @matchesCreated.
  ///
  /// In pt, this message translates to:
  /// **'Partida Cadastrada com Sucesso!!!'**
  String get matchesCreated;

  /// No description provided for @matchesFieldsRequired.
  ///
  /// In pt, this message translates to:
  /// **'Preencha todos os campos!!!'**
  String get matchesFieldsRequired;

  /// No description provided for @championshipsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma competição registrada'**
  String get championshipsEmpty;

  /// No description provided for @championshipsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as competições.'**
  String get championshipsLoadError;

  /// No description provided for @championshipsDetailsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre a Competição:'**
  String get championshipsDetailsTitle;

  /// No description provided for @championshipsPrizes.
  ///
  /// In pt, this message translates to:
  /// **'PREMIAÇÃO:\n\n1º Lugar: {first}\n2º Lugar: {second}\n3º Lugar: {third}\n\nArtilheiro: {topScorer}\nMelhor Goleiro: {goalkeeper}'**
  String championshipsPrizes(String first, String second, String third,
      String topScorer, String goalkeeper);

  /// No description provided for @championshipsRules.
  ///
  /// In pt, this message translates to:
  /// **'REGRAS:\n\n{rules}'**
  String championshipsRules(String rules);

  /// No description provided for @championshipsGroupsButton.
  ///
  /// In pt, this message translates to:
  /// **'GRUPOS'**
  String get championshipsGroupsButton;

  /// No description provided for @championshipsGroupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Grupo {name}'**
  String championshipsGroupTitle(String name);

  /// No description provided for @championshipsGroupsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Vazio'**
  String get championshipsGroupsEmpty;

  /// No description provided for @championshipsGroupsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os grupos.'**
  String get championshipsGroupsLoadError;

  /// No description provided for @championshipsStandingsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Vazio'**
  String get championshipsStandingsEmpty;

  /// No description provided for @championshipsStandingsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a classificação.'**
  String get championshipsStandingsLoadError;

  /// No description provided for @championshipsStandingsPosition.
  ///
  /// In pt, this message translates to:
  /// **'#{position}'**
  String championshipsStandingsPosition(int position);

  /// No description provided for @championshipsStandingsWins.
  ///
  /// In pt, this message translates to:
  /// **'V'**
  String get championshipsStandingsWins;

  /// No description provided for @championshipsStandingsLosses.
  ///
  /// In pt, this message translates to:
  /// **'D'**
  String get championshipsStandingsLosses;

  /// No description provided for @championshipsStandingsDraws.
  ///
  /// In pt, this message translates to:
  /// **'E'**
  String get championshipsStandingsDraws;

  /// No description provided for @championshipsStandingsPoints.
  ///
  /// In pt, this message translates to:
  /// **'P'**
  String get championshipsStandingsPoints;

  /// No description provided for @championshipsStandingsGoalsFor.
  ///
  /// In pt, this message translates to:
  /// **'GF'**
  String get championshipsStandingsGoalsFor;

  /// No description provided for @championshipsStandingsGoalsAgainst.
  ///
  /// In pt, this message translates to:
  /// **'GS'**
  String get championshipsStandingsGoalsAgainst;

  /// No description provided for @championshipsStandingsGoalDifference.
  ///
  /// In pt, this message translates to:
  /// **'SG'**
  String get championshipsStandingsGoalDifference;

  /// No description provided for @votingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Melhor da Partida'**
  String get votingTitle;

  /// No description provided for @votingNotice.
  ///
  /// In pt, this message translates to:
  /// **'Atenção: O VOTO É ÚNICO! Você pode alterar sua opção de voto quantas vezes quiser, mas apenas o último voto é contabilizado!'**
  String get votingNotice;

  /// No description provided for @votingVoteButton.
  ///
  /// In pt, this message translates to:
  /// **'VOTAR'**
  String get votingVoteButton;

  /// No description provided for @votingBlankVote.
  ///
  /// In pt, this message translates to:
  /// **'Voto em branco! Tente novamente.'**
  String get votingBlankVote;

  /// No description provided for @votingVoteRegistered.
  ///
  /// In pt, this message translates to:
  /// **'Voto registrado! Você votou em {player}. Muito obrigado pelo seu voto.'**
  String votingVoteRegistered(String player);

  /// No description provided for @votingLoginRequired.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para votar.'**
  String get votingLoginRequired;

  /// No description provided for @votingElectedLabel.
  ///
  /// In pt, this message translates to:
  /// **'Eleito o melhor jogador da partida: '**
  String get votingElectedLabel;

  /// No description provided for @votingVotesCount.
  ///
  /// In pt, this message translates to:
  /// **'Número de votos: {count}'**
  String votingVotesCount(int count);

  /// No description provided for @votingNoVotes.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum voto registrado para esta partida.'**
  String get votingNoVotes;

  /// No description provided for @votingLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível apurar a votação.'**
  String get votingLoadError;

  /// No description provided for @globalResultsTitle.
  ///
  /// In pt, this message translates to:
  /// **'RESULTADOS PELO MUNDO'**
  String get globalResultsTitle;

  /// No description provided for @globalResultsYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get globalResultsYesterday;

  /// No description provided for @globalResultsToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get globalResultsToday;

  /// No description provided for @globalResultsTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get globalResultsTomorrow;

  /// No description provided for @globalResultsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum jogo encontrado.'**
  String get globalResultsEmpty;

  /// No description provided for @globalResultsTomorrowUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Os jogos de amanhã ainda não estão disponíveis.'**
  String get globalResultsTomorrowUnavailable;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta 👋'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre para acompanhar seu time, os jogos e a tabela.'**
  String get loginWelcomeSubtitle;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get loginForgotPassword;

  /// No description provided for @loginOr.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get loginOr;

  /// No description provided for @loginContinueAsGuest.
  ///
  /// In pt, this message translates to:
  /// **'Continuar sem conta'**
  String get loginContinueAsGuest;

  /// No description provided for @loginShowPassword.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get loginHidePassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar senha'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In pt, this message translates to:
  /// **'Informe o e-mail da sua conta e enviaremos um link para você criar uma nova senha.'**
  String get forgotPasswordDescription;

  /// No description provided for @forgotPasswordSend.
  ///
  /// In pt, this message translates to:
  /// **'ENVIAR LINK'**
  String get forgotPasswordSend;

  /// No description provided for @forgotPasswordSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um link de recuperação para o seu e-mail.'**
  String get forgotPasswordSent;

  /// No description provided for @registerStepOne.
  ///
  /// In pt, this message translates to:
  /// **'Etapa 1 de 2 · seus dados de acesso'**
  String get registerStepOne;

  /// No description provided for @registerCreateAccountButton.
  ///
  /// In pt, this message translates to:
  /// **'CRIAR CONTA'**
  String get registerCreateAccountButton;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem'**
  String get registerPasswordMismatch;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In pt, this message translates to:
  /// **'Senha fraca'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthMedium.
  ///
  /// In pt, this message translates to:
  /// **'Senha média'**
  String get passwordStrengthMedium;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In pt, this message translates to:
  /// **'Senha forte'**
  String get passwordStrengthStrong;

  /// No description provided for @chooseTeamTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu time do coração'**
  String get chooseTeamTitle;

  /// No description provided for @chooseTeamSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Etapa 2 de 2 · personalize o app'**
  String get chooseTeamSubtitle;

  /// No description provided for @chooseTeamDescription.
  ///
  /// In pt, this message translates to:
  /// **'Escolha sua região e o time que você acompanha. Dá para mudar depois.'**
  String get chooseTeamDescription;

  /// No description provided for @chooseTeamConfirm.
  ///
  /// In pt, this message translates to:
  /// **'CONCLUIR'**
  String get chooseTeamConfirm;

  /// No description provided for @chooseTeamSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular por agora'**
  String get chooseTeamSkip;

  /// No description provided for @chooseTeamLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as regiões e os times.'**
  String get chooseTeamLoadError;

  /// No description provided for @chooseTeamEmptyTeams.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum time cadastrado nesta região.'**
  String get chooseTeamEmptyTeams;

  /// No description provided for @drawerNavigation.
  ///
  /// In pt, this message translates to:
  /// **'Navegação'**
  String get drawerNavigation;

  /// No description provided for @drawerAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Administração'**
  String get drawerAdmin;

  /// No description provided for @drawerLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get drawerLogout;

  /// No description provided for @drawerSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar ou criar conta'**
  String get drawerSignIn;

  /// No description provided for @drawerGuestSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre para salvar seu time e votar no melhor da partida.'**
  String get drawerGuestSubtitle;

  /// No description provided for @homeGreeting.
  ///
  /// In pt, this message translates to:
  /// **'Olá, {name} 👋'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingGuest.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao Arena 👋'**
  String get homeGreetingGuest;

  /// No description provided for @homeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Futebol amador de {region}'**
  String homeSubtitle(String region);

  /// No description provided for @homeHighlights.
  ///
  /// In pt, this message translates to:
  /// **'Destaques'**
  String get homeHighlights;

  /// No description provided for @homeLatestNews.
  ///
  /// In pt, this message translates to:
  /// **'Últimas notícias'**
  String get homeLatestNews;

  /// No description provided for @homeTodayMatches.
  ///
  /// In pt, this message translates to:
  /// **'Jogos de hoje'**
  String get homeTodayMatches;

  /// No description provided for @homeSeasonChip.
  ///
  /// In pt, this message translates to:
  /// **'Temporada {season}'**
  String homeSeasonChip(String season);

  /// No description provided for @homePublishTitle.
  ///
  /// In pt, this message translates to:
  /// **'Publicar'**
  String get homePublishTitle;

  /// No description provided for @homePublishNews.
  ///
  /// In pt, this message translates to:
  /// **'Notícia'**
  String get homePublishNews;

  /// No description provided for @homePublishGoal.
  ///
  /// In pt, this message translates to:
  /// **'Gol'**
  String get homePublishGoal;

  /// No description provided for @homePublishAd.
  ///
  /// In pt, this message translates to:
  /// **'Anúncio'**
  String get homePublishAd;

  /// No description provided for @homePublishHighlight.
  ///
  /// In pt, this message translates to:
  /// **'Destaque'**
  String get homePublishHighlight;

  /// No description provided for @homePublishMatch.
  ///
  /// In pt, this message translates to:
  /// **'Partida'**
  String get homePublishMatch;

  /// No description provided for @homePublishTeam.
  ///
  /// In pt, this message translates to:
  /// **'Time'**
  String get homePublishTeam;

  /// No description provided for @homePublishPlayer.
  ///
  /// In pt, this message translates to:
  /// **'Jogador'**
  String get homePublishPlayer;

  /// No description provided for @homeOpenMenu.
  ///
  /// In pt, this message translates to:
  /// **'Abrir menu'**
  String get homeOpenMenu;

  /// No description provided for @matchesVoteAction.
  ///
  /// In pt, this message translates to:
  /// **'Votar no melhor'**
  String get matchesVoteAction;

  /// No description provided for @matchesSeeElected.
  ///
  /// In pt, this message translates to:
  /// **'Ver eleito'**
  String get matchesSeeElected;

  /// No description provided for @matchesOpenVoting.
  ///
  /// In pt, this message translates to:
  /// **'Abrir votação'**
  String get matchesOpenVoting;

  /// No description provided for @matchesCloseVoting.
  ///
  /// In pt, this message translates to:
  /// **'Fechar votação'**
  String get matchesCloseVoting;

  /// No description provided for @championshipsSeeDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get championshipsSeeDetails;

  /// No description provided for @newsAdLabel.
  ///
  /// In pt, this message translates to:
  /// **'Publicidade'**
  String get newsAdLabel;

  /// No description provided for @newsGoalLabel.
  ///
  /// In pt, this message translates to:
  /// **'GOL'**
  String get newsGoalLabel;

  /// No description provided for @commonMoreActions.
  ///
  /// In pt, this message translates to:
  /// **'Mais ações'**
  String get commonMoreActions;

  /// No description provided for @timeJustNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In pt, this message translates to:
  /// **'há {minutes} min'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In pt, this message translates to:
  /// **'há {hours} h'**
  String timeHoursAgo(int hours);

  /// No description provided for @timeYesterday.
  ///
  /// In pt, this message translates to:
  /// **'ontem'**
  String get timeYesterday;

  /// No description provided for @newsShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get newsShare;

  /// No description provided for @newsShareFooter.
  ///
  /// In pt, this message translates to:
  /// **'via Arena Football'**
  String get newsShareFooter;

  /// No description provided for @newsReadMore.
  ///
  /// In pt, this message translates to:
  /// **'Saiba mais'**
  String get newsReadMore;

  /// No description provided for @galleryClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get galleryClose;

  /// No description provided for @galleryCounter.
  ///
  /// In pt, this message translates to:
  /// **'{current}/{total}'**
  String galleryCounter(int current, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
