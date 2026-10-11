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
  /// **'Nova notícia'**
  String get newsCreateTitle;

  /// No description provided for @newsEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar notícia'**
  String get newsEditTitle;

  /// No description provided for @newsTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get newsTitleLabel;

  /// No description provided for @newsCoverAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar capa'**
  String get newsCoverAdd;

  /// No description provided for @newsCoverHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque para tirar uma foto ou escolher da galeria'**
  String get newsCoverHint;

  /// No description provided for @newsCoverChange.
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get newsCoverChange;

  /// No description provided for @newsCoverRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get newsCoverRemove;

  /// No description provided for @newsSectionContent.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo'**
  String get newsSectionContent;

  /// No description provided for @newsSectionAlbum.
  ///
  /// In pt, this message translates to:
  /// **'Álbum de fotos'**
  String get newsSectionAlbum;

  /// No description provided for @newsSectionPublish.
  ///
  /// In pt, this message translates to:
  /// **'Publicação'**
  String get newsSectionPublish;

  /// No description provided for @newsAlbumCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{nenhuma foto} =1{1 foto} other{{count} fotos}}'**
  String newsAlbumCount(int count);

  /// No description provided for @newsAlbumAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get newsAlbumAdd;

  /// No description provided for @newsAlbumHint.
  ///
  /// In pt, this message translates to:
  /// **'As fotos aparecem na galeria da notícia.'**
  String get newsAlbumHint;

  /// No description provided for @newsRegion.
  ///
  /// In pt, this message translates to:
  /// **'Região'**
  String get newsRegion;

  /// No description provided for @newsHighlight.
  ///
  /// In pt, this message translates to:
  /// **'Destaque'**
  String get newsHighlight;

  /// No description provided for @newsHighlightNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum'**
  String get newsHighlightNone;

  /// No description provided for @newsHighlightHint.
  ///
  /// In pt, this message translates to:
  /// **'A notícia também aparece dentro do destaque escolhido.'**
  String get newsHighlightHint;

  /// No description provided for @newsLinkHint.
  ///
  /// In pt, this message translates to:
  /// **'Link externo (opcional)'**
  String get newsLinkHint;

  /// No description provided for @newsVisibleHint.
  ///
  /// In pt, this message translates to:
  /// **'Desligado, a notícia fica salva mas não aparece no app.'**
  String get newsVisibleHint;

  /// No description provided for @newsVisibleOnHint.
  ///
  /// In pt, this message translates to:
  /// **'A notícia aparece no feed do app.'**
  String get newsVisibleOnHint;

  /// No description provided for @newsPreview.
  ///
  /// In pt, this message translates to:
  /// **'Pré-visualizar'**
  String get newsPreview;

  /// No description provided for @newsPreviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como vai aparecer no feed'**
  String get newsPreviewTitle;

  /// No description provided for @newsDiscardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Descartar alterações?'**
  String get newsDiscardTitle;

  /// No description provided for @newsDiscardMessage.
  ///
  /// In pt, this message translates to:
  /// **'O que você preencheu será perdido.'**
  String get newsDiscardMessage;

  /// No description provided for @newsDiscardKeep.
  ///
  /// In pt, this message translates to:
  /// **'Continuar editando'**
  String get newsDiscardKeep;

  /// No description provided for @newsDiscardConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Descartar'**
  String get newsDiscardConfirm;

  /// No description provided for @newsPublish.
  ///
  /// In pt, this message translates to:
  /// **'Publicar notícia'**
  String get newsPublish;

  /// No description provided for @newsSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get newsSave;

  /// No description provided for @newsDescriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get newsDescriptionLabel;

  /// No description provided for @newsLinkLabel.
  ///
  /// In pt, this message translates to:
  /// **'Link'**
  String get newsLinkLabel;

  /// No description provided for @newsVisibleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Visível no app'**
  String get newsVisibleLabel;

  /// No description provided for @newsTitleRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o título da notícia'**
  String get newsTitleRequired;

  /// No description provided for @newsTitleTooShort.
  ///
  /// In pt, this message translates to:
  /// **'O título da notícia deve conter no mínimo 3 caracteres'**
  String get newsTitleTooShort;

  /// No description provided for @newsCreated.
  ///
  /// In pt, this message translates to:
  /// **'Notícia publicada!'**
  String get newsCreated;

  /// No description provided for @newsUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Notícia atualizada!'**
  String get newsUpdated;

  /// No description provided for @newsRegionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Região:'**
  String get newsRegionLabel;

  /// No description provided for @newsGoalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Card de gol'**
  String get newsGoalTitle;

  /// No description provided for @newsPublishButton.
  ///
  /// In pt, this message translates to:
  /// **'Publicar'**
  String get newsPublishButton;

  /// No description provided for @newsGoalCreated.
  ///
  /// In pt, this message translates to:
  /// **'Gol publicado!'**
  String get newsGoalCreated;

  /// No description provided for @goalTodayMatches.
  ///
  /// In pt, this message translates to:
  /// **'Jogos de hoje'**
  String get goalTodayMatches;

  /// No description provided for @goalTodayMatchesHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque para preencher os times e o placar.'**
  String get goalTodayMatchesHint;

  /// No description provided for @goalScoreboard.
  ///
  /// In pt, this message translates to:
  /// **'Placar'**
  String get goalScoreboard;

  /// No description provided for @goalPickTeam.
  ///
  /// In pt, this message translates to:
  /// **'Escolher time'**
  String get goalPickTeam;

  /// No description provided for @goalHome.
  ///
  /// In pt, this message translates to:
  /// **'Mandante'**
  String get goalHome;

  /// No description provided for @goalAway.
  ///
  /// In pt, this message translates to:
  /// **'Visitante'**
  String get goalAway;

  /// No description provided for @goalSameTeam.
  ///
  /// In pt, this message translates to:
  /// **'Escolha dois times diferentes.'**
  String get goalSameTeam;

  /// No description provided for @goalNoTeams.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum time cadastrado nesta região.'**
  String get goalNoTeams;

  /// No description provided for @goalSearchTeam.
  ///
  /// In pt, this message translates to:
  /// **'Buscar time'**
  String get goalSearchTeam;

  /// No description provided for @goalUpdateMatch.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar placar da partida'**
  String get goalUpdateMatch;

  /// No description provided for @goalUpdateMatchHint.
  ///
  /// In pt, this message translates to:
  /// **'Grava o mesmo placar na partida da tabela.'**
  String get goalUpdateMatchHint;

  /// No description provided for @goalPreview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia no feed'**
  String get goalPreview;

  /// No description provided for @goalPublish.
  ///
  /// In pt, this message translates to:
  /// **'Publicar gol'**
  String get goalPublish;

  /// No description provided for @goalConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Publicar card de gol?'**
  String get goalConfirmTitle;

  /// No description provided for @goalConfirmMessage.
  ///
  /// In pt, this message translates to:
  /// **'{home} {homeGoals} × {awayGoals} {away}'**
  String goalConfirmMessage(
      String home, int homeGoals, int awayGoals, String away);

  /// No description provided for @goalMatchUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Gol publicado e placar da partida atualizado!'**
  String get goalMatchUpdated;

  /// No description provided for @goalMatchUpdateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Gol publicado, mas não foi possível atualizar o placar da partida.'**
  String get goalMatchUpdateFailed;

  /// No description provided for @goalIncrease.
  ///
  /// In pt, this message translates to:
  /// **'Aumentar'**
  String get goalIncrease;

  /// No description provided for @goalDecrease.
  ///
  /// In pt, this message translates to:
  /// **'Diminuir'**
  String get goalDecrease;

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
  /// **'Novo time'**
  String get teamsFormTitle;

  /// No description provided for @teamsNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do time'**
  String get teamsNameLabel;

  /// No description provided for @teamsDescriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição (opcional)'**
  String get teamsDescriptionLabel;

  /// No description provided for @teamsCreated.
  ///
  /// In pt, this message translates to:
  /// **'Time cadastrado!'**
  String get teamsCreated;

  /// No description provided for @teamsNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome do time (mínimo 3 letras).'**
  String get teamsNameRequired;

  /// No description provided for @teamsCrestAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar escudo'**
  String get teamsCrestAdd;

  /// No description provided for @teamsSectionData.
  ///
  /// In pt, this message translates to:
  /// **'Dados do time'**
  String get teamsSectionData;

  /// No description provided for @teamsDescriptionHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: bairro, fundação, apelido'**
  String get teamsDescriptionHint;

  /// No description provided for @teamsPreview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia na aba Times'**
  String get teamsPreview;

  /// No description provided for @teamsInRegion.
  ///
  /// In pt, this message translates to:
  /// **'Times na região · {count}'**
  String teamsInRegion(int count);

  /// No description provided for @teamsDuplicate.
  ///
  /// In pt, this message translates to:
  /// **'Já existe um time \"{name}\" nesta região.'**
  String teamsDuplicate(String name);

  /// No description provided for @teamsSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar time'**
  String get teamsSubmit;

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
  /// **'Informe o nome (mínimo 3 letras).'**
  String get playersNameRequired;

  /// No description provided for @playersTeamRequired.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o time do jogador.'**
  String get playersTeamRequired;

  /// No description provided for @playersFormTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo jogador'**
  String get playersFormTitle;

  /// No description provided for @playersNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do jogador'**
  String get playersNameLabel;

  /// No description provided for @playersGoalsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Gols'**
  String get playersGoalsLabel;

  /// No description provided for @playersAssistsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Assistências'**
  String get playersAssistsLabel;

  /// No description provided for @playersCreated.
  ///
  /// In pt, this message translates to:
  /// **'Jogador cadastrado!'**
  String get playersCreated;

  /// No description provided for @playersPhotoAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar foto (opcional)'**
  String get playersPhotoAdd;

  /// No description provided for @playersSectionData.
  ///
  /// In pt, this message translates to:
  /// **'Dados do jogador'**
  String get playersSectionData;

  /// No description provided for @playersTeam.
  ///
  /// In pt, this message translates to:
  /// **'Time'**
  String get playersTeam;

  /// No description provided for @playersPreview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia no elenco'**
  String get playersPreview;

  /// No description provided for @playersSquadOf.
  ///
  /// In pt, this message translates to:
  /// **'Elenco do {team} · {count}'**
  String playersSquadOf(String team, int count);

  /// No description provided for @playersDuplicate.
  ///
  /// In pt, this message translates to:
  /// **'Já existe \"{name}\" no {team}.'**
  String playersDuplicate(String name, String team);

  /// No description provided for @playersSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar jogador'**
  String get playersSubmit;

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

  /// No description provided for @statsEmptyGoals.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum gol marcado ainda'**
  String get statsEmptyGoals;

  /// No description provided for @statsEmptyAssists.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma assistência ainda'**
  String get statsEmptyAssists;

  /// No description provided for @statsUnitGoals.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{gol} other{gols}}'**
  String statsUnitGoals(int count);

  /// No description provided for @statsUnitAssists.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{assist.} other{assist.}}'**
  String statsUnitAssists(int count);

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

  /// No description provided for @matchesSummaryGames.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{jogo} other{jogos}}'**
  String matchesSummaryGames(int count);

  /// No description provided for @matchesSummaryGoals.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{gol} other{gols}}'**
  String matchesSummaryGoals(int count);

  /// No description provided for @matchesSummaryAverage.
  ///
  /// In pt, this message translates to:
  /// **'gols por jogo'**
  String get matchesSummaryAverage;

  /// No description provided for @matchesDayCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 jogo} other{{count} jogos}}'**
  String matchesDayCount(int count);

  /// No description provided for @matchesNoDate.
  ///
  /// In pt, this message translates to:
  /// **'Sem data'**
  String get matchesNoDate;

  /// No description provided for @matchesFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get matchesFilterAll;

  /// No description provided for @matchesEmptyForTeam.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma partida deste time'**
  String get matchesEmptyForTeam;

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
  /// **'Nova partida'**
  String get matchesFormTitle;

  /// No description provided for @matchesCreated.
  ///
  /// In pt, this message translates to:
  /// **'Partida cadastrada!'**
  String get matchesCreated;

  /// No description provided for @matchFormMatchup.
  ///
  /// In pt, this message translates to:
  /// **'Confronto'**
  String get matchFormMatchup;

  /// No description provided for @matchFormSwap.
  ///
  /// In pt, this message translates to:
  /// **'Inverter mando'**
  String get matchFormSwap;

  /// No description provided for @matchFormWhen.
  ///
  /// In pt, this message translates to:
  /// **'Quando'**
  String get matchFormWhen;

  /// No description provided for @matchFormWhere.
  ///
  /// In pt, this message translates to:
  /// **'Onde'**
  String get matchFormWhere;

  /// No description provided for @matchFormToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get matchFormToday;

  /// No description provided for @matchFormTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get matchFormTomorrow;

  /// No description provided for @matchFormOtherDate.
  ///
  /// In pt, this message translates to:
  /// **'Outra data'**
  String get matchFormOtherDate;

  /// No description provided for @matchFormOtherTime.
  ///
  /// In pt, this message translates to:
  /// **'Outro horário'**
  String get matchFormOtherTime;

  /// No description provided for @matchFormNewVenue.
  ///
  /// In pt, this message translates to:
  /// **'Novo local'**
  String get matchFormNewVenue;

  /// No description provided for @matchFormVenueHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome do local'**
  String get matchFormVenueHint;

  /// No description provided for @matchFormPreview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia'**
  String get matchFormPreview;

  /// No description provided for @matchFormSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar partida'**
  String get matchFormSubmit;

  /// No description provided for @matchFormMissingTeams.
  ///
  /// In pt, this message translates to:
  /// **'Escolha os dois times.'**
  String get matchFormMissingTeams;

  /// No description provided for @matchFormMissingDate.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a data da partida.'**
  String get matchFormMissingDate;

  /// No description provided for @matchFormMissingTime.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o horário da partida.'**
  String get matchFormMissingTime;

  /// No description provided for @matchFormConflictTeam.
  ///
  /// In pt, this message translates to:
  /// **'{team} já tem jogo nesta data ({times}).'**
  String matchFormConflictTeam(String team, String times);

  /// No description provided for @matchFormConflictVenue.
  ///
  /// In pt, this message translates to:
  /// **'{venue} já tem jogo nesta data às {time}.'**
  String matchFormConflictVenue(String venue, String time);

  /// No description provided for @matchFormSaved.
  ///
  /// In pt, this message translates to:
  /// **'Partida cadastrada! Escolha os times da próxima.'**
  String get matchFormSaved;

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
  /// **'Nenhum grupo cadastrado nesta temporada.'**
  String get championshipsGroupsEmpty;

  /// No description provided for @championshipsGroupsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os grupos.'**
  String get championshipsGroupsLoadError;

  /// No description provided for @championshipsStandingsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Classificação ainda não disponível.'**
  String get championshipsStandingsEmpty;

  /// No description provided for @championshipsStandingsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a classificação.'**
  String get championshipsStandingsLoadError;

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

  /// No description provided for @votingBlankVote.
  ///
  /// In pt, this message translates to:
  /// **'Voto em branco! Tente novamente.'**
  String get votingBlankVote;

  /// No description provided for @votingHint.
  ///
  /// In pt, this message translates to:
  /// **'Você pode trocar o voto quando quiser; só o último conta.'**
  String get votingHint;

  /// No description provided for @votingSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar jogador'**
  String get votingSearchHint;

  /// No description provided for @votingChoosePlayer.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um jogador'**
  String get votingChoosePlayer;

  /// No description provided for @votingVoteFor.
  ///
  /// In pt, this message translates to:
  /// **'Votar em {name}'**
  String votingVoteFor(String name);

  /// No description provided for @votingChangeVoteTo.
  ///
  /// In pt, this message translates to:
  /// **'Trocar voto para {name}'**
  String votingChangeVoteTo(String name);

  /// No description provided for @votingYouVotedFor.
  ///
  /// In pt, this message translates to:
  /// **'Você votou em {name}'**
  String votingYouVotedFor(String name);

  /// No description provided for @votingYourVote.
  ///
  /// In pt, this message translates to:
  /// **'Seu voto'**
  String get votingYourVote;

  /// No description provided for @votingGuestTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre na sua conta para votar no craque da partida'**
  String get votingGuestTitle;

  /// No description provided for @votingGuestAction.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get votingGuestAction;

  /// No description provided for @votingSuccessTitle.
  ///
  /// In pt, this message translates to:
  /// **'Voto registrado!'**
  String get votingSuccessTitle;

  /// No description provided for @votingEmptySquad.
  ///
  /// In pt, this message translates to:
  /// **'Elenco não cadastrado'**
  String get votingEmptySquad;

  /// No description provided for @votingNoSearchResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum jogador encontrado'**
  String get votingNoSearchResults;

  /// No description provided for @commonClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get commonClose;

  /// No description provided for @votingLoginRequired.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para votar.'**
  String get votingLoginRequired;

  /// No description provided for @votingElectedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Craque da partida'**
  String get votingElectedTitle;

  /// No description provided for @votingMatchSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{home} x {away}'**
  String votingMatchSubtitle(String home, String away);

  /// No description provided for @votingVotes.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 voto} other{{count} votos}}'**
  String votingVotes(int count);

  /// No description provided for @votingShareOfVotes.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% dos votos'**
  String votingShareOfVotes(int percent);

  /// No description provided for @votingRankingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Votação'**
  String get votingRankingTitle;

  /// No description provided for @votingNoVotesYet.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém votou nesta partida ainda'**
  String get votingNoVotesYet;

  /// No description provided for @votingShareText.
  ///
  /// In pt, this message translates to:
  /// **'{player} foi eleito o craque de {match} com {votes}! ⚽ via Arena Football'**
  String votingShareText(String player, String match, String votes);

  /// No description provided for @votingLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível apurar a votação.'**
  String get votingLoadError;

  /// No description provided for @globalResultsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resultados pelo mundo'**
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

  /// No description provided for @globalResultsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Placares das principais ligas do mundo'**
  String get globalResultsSubtitle;

  /// No description provided for @globalResultsLive.
  ///
  /// In pt, this message translates to:
  /// **'Ao vivo'**
  String get globalResultsLive;

  /// No description provided for @globalResultsHalfTime.
  ///
  /// In pt, this message translates to:
  /// **'Intervalo'**
  String get globalResultsHalfTime;

  /// No description provided for @globalResultsFinished.
  ///
  /// In pt, this message translates to:
  /// **'Encerrado'**
  String get globalResultsFinished;

  /// No description provided for @globalResultsPostponed.
  ///
  /// In pt, this message translates to:
  /// **'Adiado'**
  String get globalResultsPostponed;

  /// No description provided for @globalResultsLiveFilter.
  ///
  /// In pt, this message translates to:
  /// **'Ao vivo ({count})'**
  String globalResultsLiveFilter(int count);

  /// No description provided for @globalResultsSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar time ou liga'**
  String get globalResultsSearchHint;

  /// No description provided for @globalResultsNoMatches.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum jogo encontrado'**
  String get globalResultsNoMatches;

  /// No description provided for @globalResultsPenalty.
  ///
  /// In pt, this message translates to:
  /// **'pênalti'**
  String get globalResultsPenalty;

  /// No description provided for @globalResultsOwnGoal.
  ///
  /// In pt, this message translates to:
  /// **'contra'**
  String get globalResultsOwnGoal;

  /// No description provided for @globalResultsGoalsError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os gols. Toque para tentar de novo.'**
  String get globalResultsGoalsError;

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

  /// No description provided for @playersSummaryPlayers.
  ///
  /// In pt, this message translates to:
  /// **'Jogadores'**
  String get playersSummaryPlayers;

  /// No description provided for @playersSummaryGoals.
  ///
  /// In pt, this message translates to:
  /// **'Gols'**
  String get playersSummaryGoals;

  /// No description provided for @playersSummaryAssists.
  ///
  /// In pt, this message translates to:
  /// **'Assistências'**
  String get playersSummaryAssists;

  /// No description provided for @playersSortGoals.
  ///
  /// In pt, this message translates to:
  /// **'Gols'**
  String get playersSortGoals;

  /// No description provided for @playersSortAssists.
  ///
  /// In pt, this message translates to:
  /// **'Assistências'**
  String get playersSortAssists;

  /// No description provided for @playersSortName.
  ///
  /// In pt, this message translates to:
  /// **'A–Z'**
  String get playersSortName;

  /// No description provided for @playersSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar jogador'**
  String get playersSearchHint;

  /// No description provided for @playersNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum jogador encontrado.'**
  String get playersNoResults;

  /// No description provided for @playersTopScorer.
  ///
  /// In pt, this message translates to:
  /// **'Artilheiro do time'**
  String get playersTopScorer;

  /// No description provided for @playersChangePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Trocar foto'**
  String get playersChangePhoto;

  /// No description provided for @playersEditName.
  ///
  /// In pt, this message translates to:
  /// **'Editar nome'**
  String get playersEditName;

  /// No description provided for @playersSaveName.
  ///
  /// In pt, this message translates to:
  /// **'Salvar nome'**
  String get playersSaveName;

  /// No description provided for @commonClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get commonClear;

  /// No description provided for @groupsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Grupos'**
  String get groupsTitle;

  /// No description provided for @groupsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{region} · Temporada {season}'**
  String groupsSubtitle(String region, String season);

  /// No description provided for @groupsSeeStandings.
  ///
  /// In pt, this message translates to:
  /// **'Ver classificação'**
  String get groupsSeeStandings;

  /// No description provided for @standingsColPosition.
  ///
  /// In pt, this message translates to:
  /// **'#'**
  String get standingsColPosition;

  /// No description provided for @standingsColTeam.
  ///
  /// In pt, this message translates to:
  /// **'Time'**
  String get standingsColTeam;

  /// No description provided for @standingsColGames.
  ///
  /// In pt, this message translates to:
  /// **'J'**
  String get standingsColGames;

  /// No description provided for @standingsQualifiedLegend.
  ///
  /// In pt, this message translates to:
  /// **'Classificados para a próxima fase'**
  String get standingsQualifiedLegend;

  /// No description provided for @standingsGoalsFor.
  ///
  /// In pt, this message translates to:
  /// **'Gols feitos'**
  String get standingsGoalsFor;

  /// No description provided for @standingsGoalsAgainst.
  ///
  /// In pt, this message translates to:
  /// **'Gols sofridos'**
  String get standingsGoalsAgainst;

  /// No description provided for @standingsPerformance.
  ///
  /// In pt, this message translates to:
  /// **'Aproveitamento'**
  String get standingsPerformance;

  /// No description provided for @standingsYourTeam.
  ///
  /// In pt, this message translates to:
  /// **'Seu time'**
  String get standingsYourTeam;
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
