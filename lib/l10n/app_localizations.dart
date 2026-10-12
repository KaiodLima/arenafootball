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
  /// **'Destaques'**
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

  /// No description provided for @goalOfTeam.
  ///
  /// In pt, this message translates to:
  /// **'Gol do {team}'**
  String goalOfTeam(String team);

  /// No description provided for @goalWhoScoredQ.
  ///
  /// In pt, this message translates to:
  /// **'Quem fez o gol?'**
  String get goalWhoScoredQ;

  /// No description provided for @goalWhoAssistedQ.
  ///
  /// In pt, this message translates to:
  /// **'Quem deu o passe para {scorer}?'**
  String goalWhoAssistedQ(String scorer);

  /// No description provided for @goalSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get goalSkip;

  /// No description provided for @goalNoAssist.
  ///
  /// In pt, this message translates to:
  /// **'Sem assistência'**
  String get goalNoAssist;

  /// No description provided for @goalBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get goalBack;

  /// No description provided for @goalEditScorer.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get goalEditScorer;

  /// No description provided for @goalSearchPlayer.
  ///
  /// In pt, this message translates to:
  /// **'Buscar jogador'**
  String get goalSearchPlayer;

  /// No description provided for @goalClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get goalClear;

  /// No description provided for @goalScorerLine.
  ///
  /// In pt, this message translates to:
  /// **'⚽ {scorer}'**
  String goalScorerLine(String scorer);

  /// No description provided for @goalScorerAssistLine.
  ///
  /// In pt, this message translates to:
  /// **'⚽ {scorer} · assist. {assistant}'**
  String goalScorerAssistLine(String scorer, String assistant);

  /// No description provided for @goalStatsSaved.
  ///
  /// In pt, this message translates to:
  /// **'Gol publicado! {scorer} +1 gol.'**
  String goalStatsSaved(String scorer);

  /// No description provided for @goalStatsSavedWithAssist.
  ///
  /// In pt, this message translates to:
  /// **'Gol publicado! {scorer} +1 gol, {assistant} +1 assistência.'**
  String goalStatsSavedWithAssist(String scorer, String assistant);

  /// No description provided for @goalStatsFailed.
  ///
  /// In pt, this message translates to:
  /// **'Gol publicado, mas não foi possível somar nos números dos jogadores.'**
  String get goalStatsFailed;

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

  /// No description provided for @newsAdCreated.
  ///
  /// In pt, this message translates to:
  /// **'Publicidade publicada!'**
  String get newsAdCreated;

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
  /// **'Exibir no carrossel'**
  String get highlightVisibleLabel;

  /// No description provided for @highlightTitleRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o título do destaque.'**
  String get highlightTitleRequired;

  /// No description provided for @highlightCreated.
  ///
  /// In pt, this message translates to:
  /// **'Destaque publicado!'**
  String get highlightCreated;

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

  /// No description provided for @loginWithGoogleButton.
  ///
  /// In pt, this message translates to:
  /// **'ENTRAR COM GOOGLE'**
  String get loginWithGoogleButton;

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

  /// No description provided for @drawerChooseTeam.
  ///
  /// In pt, this message translates to:
  /// **'Escolher meu time'**
  String get drawerChooseTeam;

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

  /// No description provided for @athleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atleta'**
  String get athleteTitle;

  /// No description provided for @athleteScored.
  ///
  /// In pt, this message translates to:
  /// **'Fez o gol'**
  String get athleteScored;

  /// No description provided for @athleteAssisted.
  ///
  /// In pt, this message translates to:
  /// **'Deu o passe'**
  String get athleteAssisted;

  /// No description provided for @athleteRankGoals.
  ///
  /// In pt, this message translates to:
  /// **'{position}º na artilharia'**
  String athleteRankGoals(int position);

  /// No description provided for @athleteRankAssists.
  ///
  /// In pt, this message translates to:
  /// **'{position}º em assistências'**
  String athleteRankAssists(int position);

  /// No description provided for @athleteNoRank.
  ///
  /// In pt, this message translates to:
  /// **'Fora do ranking'**
  String get athleteNoRank;

  /// No description provided for @athleteParticipations.
  ///
  /// In pt, this message translates to:
  /// **'Participações em gols'**
  String get athleteParticipations;

  /// No description provided for @athleteNoParticipations.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem gols registrados no feed.'**
  String get athleteNoParticipations;

  /// No description provided for @athleteNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Jogador não encontrado.'**
  String get athleteNotFound;

  /// No description provided for @athleteLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o jogador.'**
  String get athleteLoadError;

  /// No description provided for @athleteEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar (admin)'**
  String get athleteEdit;

  /// No description provided for @athleteShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get athleteShare;

  /// No description provided for @athleteShareText.
  ///
  /// In pt, this message translates to:
  /// **'{name} ({team}): {goals} gols e {assists} assistências · via Arena Football'**
  String athleteShareText(String name, String team, int goals, int assists);

  /// No description provided for @athleteSeason.
  ///
  /// In pt, this message translates to:
  /// **'Temporada {season}'**
  String athleteSeason(String season);

  /// No description provided for @adCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova publicidade'**
  String get adCreateTitle;

  /// No description provided for @adEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar publicidade'**
  String get adEditTitle;

  /// No description provided for @adPublish.
  ///
  /// In pt, this message translates to:
  /// **'Publicar anúncio'**
  String get adPublish;

  /// No description provided for @adUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Publicidade atualizada!'**
  String get adUpdated;

  /// No description provided for @adBannerAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar banner'**
  String get adBannerAdd;

  /// No description provided for @adBannerHint.
  ///
  /// In pt, this message translates to:
  /// **'Use uma imagem horizontal 2:1 (ex.: 1200×600). É assim que ela aparece no feed.'**
  String get adBannerHint;

  /// No description provided for @adSectionAd.
  ///
  /// In pt, this message translates to:
  /// **'Anúncio'**
  String get adSectionAd;

  /// No description provided for @adNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Anunciante (opcional)'**
  String get adNameLabel;

  /// No description provided for @adNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Só para você identificar o anúncio'**
  String get adNameHint;

  /// No description provided for @adLinkHint.
  ///
  /// In pt, this message translates to:
  /// **'Site, Instagram ou WhatsApp do anunciante'**
  String get adLinkHint;

  /// No description provided for @adLinkInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Link inválido. Ex.: https://loja.com.br'**
  String get adLinkInvalid;

  /// No description provided for @adTestLink.
  ///
  /// In pt, this message translates to:
  /// **'Testar'**
  String get adTestLink;

  /// No description provided for @adImageRequired.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a imagem do anúncio.'**
  String get adImageRequired;

  /// No description provided for @highlightCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo destaque'**
  String get highlightCreateTitle;

  /// No description provided for @highlightPhotoAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar foto'**
  String get highlightPhotoAdd;

  /// No description provided for @highlightPhotoHint.
  ///
  /// In pt, this message translates to:
  /// **'Aparece no círculo do carrossel. Prefira uma imagem quadrada.'**
  String get highlightPhotoHint;

  /// No description provided for @highlightPreview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia no carrossel'**
  String get highlightPreview;

  /// No description provided for @highlightSection.
  ///
  /// In pt, this message translates to:
  /// **'Destaque'**
  String get highlightSection;

  /// No description provided for @highlightTitleHint.
  ///
  /// In pt, this message translates to:
  /// **'Notícias marcadas com este destaque aparecem nele'**
  String get highlightTitleHint;

  /// No description provided for @highlightTitleTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Use pelo menos 3 letras.'**
  String get highlightTitleTooShort;

  /// No description provided for @highlightDuplicate.
  ///
  /// In pt, this message translates to:
  /// **'Já existe um destaque com esse nome.'**
  String get highlightDuplicate;

  /// No description provided for @highlightVisibleOnHint.
  ///
  /// In pt, this message translates to:
  /// **'Aparece no topo da home para todos.'**
  String get highlightVisibleOnHint;

  /// No description provided for @highlightVisibleHint.
  ///
  /// In pt, this message translates to:
  /// **'Fica oculto até você ativar.'**
  String get highlightVisibleHint;

  /// No description provided for @highlightPublish.
  ///
  /// In pt, this message translates to:
  /// **'Publicar destaque'**
  String get highlightPublish;

  /// No description provided for @highlightNewsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhuma notícia} =1{1 notícia} other{{count} notícias}}'**
  String highlightNewsCount(int count);

  /// No description provided for @highlightOpenLink.
  ///
  /// In pt, this message translates to:
  /// **'Abrir link'**
  String get highlightOpenLink;

  /// No description provided for @highlightEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há notícias neste destaque.'**
  String get highlightEmpty;

  /// No description provided for @highlightLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as notícias.'**
  String get highlightLoadError;

  /// No description provided for @highlightAddNews.
  ///
  /// In pt, this message translates to:
  /// **'Notícia'**
  String get highlightAddNews;

  /// No description provided for @highlightShareText.
  ///
  /// In pt, this message translates to:
  /// **'{title} · Arena Football'**
  String highlightShareText(String title);

  /// No description provided for @highlightsManageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Destaques'**
  String get highlightsManageTitle;

  /// No description provided for @highlightsReorderHint.
  ///
  /// In pt, this message translates to:
  /// **'Arraste pela alça para definir a ordem do carrossel.'**
  String get highlightsReorderHint;

  /// No description provided for @highlightsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum destaque cadastrado. Toque em + para criar.'**
  String get highlightsEmpty;

  /// No description provided for @highlightHidden.
  ///
  /// In pt, this message translates to:
  /// **'Oculto'**
  String get highlightHidden;

  /// No description provided for @highlightView.
  ///
  /// In pt, this message translates to:
  /// **'Ver'**
  String get highlightView;

  /// No description provided for @highlightEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar destaque'**
  String get highlightEditTitle;

  /// No description provided for @highlightUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Destaque atualizado!'**
  String get highlightUpdated;

  /// No description provided for @highlightRenameHint.
  ///
  /// In pt, this message translates to:
  /// **'As notícias marcadas com \"{old}\" passam para o novo nome.'**
  String highlightRenameHint(String old);

  /// No description provided for @highlightDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir \"{title}\"?'**
  String highlightDeleteTitle(String title);

  /// No description provided for @highlightDeleteMessage.
  ///
  /// In pt, this message translates to:
  /// **'As notícias marcadas continuam no feed, só perdem a marcação deste destaque.'**
  String get highlightDeleteMessage;

  /// No description provided for @highlightDeleted.
  ///
  /// In pt, this message translates to:
  /// **'\"{title}\" excluído.'**
  String highlightDeleted(String title);

  /// No description provided for @pushPanelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get pushPanelTitle;

  /// No description provided for @pushTabActions.
  ///
  /// In pt, this message translates to:
  /// **'Ações'**
  String get pushTabActions;

  /// No description provided for @pushTabHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get pushTabHistory;

  /// No description provided for @pushTabSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar aviso'**
  String get pushTabSend;

  /// No description provided for @pushActionsIntro.
  ///
  /// In pt, this message translates to:
  /// **'Escolha quais ações enviam push. Cada usuário recebe da região escolhida no app; os jogos também chegam para quem torce pelos times.'**
  String get pushActionsIntro;

  /// No description provided for @pushActionGoal.
  ///
  /// In pt, this message translates to:
  /// **'Gol'**
  String get pushActionGoal;

  /// No description provided for @pushActionGoalHint.
  ///
  /// In pt, this message translates to:
  /// **'Card de gol publicado · \"⚽ GOL! Lava Jato 2 × 1 Volta\"'**
  String get pushActionGoalHint;

  /// No description provided for @pushActionNews.
  ///
  /// In pt, this message translates to:
  /// **'Notícia publicada'**
  String get pushActionNews;

  /// No description provided for @pushActionNewsHint.
  ///
  /// In pt, this message translates to:
  /// **'Notícia visível no feed (sem anúncios) · título da notícia'**
  String get pushActionNewsHint;

  /// No description provided for @pushActionMatch.
  ///
  /// In pt, this message translates to:
  /// **'Nova partida'**
  String get pushActionMatch;

  /// No description provided for @pushActionMatchHint.
  ///
  /// In pt, this message translates to:
  /// **'Partida cadastrada · data, horário e local'**
  String get pushActionMatchHint;

  /// No description provided for @pushActionVotingOpen.
  ///
  /// In pt, this message translates to:
  /// **'Votação aberta'**
  String get pushActionVotingOpen;

  /// No description provided for @pushActionVotingOpenHint.
  ///
  /// In pt, this message translates to:
  /// **'Votação do melhor da partida liberada'**
  String get pushActionVotingOpenHint;

  /// No description provided for @pushActionVotingClosed.
  ///
  /// In pt, this message translates to:
  /// **'Votação encerrada'**
  String get pushActionVotingClosed;

  /// No description provided for @pushActionVotingClosedHint.
  ///
  /// In pt, this message translates to:
  /// **'Votação fechada · convida a ver o eleito'**
  String get pushActionVotingClosedHint;

  /// No description provided for @pushActionDailyGame.
  ///
  /// In pt, this message translates to:
  /// **'Jogo do seu time'**
  String get pushActionDailyGame;

  /// No description provided for @pushActionDailyGameHint.
  ///
  /// In pt, this message translates to:
  /// **'Todo dia às 9h, para quem torce por um time que joga hoje'**
  String get pushActionDailyGameHint;

  /// No description provided for @pushActionNotice.
  ///
  /// In pt, this message translates to:
  /// **'Aviso manual'**
  String get pushActionNotice;

  /// No description provided for @pushActionNoticeHint.
  ///
  /// In pt, this message translates to:
  /// **'Avisos enviados pela aba \"Enviar aviso\"'**
  String get pushActionNoticeHint;

  /// No description provided for @pushHistoryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma notificação enviada ainda.'**
  String get pushHistoryEmpty;

  /// No description provided for @pushStatusSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviada'**
  String get pushStatusSent;

  /// No description provided for @pushStatusDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Desligada'**
  String get pushStatusDisabled;

  /// No description provided for @pushStatusError.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get pushStatusError;

  /// No description provided for @pushAllRegions.
  ///
  /// In pt, this message translates to:
  /// **'Todas as regiões'**
  String get pushAllRegions;

  /// No description provided for @pushAudienceTeams.
  ///
  /// In pt, this message translates to:
  /// **'Torcedores dos times'**
  String get pushAudienceTeams;

  /// No description provided for @pushNoticeSection.
  ///
  /// In pt, this message translates to:
  /// **'Aviso'**
  String get pushNoticeSection;

  /// No description provided for @pushNoticeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get pushNoticeTitle;

  /// No description provided for @pushNoticeBody.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem'**
  String get pushNoticeBody;

  /// No description provided for @pushNoticeAudience.
  ///
  /// In pt, this message translates to:
  /// **'Para quem'**
  String get pushNoticeAudience;

  /// No description provided for @pushNoticePreview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia'**
  String get pushNoticePreview;

  /// No description provided for @pushNoticeHint.
  ///
  /// In pt, this message translates to:
  /// **'O envio leva alguns segundos e aparece no Histórico.'**
  String get pushNoticeHint;

  /// No description provided for @pushSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get pushSend;

  /// No description provided for @pushSendConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar notificação?'**
  String get pushSendConfirmTitle;

  /// No description provided for @pushSendConfirmMessage.
  ///
  /// In pt, this message translates to:
  /// **'Todos os usuários de \"{audience}\" vão receber este aviso agora.'**
  String pushSendConfirmMessage(String audience);

  /// No description provided for @pushSent.
  ///
  /// In pt, this message translates to:
  /// **'Aviso enviado!'**
  String get pushSent;

  /// No description provided for @playerRequestMenu.
  ///
  /// In pt, this message translates to:
  /// **'Sou jogador'**
  String get playerRequestMenu;

  /// No description provided for @playerRequestTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sou jogador'**
  String get playerRequestTitle;

  /// No description provided for @playerRequestIntro.
  ///
  /// In pt, this message translates to:
  /// **'Jogue pelo seu time da região: envie a solicitação e um administrador vai analisar.'**
  String get playerRequestIntro;

  /// No description provided for @playerRequestTeamRequired.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o time em que você joga.'**
  String get playerRequestTeamRequired;

  /// No description provided for @playerRequestNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome de jogador'**
  String get playerRequestNameLabel;

  /// No description provided for @playerRequestPositionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Posição'**
  String get playerRequestPositionLabel;

  /// No description provided for @playerRequestPositionRequired.
  ///
  /// In pt, this message translates to:
  /// **'Escolha sua posição.'**
  String get playerRequestPositionRequired;

  /// No description provided for @playerRequestMessageLabel.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem para o admin (opcional)'**
  String get playerRequestMessageLabel;

  /// No description provided for @playerRequestMessageHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: jogo de lateral no time desde 2022'**
  String get playerRequestMessageHint;

  /// No description provided for @playerRequestSubmit.
  ///
  /// In pt, this message translates to:
  /// **'ENVIAR SOLICITAÇÃO'**
  String get playerRequestSubmit;

  /// No description provided for @playerRequestResubmit.
  ///
  /// In pt, this message translates to:
  /// **'Enviar nova solicitação'**
  String get playerRequestResubmit;

  /// No description provided for @playerRequestSent.
  ///
  /// In pt, this message translates to:
  /// **'Solicitação enviada! Você será avisado quando o admin responder.'**
  String get playerRequestSent;

  /// No description provided for @playerRequestCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Solicitação cancelada.'**
  String get playerRequestCancelled;

  /// No description provided for @playerRequestStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando aprovação'**
  String get playerRequestStatusPending;

  /// No description provided for @playerRequestStatusApproved.
  ///
  /// In pt, this message translates to:
  /// **'Aprovada'**
  String get playerRequestStatusApproved;

  /// No description provided for @playerRequestStatusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitada'**
  String get playerRequestStatusRejected;

  /// No description provided for @playerRequestPendingInfo.
  ///
  /// In pt, this message translates to:
  /// **'Um administrador vai analisar seu pedido. Enquanto isso, você ainda pode corrigir os dados.'**
  String get playerRequestPendingInfo;

  /// No description provided for @playerRequestApprovedInfo.
  ///
  /// In pt, this message translates to:
  /// **'Você é jogador do {team}!'**
  String playerRequestApprovedInfo(String team);

  /// No description provided for @playerRequestRejectedInfo.
  ///
  /// In pt, this message translates to:
  /// **'Sua solicitação não foi aprovada. Você pode enviar uma nova.'**
  String get playerRequestRejectedInfo;

  /// No description provided for @playerRequestReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo: {reason}'**
  String playerRequestReason(String reason);

  /// No description provided for @playerRequestSentOn.
  ///
  /// In pt, this message translates to:
  /// **'Enviada em {date}'**
  String playerRequestSentOn(String date);

  /// No description provided for @playerRequestEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar solicitação'**
  String get playerRequestEdit;

  /// No description provided for @playerRequestCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar solicitação'**
  String get playerRequestCancel;

  /// No description provided for @playerRequestCancelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar solicitação?'**
  String get playerRequestCancelTitle;

  /// No description provided for @playerRequestCancelMessage.
  ///
  /// In pt, this message translates to:
  /// **'Seu pedido para entrar no {team} será apagado.'**
  String playerRequestCancelMessage(String team);

  /// No description provided for @playerRequestKeep.
  ///
  /// In pt, this message translates to:
  /// **'Manter'**
  String get playerRequestKeep;

  /// No description provided for @playerRequestDiscardEdit.
  ///
  /// In pt, this message translates to:
  /// **'Descartar alterações'**
  String get playerRequestDiscardEdit;

  /// No description provided for @playerRequestViewProfile.
  ///
  /// In pt, this message translates to:
  /// **'Ver meu perfil de jogador'**
  String get playerRequestViewProfile;

  /// No description provided for @playerRequestLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar sua solicitação.'**
  String get playerRequestLoadError;

  /// No description provided for @playerPositionGoalkeeper.
  ///
  /// In pt, this message translates to:
  /// **'Goleiro'**
  String get playerPositionGoalkeeper;

  /// No description provided for @playerPositionDefender.
  ///
  /// In pt, this message translates to:
  /// **'Zagueiro'**
  String get playerPositionDefender;

  /// No description provided for @playerPositionFullBack.
  ///
  /// In pt, this message translates to:
  /// **'Lateral'**
  String get playerPositionFullBack;

  /// No description provided for @playerPositionMidfielder.
  ///
  /// In pt, this message translates to:
  /// **'Meia'**
  String get playerPositionMidfielder;

  /// No description provided for @playerPositionForward.
  ///
  /// In pt, this message translates to:
  /// **'Atacante'**
  String get playerPositionForward;

  /// No description provided for @playerRequestsPanelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Solicitações de jogadores'**
  String get playerRequestsPanelTitle;

  /// No description provided for @playerRequestsTabPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes'**
  String get playerRequestsTabPending;

  /// No description provided for @playerRequestsTabAnswered.
  ///
  /// In pt, this message translates to:
  /// **'Respondidas'**
  String get playerRequestsTabAnswered;

  /// No description provided for @playerRequestsEmptyPending.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma solicitação pendente.'**
  String get playerRequestsEmptyPending;

  /// No description provided for @playerRequestsEmptyAnswered.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma solicitação respondida ainda.'**
  String get playerRequestsEmptyAnswered;

  /// No description provided for @playerRequestsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as solicitações.'**
  String get playerRequestsLoadError;

  /// No description provided for @playerRequestsApprove.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar'**
  String get playerRequestsApprove;

  /// No description provided for @playerRequestsReject.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitar'**
  String get playerRequestsReject;

  /// No description provided for @playerRequestsApproveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar {name}?'**
  String playerRequestsApproveTitle(String name);

  /// No description provided for @playerRequestsApproveMessage.
  ///
  /// In pt, this message translates to:
  /// **'{name} entra no elenco do {team}.'**
  String playerRequestsApproveMessage(String name, String team);

  /// No description provided for @playerRequestsRejectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitar a solicitação de {name}?'**
  String playerRequestsRejectTitle(String name);

  /// No description provided for @playerRequestsRejectReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo (opcional)'**
  String get playerRequestsRejectReason;

  /// No description provided for @playerRequestsApproved.
  ///
  /// In pt, this message translates to:
  /// **'{name} agora é jogador do {team}.'**
  String playerRequestsApproved(String name, String team);

  /// No description provided for @playerRequestsRejected.
  ///
  /// In pt, this message translates to:
  /// **'Solicitação rejeitada.'**
  String get playerRequestsRejected;

  /// No description provided for @playerRequestsUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Solicitação atualizada.'**
  String get playerRequestsUpdated;

  /// No description provided for @playerRequestsAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta: {name}'**
  String playerRequestsAccount(String name);

  /// No description provided for @pushActionPlayerRequest.
  ///
  /// In pt, this message translates to:
  /// **'Nova solicitação de jogador'**
  String get pushActionPlayerRequest;

  /// No description provided for @pushActionPlayerRequestHint.
  ///
  /// In pt, this message translates to:
  /// **'Para os admins · \"Fulano quer jogar no Lava Jato\"'**
  String get pushActionPlayerRequestHint;

  /// No description provided for @pushActionPlayerRequestAnswer.
  ///
  /// In pt, this message translates to:
  /// **'Resposta da solicitação'**
  String get pushActionPlayerRequestAnswer;

  /// No description provided for @pushActionPlayerRequestAnswerHint.
  ///
  /// In pt, this message translates to:
  /// **'Para quem pediu · aprovada ou rejeitada'**
  String get pushActionPlayerRequestAnswerHint;

  /// No description provided for @athleteDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir atleta'**
  String get athleteDelete;

  /// No description provided for @athleteDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir {name}?'**
  String athleteDeleteTitle(String name);

  /// No description provided for @athleteDeleteMessage.
  ///
  /// In pt, this message translates to:
  /// **'{name} sai do elenco do {team}. Gols e assistências dele deixam de contar no ranking. Essa ação não pode ser desfeita.'**
  String athleteDeleteMessage(String name, String team);

  /// No description provided for @athleteDeleted.
  ///
  /// In pt, this message translates to:
  /// **'{name} foi excluído do {team}.'**
  String athleteDeleted(String name, String team);

  /// No description provided for @athleteRemoveFromSquad.
  ///
  /// In pt, this message translates to:
  /// **'Remover do elenco'**
  String get athleteRemoveFromSquad;

  /// No description provided for @athleteRemoveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover {name} do elenco?'**
  String athleteRemoveTitle(String name);

  /// No description provided for @athleteRemoveMessage.
  ///
  /// In pt, this message translates to:
  /// **'{name} sai do elenco do {team}. Os gols e assistências continuam na conta dele, e ele pode pedir para entrar em outro time.'**
  String athleteRemoveMessage(String name, String team);

  /// No description provided for @athleteRemoved.
  ///
  /// In pt, this message translates to:
  /// **'{name} saiu do elenco do {team}.'**
  String athleteRemoved(String name, String team);

  /// No description provided for @playerRequestStatusRemoved.
  ///
  /// In pt, this message translates to:
  /// **'Fora do elenco'**
  String get playerRequestStatusRemoved;

  /// No description provided for @playerRequestRemovedInfo.
  ///
  /// In pt, this message translates to:
  /// **'Você saiu do elenco do {team}. Suas estatísticas continuam salvas e você pode pedir para entrar em outro time.'**
  String playerRequestRemovedInfo(String team);

  /// No description provided for @playerRequestJoinAnother.
  ///
  /// In pt, this message translates to:
  /// **'Pedir para entrar em outro time'**
  String get playerRequestJoinAnother;
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
