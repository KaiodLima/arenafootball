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
  String get loginEmailLabel => 'Insira seu E-mail';

  @override
  String get loginEmailHint => 'exemplo@exemplo.com';

  @override
  String get loginPasswordLabel => 'Insira sua Senha';

  @override
  String get loginButton => 'ENTRAR';

  @override
  String get loginCreateAccountButton => 'CRIAR CONTA';

  @override
  String get loginSkipButton => 'Pular';

  @override
  String get loginSuccess => 'Usuário Logado!';

  @override
  String get loginInvalidEmail => 'E-mail inválido!';

  @override
  String get loginInvalidPassword =>
      'Senha inválida! Utilize no mínimo 8 caracteres.';

  @override
  String get registerTitle => 'Criar Conta';

  @override
  String get registerNameLabel => 'Nome';

  @override
  String get registerEmailLabel => 'E-mail';

  @override
  String get registerPasswordLabel => 'Senha';

  @override
  String get registerRegionLabel => 'Região:';

  @override
  String get registerTeamLabel => 'Time do coração:';

  @override
  String get registerButton => 'CADASTRAR';

  @override
  String get registerHaveAccountButton => 'Já tenho uma conta!';

  @override
  String get registerSuccess => 'Usuário Cadastrado com Sucesso!';

  @override
  String get registerNameTooShort =>
      'Seu nome de usuário deve conter no mínimo 3 caracteres';

  @override
  String get registerEmailExample => 'Exemplo: teste@teste.com';

  @override
  String get registerPasswordTooShort =>
      'Sua senha deve conter no mínimo 8 caracteres';

  @override
  String get homeTabHome => 'HOME';

  @override
  String get homeTabChampionships => 'CAMPEONATOS';

  @override
  String get homeTabTeams => 'TIMES';

  @override
  String get homeTabTables => 'TABELAS';

  @override
  String get drawerHome => 'INÍCIO';

  @override
  String get drawerResults => 'RESULTADOS';

  @override
  String get drawerRegisterHighlight => 'CADASTRAR DESTAQUES';

  @override
  String get drawerRegisterPlayer => 'CADASTRAR JOGADOR';

  @override
  String get drawerRegisterMatch => 'CADASTRAR NOVA PARTIDA';

  @override
  String get drawerRegisterNews => 'CADASTRAR NOTÍCIA';

  @override
  String get drawerRegisterTeam => 'CADASTRAR TIME';

  @override
  String drawerFanOf(String team) {
    return 'Torcedor do: $team';
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
  String get newsMoreInfo => 'Mais Informações';

  @override
  String get newsAdPlaceholder => 'PUBLICIDADE';

  @override
  String get newsCreateTitle => 'CADASTRAR NOTICIA';

  @override
  String get newsEditTitle => 'EDITAR NOTÍCIA';

  @override
  String get newsTitleLabel => 'Título';

  @override
  String get newsDescriptionLabel => 'Descrição';

  @override
  String get newsTagLabel => 'Tag';

  @override
  String get newsLinkLabel => 'Link';

  @override
  String get newsVisibleLabel => 'Exibir notícia';

  @override
  String get newsAttachPhotos => 'ANEXAR FOTOS';

  @override
  String get newsRegisterButton => 'CADASTRAR';

  @override
  String get newsUpdateButton => 'ATUALIZAR';

  @override
  String get newsTitleRequired => 'A notícia precisa de um título!!!';

  @override
  String get newsTitleTooShort =>
      'O título da notícia deve conter no mínimo 3 caracteres';

  @override
  String get newsCreated => 'Notícia Cadastrada com Sucesso!!!';

  @override
  String get newsUpdated => 'Notícia Atualizada com Sucesso!!!';

  @override
  String get newsRegionLabel => 'Região:';

  @override
  String get newsGoalTitle => 'Cadastrar Card de Gol:';

  @override
  String get newsHomeTeamLabel => 'Time da Casa:';

  @override
  String get newsAwayTeamLabel => 'Time Visitante:';

  @override
  String get newsScoreLabel => 'Placar:';

  @override
  String get newsPublishButton => 'Publicar';

  @override
  String get newsGoalCreated => 'Gol registrado com Sucesso!!!';

  @override
  String get newsGoalTeamsRequired => 'Selecione os dois times!';

  @override
  String get newsAdTitle => 'Cadastrar Card de Publicidade:';

  @override
  String get newsAdCreated => 'Publicidade registrada com Sucesso!!!';

  @override
  String get highlightFormTitle => 'CADASTRAR DESTAQUE';

  @override
  String get highlightTitleLabel => 'Título';

  @override
  String get highlightLinkLabel => 'Link';

  @override
  String get highlightVisibleLabel => 'Exibir destaque';

  @override
  String get highlightRegisterButton => 'CADASTRAR';

  @override
  String get highlightTitleRequired => 'Preencha o campo TÍTULO!!!';

  @override
  String get highlightCreated => 'Destaque Cadastrado!!!';

  @override
  String get highlightNoNews => 'Nenhuma notícia disponível!';

  @override
  String get teamsEmpty => 'Equipes ainda não registradas';

  @override
  String get teamsLoadError => 'Não foi possível carregar os times.';

  @override
  String get teamsFormTitle => 'CADASTRAR TIME';

  @override
  String get teamsRegionLabel => 'Região:';

  @override
  String get teamsNameLabel => 'Time';

  @override
  String get teamsDescriptionLabel => 'Descrição';

  @override
  String get teamsRegisterButton => 'CADASTRAR';

  @override
  String get teamsCreated => 'Time registrado com Sucesso!!!';

  @override
  String get teamsNameRequired => 'Preencha os campos obrigatórios!!!';

  @override
  String get playersEmpty => 'Jogadores ainda não registrados!';

  @override
  String get playersLoadError => 'Não foi possível carregar os jogadores.';

  @override
  String playersTeamInfo(String team) {
    return 'Time: $team';
  }

  @override
  String playersGoalsCount(int count) {
    return 'Gols: $count';
  }

  @override
  String playersAssistsCount(int count) {
    return 'Assistências: $count';
  }

  @override
  String get playersNameRequired => 'Preencha o campo NOME!!!';

  @override
  String get playersTeamRequired => 'Informe um Time!!!';

  @override
  String get playersFormTitle => 'CADASTRAR JOGADOR';

  @override
  String get playersNameLabel => 'Nome';

  @override
  String get playersGoalsLabel => 'Gols';

  @override
  String get playersAssistsLabel => 'Assistencias';

  @override
  String get playersTeamLabel => 'Time:';

  @override
  String get playersRegisterButton => 'CADASTRAR';

  @override
  String get playersCreated => 'Jogador Cadastrado!!!';

  @override
  String get playersPhotoBack => 'Voltar';

  @override
  String get playersPhotoSave => 'Salvar';

  @override
  String get statsGoalsTitle => 'ARTILHARIA';

  @override
  String get statsAssistsTitle => 'ASSISTENCIAS';

  @override
  String get statsEmpty => 'Nenhum jogador no ranking ainda.';

  @override
  String get statsLoadError => 'Não foi possível carregar o ranking.';

  @override
  String get matchesNoChampionship => 'Nenhum registro no momento';

  @override
  String get matchesEmpty => 'Nenhuma partida cadastrada';

  @override
  String get matchesLoadError => 'Não foi possível carregar as partidas.';

  @override
  String get matchesAllGames => 'VER TODOS OS JOGOS';

  @override
  String get matchesGroups => 'VER GRUPOS';

  @override
  String get matchesTopScorers => 'ARTILHARIA';

  @override
  String get matchesAssists => 'ASSISTÊNCIAS';

  @override
  String get matchesAllGamesTitle => 'TODOS OS JOGOS';

  @override
  String get matchesVersus => 'X';

  @override
  String matchesSchedule(String date, String time, String venue) {
    return '$date às $time horas\n$venue';
  }

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
  String get matchesFormTitle => 'CADASTRAR PARTIDA';

  @override
  String get matchesRegionLabel => 'Região:';

  @override
  String get matchesHomeTeamLabel => 'Time Casa:';

  @override
  String get matchesAwayTeamLabel => 'Time Fora:';

  @override
  String get matchesDateLabel => 'Data';

  @override
  String get matchesTimeLabel => 'Hora';

  @override
  String get matchesVenueLabel => 'Local';

  @override
  String get matchesRegisterButton => 'CADASTRAR';

  @override
  String get matchesCreated => 'Partida Cadastrada com Sucesso!!!';

  @override
  String get matchesFieldsRequired => 'Preencha todos os campos!!!';

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
  String get championshipsGroupsEmpty => 'Vazio';

  @override
  String get championshipsGroupsLoadError =>
      'Não foi possível carregar os grupos.';

  @override
  String get championshipsStandingsEmpty => 'Vazio';

  @override
  String get championshipsStandingsLoadError =>
      'Não foi possível carregar a classificação.';

  @override
  String championshipsStandingsPosition(int position) {
    return '#$position';
  }

  @override
  String get championshipsStandingsWins => 'V';

  @override
  String get championshipsStandingsLosses => 'D';

  @override
  String get championshipsStandingsDraws => 'E';

  @override
  String get championshipsStandingsPoints => 'P';

  @override
  String get championshipsStandingsGoalsFor => 'GF';

  @override
  String get championshipsStandingsGoalsAgainst => 'GS';

  @override
  String get championshipsStandingsGoalDifference => 'SG';

  @override
  String get votingTitle => 'Melhor da Partida';

  @override
  String get votingNotice =>
      'Atenção: O VOTO É ÚNICO! Você pode alterar sua opção de voto quantas vezes quiser, mas apenas o último voto é contabilizado!';

  @override
  String get votingVoteButton => 'VOTAR';

  @override
  String get votingBlankVote => 'Voto em branco! Tente novamente.';

  @override
  String votingVoteRegistered(String player) {
    return 'Voto registrado! Você votou em $player. Muito obrigado pelo seu voto.';
  }

  @override
  String get votingLoginRequired => 'Faça login para votar.';

  @override
  String get votingElectedLabel => 'Eleito o melhor jogador da partida: ';

  @override
  String votingVotesCount(int count) {
    return 'Número de votos: $count';
  }

  @override
  String get votingNoVotes => 'Nenhum voto registrado para esta partida.';

  @override
  String get votingLoadError => 'Não foi possível apurar a votação.';

  @override
  String get globalResultsTitle => 'RESULTADOS PELO MUNDO';

  @override
  String get globalResultsYesterday => 'Ontem';

  @override
  String get globalResultsToday => 'Hoje';

  @override
  String get globalResultsTomorrow => 'Amanhã';

  @override
  String get globalResultsEmpty => 'Nenhum jogo encontrado.';

  @override
  String get globalResultsTomorrowUnavailable =>
      'Os jogos de amanhã ainda não estão disponíveis.';
}
