// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Arena Football';

  @override
  String get commonRequiredField => 'Campo obrigatório';

  @override
  String get commonTryAgain => 'Tentar novamente';

  @override
  String get commonLoading => 'Carregando...';

  @override
  String get commonSave => 'SALVAR';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonGenericError => 'Algo deu errado. Tente novamente.';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginButton => 'ENTRAR';

  @override
  String get loginCreateAccountButton => 'CRIAR CONTA';

  @override
  String get loginSuccess => 'Usuário Logado!';

  @override
  String get loginInvalidEmail => 'E-mail inválido!';

  @override
  String get loginInvalidPassword =>
      'Senha inválida! Utilize no mínimo 8 caracteres.';

  @override
  String get registerTitle => 'Criar conta';

  @override
  String get registerNameLabel => 'Nome';

  @override
  String get registerEmailLabel => 'E-mail';

  @override
  String get registerPasswordLabel => 'Senha';

  @override
  String get registerRegionLabel => 'Região';

  @override
  String get registerTeamLabel => 'Time do coração';

  @override
  String get registerHaveAccountButton => 'Já tenho uma conta!';

  @override
  String get registerSuccess => 'Usuário Cadastrado com Sucesso!';

  @override
  String get registerNameTooShort =>
      'Seu nome de usuário deve conter no mínimo 3 caracteres';

  @override
  String get registerEmailExample =>
      'Informe um e-mail válido, ex.: nome@email.com';

  @override
  String get registerPasswordTooShort =>
      'Sua senha deve conter no mínimo 8 caracteres';

  @override
  String get homeTabHome => 'Início';

  @override
  String get homeTabChampionships => 'Campeonatos';

  @override
  String get homeTabTeams => 'Times';

  @override
  String get homeTabTables => 'Tabelas';

  @override
  String get drawerHome => 'Início';

  @override
  String get drawerResults => 'Resultados pelo mundo';

  @override
  String get drawerRegisterHighlight => 'Destaques';

  @override
  String get drawerRegisterPlayer => 'Cadastrar jogador';

  @override
  String get drawerRegisterMatch => 'Cadastrar partida';

  @override
  String get drawerRegisterNews => 'Cadastrar notícia';

  @override
  String get drawerRegisterTeam => 'Cadastrar time';

  @override
  String drawerFanOf(String team) {
    return 'Torcedor do $team';
  }

  @override
  String get drawerGuest => 'Visitante';

  @override
  String get commonTakePhoto => 'Tirar foto';

  @override
  String get commonGallery => 'Galeria';

  @override
  String get newsEmpty => 'Nenhuma notícia registrada';

  @override
  String get newsLoadError => 'Não foi possível carregar as notícias.';

  @override
  String get newsDeleteConfirm => 'DESEJA REALMENTE EXCLUIR ESSA NOTÍCIA ?';

  @override
  String get newsAdPlaceholder => 'PUBLICIDADE';

  @override
  String get newsCreateTitle => 'Nova notícia';

  @override
  String get newsEditTitle => 'Editar notícia';

  @override
  String get newsTitleLabel => 'Título';

  @override
  String get newsCoverAdd => 'Adicionar capa';

  @override
  String get newsCoverHint =>
      'Toque para tirar uma foto ou escolher da galeria';

  @override
  String get newsCoverChange => 'Trocar';

  @override
  String get newsCoverRemove => 'Remover';

  @override
  String get newsSectionContent => 'Conteúdo';

  @override
  String get newsSectionAlbum => 'Álbum de fotos';

  @override
  String get newsSectionPublish => 'Publicação';

  @override
  String newsAlbumCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
      zero: 'nenhuma foto',
    );
    return '$_temp0';
  }

  @override
  String get newsAlbumAdd => 'Adicionar';

  @override
  String get newsAlbumHint => 'As fotos aparecem na galeria da notícia.';

  @override
  String get newsRegion => 'Região';

  @override
  String get newsHighlight => 'Destaque';

  @override
  String get newsHighlightNone => 'Nenhum';

  @override
  String get newsHighlightHint =>
      'A notícia também aparece dentro do destaque escolhido.';

  @override
  String get newsLinkHint => 'Link externo (opcional)';

  @override
  String get newsVisibleHint =>
      'Desligado, a notícia fica salva mas não aparece no app.';

  @override
  String get newsVisibleOnHint => 'A notícia aparece no feed do app.';

  @override
  String get newsPreview => 'Pré-visualizar';

  @override
  String get newsPreviewTitle => 'Como vai aparecer no feed';

  @override
  String get newsDiscardTitle => 'Descartar alterações?';

  @override
  String get newsDiscardMessage => 'O que você preencheu será perdido.';

  @override
  String get newsDiscardKeep => 'Continuar editando';

  @override
  String get newsDiscardConfirm => 'Descartar';

  @override
  String get newsPublish => 'Publicar notícia';

  @override
  String get newsSave => 'Salvar alterações';

  @override
  String get newsDescriptionLabel => 'Descrição';

  @override
  String get newsLinkLabel => 'Link';

  @override
  String get newsVisibleLabel => 'Visível no app';

  @override
  String get newsTitleRequired => 'Informe o título da notícia';

  @override
  String get newsTitleTooShort =>
      'O título da notícia deve conter no mínimo 3 caracteres';

  @override
  String get newsCreated => 'Notícia publicada!';

  @override
  String get newsUpdated => 'Notícia atualizada!';

  @override
  String get newsRegionLabel => 'Região:';

  @override
  String get newsGoalTitle => 'Card de gol';

  @override
  String get newsPublishButton => 'Publicar';

  @override
  String get newsGoalCreated => 'Gol publicado!';

  @override
  String get goalTodayMatches => 'Jogos de hoje';

  @override
  String get goalTodayMatchesHint =>
      'Toque para preencher os times e o placar.';

  @override
  String get goalScoreboard => 'Placar';

  @override
  String get goalPickTeam => 'Escolher time';

  @override
  String get goalHome => 'Mandante';

  @override
  String get goalAway => 'Visitante';

  @override
  String get goalSameTeam => 'Escolha dois times diferentes.';

  @override
  String get goalNoTeams => 'Nenhum time cadastrado nesta região.';

  @override
  String get goalSearchTeam => 'Buscar time';

  @override
  String get goalUpdateMatch => 'Atualizar placar da partida';

  @override
  String get goalUpdateMatchHint =>
      'Grava o mesmo placar na partida da tabela.';

  @override
  String get goalPreview => 'Prévia no feed';

  @override
  String get goalPublish => 'Publicar gol';

  @override
  String get goalConfirmTitle => 'Publicar card de gol?';

  @override
  String goalConfirmMessage(
      String home, int homeGoals, int awayGoals, String away) {
    return '$home $homeGoals × $awayGoals $away';
  }

  @override
  String get goalMatchUpdated =>
      'Gol publicado e placar da partida atualizado!';

  @override
  String get goalMatchUpdateFailed =>
      'Gol publicado, mas não foi possível atualizar o placar da partida.';

  @override
  String goalOfTeam(String team) {
    return 'Gol do $team';
  }

  @override
  String get goalWhoScoredQ => 'Quem fez o gol?';

  @override
  String goalWhoAssistedQ(String scorer) {
    return 'Quem deu o passe para $scorer?';
  }

  @override
  String get goalSkip => 'Pular';

  @override
  String get goalNoAssist => 'Sem assistência';

  @override
  String get goalBack => 'Voltar';

  @override
  String get goalEditScorer => 'Editar';

  @override
  String get goalSearchPlayer => 'Buscar jogador';

  @override
  String get goalClear => 'Limpar';

  @override
  String goalScorerLine(String scorer) {
    return '⚽ $scorer';
  }

  @override
  String goalScorerAssistLine(String scorer, String assistant) {
    return '⚽ $scorer · assist. $assistant';
  }

  @override
  String goalStatsSaved(String scorer) {
    return 'Gol publicado! $scorer +1 gol.';
  }

  @override
  String goalStatsSavedWithAssist(String scorer, String assistant) {
    return 'Gol publicado! $scorer +1 gol, $assistant +1 assistência.';
  }

  @override
  String get goalStatsFailed =>
      'Gol publicado, mas não foi possível somar nos números dos jogadores.';

  @override
  String get goalIncrease => 'Aumentar';

  @override
  String get goalDecrease => 'Diminuir';

  @override
  String get newsAdCreated => 'Publicidade publicada!';

  @override
  String get highlightTitleLabel => 'Título';

  @override
  String get highlightLinkLabel => 'Link';

  @override
  String get highlightVisibleLabel => 'Exibir no carrossel';

  @override
  String get highlightTitleRequired => 'Informe o título do destaque.';

  @override
  String get highlightCreated => 'Destaque publicado!';

  @override
  String get teamsEmpty => 'Equipes ainda não registradas';

  @override
  String get teamsLoadError => 'Não foi possível carregar os times.';

  @override
  String get teamsFormTitle => 'Novo time';

  @override
  String get teamsNameLabel => 'Nome do time';

  @override
  String get teamsDescriptionLabel => 'Descrição (opcional)';

  @override
  String get teamsCreated => 'Time cadastrado!';

  @override
  String get teamsNameRequired => 'Informe o nome do time (mínimo 3 letras).';

  @override
  String get teamsCrestAdd => 'Adicionar escudo';

  @override
  String get teamsSectionData => 'Dados do time';

  @override
  String get teamsDescriptionHint => 'Ex.: bairro, fundação, apelido';

  @override
  String get teamsPreview => 'Prévia na aba Times';

  @override
  String teamsInRegion(int count) {
    return 'Times na região · $count';
  }

  @override
  String teamsDuplicate(String name) {
    return 'Já existe um time \"$name\" nesta região.';
  }

  @override
  String get teamsSubmit => 'Cadastrar time';

  @override
  String get playersEmpty => 'Jogadores ainda não registrados!';

  @override
  String get playersLoadError => 'Não foi possível carregar os jogadores.';

  @override
  String playersGoalsCount(int count) {
    return 'Gols: $count';
  }

  @override
  String playersAssistsCount(int count) {
    return 'Assistências: $count';
  }

  @override
  String get playersNameRequired => 'Informe o nome (mínimo 3 letras).';

  @override
  String get playersTeamRequired => 'Escolha o time do jogador.';

  @override
  String get playersFormTitle => 'Novo jogador';

  @override
  String get playersNameLabel => 'Nome do jogador';

  @override
  String get playersGoalsLabel => 'Gols';

  @override
  String get playersAssistsLabel => 'Assistências';

  @override
  String get playersCreated => 'Jogador cadastrado!';

  @override
  String get playersPhotoAdd => 'Adicionar foto (opcional)';

  @override
  String get playersSectionData => 'Dados do jogador';

  @override
  String get playersTeam => 'Time';

  @override
  String get playersPreview => 'Prévia no elenco';

  @override
  String playersSquadOf(String team, int count) {
    return 'Elenco do $team · $count';
  }

  @override
  String playersDuplicate(String name, String team) {
    return 'Já existe \"$name\" no $team.';
  }

  @override
  String get playersSubmit => 'Cadastrar jogador';

  @override
  String get playersPhotoBack => 'Voltar';

  @override
  String get playersPhotoSave => 'Salvar';

  @override
  String get statsEmptyGoals => 'Nenhum gol marcado ainda';

  @override
  String get statsEmptyAssists => 'Nenhuma assistência ainda';

  @override
  String statsUnitGoals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'gols',
      one: 'gol',
    );
    return '$_temp0';
  }

  @override
  String statsUnitAssists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'assist.',
      one: 'assist.',
    );
    return '$_temp0';
  }

  @override
  String get statsLoadError => 'Não foi possível carregar o ranking.';

  @override
  String get matchesNoChampionship => 'Nenhum registro no momento';

  @override
  String get matchesEmpty => 'Nenhuma partida cadastrada';

  @override
  String get matchesLoadError => 'Não foi possível carregar as partidas.';

  @override
  String get matchesAllGames => 'Todos os jogos';

  @override
  String get matchesGroups => 'Grupos';

  @override
  String get matchesTopScorers => 'Artilharia';

  @override
  String get matchesAssists => 'Assistências';

  @override
  String get matchesAllGamesTitle => 'Todos os jogos';

  @override
  String matchesSummaryGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jogos',
      one: 'jogo',
    );
    return '$_temp0';
  }

  @override
  String matchesSummaryGoals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'gols',
      one: 'gol',
    );
    return '$_temp0';
  }

  @override
  String get matchesSummaryAverage => 'gols por jogo';

  @override
  String matchesDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jogos',
      one: '1 jogo',
    );
    return '$_temp0';
  }

  @override
  String get matchesNoDate => 'Sem data';

  @override
  String get matchesFilterAll => 'Todos';

  @override
  String get matchesEmptyForTeam => 'Nenhuma partida deste time';

  @override
  String get matchesVersus => 'X';

  @override
  String get matchesEditScore => 'Editar Placar';

  @override
  String get matchesDeleteMatch => 'Excluir Partida';

  @override
  String get matchesDeleteConfirm => 'DESEJA REALMENTE EXCLUIR ESSA PARTIDA ?';

  @override
  String get matchesEditScoreTitle => 'Alterar Placar:';

  @override
  String get matchesHomeLabel => 'Casa';

  @override
  String get matchesAwayLabel => 'Fora';

  @override
  String get matchesFormTitle => 'Nova partida';

  @override
  String get matchesCreated => 'Partida cadastrada!';

  @override
  String get matchFormMatchup => 'Confronto';

  @override
  String get matchFormSwap => 'Inverter mando';

  @override
  String get matchFormWhen => 'Quando';

  @override
  String get matchFormWhere => 'Onde';

  @override
  String get matchFormToday => 'Hoje';

  @override
  String get matchFormTomorrow => 'Amanhã';

  @override
  String get matchFormOtherDate => 'Outra data';

  @override
  String get matchFormOtherTime => 'Outro horário';

  @override
  String get matchFormNewVenue => 'Novo local';

  @override
  String get matchFormVenueHint => 'Nome do local';

  @override
  String get matchFormPreview => 'Prévia';

  @override
  String get matchFormSubmit => 'Cadastrar partida';

  @override
  String get matchFormMissingTeams => 'Escolha os dois times.';

  @override
  String get matchFormMissingDate => 'Escolha a data da partida.';

  @override
  String get matchFormMissingTime => 'Escolha o horário da partida.';

  @override
  String matchFormConflictTeam(String team, String times) {
    return '$team já tem jogo nesta data ($times).';
  }

  @override
  String matchFormConflictVenue(String venue, String time) {
    return '$venue já tem jogo nesta data às $time.';
  }

  @override
  String get matchFormSaved =>
      'Partida cadastrada! Escolha os times da próxima.';

  @override
  String get championshipsEmpty => 'Nenhuma competição registrada';

  @override
  String get championshipsLoadError =>
      'Não foi possível carregar as competições.';

  @override
  String get championshipsDetailsTitle => 'Sobre a Competição:';

  @override
  String championshipsPrizes(String first, String second, String third,
      String topScorer, String goalkeeper) {
    return 'PREMIAÇÃO:\n\n1º Lugar: $first\n2º Lugar: $second\n3º Lugar: $third\n\nArtilheiro: $topScorer\nMelhor Goleiro: $goalkeeper';
  }

  @override
  String championshipsRules(String rules) {
    return 'REGRAS:\n\n$rules';
  }

  @override
  String get championshipsGroupsButton => 'GRUPOS';

  @override
  String championshipsGroupTitle(String name) {
    return 'Grupo $name';
  }

  @override
  String get championshipsGroupsEmpty =>
      'Nenhum grupo cadastrado nesta temporada.';

  @override
  String get championshipsGroupsLoadError =>
      'Não foi possível carregar os grupos.';

  @override
  String get championshipsStandingsEmpty =>
      'Classificação ainda não disponível.';

  @override
  String get championshipsStandingsLoadError =>
      'Não foi possível carregar a classificação.';

  @override
  String get championshipsStandingsWins => 'V';

  @override
  String get championshipsStandingsLosses => 'D';

  @override
  String get championshipsStandingsDraws => 'E';

  @override
  String get championshipsStandingsPoints => 'P';

  @override
  String get championshipsStandingsGoalDifference => 'SG';

  @override
  String get votingTitle => 'Melhor da Partida';

  @override
  String get votingBlankVote => 'Voto em branco! Tente novamente.';

  @override
  String get votingHint =>
      'Você pode trocar o voto quando quiser; só o último conta.';

  @override
  String get votingSearchHint => 'Buscar jogador';

  @override
  String get votingChoosePlayer => 'Escolha um jogador';

  @override
  String votingVoteFor(String name) {
    return 'Votar em $name';
  }

  @override
  String votingChangeVoteTo(String name) {
    return 'Trocar voto para $name';
  }

  @override
  String votingYouVotedFor(String name) {
    return 'Você votou em $name';
  }

  @override
  String get votingYourVote => 'Seu voto';

  @override
  String get votingGuestTitle =>
      'Entre na sua conta para votar no craque da partida';

  @override
  String get votingGuestAction => 'Entrar';

  @override
  String get votingSuccessTitle => 'Voto registrado!';

  @override
  String get votingEmptySquad => 'Elenco não cadastrado';

  @override
  String get votingNoSearchResults => 'Nenhum jogador encontrado';

  @override
  String get commonClose => 'Fechar';

  @override
  String get votingLoginRequired => 'Faça login para votar.';

  @override
  String get votingElectedTitle => 'Craque da partida';

  @override
  String votingMatchSubtitle(String home, String away) {
    return '$home x $away';
  }

  @override
  String votingVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String votingShareOfVotes(int percent) {
    return '$percent% dos votos';
  }

  @override
  String get votingRankingTitle => 'Votação';

  @override
  String get votingNoVotesYet => 'Ninguém votou nesta partida ainda';

  @override
  String votingShareText(String player, String match, String votes) {
    return '$player foi eleito o craque de $match com $votes! ⚽ via Arena Football';
  }

  @override
  String get votingLoadError => 'Não foi possível apurar a votação.';

  @override
  String get globalResultsTitle => 'Resultados pelo mundo';

  @override
  String get globalResultsYesterday => 'Ontem';

  @override
  String get globalResultsToday => 'Hoje';

  @override
  String get globalResultsTomorrow => 'Amanhã';

  @override
  String get globalResultsSubtitle => 'Placares das principais ligas do mundo';

  @override
  String get globalResultsLive => 'Ao vivo';

  @override
  String get globalResultsHalfTime => 'Intervalo';

  @override
  String get globalResultsFinished => 'Encerrado';

  @override
  String get globalResultsPostponed => 'Adiado';

  @override
  String globalResultsLiveFilter(int count) {
    return 'Ao vivo ($count)';
  }

  @override
  String get globalResultsSearchHint => 'Buscar time ou liga';

  @override
  String get globalResultsNoMatches => 'Nenhum jogo encontrado';

  @override
  String get globalResultsPenalty => 'pênalti';

  @override
  String get globalResultsOwnGoal => 'contra';

  @override
  String get globalResultsGoalsError =>
      'Não foi possível carregar os gols. Toque para tentar de novo.';

  @override
  String get loginWelcomeTitle => 'Bem-vindo de volta 👋';

  @override
  String get loginWelcomeSubtitle =>
      'Entre para acompanhar seu time, os jogos e a tabela.';

  @override
  String get loginForgotPassword => 'Esqueci minha senha';

  @override
  String get loginOr => 'ou';

  @override
  String get loginWithGoogleButton => 'ENTRAR COM GOOGLE';

  @override
  String get loginContinueAsGuest => 'Continuar sem conta';

  @override
  String get loginShowPassword => 'Mostrar senha';

  @override
  String get loginHidePassword => 'Ocultar senha';

  @override
  String get forgotPasswordTitle => 'Recuperar senha';

  @override
  String get forgotPasswordDescription =>
      'Informe o e-mail da sua conta e enviaremos um link para você criar uma nova senha.';

  @override
  String get forgotPasswordSend => 'ENVIAR LINK';

  @override
  String get forgotPasswordSent =>
      'Enviamos um link de recuperação para o seu e-mail.';

  @override
  String get registerStepOne => 'Etapa 1 de 2 · seus dados de acesso';

  @override
  String get registerCreateAccountButton => 'CRIAR CONTA';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar senha';

  @override
  String get registerPasswordMismatch => 'As senhas não coincidem';

  @override
  String get passwordStrengthWeak => 'Senha fraca';

  @override
  String get passwordStrengthMedium => 'Senha média';

  @override
  String get passwordStrengthStrong => 'Senha forte';

  @override
  String get chooseTeamTitle => 'Seu time do coração';

  @override
  String get chooseTeamSubtitle => 'Etapa 2 de 2 · personalize o app';

  @override
  String get chooseTeamDescription =>
      'Escolha sua região e o time que você acompanha. Dá para mudar depois.';

  @override
  String get chooseTeamConfirm => 'CONCLUIR';

  @override
  String get chooseTeamSkip => 'Pular por agora';

  @override
  String get chooseTeamLoadError =>
      'Não foi possível carregar as regiões e os times.';

  @override
  String get chooseTeamEmptyTeams => 'Nenhum time cadastrado nesta região.';

  @override
  String get drawerNavigation => 'Navegação';

  @override
  String get drawerAdmin => 'Administração';

  @override
  String get drawerLogout => 'Sair da conta';

  @override
  String get drawerChooseTeam => 'Escolher meu time';

  @override
  String get drawerSignIn => 'Entrar ou criar conta';

  @override
  String get drawerGuestSubtitle =>
      'Entre para salvar seu time e votar no melhor da partida.';

  @override
  String homeGreeting(String name) {
    return 'Olá, $name 👋';
  }

  @override
  String get homeGreetingGuest => 'Bem-vindo ao Arena 👋';

  @override
  String homeSubtitle(String region) {
    return 'Futebol amador de $region';
  }

  @override
  String get homeHighlights => 'Destaques';

  @override
  String get homeLatestNews => 'Últimas notícias';

  @override
  String get homeTodayMatches => 'Jogos de hoje';

  @override
  String homeSeasonChip(String season) {
    return 'Temporada $season';
  }

  @override
  String get homePublishTitle => 'Publicar';

  @override
  String get homePublishNews => 'Notícia';

  @override
  String get homePublishGoal => 'Gol';

  @override
  String get homePublishAd => 'Anúncio';

  @override
  String get homePublishHighlight => 'Destaque';

  @override
  String get homePublishMatch => 'Partida';

  @override
  String get homePublishTeam => 'Time';

  @override
  String get homePublishPlayer => 'Jogador';

  @override
  String get homeOpenMenu => 'Abrir menu';

  @override
  String get matchesVoteAction => 'Votar no melhor';

  @override
  String get matchesSeeElected => 'Ver eleito';

  @override
  String get matchesOpenVoting => 'Abrir votação';

  @override
  String get matchesCloseVoting => 'Fechar votação';

  @override
  String get championshipsSeeDetails => 'Ver detalhes';

  @override
  String get newsAdLabel => 'Publicidade';

  @override
  String get newsGoalLabel => 'GOL';

  @override
  String get commonMoreActions => 'Mais ações';

  @override
  String get timeJustNow => 'agora';

  @override
  String timeMinutesAgo(int minutes) {
    return 'há $minutes min';
  }

  @override
  String timeHoursAgo(int hours) {
    return 'há $hours h';
  }

  @override
  String get timeYesterday => 'ontem';

  @override
  String get newsShare => 'Compartilhar';

  @override
  String get newsShareFooter => 'via Arena Football';

  @override
  String get newsReadMore => 'Saiba mais';

  @override
  String get galleryClose => 'Fechar';

  @override
  String galleryCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playersSummaryPlayers => 'Jogadores';

  @override
  String get playersSummaryGoals => 'Gols';

  @override
  String get playersSummaryAssists => 'Assistências';

  @override
  String get playersSortGoals => 'Gols';

  @override
  String get playersSortAssists => 'Assistências';

  @override
  String get playersSortName => 'A–Z';

  @override
  String get playersSearchHint => 'Buscar jogador';

  @override
  String get playersNoResults => 'Nenhum jogador encontrado.';

  @override
  String get playersTopScorer => 'Artilheiro do time';

  @override
  String get playersChangePhoto => 'Trocar foto';

  @override
  String get playersEditName => 'Editar nome';

  @override
  String get playersSaveName => 'Salvar nome';

  @override
  String get commonClear => 'Limpar';

  @override
  String get groupsTitle => 'Grupos';

  @override
  String groupsSubtitle(String region, String season) {
    return '$region · Temporada $season';
  }

  @override
  String get groupsSeeStandings => 'Ver classificação';

  @override
  String get standingsColPosition => '#';

  @override
  String get standingsColTeam => 'Time';

  @override
  String get standingsColGames => 'J';

  @override
  String get standingsQualifiedLegend => 'Classificados para a próxima fase';

  @override
  String get standingsGoalsFor => 'Gols feitos';

  @override
  String get standingsGoalsAgainst => 'Gols sofridos';

  @override
  String get standingsPerformance => 'Aproveitamento';

  @override
  String get standingsYourTeam => 'Seu time';

  @override
  String get athleteTitle => 'Atleta';

  @override
  String get athleteScored => 'Fez o gol';

  @override
  String get athleteAssisted => 'Deu o passe';

  @override
  String athleteRankGoals(int position) {
    return '$positionº na artilharia';
  }

  @override
  String athleteRankAssists(int position) {
    return '$positionº em assistências';
  }

  @override
  String get athleteNoRank => 'Fora do ranking';

  @override
  String get athleteParticipations => 'Participações em gols';

  @override
  String get athleteNoParticipations => 'Ainda sem gols registrados no feed.';

  @override
  String get athleteNotFound => 'Jogador não encontrado.';

  @override
  String get athleteLoadError => 'Não foi possível carregar o jogador.';

  @override
  String get athleteEdit => 'Editar (admin)';

  @override
  String get athleteShare => 'Compartilhar';

  @override
  String athleteShareText(String name, String team, int goals, int assists) {
    return '$name ($team): $goals gols e $assists assistências · via Arena Football';
  }

  @override
  String athleteSeason(String season) {
    return 'Temporada $season';
  }

  @override
  String get adCreateTitle => 'Nova publicidade';

  @override
  String get adEditTitle => 'Editar publicidade';

  @override
  String get adPublish => 'Publicar anúncio';

  @override
  String get adUpdated => 'Publicidade atualizada!';

  @override
  String get adBannerAdd => 'Adicionar banner';

  @override
  String get adBannerHint =>
      'Use uma imagem horizontal 2:1 (ex.: 1200×600). É assim que ela aparece no feed.';

  @override
  String get adSectionAd => 'Anúncio';

  @override
  String get adNameLabel => 'Anunciante (opcional)';

  @override
  String get adNameHint => 'Só para você identificar o anúncio';

  @override
  String get adLinkHint => 'Site, Instagram ou WhatsApp do anunciante';

  @override
  String get adLinkInvalid => 'Link inválido. Ex.: https://loja.com.br';

  @override
  String get adTestLink => 'Testar';

  @override
  String get adImageRequired => 'Escolha a imagem do anúncio.';

  @override
  String get highlightCreateTitle => 'Novo destaque';

  @override
  String get highlightPhotoAdd => 'Adicionar foto';

  @override
  String get highlightPhotoHint =>
      'Aparece no círculo do carrossel. Prefira uma imagem quadrada.';

  @override
  String get highlightPreview => 'Prévia no carrossel';

  @override
  String get highlightSection => 'Destaque';

  @override
  String get highlightTitleHint =>
      'Notícias marcadas com este destaque aparecem nele';

  @override
  String get highlightTitleTooShort => 'Use pelo menos 3 letras.';

  @override
  String get highlightDuplicate => 'Já existe um destaque com esse nome.';

  @override
  String get highlightVisibleOnHint => 'Aparece no topo da home para todos.';

  @override
  String get highlightVisibleHint => 'Fica oculto até você ativar.';

  @override
  String get highlightPublish => 'Publicar destaque';

  @override
  String highlightNewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notícias',
      one: '1 notícia',
      zero: 'Nenhuma notícia',
    );
    return '$_temp0';
  }

  @override
  String get highlightOpenLink => 'Abrir link';

  @override
  String get highlightEmpty => 'Ainda não há notícias neste destaque.';

  @override
  String get highlightLoadError => 'Não foi possível carregar as notícias.';

  @override
  String get highlightAddNews => 'Notícia';

  @override
  String highlightShareText(String title) {
    return '$title · Arena Football';
  }

  @override
  String get highlightsManageTitle => 'Destaques';

  @override
  String get highlightsReorderHint =>
      'Arraste pela alça para definir a ordem do carrossel.';

  @override
  String get highlightsEmpty =>
      'Nenhum destaque cadastrado. Toque em + para criar.';

  @override
  String get highlightHidden => 'Oculto';

  @override
  String get highlightView => 'Ver';

  @override
  String get highlightEditTitle => 'Editar destaque';

  @override
  String get highlightUpdated => 'Destaque atualizado!';

  @override
  String highlightRenameHint(String old) {
    return 'As notícias marcadas com \"$old\" passam para o novo nome.';
  }

  @override
  String highlightDeleteTitle(String title) {
    return 'Excluir \"$title\"?';
  }

  @override
  String get highlightDeleteMessage =>
      'As notícias marcadas continuam no feed, só perdem a marcação deste destaque.';

  @override
  String highlightDeleted(String title) {
    return '\"$title\" excluído.';
  }

  @override
  String get pushPanelTitle => 'Notificações';

  @override
  String get pushTabActions => 'Ações';

  @override
  String get pushTabHistory => 'Histórico';

  @override
  String get pushTabSend => 'Enviar aviso';

  @override
  String get pushActionsIntro =>
      'Escolha quais ações enviam push. Cada usuário recebe da região escolhida no app; os jogos também chegam para quem torce pelos times.';

  @override
  String get pushActionGoal => 'Gol';

  @override
  String get pushActionGoalHint =>
      'Card de gol publicado · \"⚽ GOL! Lava Jato 2 × 1 Volta\"';

  @override
  String get pushActionNews => 'Notícia publicada';

  @override
  String get pushActionNewsHint =>
      'Notícia visível no feed (sem anúncios) · título da notícia';

  @override
  String get pushActionMatch => 'Nova partida';

  @override
  String get pushActionMatchHint =>
      'Partida cadastrada · data, horário e local';

  @override
  String get pushActionVotingOpen => 'Votação aberta';

  @override
  String get pushActionVotingOpenHint =>
      'Votação do melhor da partida liberada';

  @override
  String get pushActionVotingClosed => 'Votação encerrada';

  @override
  String get pushActionVotingClosedHint =>
      'Votação fechada · convida a ver o eleito';

  @override
  String get pushActionDailyGame => 'Jogo do seu time';

  @override
  String get pushActionDailyGameHint =>
      'Todo dia às 9h, para quem torce por um time que joga hoje';

  @override
  String get pushActionNotice => 'Aviso manual';

  @override
  String get pushActionNoticeHint =>
      'Avisos enviados pela aba \"Enviar aviso\"';

  @override
  String get pushHistoryEmpty => 'Nenhuma notificação enviada ainda.';

  @override
  String get pushStatusSent => 'Enviada';

  @override
  String get pushStatusDisabled => 'Desligada';

  @override
  String get pushStatusError => 'Erro';

  @override
  String get pushAllRegions => 'Todas as regiões';

  @override
  String get pushAudienceTeams => 'Torcedores dos times';

  @override
  String get pushNoticeSection => 'Aviso';

  @override
  String get pushNoticeTitle => 'Título';

  @override
  String get pushNoticeBody => 'Mensagem';

  @override
  String get pushNoticeAudience => 'Para quem';

  @override
  String get pushNoticePreview => 'Prévia';

  @override
  String get pushNoticeHint =>
      'O envio leva alguns segundos e aparece no Histórico.';

  @override
  String get pushSend => 'Enviar';

  @override
  String get pushSendConfirmTitle => 'Enviar notificação?';

  @override
  String pushSendConfirmMessage(String audience) {
    return 'Todos os usuários de \"$audience\" vão receber este aviso agora.';
  }

  @override
  String get pushSent => 'Aviso enviado!';

  @override
  String get playerRequestMenu => 'Sou jogador';

  @override
  String get playerRequestTitle => 'Sou jogador';

  @override
  String get playerRequestIntro =>
      'Jogue pelo seu time da região: envie a solicitação e um administrador vai analisar.';

  @override
  String get playerRequestTeamRequired => 'Escolha o time em que você joga.';

  @override
  String get playerRequestNameLabel => 'Nome de jogador';

  @override
  String get playerRequestPositionLabel => 'Posição';

  @override
  String get playerRequestPositionRequired => 'Escolha sua posição.';

  @override
  String get playerRequestMessageLabel => 'Mensagem para o admin (opcional)';

  @override
  String get playerRequestMessageHint =>
      'Ex.: jogo de lateral no time desde 2022';

  @override
  String get playerRequestSubmit => 'ENVIAR SOLICITAÇÃO';

  @override
  String get playerRequestResubmit => 'Enviar nova solicitação';

  @override
  String get playerRequestSent =>
      'Solicitação enviada! Você será avisado quando o admin responder.';

  @override
  String get playerRequestCancelled => 'Solicitação cancelada.';

  @override
  String get playerRequestStatusPending => 'Aguardando aprovação';

  @override
  String get playerRequestStatusApproved => 'Aprovada';

  @override
  String get playerRequestStatusRejected => 'Rejeitada';

  @override
  String get playerRequestPendingInfo =>
      'Um administrador vai analisar seu pedido. Enquanto isso, você ainda pode corrigir os dados.';

  @override
  String playerRequestApprovedInfo(String team) {
    return 'Você é jogador do $team!';
  }

  @override
  String get playerRequestRejectedInfo =>
      'Sua solicitação não foi aprovada. Você pode enviar uma nova.';

  @override
  String playerRequestReason(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String playerRequestSentOn(String date) {
    return 'Enviada em $date';
  }

  @override
  String get playerRequestEdit => 'Editar solicitação';

  @override
  String get playerRequestCancel => 'Cancelar solicitação';

  @override
  String get playerRequestCancelTitle => 'Cancelar solicitação?';

  @override
  String playerRequestCancelMessage(String team) {
    return 'Seu pedido para entrar no $team será apagado.';
  }

  @override
  String get playerRequestKeep => 'Manter';

  @override
  String get playerRequestDiscardEdit => 'Descartar alterações';

  @override
  String get playerRequestViewProfile => 'Ver meu perfil de jogador';

  @override
  String get playerRequestLoadError =>
      'Não foi possível carregar sua solicitação.';

  @override
  String get playerPositionGoalkeeper => 'Goleiro';

  @override
  String get playerPositionDefender => 'Zagueiro';

  @override
  String get playerPositionFullBack => 'Lateral';

  @override
  String get playerPositionMidfielder => 'Meia';

  @override
  String get playerPositionForward => 'Atacante';

  @override
  String get playerRequestsPanelTitle => 'Solicitações de jogadores';

  @override
  String get playerRequestsTabPending => 'Pendentes';

  @override
  String get playerRequestsTabAnswered => 'Respondidas';

  @override
  String get playerRequestsEmptyPending => 'Nenhuma solicitação pendente.';

  @override
  String get playerRequestsEmptyAnswered =>
      'Nenhuma solicitação respondida ainda.';

  @override
  String get playerRequestsLoadError =>
      'Não foi possível carregar as solicitações.';

  @override
  String get playerRequestsApprove => 'Aprovar';

  @override
  String get playerRequestsReject => 'Rejeitar';

  @override
  String playerRequestsApproveTitle(String name) {
    return 'Aprovar $name?';
  }

  @override
  String playerRequestsApproveMessage(String name, String team) {
    return '$name entra no elenco do $team.';
  }

  @override
  String playerRequestsRejectTitle(String name) {
    return 'Rejeitar a solicitação de $name?';
  }

  @override
  String get playerRequestsRejectReason => 'Motivo (opcional)';

  @override
  String playerRequestsApproved(String name, String team) {
    return '$name agora é jogador do $team.';
  }

  @override
  String get playerRequestsRejected => 'Solicitação rejeitada.';

  @override
  String get playerRequestsUpdated => 'Solicitação atualizada.';

  @override
  String playerRequestsAccount(String name) {
    return 'Conta: $name';
  }

  @override
  String get pushActionPlayerRequest => 'Nova solicitação de jogador';

  @override
  String get pushActionPlayerRequestHint =>
      'Para os admins · \"Fulano quer jogar no Lava Jato\"';

  @override
  String get pushActionPlayerRequestAnswer => 'Resposta da solicitação';

  @override
  String get pushActionPlayerRequestAnswerHint =>
      'Para quem pediu · aprovada ou rejeitada';

  @override
  String get athleteDelete => 'Excluir atleta';

  @override
  String athleteDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String athleteDeleteMessage(String name, String team) {
    return '$name sai do elenco do $team. Gols e assistências dele deixam de contar no ranking. Essa ação não pode ser desfeita.';
  }

  @override
  String athleteDeleted(String name, String team) {
    return '$name foi excluído do $team.';
  }

  @override
  String get athleteRemoveFromSquad => 'Remover do elenco';

  @override
  String athleteRemoveTitle(String name) {
    return 'Remover $name do elenco?';
  }

  @override
  String athleteRemoveMessage(String name, String team) {
    return '$name sai do elenco do $team. Os gols e assistências continuam na conta dele, e ele pode pedir para entrar em outro time.';
  }

  @override
  String athleteRemoved(String name, String team) {
    return '$name saiu do elenco do $team.';
  }

  @override
  String get playerRequestStatusRemoved => 'Fora do elenco';

  @override
  String playerRequestRemovedInfo(String team) {
    return 'Você saiu do elenco do $team. Suas estatísticas continuam salvas e você pode pedir para entrar em outro time.';
  }

  @override
  String get playerRequestJoinAnother => 'Pedir para entrar em outro time';

  @override
  String get matchesYesterday => 'Ontem';

  @override
  String get matchesToday => 'Hoje';

  @override
  String get matchesTomorrow => 'Amanhã';

  @override
  String get matchesYesterdayTitle => 'Jogos de ontem';

  @override
  String get matchesTomorrowTitle => 'Jogos de amanhã';

  @override
  String get matchesNoGamesYesterday => 'Nenhum jogo ontem';

  @override
  String get matchesNoGamesToday => 'Nenhum jogo hoje';

  @override
  String get matchesNoGamesTomorrow => 'Nenhum jogo amanhã';

  @override
  String get championshipsManageTitle => 'Campeonatos';

  @override
  String get championshipsManageEmpty =>
      'Nenhum campeonato cadastrado nesta região.';

  @override
  String championshipsManageTeamsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
      zero: 'Sem times',
    );
    return '$_temp0';
  }

  @override
  String championshipsManageDeleteTitle(String title) {
    return 'Excluir $title?';
  }

  @override
  String get championshipsManageDeleteMessage =>
      'O campeonato sai da lista. Partidas, grupos e classificação continuam salvos.';

  @override
  String get championshipsManageDeleted => 'Campeonato excluído.';

  @override
  String championshipsSeasonLabel(String region, String season) {
    return '$region · temporada $season';
  }

  @override
  String get championshipFormNewTitle => 'Novo campeonato';

  @override
  String get championshipFormEditTitle => 'Editar campeonato';

  @override
  String get championshipFormSectionData => 'Dados';

  @override
  String get championshipFormTitleLabel => 'Nome do campeonato';

  @override
  String get championshipFormTitleRequired =>
      'Informe o nome (mínimo 3 letras).';

  @override
  String get championshipFormDescriptionLabel => 'Descrição (opcional)';

  @override
  String get championshipFormSeasonLabel => 'Temporada';

  @override
  String get championshipFormSectionTeams => 'Times participantes';

  @override
  String get championshipFormTeamsAll => 'Todos';

  @override
  String get championshipFormTeamsClear => 'Limpar';

  @override
  String get championshipFormTeamsRequired => 'Escolha ao menos um time.';

  @override
  String get championshipFormTeamsEmpty =>
      'Nenhum time cadastrado nesta região.';

  @override
  String championshipFormTeamsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '1 selecionado',
      zero: 'Nenhum selecionado',
    );
    return '$_temp0';
  }

  @override
  String get championshipFormSectionRules => 'Regulamento';

  @override
  String get championshipFormRulesHint =>
      'Anexe o regulamento em PDF: os usuários abrem na página do campeonato.';

  @override
  String get championshipFormRulesAttach => 'Anexar PDF';

  @override
  String get championshipFormRulesReplace => 'Trocar';

  @override
  String get championshipFormRulesRemove => 'Remover';

  @override
  String get championshipFormRulesTooBig => 'O PDF passa de 10 MB.';

  @override
  String get championshipFormRulesSummary => 'Resumo das regras (opcional)';

  @override
  String get championshipFormSectionPrizes => 'Premiação';

  @override
  String get championshipFormPrize1 => '1º lugar';

  @override
  String get championshipFormPrize2 => '2º lugar';

  @override
  String get championshipFormPrize3 => '3º lugar';

  @override
  String get championshipFormPrizeTopScorer => 'Artilheiro';

  @override
  String get championshipFormPrizeGoalkeeper => 'Melhor goleiro';

  @override
  String get championshipFormSubmitCreate => 'CADASTRAR CAMPEONATO';

  @override
  String get championshipFormCreated => 'Campeonato cadastrado!';

  @override
  String get championshipFormSaved => 'Campeonato atualizado!';

  @override
  String get championshipFormLoadError =>
      'Não foi possível carregar as regiões e os times.';

  @override
  String get championshipRulesOpen => 'Abrir regulamento';

  @override
  String get championshipRulesOpenError =>
      'Não foi possível abrir o regulamento.';

  @override
  String get homePublishChampionship => 'Campeonato';

  @override
  String get championshipsCurrentBadge => 'EM ANDAMENTO';

  @override
  String get championshipsPrevious => 'Anteriores';

  @override
  String get championshipTabOverview => 'Visão geral';

  @override
  String get championshipTabTeams => 'Times';

  @override
  String get championshipTabRules => 'Regulamento';

  @override
  String get championshipRulesEmpty => 'Regulamento ainda não publicado';

  @override
  String get championshipTeamsEmpty => 'Times ainda não definidos';

  @override
  String get championshipGroupsAndStandings => 'Grupos e classificação';

  @override
  String championshipSeasonShort(String season) {
    return 'Temporada $season';
  }

  @override
  String get championshipOverviewEmpty =>
      'Premiação e informações ainda não publicadas';

  @override
  String get championshipAbout => 'Sobre';

  @override
  String get seasonsPanelTitle => 'Temporadas';

  @override
  String get seasonsCurrentLabel => 'Temporada atual';

  @override
  String get seasonsCurrentInfo =>
      'Times, partidas, jogadores e campeonatos novos são gravados nesta temporada.';

  @override
  String get seasonsAvailable => 'Temporadas disponíveis';

  @override
  String get seasonsCurrentTag => 'Atual';

  @override
  String seasonsStartTitle(String season) {
    return 'Iniciar temporada $season';
  }

  @override
  String seasonsStartInfo(String current) {
    return 'A temporada $current fica guardada para consulta no seletor de temporada. Nada é apagado.';
  }

  @override
  String get seasonsCopyTeams => 'Copiar os times da temporada atual';

  @override
  String get seasonsCopyTeamsHint =>
      'Os times entram na nova temporada com a classificação zerada. Os elencos começam vazios.';

  @override
  String seasonsStartButton(String season) {
    return 'INICIAR TEMPORADA $season';
  }

  @override
  String seasonsConfirmTitle(String season) {
    return 'Iniciar a temporada $season?';
  }

  @override
  String seasonsConfirmMessage(String season) {
    return 'Todos os usuários passam a ver $season como temporada atual e os novos cadastros vão para ela. Não dá para desfazer pelo app.';
  }

  @override
  String get seasonsConfirmAction => 'Iniciar';

  @override
  String seasonsStarted(String season) {
    return 'Temporada $season iniciada!';
  }

  @override
  String get matchFormChampionship => 'Campeonato';

  @override
  String get teamRequestMenu => 'Sou dono de time';

  @override
  String get teamRequestTitle => 'Sou dono de time';

  @override
  String get teamRequestIntro =>
      'Cadastre o seu time: um administrador analisa o pedido e, aprovado, você gerencia o elenco.';

  @override
  String get teamRequestNameLabel => 'Nome do time';

  @override
  String get teamRequestNameRequired =>
      'Informe o nome do time (mínimo 3 letras).';

  @override
  String teamRequestNameTaken(String name) {
    return 'Já existe um time chamado $name nesta região.';
  }

  @override
  String get teamRequestCrestAdd => 'Adicionar escudo (opcional)';

  @override
  String get teamRequestDescriptionLabel => 'Descrição / história (opcional)';

  @override
  String get teamRequestContactLabel => 'WhatsApp do responsável';

  @override
  String get teamRequestContactHint => '(89) 99999-9999';

  @override
  String get teamRequestContactRequired => 'Informe um WhatsApp com DDD.';

  @override
  String get teamRequestContactInfo => 'Só o administrador vê o seu contato.';

  @override
  String get teamRequestSubmit => 'ENVIAR PEDIDO';

  @override
  String get teamRequestSent =>
      'Pedido enviado! Você será avisado quando o admin responder.';

  @override
  String get teamRequestCancelled => 'Pedido cancelado.';

  @override
  String get teamRequestPendingInfo =>
      'Um administrador vai analisar o seu time. Enquanto isso, você ainda pode corrigir os dados.';

  @override
  String get teamRequestRejectedInfo =>
      'Seu pedido não foi aprovado. Você pode enviar um novo.';

  @override
  String get teamRequestEdit => 'Editar pedido';

  @override
  String get teamRequestCancel => 'Cancelar pedido';

  @override
  String get teamRequestCancelTitle => 'Cancelar pedido?';

  @override
  String teamRequestCancelMessage(String team) {
    return 'O pedido do time $team será apagado.';
  }

  @override
  String get teamRequestResubmit => 'Enviar novo pedido';

  @override
  String get teamRequestLoadError => 'Não foi possível carregar o seu pedido.';

  @override
  String get myTeamTitle => 'Meu time';

  @override
  String get myTeamOwnerBadge => 'Você é o dono';

  @override
  String get myTeamTabSquad => 'Elenco';

  @override
  String get myTeamTabRequests => 'Pedidos';

  @override
  String get myTeamTabEdit => 'Editar';

  @override
  String get myTeamAddPlayer => 'Adicionar jogador';

  @override
  String get myTeamSquadEmpty => 'Nenhum jogador no elenco ainda.';

  @override
  String get myTeamRequestsEmpty => 'Nenhum pedido para entrar no time.';

  @override
  String myTeamPlayerAdded(String name) {
    return '$name entrou no elenco.';
  }

  @override
  String get myTeamSaved => 'Time atualizado!';

  @override
  String get myTeamNameLocked =>
      'Para trocar o nome do time, fale com o administrador.';

  @override
  String get myTeamLoadError => 'Não foi possível carregar o seu time.';

  @override
  String get teamRequestsPanelTitle => 'Solicitações de times';

  @override
  String get teamRequestsEmptyPending => 'Nenhum pedido de time pendente.';

  @override
  String get teamRequestsEmptyAnswered =>
      'Nenhum pedido de time respondido ainda.';

  @override
  String get teamRequestsLoadError =>
      'Não foi possível carregar os pedidos de time.';

  @override
  String teamRequestsApproveTitle(String name) {
    return 'Aprovar o time $name?';
  }

  @override
  String teamRequestsApproveMessage(String region, String owner) {
    return 'O time entra em $region na temporada atual, com $owner como dono.';
  }

  @override
  String teamRequestsApproved(String name) {
    return 'Time $name criado!';
  }

  @override
  String teamRequestsRejectTitle(String name) {
    return 'Rejeitar o time $name?';
  }

  @override
  String teamRequestsOwner(String name) {
    return 'Dono: $name';
  }

  @override
  String get teamRequestsWhatsApp => 'Chamar no WhatsApp';

  @override
  String get teamRequestsWhatsAppError => 'Não foi possível abrir o WhatsApp.';

  @override
  String get pushActionTeamRequest => 'Novo pedido de time';

  @override
  String get pushActionTeamRequestHint =>
      'Para os admins · \"Fulano quer cadastrar o time X\"';

  @override
  String get pushActionTeamRequestAnswer => 'Resposta do pedido de time';

  @override
  String get pushActionTeamRequestAnswerHint =>
      'Para quem pediu · aprovado ou rejeitado';

  @override
  String get teamDelete => 'Excluir time';

  @override
  String teamDeleteTitle(String team) {
    return 'Excluir $team?';
  }

  @override
  String teamDeleteMessage(String season) {
    return 'O time sai da temporada $season. Jogadores com conta no app ficam sem time e mantêm os números; os demais jogadores do elenco são excluídos. As partidas já cadastradas continuam no histórico. Não dá para desfazer.';
  }

  @override
  String teamDeleted(String team) {
    return '$team foi excluído.';
  }

  @override
  String drawerPlayerOf(String team) {
    return 'Jogador do $team';
  }

  @override
  String drawerOwnerOf(String team) {
    return 'Dono/treinador do $team';
  }

  @override
  String get drawerMyPlayerProfile => 'Meu perfil de jogador';

  @override
  String get teamColorsSection => 'Cores do time';

  @override
  String get teamColorPrimary => 'Cor principal';

  @override
  String get teamColorSecondary => 'Cor secundária';

  @override
  String get teamColorNone => 'Sem cor';

  @override
  String get teamColorPreview => 'Assim fica o uniforme';

  @override
  String get colorWhite => 'Branco';

  @override
  String get colorBlack => 'Preto';

  @override
  String get colorGrey => 'Cinza';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorWine => 'Vinho';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorNavy => 'Azul-marinho';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorPink => 'Rosa';
}
