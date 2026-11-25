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
  String get fanRankingTitle => 'Ranking de torcidas';

  @override
  String get qrCodesTitle => 'QR codes';

  @override
  String get qrKindNow => 'Acontecendo agora';

  @override
  String qrNowTitle(String region) {
    return 'QR fixo de $region';
  }

  @override
  String get qrNowSubtitle =>
      'Sempre leva ao que está acontecendo agora: votação, jogo ao vivo, eventos e palpites';

  @override
  String qrNowPosterTitle(String region) {
    return 'Acontecendo agora em $region';
  }

  @override
  String get nowTitle => 'Acontecendo agora';

  @override
  String nowIn(String region) {
    return 'em $region';
  }

  @override
  String get nowRegionGone => 'Esta região não existe mais no app.';

  @override
  String nowQuiet(String region) {
    return 'Nada acontecendo agora em $region. Que tal palpitar no próximo jogo?';
  }

  @override
  String get nowSectionVotes => 'Votações do craque abertas';

  @override
  String get nowSectionLive => 'Ao vivo';

  @override
  String get nowSectionEvents => 'Eventos de votação';

  @override
  String get nowSectionUpcoming => 'Próximos jogos';

  @override
  String get nowSectionMore => 'Participe também';

  @override
  String get nowVote => 'VOTAR NO CRAQUE';

  @override
  String get nowWatch => 'VER A PARTIDA';

  @override
  String get nowEventVote => 'VOTAR NO EVENTO';

  @override
  String get nowPredict => 'DAR PALPITE';

  @override
  String get nowPool => 'ABRIR O BOLÃO';

  @override
  String get nowLiveBadge => 'AO VIVO';

  @override
  String get qrCodesIntro =>
      'Gere o QR code do que está acontecendo agora: imprima, mostre no telão ou poste nas redes.';

  @override
  String get qrSectionAlways => 'Sempre ativos';

  @override
  String get qrSectionEvents => 'Eventos de votação abertos';

  @override
  String get qrSectionVotes => 'Votações do craque abertas';

  @override
  String get qrSectionMatches => 'Próximas partidas (palpite)';

  @override
  String get qrSectionEmpty => 'Nada aberto agora.';

  @override
  String get qrKindVote => 'Vote no craque';

  @override
  String get qrKindMatch => 'Dê o seu palpite';

  @override
  String get qrKindPool => 'Bolão';

  @override
  String get qrKindAlbum => 'Álbum de figurinhas';

  @override
  String get qrKindEvent => 'Evento de votação';

  @override
  String get qrPoolTitle => 'Bolão do Arena Football';

  @override
  String get qrPoolSubtitle =>
      'Palpite nos jogos e dispute o ranking da sua região';

  @override
  String get qrAlbumSubtitle => 'Abra pacotinhos e complete o álbum';

  @override
  String get qrScanCta => 'Aponte a câmera e participe!';

  @override
  String get qrPosterTitle => 'Cartaz do QR code';

  @override
  String get qrCopyLink => 'Copiar link';

  @override
  String get qrLinkCopied => 'Link copiado!';

  @override
  String qrShareText(String title, String link) {
    return '$title — aponte a câmera ou toque no link e participe! ⚽\n$link';
  }

  @override
  String get qrMatchVote => 'QR code da votação';

  @override
  String get qrMatchMatch => 'QR code da partida';

  @override
  String get qrMenu => 'QR code';

  @override
  String get fanRankingScopeRegion => 'Região';

  @override
  String get fanRankingScopeOverall => 'Geral';

  @override
  String fanRankingBiggestIn(String region) {
    return 'Maior torcida de $region';
  }

  @override
  String get fanRankingBiggestOverall => 'Maior torcida do app';

  @override
  String get fanRankingTopTie => 'Empate no topo';

  @override
  String fanRankingShareOf(int percent) {
    return '$percent% da torcida';
  }

  @override
  String get fanRankingSplit => 'Divisão das torcidas';

  @override
  String get fanRankingOthers => 'Outros';

  @override
  String fanRankingGap(int count, String team) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count torcedores para passar $team',
      one: 'Falta 1 torcedor para passar $team',
    );
    return '$_temp0';
  }

  @override
  String get fanRankingYouLead => 'Sua torcida lidera!';

  @override
  String get fanRankingRally => 'Convocar a torcida';

  @override
  String fanRankingRallyText(String team, String link) {
    return 'Ajude o $team a subir no ranking de torcidas do Arena Football! Baixe o app e escolha o $team como time do coração ⚽\n$link';
  }

  @override
  String get fanRankingChooseTitle => 'Entre na disputa!';

  @override
  String get fanRankingChooseText =>
      'Escolha seu time do coração e ajude a sua torcida a subir no ranking.';

  @override
  String get fanRankingFullRanking => 'Ranking completo';

  @override
  String get fanRankingBattle => 'Guerra das torcidas';

  @override
  String fanRankingFansLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'torcedores',
      one: 'torcedor',
    );
    return '$_temp0';
  }

  @override
  String fanRankingFans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count torcedores',
      one: '1 torcedor',
      zero: 'nenhum torcedor',
    );
    return '$_temp0';
  }

  @override
  String get fanRankingYourFans => 'Sua torcida';

  @override
  String fanRankingUpdatedAt(String time) {
    return 'Atualizado às $time · conta os usuários do app pelo time do coração';
  }

  @override
  String get fanRankingPreparing =>
      'O ranking de torcidas está sendo preparado. Volte daqui a pouco!';

  @override
  String get fanRankingNoTeams => 'Nenhum time nesta região ainda.';

  @override
  String get fanRankingError =>
      'Não foi possível carregar o ranking de torcidas.';

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
  String get newsMoveRegion => 'Mudar região';

  @override
  String newsMoveRegionTitle(String region) {
    return 'Mover para $region?';
  }

  @override
  String newsMoveRegionMessage(String region) {
    return 'O card passa a aparecer só no feed de $region. O push já enviado não é desfeito.';
  }

  @override
  String get newsMoveRegionLiveNote =>
      'Card ao vivo da partida: corrija também a região/competição da partida, senão o próximo lance o traz de volta.';

  @override
  String newsMovedRegion(String region) {
    return 'Notícia movida para $region';
  }

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
  String get goalChampionship => 'Competição';

  @override
  String get goalChampionshipHint =>
      'O gol soma nos números do atleta nesta competição.';

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
    return '$scorer';
  }

  @override
  String goalScorerAssistLine(String scorer, String assistant) {
    return '$scorer · assist. $assistant';
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
  String get playersPhotoHeader => 'Foto do atleta';

  @override
  String get playersPhotoTitle => 'Trocar foto';

  @override
  String get playersPhotoMessage => 'Escolha uma foto da câmera ou da galeria';

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
  String get statsGeneral => 'Geral';

  @override
  String get statsLoadError => 'Não foi possível carregar o ranking.';

  @override
  String get matchesNoChampionship => 'Nenhum registro no momento';

  @override
  String get matchesEmpty => 'Nenhuma partida cadastrada';

  @override
  String get matchesLoadError => 'Não foi possível carregar as partidas.';

  @override
  String get matchesAllChampionships => 'Todas as competições';

  @override
  String get matchesChampionshipFilter => 'Competição';

  @override
  String get matchesFriendly => 'Amistoso';

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
  String get matchGoalsTitle => 'Gols da partida';

  @override
  String get matchGoalsAdd => 'Gol';

  @override
  String get matchGoalsNone => 'Nenhum gol.';

  @override
  String get matchGoalsNoScorer => 'Gol sem autor';

  @override
  String get matchGoalsRemove => 'Tirar gol';

  @override
  String get matchGoalsSave => 'SALVAR PLACAR';

  @override
  String get matchGoalsSaved => 'Placar salvo.';

  @override
  String get matchGoalsDiscardTitle => 'Descartar as alterações do placar?';

  @override
  String get matchGoalsDiscard => 'Descartar';

  @override
  String matchGoalsAssist(String name) {
    return 'assist. $name';
  }

  @override
  String get matchCardGoals => 'Gols';

  @override
  String get matchCardHideGoals => 'Ocultar gols';

  @override
  String get matchCardToday => 'HOJE';

  @override
  String get matchCardTomorrow => 'AMANHÃ';

  @override
  String get shareArtTemplateVibrant => 'Cores';

  @override
  String get playerArtAction => 'Gerar arte do atleta';

  @override
  String get playerArtTitle => 'Arte do atleta';

  @override
  String get playerArtTemplateSigning => 'Reforço';

  @override
  String get playerArtTemplateDeal => 'Fechado!';

  @override
  String get playerArtTemplatePoster => 'Pôster';

  @override
  String get playerArtHeadline => 'Reforço';

  @override
  String playerArtWelcome(String team) {
    return '$team anuncia';
  }

  @override
  String playerArtDeal(String team) {
    return 'Agora é $team!';
  }

  @override
  String get playerArtOfficial => 'Anúncio oficial';

  @override
  String get playerChangeOwnPhoto => 'Trocar minha foto';

  @override
  String get playerPhotoUpdated => 'Foto atualizada!';

  @override
  String get shareArtFramingHint =>
      'Arraste a foto para enquadrar · pinça para zoom';

  @override
  String get shareArtFramingReset => 'Centralizar';

  @override
  String get shareArtUseGalleryPhoto => 'Usar foto da galeria';

  @override
  String get shareArtUseAthletePhoto => 'Voltar à foto do atleta';

  @override
  String get shareArtNoPhotoHint =>
      'Atleta sem foto: use uma da galeria só nesta arte';

  @override
  String get playerMatchArtAction => 'Arte do atleta';

  @override
  String get playerMatchArtSheetTitle => 'Gerar arte';

  @override
  String get playerMatchArtPick => 'Escolher atleta';

  @override
  String get playerMatchArtSearch => 'Buscar atleta';

  @override
  String get playerMatchArtEmpty => 'Nenhum atleta nos elencos desta partida';

  @override
  String get playerMatchArtTeamEmpty => 'Nenhum atleta no elenco deste time';

  @override
  String get playerMatchArtTitle => 'Atleta na partida';

  @override
  String get playerMatchArtTemplateCover => 'Capa';

  @override
  String get playerMatchArtTemplateCountdown => 'Contagem';

  @override
  String get playerMatchArtTemplateAgenda => 'Agenda';

  @override
  String get playerMatchArtTemplateDuel => 'Duelo';

  @override
  String get playerMatchArtTemplateLineup => 'Escalação';

  @override
  String get playerMatchArtTemplateSpotlight => 'Holofote';

  @override
  String get playerMatchArtLineup => 'Na escalação!';

  @override
  String get playerMatchArtMatchday => 'Dia de jogo';

  @override
  String playerMatchArtDaysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dias para o jogo',
      one: 'dia para o jogo',
    );
    return '$_temp0';
  }

  @override
  String playerMatchArtWaiting(String name) {
    return '$name te espera';
  }

  @override
  String get playerMatchArtComeWatch => 'Vem pro jogo!';

  @override
  String playerMatchArtShareText(
      String name, String home, String away, String when, String link) {
    return '$name em campo: $home x $away · $when $link';
  }

  @override
  String get playerArtTemplateImpact => 'Impacto';

  @override
  String get playerArtTemplateCard => 'Carta';

  @override
  String playerArtPresents(String team) {
    return '$team apresenta';
  }

  @override
  String get playerArtNewSigning => 'Novo reforço';

  @override
  String get playerArtDebut => 'Estreia';

  @override
  String get playerArtAbbrGoalkeeper => 'GOL';

  @override
  String get playerArtAbbrDefender => 'ZAG';

  @override
  String get playerArtAbbrFullBack => 'LAT';

  @override
  String get playerArtAbbrDefensiveMidfielder => 'VOL';

  @override
  String get playerArtAbbrMidfielder => 'MEI';

  @override
  String get playerArtAbbrForward => 'ATA';

  @override
  String playerArtShareText(String name, String team, String link) {
    return '$name agora é $team! $link';
  }

  @override
  String get shareArtPreviewTitle => 'Divulgar partida';

  @override
  String get shareArtTemplateMatchday => 'Dia de jogo';

  @override
  String get shareArtTemplateVersus => 'Duelo';

  @override
  String get shareArtTemplateCalendar => 'Agenda';

  @override
  String get shareArtTemplateChampionship => 'Campeonato';

  @override
  String get shareArtTemplateTicket => 'Ingresso';

  @override
  String get shareArtTemplateScoreboard => 'Placar';

  @override
  String get shareArtToday2 => 'Hoje';

  @override
  String get shareArtTicketLabel => 'Ingresso oficial';

  @override
  String get shareArtColors => 'Cores';

  @override
  String get shareArtPaletteTeams => 'Times';

  @override
  String get shareArtPaletteArena => 'Arena';

  @override
  String get shareArtPaletteNight => 'Noite';

  @override
  String get shareArtPaletteCrimson => 'Rubro';

  @override
  String get shareArtPaletteOcean => 'Oceano';

  @override
  String get shareArtPaletteGraphite => 'Grafite';

  @override
  String get shareArtDateLabel => 'Data';

  @override
  String get shareArtTimeLabel => 'Horário';

  @override
  String get shareArtVenueLabel => 'Local';

  @override
  String shareArtDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count dias',
      one: 'Falta 1 dia',
      zero: 'Hoje',
    );
    return '$_temp0';
  }

  @override
  String get shareArtToday => 'É hoje!';

  @override
  String get shareArtNextMatch => 'Próximo jogo';

  @override
  String get shareArtVenueTbd => 'Local a definir';

  @override
  String get shareArtMissingTime => 'horário';

  @override
  String shareArtWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(
      day,
      {
        '1': 'Segunda',
        '2': 'Terça',
        '3': 'Quarta',
        '4': 'Quinta',
        '5': 'Sexta',
        '6': 'Sábado',
        '7': 'Domingo',
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
        '1': 'Seg',
        '2': 'Ter',
        '3': 'Qua',
        '4': 'Qui',
        '5': 'Sex',
        '6': 'Sáb',
        '7': 'Dom',
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
        '2': 'Fev',
        '3': 'Mar',
        '4': 'Abr',
        '5': 'Mai',
        '6': 'Jun',
        '7': 'Jul',
        '8': 'Ago',
        '9': 'Set',
        '10': 'Out',
        '11': 'Nov',
        '12': 'Dez',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get shareArtTemplatePoster => 'Fim de jogo';

  @override
  String get shareArtTemplateFaceOff => 'Confronto';

  @override
  String get shareArtTemplateEditorial => 'Editorial';

  @override
  String get shareArtTitle => 'Gerar arte';

  @override
  String get shareArtTemplate => 'Modelo';

  @override
  String get shareArtFormat => 'Formato';

  @override
  String get shareArtFormatFeed => 'Feed 4:5';

  @override
  String get shareArtFormatStory => 'Story 9:16';

  @override
  String get shareArtFormatSquare => 'Quadrado';

  @override
  String get shareArtFormatLandscape => 'Paisagem';

  @override
  String get shareArtQr => 'Incluir QR Code';

  @override
  String get shareArtSave => 'Salvar';

  @override
  String get shareArtInstagram => 'Instagram';

  @override
  String get shareArtSaved => 'Arte salva na galeria.';

  @override
  String get shareArtSaveError => 'Não foi possível salvar na galeria.';

  @override
  String get shareArtError => 'Não foi possível gerar a arte.';

  @override
  String get shareArtCallToAction => 'Confira mais no Arena Football';

  @override
  String shareArtHalfTime(String score) {
    return '1º tempo $score';
  }

  @override
  String shareArtMissing(String items) {
    return 'Sem cadastro: $items. A arte sai sem esses dados.';
  }

  @override
  String shareArtMissingCrest(String team) {
    return 'escudo do $team';
  }

  @override
  String get shareArtMissingVenue => 'local';

  @override
  String get shareArtMissingDate => 'data';

  @override
  String shareArtShareText(String home, String away, String link) {
    return '$home x $away no Arena Football: $link';
  }

  @override
  String get pdfTitle => 'SÚMULA DA PARTIDA';

  @override
  String get pdfDraft => 'RASCUNHO - alterações não salvas';

  @override
  String get pdfMatchInfo => 'Dados do jogo';

  @override
  String get pdfDate => 'Data';

  @override
  String get pdfTime => 'Horário';

  @override
  String get pdfVenue => 'Local';

  @override
  String get pdfRegion => 'Região';

  @override
  String get pdfDuration => 'Duração';

  @override
  String get pdfStatus => 'Situação';

  @override
  String get pdfLineups => 'Escalações';

  @override
  String get pdfStarters => 'Titulares';

  @override
  String get pdfReserves => 'Reservas';

  @override
  String get pdfGoals => 'Gols';

  @override
  String get pdfBookings => 'Cartões';

  @override
  String get pdfSubstitutions => 'Substituições';

  @override
  String get pdfMinute => 'Min.';

  @override
  String get pdfTeam => 'Time';

  @override
  String get pdfPlayer => 'Atleta';

  @override
  String get pdfScorer => 'Autor';

  @override
  String get pdfAssist => 'Assistência';

  @override
  String get pdfType => 'Tipo';

  @override
  String get pdfIn => 'Entra';

  @override
  String get pdfOut => 'Sai';

  @override
  String get pdfYellow => 'Amarelo';

  @override
  String get pdfRed => 'Vermelho';

  @override
  String get pdfBestPlayer => 'Craque da partida';

  @override
  String get pdfNotes => 'Observações';

  @override
  String get pdfSignatures => 'Assinaturas';

  @override
  String get pdfSignReferee => 'Árbitro';

  @override
  String get pdfSignOrganizer => 'Organizador';

  @override
  String pdfSignCaptain(String team) {
    return 'Capitão - $team';
  }

  @override
  String get pdfNone => 'Nenhum registro';

  @override
  String get pdfChampionship => 'Competição';

  @override
  String pdfGeneratedAt(String date) {
    return 'Gerado pelo Arena Football em $date';
  }

  @override
  String pdfPage(int page, int total) {
    return 'página $page/$total';
  }

  @override
  String pdfMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String pdfCameIn(String minute) {
    return 'entrou$minute';
  }

  @override
  String pdfWentOut(String minute) {
    return 'saiu$minute';
  }

  @override
  String get matchReportExportPdf => 'Exportar PDF';

  @override
  String get matchReportExport => 'Exportar súmula';

  @override
  String get matchReportExportError =>
      'Não foi possível gerar o PDF da súmula.';

  @override
  String get votingOnlyParticipants =>
      'Só aparecem os jogadores que participaram da partida.';

  @override
  String get liveFullTime => 'Fim de jogo';

  @override
  String get liveEventsTitle => 'Lances da partida';

  @override
  String get liveSeeMatch => 'Ver partida';

  @override
  String get liveYellowCard => 'Cartão amarelo';

  @override
  String get liveLabel => 'Ao vivo';

  @override
  String get liveNoEvents => 'Sem lances ainda.';

  @override
  String get liveSentOff => 'Expulso';

  @override
  String get pushActionRedCard => 'Cartão vermelho';

  @override
  String get pushActionRedCardHint =>
      'Expulsão lançada na súmula (\"Expulso!\")';

  @override
  String get reportSubstitution => 'Substituição';

  @override
  String get reportPenalty => 'Pênalti';

  @override
  String get reportPenaltyScored => 'Convertido (gol)';

  @override
  String get reportPenaltySavedOption => 'Perdido · defendido';

  @override
  String get reportPenaltyWideOption => 'Perdido · para fora/trave';

  @override
  String get reportPenaltyTaker => 'Quem cobrou';

  @override
  String get reportPenaltyWhoSaved => 'Quem defendeu? (opcional)';

  @override
  String get reportPenaltyNoKeeper => 'Sem goleiro';

  @override
  String get reportPenaltyGoal => 'De pênalti';

  @override
  String get reportPenaltyShort => 'pên.';

  @override
  String get reportPenaltyMissed => 'Pênalti perdido';

  @override
  String get reportPenaltySaved => 'defendido';

  @override
  String reportPenaltySavedBy(String name) {
    return 'defendido por $name';
  }

  @override
  String get reportPenaltyWide => 'para fora';

  @override
  String get reportPenaltiesMissed => 'Pênaltis perdidos';

  @override
  String get reportWhoLeaves => 'Quem sai?';

  @override
  String get reportWhoEnters => 'Quem entra?';

  @override
  String reportLeaving(String name) {
    return 'Sai $name';
  }

  @override
  String reportEntering(String name) {
    return 'Entra $name';
  }

  @override
  String get reportLineupNeeded =>
      'Sem escalação: aparecem todos do elenco. Monte a escalação para ver só quem está em campo.';

  @override
  String get reportNobodyToPick => 'Ninguém disponível neste passo.';

  @override
  String organizerMatchTeamNotEnrolled(String team) {
    return '$team não está inscrito nesta competição. Inscreva o time pela aba Times.';
  }

  @override
  String get organizerPermissionDenied =>
      'Sem permissão para gravar nesta competição. Peça ao admin para abrir o painel \"Organizadores de campeonato\" e tente de novo.';

  @override
  String get organizerNewMatch => 'Nova partida';

  @override
  String get organizerMatchNeedsTeams =>
      'Inscreva ao menos 2 times na competição (aba Times) para cadastrar partidas.';

  @override
  String get squadGoalkeepers => 'Goleiros';

  @override
  String get squadDefenders => 'Zagueiros';

  @override
  String get squadFullBacks => 'Laterais';

  @override
  String get squadDefensiveMidfielders => 'Volantes';

  @override
  String get squadMidfielders => 'Meias';

  @override
  String get squadForwards => 'Atacantes';

  @override
  String get squadNoPosition => 'Sem posição';

  @override
  String get squadAllPlayers => 'Atletas';

  @override
  String get squadTopScorer => 'Artilheiro';

  @override
  String get squadTopAssister => 'Garçom';

  @override
  String get squadSortBy => 'Ordenar por';

  @override
  String get squadSortPosition => 'Posição';

  @override
  String get squadGoalsShort => 'G';

  @override
  String get squadAssistsShort => 'A';

  @override
  String get squadSearch => 'Buscar atleta';

  @override
  String get squadPlayerActions => 'Ações do atleta';

  @override
  String get organizerSquadPermission =>
      'Sem permissão para mudar este elenco. Peça ao admin para abrir o painel \"Organizadores de campeonato\" e tente de novo.';

  @override
  String get organizerSquadAdd => 'Do elenco geral';

  @override
  String get organizerSquadNew => 'Novo atleta';

  @override
  String get organizerSquadAddTitle => 'Adicionar à competição';

  @override
  String organizerSquadAddHint(String championship) {
    return 'Atletas do elenco geral do time que ainda não estão em $championship.';
  }

  @override
  String organizerSquadAddConfirm(int count) {
    return 'Adicionar ($count)';
  }

  @override
  String get organizerSquadNone =>
      'Todos os atletas do elenco geral já estão na competição.';

  @override
  String organizerSquadAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atletas adicionados',
      one: '1 atleta adicionado',
    );
    return '$_temp0.';
  }

  @override
  String organizerSquadNewHint(String championship) {
    return 'Entra no time e já inscrito só em $championship.';
  }

  @override
  String organizerSquadCreated(String name) {
    return '$name inscrito na competição.';
  }

  @override
  String get organizerSquadRemove => 'Tirar da competição';

  @override
  String organizerSquadRemoveTitle(String name) {
    return 'Tirar $name da competição?';
  }

  @override
  String get organizerSquadRemoveMessage =>
      'Continua no elenco geral do time. Os números já marcados nesta competição ficam fora dela.';

  @override
  String organizerSquadRemoved(String name) {
    return '$name saiu da competição.';
  }

  @override
  String get organizerSquadLegacy =>
      'Atleta antigo: o admin ou o dono do time ajustam as competições dele.';

  @override
  String organizerSquadOtherTeam(String team) {
    return 'Joga por $team nesta competição.';
  }

  @override
  String get organizerSquadError => 'Não foi possível salvar. Tente de novo.';

  @override
  String get organizerEnrollTeam => 'Inscrever time';

  @override
  String get organizerFormGroups => 'Formar grupos';

  @override
  String get organizerEditChampionship => 'Editar campeonato';

  @override
  String get organizerPickChampionship => 'Qual campeonato?';

  @override
  String get organizerEnrollNoCandidates =>
      'Todos os times disponíveis já estão inscritos.';

  @override
  String organizerEnrolled(String team, String championship) {
    return '$team inscrito em $championship.';
  }

  @override
  String get organizerOutsideRegion =>
      'Campeonato municipal só aceita times da própria região.';

  @override
  String get organizerRemoveTeam => 'Tirar do campeonato';

  @override
  String organizerRemoveTeamTitle(String team) {
    return 'Tirar $team?';
  }

  @override
  String organizerRemoveTeamMessage(String championship) {
    return 'O time sai de $championship. As partidas já cadastradas continuam.';
  }

  @override
  String organizerRemoved(String team) {
    return '$team saiu do campeonato.';
  }

  @override
  String organizerGroupsTitle(String championship) {
    return 'Grupos · $championship';
  }

  @override
  String get organizerGroupsEmpty =>
      'Nenhum grupo ainda. Crie um grupo ou sorteie.';

  @override
  String get organizerGroupsLoadError => 'Não foi possível carregar os grupos.';

  @override
  String get organizerGroupNew => 'Novo grupo';

  @override
  String get organizerGroupEdit => 'Editar grupo';

  @override
  String get groupRulesTitle => 'Regras do grupo';

  @override
  String get groupRulesQualified => 'Classificados';

  @override
  String get groupRulesQualifiedHint => 'Os primeiros colocados que avançam';

  @override
  String get groupRulesNextPhase => 'Nome da próxima fase (opcional)';

  @override
  String get groupRulesPlayoff => 'Repescagem';

  @override
  String get groupRulesPlayoffHint => 'Os seguintes, que disputam a repescagem';

  @override
  String get groupRulesEliminated => 'Eliminados';

  @override
  String get groupRulesEliminatedHint => 'Os últimos colocados';

  @override
  String get groupRulesHomeAndAway => 'Ida e volta';

  @override
  String get groupRulesHomeAndAwayHint =>
      'Cada time enfrenta o outro duas vezes';

  @override
  String get groupRulesApplyAll => 'Aplicar a todos os grupos';

  @override
  String groupRulesExceeds(int total) {
    return 'A soma das faixas passa do total de times do grupo ($total).';
  }

  @override
  String get groupRulesSaved => 'Regras salvas';

  @override
  String groupRulesSummaryQualified(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classificam',
      one: '1 classifica',
    );
    return '$_temp0';
  }

  @override
  String groupRulesSummaryPlayoff(int count) {
    return '$count na repescagem';
  }

  @override
  String groupRulesSummaryEliminated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eliminados',
      one: '1 eliminado',
    );
    return '$_temp0';
  }

  @override
  String standingsQualifiedFor(String phase) {
    return 'Classificados para a $phase';
  }

  @override
  String get standingsPlayoffLegend => 'Repescagem';

  @override
  String get standingsEliminatedLegend => 'Eliminados';

  @override
  String get organizerGroupName => 'Nome do grupo';

  @override
  String get organizerGroupNameRequired => 'Informe o nome do grupo.';

  @override
  String organizerGroupLabel(String name) {
    return 'Grupo $name';
  }

  @override
  String get organizerGroupAddTeam => 'Adicionar time';

  @override
  String get organizerGroupFull => 'O grupo já tem 4 times.';

  @override
  String get organizerGroupNoTeamsLeft =>
      'Todos os times inscritos já estão em grupos.';

  @override
  String get organizerGroupSaved => 'Grupo salvo.';

  @override
  String get organizerGroupDelete => 'Apagar grupo';

  @override
  String organizerGroupDeleteTitle(String name) {
    return 'Apagar o grupo $name?';
  }

  @override
  String get organizerGroupDeleteMessage =>
      'Os times voltam a ficar sem grupo e a classificação do grupo é refeita.';

  @override
  String get organizerGroupsDraw => 'Sortear grupos';

  @override
  String get organizerGroupsDrawCount => 'Quantos grupos?';

  @override
  String organizerGroupsDrawOption(int count, int perGroup) {
    return '$count grupos · até $perGroup times cada';
  }

  @override
  String get organizerGroupsDrawNeedTeams =>
      'Inscreva ao menos 2 times para sortear.';

  @override
  String organizerGroupsDrawConfirmTitle(int count) {
    return 'Sortear $count grupos?';
  }

  @override
  String get organizerGroupsDrawConfirmMessage =>
      'Os grupos atuais são apagados e os times inscritos são distribuídos ao acaso.';

  @override
  String get organizerGroupsDrawn => 'Grupos sorteados.';

  @override
  String get organizerModeFan => 'Modo torcedor';

  @override
  String get organizerModeOrganizer => 'Modo organizador';

  @override
  String get homeModeAdmin => 'Modo admin';

  @override
  String get homeModePlayer => 'Modo jogador';

  @override
  String get homeModePlayerBanner =>
      'Modo jogador: você vê o app como um jogador';

  @override
  String get homeModePlayerExit => 'Sair';

  @override
  String get organizerModeToggle => 'Trocar entre torcedor e organizador';

  @override
  String get homeTabMyChampionships => 'Meus camp.';

  @override
  String get organizerModeSubtitle => 'Modo organizador · seus campeonatos';

  @override
  String get organizerNoChampionships =>
      'Nenhum campeonato organizado por você.';

  @override
  String get organizerTeamsEmpty => 'Nenhum time inscrito neste campeonato.';

  @override
  String get organizerRequestMenu => 'Sou organizador de campeonato';

  @override
  String get organizerRequestTitle => 'Sou organizador de campeonato';

  @override
  String get organizerRequestIntro =>
      'Organiza uma competição? Peça para cadastrá-la no Arena. Aprovado, o campeonato é criado e você cuida dos detalhes (descrição, regulamento, prêmios e times).';

  @override
  String get organizerRequestLogoAdd => 'Logo (opcional)';

  @override
  String get organizerRequestSectionCompetition => 'Competição';

  @override
  String get organizerRequestNameLabel => 'Nome da competição';

  @override
  String get organizerRequestNameRequired =>
      'Informe o nome da competição (mínimo 3 letras).';

  @override
  String get organizerRequestScopeLabel => 'Categoria';

  @override
  String get organizerRequestDescriptionLabel =>
      'Sobre a competição (datas, formato, número de times)';

  @override
  String get organizerRequestSubmit => 'Enviar pedido';

  @override
  String get organizerRequestSent =>
      'Pedido enviado! O administrador vai analisar.';

  @override
  String get organizerRequestCancelled => 'Pedido cancelado.';

  @override
  String get organizerRequestLoadError =>
      'Não foi possível carregar o seu pedido.';

  @override
  String get organizerRequestPendingInfo =>
      'Seu pedido está com o administrador. Você recebe um aviso quando ele responder.';

  @override
  String get organizerRequestRejectedInfo =>
      'Seu pedido não foi aprovado. Corrija os dados e envie de novo.';

  @override
  String get organizerRequestApprovedInfo =>
      'Seu campeonato foi criado! Edite os detalhes em \"Meus campeonatos\".';

  @override
  String get organizerRequestEdit => 'Corrigir pedido';

  @override
  String get organizerRequestCancel => 'Cancelar pedido';

  @override
  String get organizerRequestCancelTitle => 'Cancelar o pedido?';

  @override
  String organizerRequestCancelMessage(String name) {
    return 'O pedido de $name será apagado.';
  }

  @override
  String get organizerRequestResubmit => 'Enviar de novo';

  @override
  String get organizerRequestNew => 'Pedir outro campeonato';

  @override
  String get organizerMyChampionships => 'Meus campeonatos';

  @override
  String get organizerRequestsPanelTitle => 'Organizadores de campeonato';

  @override
  String get organizerRequestsEmptyPending =>
      'Nenhum pedido de organizador esperando resposta.';

  @override
  String get organizerRequestsEmptyAnswered =>
      'Nenhum pedido respondido ainda.';

  @override
  String get organizerRequestsLoadError =>
      'Não foi possível carregar os pedidos de organizador.';

  @override
  String organizerRequestsApproveTitle(String name) {
    return 'Aprovar $name?';
  }

  @override
  String organizerRequestsApproveMessage(
      String region, String scope, String user) {
    return 'Cria o campeonato em $region ($scope) na temporada atual, organizado por $user.';
  }

  @override
  String organizerRequestsApproved(String name) {
    return 'Campeonato $name criado.';
  }

  @override
  String organizerRequestsRejectTitle(String name) {
    return 'Rejeitar $name?';
  }

  @override
  String organizerRequestsOrganizer(String user) {
    return 'Organizador: $user';
  }

  @override
  String get championshipFormOrganizerLocked =>
      'Nome, região, categoria e temporada foram definidos na aprovação. Para mudar, fale com o administrador.';

  @override
  String get pushActionOrganizerRequest => 'Pedido de organizador';

  @override
  String get pushActionOrganizerRequestHint =>
      'Para os admins · alguém quer cadastrar um campeonato';

  @override
  String get pushActionOrganizerAnswer => 'Resposta ao organizador';

  @override
  String get pushActionOrganizerAnswerHint =>
      'Para quem pediu · campeonato aprovado ou recusado';

  @override
  String get pushActionChampion => 'Campeão';

  @override
  String get pushActionChampionHint =>
      'Região e torcida · competição encerrada com o campeão';

  @override
  String get referralTitle => 'Indique amigos';

  @override
  String get referralPaused => 'As indicações estão pausadas no momento.';

  @override
  String get referralSettingsSwitch => 'Indicações ligadas';

  @override
  String get referralSettingsOn =>
      'O \"Indique amigos\" aparece no menu e no álbum, e as indicações valem.';

  @override
  String get referralSettingsOff =>
      'Desligado: o item some do menu e do álbum. Indicações feitas agora ficam guardadas e valem quando você religar (se a conta do amigo ainda tiver até 7 dias). Os pacotinhos extras já ganhos continuam abrindo.';

  @override
  String referralSettingsRules(int max) {
    return 'Regras: o amigo cria a conta, informa o código (até 7 dias) e escolhe o time do coração; os dois ganham 1 pacotinho extra (até $max guardados) e quem indicou soma na conquista \"Amigos indicados\".';
  }

  @override
  String get referralSettingsSaved => 'Configuração salva';

  @override
  String get referralHeadline => 'Convide amigos e ganhem figurinhas';

  @override
  String get referralSubtitle =>
      'Cada amigo que entrar pelo seu convite e escolher o time dá 1 pacotinho extra para você e outro para ele.';

  @override
  String get referralYourCode => 'SEU CÓDIGO';

  @override
  String get referralShare => 'Compartilhar convite';

  @override
  String referralShareText(String code, String link) {
    return 'Bora acompanhar o futebol da nossa região no Arena Football! Entra com o meu código $code e a gente ganha pacotinhos de figurinhas: $link';
  }

  @override
  String get referralCodeCopied => 'Código copiado';

  @override
  String get referralStatInvited => 'Amigos indicados';

  @override
  String get referralStatExtraPacks => 'Pacotinhos guardados';

  @override
  String get referralStatEarned => 'Pacotinhos ganhos';

  @override
  String get referralHowTitle => 'Como funciona';

  @override
  String get referralHowStep1 =>
      'Compartilhe o seu convite (ou o código) com os amigos.';

  @override
  String get referralHowStep2 =>
      'O amigo cria a conta, informa o seu código e escolhe o time do coração.';

  @override
  String referralHowStep3(int max) {
    return 'Vocês dois ganham 1 pacotinho extra para abrir no álbum na hora, fora da espera de 24 h (guarda até $max).';
  }

  @override
  String get referralFriendsTitle => 'Seus indicados';

  @override
  String get referralFriendsEmpty => 'Ninguém entrou pelo seu convite ainda.';

  @override
  String get referralFriendNoName => 'Amigo';

  @override
  String get referralClaimTitle => 'Fui indicado';

  @override
  String get referralClaimHint =>
      'Conta nova? Informe o código de quem te convidou (vale nos primeiros 7 dias).';

  @override
  String get referralClaimField => 'Código do amigo';

  @override
  String get referralClaimButton => 'Usar código';

  @override
  String get referralClaimSaved =>
      'Código salvo! O pacotinho chega quando você tiver o time do coração.';

  @override
  String get referralClaimInvalid =>
      'Código inválido: são 8 ou 10 letras e números.';

  @override
  String get referralClaimOwn => 'Esse código é o seu.';

  @override
  String get referralClaimOldAccount =>
      'O código de convite vale só nos primeiros 7 dias da conta.';

  @override
  String get referralClaimAlready => 'A sua conta já usou um código.';

  @override
  String referralClaimUsed(String code) {
    return 'Você entrou com o código $code';
  }

  @override
  String get referralClaimValid =>
      'Indicação confirmada: o pacotinho extra é seu!';

  @override
  String get referralClaimPending =>
      'Escolha o seu time do coração para confirmar.';

  @override
  String get referralRefusedCode => 'Esse código não existe.';

  @override
  String albumExtraPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count pacotinhos extras guardados',
      one: '+1 pacotinho extra guardado',
    );
    return '$_temp0';
  }

  @override
  String get albumOpenExtraPack => 'Abrir pacotinho extra';

  @override
  String get albumInviteForPacks => 'Ganhe pacotinhos indicando amigos';

  @override
  String get pushActionReferral => 'Indicação confirmada';

  @override
  String get pushActionReferralHint =>
      'Para quem indicou · o amigo entrou e o pacotinho extra chegou';

  @override
  String get achievementMetricReferrals => 'Amigos indicados';

  @override
  String get teamPickerOtherRegion => 'Outras regiões';

  @override
  String get matchFormRegionFilter => 'Procurar campeonatos e times em';

  @override
  String get matchFormRegionFilterHint =>
      'Campeonatos intermunicipais aparecem em todas as regiões.';

  @override
  String matchFormAppearsIn(String regions) {
    return 'Aparece em $regions';
  }

  @override
  String matchFormAppearsHostTeams(String championship) {
    return 'Sede do $championship e região dos times';
  }

  @override
  String matchFormAppearsHost(String championship) {
    return 'Sede do $championship';
  }

  @override
  String get matchFormAppearsTeams => 'Região dos times';

  @override
  String get matchFormAppearsFilter => 'Região selecionada acima';

  @override
  String get matchFormAnd => 'e';

  @override
  String get matchDelay => 'Atrasou';

  @override
  String get matchDelayTitle => 'Novo horário';

  @override
  String matchDelayCurrent(String time) {
    return 'Marcada para $time';
  }

  @override
  String matchDelayPlus(int minutes) {
    return '+$minutes min';
  }

  @override
  String get matchDelayHint =>
      'O card mostra a partida como atrasada e o relógio, o bolão e a votação passam a contar do novo horário.';

  @override
  String get matchDelayStartedNow => 'Começou agora';

  @override
  String matchDelayedTo(String time) {
    return 'Horário alterado para $time';
  }

  @override
  String get matchStartNow => 'Iniciar agora';

  @override
  String get matchCardDelayed => 'ATRASADA';

  @override
  String get matchCardWaiting => 'AGUARDANDO';

  @override
  String get matchDelayPause => 'Pausar até começar';

  @override
  String get matchPausedNotice => 'Partida pausada até o início';

  @override
  String matchCardWas(String time) {
    return 'era $time';
  }

  @override
  String get reportLive => 'Ao vivo';

  @override
  String get reportHalfTime => 'Intervalo';

  @override
  String get reportFinished => 'Encerrado';

  @override
  String get reportNotStarted => 'Não iniciado';

  @override
  String get reportStageBefore => 'Antes';

  @override
  String get reportStageFirstHalf => '1º T';

  @override
  String get reportStageHalfTime => 'Intervalo';

  @override
  String get reportStageSecondHalf => '2º T';

  @override
  String get reportStageEnd => 'Fim';

  @override
  String get reportGoal => 'Gol';

  @override
  String reportGoalOf(String team) {
    return 'Gol do $team';
  }

  @override
  String reportGoalBy(String name) {
    return 'Gol de $name';
  }

  @override
  String get reportWhoAssisted => 'Quem deu o passe?';

  @override
  String get reportNoAssist => 'Sem assistência';

  @override
  String get reportGoalNoScorer => 'Sem autor';

  @override
  String get reportNoEvents =>
      'Nenhum lance ainda. Use os botões acima para lançar gols e cartões.';

  @override
  String get reportNoMinute => 'Sem minuto';

  @override
  String get reportFirstHalf => '1º tempo';

  @override
  String get reportSecondHalf => '2º tempo';

  @override
  String get reportEditEvent => 'Editar lance';

  @override
  String get reportDeleteEvent => 'Apagar lance';

  @override
  String get reportUndo => 'Desfazer';

  @override
  String get reportNotRelated => 'Não relacionados';

  @override
  String reportStarters(int count) {
    return 'Titulares $count/11';
  }

  @override
  String reportSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reservas',
      one: '1 reserva',
      zero: 'Nenhum reserva',
    );
    return '$_temp0';
  }

  @override
  String get reportStarter => 'Titular';

  @override
  String get reportSub => 'Reserva';

  @override
  String get reportWhen => 'Quando';

  @override
  String get reportWhere => 'Onde';

  @override
  String get matchEditInfo => 'Editar partida';

  @override
  String get matchEditInfoTitle => 'Editar partida';

  @override
  String get matchEditInfoSubtitle => 'Data, horário, duração e local';

  @override
  String get matchEditInfoSaved => 'Partida atualizada';

  @override
  String get reportRefereeing => 'Arbitragem';

  @override
  String get reportVoting => 'Votação do craque';

  @override
  String get reportVotingOpen => 'Aberta agora';

  @override
  String get reportVotingClosed => 'Fechada';

  @override
  String get reportNotesHint => 'Ocorrências, expulsões, atrasos, W.O....';

  @override
  String reportChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mudanças',
      one: '1 mudança',
    );
    return '$_temp0';
  }

  @override
  String get reportPublishCards => 'Publicar no feed (card ao vivo da partida)';

  @override
  String get reportSave => 'Salvar';

  @override
  String get athleteBookings => 'Cartões na temporada';

  @override
  String get matchDetailsStarters => 'Titulares';

  @override
  String get matchDetailsSubs => 'Reservas';

  @override
  String matchDetailsReferee(String name) {
    return 'Árbitro: $name';
  }

  @override
  String get matchReportManage => 'Gerenciar partida';

  @override
  String get matchReportTitle => 'Súmula';

  @override
  String get matchReportTabEvents => 'Lances';

  @override
  String get matchReportTabLineup => 'Escalação';

  @override
  String get matchReportTabGame => 'Jogo';

  @override
  String get matchReportSave => 'Salvar súmula';

  @override
  String get matchReportSaved => 'Súmula salva.';

  @override
  String matchReportSavedWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Súmula salva · $count cards de gol publicados',
      one: 'Súmula salva · 1 card de gol publicado',
    );
    return '$_temp0';
  }

  @override
  String get matchReportDiscardTitle => 'Sair sem salvar?';

  @override
  String get matchReportDiscardMessage =>
      'As mudanças da súmula (lances, escalação e dados do jogo) serão perdidas.';

  @override
  String get matchReportDiscard => 'Sair sem salvar';

  @override
  String get matchReportAddGoal => '+ Gol';

  @override
  String get matchReportAddBooking => '+ Cartão';

  @override
  String get matchReportNoEvents =>
      'Nenhum lance ainda. Lance os gols e os cartões aqui.';

  @override
  String get matchReportSwipeHint =>
      'Toque num gol para editar; arraste um lance para o lado para apagar.';

  @override
  String get matchReportGoalNoScorer => 'Gol (sem autor)';

  @override
  String matchReportAssist(String name) {
    return 'assist. $name';
  }

  @override
  String get matchReportSecondYellow => '2º amarelo';

  @override
  String get matchReportGoalTitle => 'Gol';

  @override
  String get matchReportBookingTitle => 'Cartão';

  @override
  String get matchReportScorer => 'Autor do gol';

  @override
  String get matchReportPlayer => 'Atleta';

  @override
  String get matchReportAssistant => 'Assistência (opcional)';

  @override
  String get matchReportNone => 'Nenhum';

  @override
  String get matchReportYellow => 'Amarelo';

  @override
  String get matchReportRed => 'Vermelho';

  @override
  String get matchReportMinute => 'Minuto';

  @override
  String get matchReportAdd => 'Adicionar';

  @override
  String get matchReportNoSquad =>
      'Nenhum atleta no elenco deste time nesta competição. Adicione pela aba Escalação.';

  @override
  String matchReportLineupCount(int starters, int subs) {
    return '$starters titulares · $subs reservas';
  }

  @override
  String get matchReportLineupHint =>
      'Marque T (titular) ou R (reserva); toque no número para trocar a camisa.';

  @override
  String get matchReportStarterShort => 'T';

  @override
  String get matchReportSubShort => 'R';

  @override
  String get matchReportAddPlayer => 'Adicionar atleta';

  @override
  String get matchReportAddPlayerHint =>
      'Ele entra no elenco do time nesta competição e na escalação.';

  @override
  String get matchReportPlayerAdded => 'Atleta cadastrado e escalado.';

  @override
  String get matchReportPlayerName => 'Nome do atleta';

  @override
  String get matchReportPhoto => 'Foto';

  @override
  String matchReportShirtNumber(String name) {
    return 'Número da camisa de $name';
  }

  @override
  String get matchReportDate => 'Data';

  @override
  String get matchReportTime => 'Horário';

  @override
  String get matchReportDuration => 'Duração (minutos)';

  @override
  String get matchReportVenue => 'Local';

  @override
  String get matchReportReferee => 'Árbitro';

  @override
  String get matchReportNotes => 'Observações da súmula';

  @override
  String get matchReportVoting => 'Votação do craque aberta';

  @override
  String get matchReportVotingHint => 'Abre ou fecha na hora para todos.';

  @override
  String get commonCardSettings => 'Configurações';

  @override
  String matchGoalsPublishCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Publicar cards dos $count gols novos',
      one: 'Publicar card do gol novo',
    );
    return '$_temp0';
  }

  @override
  String get matchGoalsPublishCardsHint =>
      'Aparece no feed e manda o push \"GOL!\". Desligue para lançar o placar de um jogo antigo em silêncio.';

  @override
  String matchGoalsSavedWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Placar salvo · $count cards de gol publicados',
      one: 'Placar salvo · 1 card de gol publicado',
    );
    return '$_temp0';
  }

  @override
  String get matchGoalsSavedCardsFailed =>
      'Placar salvo, mas não deu para publicar o card de gol.';

  @override
  String get tourSkip => 'Pular';

  @override
  String get tourNext => 'Próximo';

  @override
  String get tourDone => 'Entendi';

  @override
  String tourWelcomeTitle(String name) {
    return 'Bem-vindo à Arena, $name! ⚽';
  }

  @override
  String get tourWelcomeSubtitle => 'O futebol da sua região, num lugar só.';

  @override
  String get tourWelcomeItemNews => 'Notícias, jogos e placares da sua região';

  @override
  String get tourWelcomeItemPlay => 'Palpites, votação do craque e conquistas';

  @override
  String get tourWelcomeItemAlbum => 'Álbum de figurinhas com pacotinho grátis';

  @override
  String get tourWelcomeStart => 'Fazer tour rápido (30 s)';

  @override
  String get tourWelcomeLater => 'Agora não';

  @override
  String get tourHomeRegionTitle => 'Sua região';

  @override
  String get tourHomeRegionBody =>
      'Escolha a cidade aqui. Notícias, jogos, times e campeonatos mostram só o que é de lá.';

  @override
  String get tourHomeTabsTitle => 'Tudo em 4 abas';

  @override
  String get tourHomeTabsBody =>
      'Notícias, campeonatos, times com os elencos e a tabela de jogos com os placares.';

  @override
  String get tourHomeMenuTitle => 'Seu menu';

  @override
  String get tourHomeMenuBody =>
      'Carteirinha, conquistas, bolão, ranking de torcidas e o \"Sou jogador\" para entrar no elenco do seu time.';

  @override
  String get tourHomeAlbumTitle => 'Álbum de figurinhas';

  @override
  String get tourHomeAlbumBody =>
      'Um pacotinho grátis a cada 24 h. Arraste o selo para onde preferir.';

  @override
  String get tourDrawerProfileTitle => 'Seu perfil';

  @override
  String get tourDrawerProfileBody =>
      'Seu time do coração e a sua carteirinha de torcedor.';

  @override
  String get tourDrawerPredictionsTitle => 'Bolão';

  @override
  String get tourDrawerPredictionsBody =>
      'Dê palpites grátis nos jogos e dispute o ranking da região.';

  @override
  String get tourDrawerAchievementsTitle => 'Conquistas';

  @override
  String get tourDrawerAchievementsBody => 'Ganhe medalhas e XP usando o app.';

  @override
  String get tourDrawerPlayerTitle => 'Sou jogador';

  @override
  String get tourDrawerPlayerBody =>
      'Joga num time da região? Peça para entrar no elenco e tenha seu perfil de atleta.';

  @override
  String get tourTablesFilterTitle => 'Escolha a competição';

  @override
  String get tourTablesFilterBody =>
      'Veja os jogos de uma competição ou de todas de uma vez.';

  @override
  String get tourTablesShortcutsTitle => 'Atalhos';

  @override
  String get tourTablesShortcutsBody =>
      'Todos os jogos, os grupos com a classificação e a artilharia.';

  @override
  String get tourTablesDayTitle => 'Jogos do dia';

  @override
  String get tourTablesDayBody =>
      'Ontem, hoje e amanhã. Toque num jogo para ver os gols, votar no craque e dar seu palpite.';

  @override
  String get tourTeamsTitle => 'Os times da região';

  @override
  String get tourTeamsBody =>
      'Toque num time para ver o elenco, os atletas e os números de cada competição.';

  @override
  String get tourChampionshipsTitle => 'Campeonatos';

  @override
  String get tourChampionshipsBody =>
      'Toque para ver regulamento, premiação, grupos e a classificação, que se atualiza sozinha.';

  @override
  String get tourChampionshipsShortcutsTitle => 'Atalhos da competição';

  @override
  String get tourChampionshipsShortcutsBody =>
      'Grupos, artilharia e regulamento do campeonato em destaque.';

  @override
  String get tourAlbumPackTitle => 'Pacotinho grátis';

  @override
  String get tourAlbumPackBody =>
      'Um a cada 24 h, com figurinhas novas. A gente avisa quando o próximo chegar.';

  @override
  String get tourAlbumPagesTitle => 'Páginas dos times';

  @override
  String get tourAlbumPagesBody =>
      'Toque num time para ver as figurinhas coladas e o que falta para completar a página.';

  @override
  String get tourAlbumTabsTitle => 'Repetidas e ranking';

  @override
  String get tourAlbumTabsBody =>
      'Veja suas repetidas e dispute o ranking de colecionadores.';

  @override
  String get tourPredictionsHeroTitle => 'Seu bolão';

  @override
  String get tourPredictionsHeroBody =>
      'Sua posição, pontos e quantos faltam para passar o próximo. Exato vale 10, vencedor e saldo 7, só o vencedor 5.';

  @override
  String get tourPredictionsMatchTitle => 'Palpite antes do jogo';

  @override
  String get tourPredictionsMatchBody =>
      'Toque em \"Palpitar\" e escolha o placar. Dá para mudar até a partida começar.';

  @override
  String get tourPredictionsTabsTitle => 'Palpitar e ranking';

  @override
  String get tourPredictionsTabsBody =>
      'Troque de aba para ver o ranking da região e desafiar os amigos.';

  @override
  String get tourFanCardCardTitle => 'Sua carteirinha';

  @override
  String get tourFanCardCardBody =>
      'Incline o celular para ver o brilho e toque para virar o cartão.';

  @override
  String get tourFanCardActionsTitle => 'Compartilhar, foto e time';

  @override
  String get tourFanCardActionsBody =>
      'Mande a carteirinha para os amigos, troque a foto ou o time do coração.';

  @override
  String get tourFanCardLevelTitle => 'Seu nível de torcedor';

  @override
  String get tourFanCardLevelBody =>
      'Suba de nível ganhando conquistas no app.';

  @override
  String get tourFanRankingScopeTitle => 'Região ou geral';

  @override
  String get tourFanRankingScopeBody =>
      'Veja as maiores torcidas da sua região ou do app inteiro.';

  @override
  String get tourFanRankingLeaderTitle => 'A maior torcida';

  @override
  String get tourFanRankingLeaderBody =>
      'Quem lidera, com quantos torcedores e a fatia de cada time.';

  @override
  String get tourFanRankingMineTitle => 'Sua torcida';

  @override
  String get tourFanRankingMineBody =>
      'Veja a posição do seu time e convoque mais torcedores para subir.';

  @override
  String get tourAchievementsLevelTitle => 'Nível e XP';

  @override
  String get tourAchievementsLevelBody =>
      'Cada conquista dá XP e sobe o seu nível de torcedor.';

  @override
  String get tourAchievementsAlmostTitle => 'Quase lá';

  @override
  String get tourAchievementsAlmostBody =>
      'A próxima medalha que você está perto de ganhar.';

  @override
  String get tourAchievementsShelfTitle => 'Medalhas por categoria';

  @override
  String get tourAchievementsShelfBody =>
      'Toque numa medalha para ver como ganhar.';

  @override
  String get tourMatchArtTitle => 'Gerar arte';

  @override
  String get tourMatchArtBody =>
      'Monte uma arte do jogo para postar no Instagram ou mandar no WhatsApp.';

  @override
  String get tourMatchBestPlayerTitle => 'Craque da partida';

  @override
  String get tourMatchBestPlayerBody =>
      'Quando a votação abrir, vote aqui no melhor jogador do jogo.';

  @override
  String get tourMatchPredictionTitle => 'Seu palpite';

  @override
  String get tourMatchPredictionBody =>
      'Palpite o placar antes do jogo e ganhe pontos no bolão.';

  @override
  String get tourMatchPitchTitle => 'Escalações em campo';

  @override
  String get tourMatchPitchBody =>
      'Quem está em campo agora, com o número, os gols e os cartões. Toque num jogador para ver o perfil.';

  @override
  String get tourEventPollHeaderTitle => 'Evento de votação';

  @override
  String get tourEventPollHeaderBody =>
      'Fica aberto até o prazo. O resultado sai no encerramento.';

  @override
  String get tourEventPollOptionTitle => 'Escolha a sua';

  @override
  String get tourEventPollOptionBody =>
      'Toque numa opção e confirme. Você vota uma vez só; o botão do vídeo abre o lance na rede.';

  @override
  String get tourArtPreviewTitle => 'Sua arte';

  @override
  String get tourArtPreviewBody =>
      'A prévia mostra a arte do jeito que vai ser salva.';

  @override
  String get tourArtFramingTitle => 'Ajuste a foto';

  @override
  String get tourArtFramingBody =>
      'Arraste para mover e use a pinça para dar zoom. Também dá para usar uma foto da galeria.';

  @override
  String get tourArtTemplatesTitle => 'Modelos';

  @override
  String get tourArtTemplatesBody =>
      'Troque o modelo para mudar o visual da arte.';

  @override
  String get tourArtFormatTitle => 'Formato';

  @override
  String get tourArtFormatBody =>
      'Feed, story, quadrado ou paisagem: no tamanho certo de cada rede.';

  @override
  String get tourArtShareTitle => 'Salvar e compartilhar';

  @override
  String get tourArtShareBody =>
      'Salve na galeria ou mande direto no Instagram e no WhatsApp.';

  @override
  String get tourReferralInviteTitle => 'Seu convite';

  @override
  String get tourReferralInviteBody =>
      'Mande o seu link. Quando o amigo entrar e escolher o time, os dois ganham um pacotinho extra.';

  @override
  String get tourReferralStatsTitle => 'Suas indicações';

  @override
  String get tourReferralStatsBody =>
      'Quantos amigos entraram e os pacotinhos extras guardados.';

  @override
  String get tourReferralClaimTitle => 'Foi indicado?';

  @override
  String get tourReferralClaimBody =>
      'Coloque aqui o código de quem te convidou.';

  @override
  String get tourPlayerClaimTitle => 'É você?';

  @override
  String get tourPlayerClaimBody =>
      'Se esse atleta é você, peça para vincular à sua conta e tenha o seu perfil.';

  @override
  String get tourProfilePhotoTitle => 'Sua foto';

  @override
  String get tourProfilePhotoBody =>
      'Toque para trocar a foto da conta. Ela aparece na carteirinha.';

  @override
  String get tourProfileNameTitle => 'Seu nome';

  @override
  String get tourProfileNameBody =>
      'O nome que aparece nos rankings e votações.';

  @override
  String get tourProfileTeamTitle => 'Time do coração';

  @override
  String get tourProfileTeamBody => 'Dá para trocar uma vez a cada 15 dias.';

  @override
  String get tourDrawerFanCardTitle => 'Minha carteirinha';

  @override
  String get tourDrawerFanCardBody =>
      'Seu cartão de torcedor nas cores do seu time.';

  @override
  String get tourDrawerFanRankingTitle => 'Guerra das torcidas';

  @override
  String get tourDrawerFanRankingBody =>
      'Qual time tem mais torcedores no app.';

  @override
  String get tourDrawerReferralTitle => 'Indique amigos';

  @override
  String get tourDrawerReferralBody =>
      'Convide amigos e ganhe pacotinhos extras do álbum.';

  @override
  String get tourFantasyRoundTitle => 'Sua rodada';

  @override
  String get tourFantasyRoundBody =>
      'Cada campeonato com Fantasy tem a rodada, o prazo para escalar e os seus pontos.';

  @override
  String get tourFantasyPlayTitle => 'Monte seu time';

  @override
  String get tourFantasyPlayBody =>
      'Escolha seus atletas do campeonato e um capitão. Eles pontuam pelo que fazem nos jogos de verdade.';

  @override
  String get tourFantasyRankingTitle => 'Ranking';

  @override
  String get tourFantasyRankingBody =>
      'Veja quem está na frente na rodada e no geral.';

  @override
  String get tourFantasyLineupDeadlineTitle => 'Prazo da rodada';

  @override
  String get tourFantasyLineupDeadlineBody =>
      'Dá para mudar até o 1º jogo da rodada começar. Depois, a escalação trava.';

  @override
  String get tourFantasyLineupPitchTitle => 'Seu campo';

  @override
  String get tourFantasyLineupPitchBody =>
      'Toque num espaço para escolher o atleta da posição. A vaga livre aceita qualquer posição.';

  @override
  String get tourFantasyLineupCaptainTitle => 'Capitão';

  @override
  String tourFantasyLineupCaptainBody(String mult) {
    return 'Toque no \"C\" de um atleta para torná-lo capitão: ele pontua $mult.';
  }

  @override
  String get tourFantasyLineupSaveTitle => 'Confirme a escalação';

  @override
  String get tourFantasyLineupSaveBody =>
      'Salve antes do prazo. Se não mudar nada, a escalação anterior vale para a próxima rodada.';

  @override
  String get tourFantasyRankTabsTitle => 'Quatro rankings';

  @override
  String get tourFantasyRankTabsBody =>
      'Rodada, os atletas que mais pontuaram, o geral e o histórico das suas escalações.';

  @override
  String get tourFantasyRankRoundTitle => 'Troque de rodada';

  @override
  String get tourFantasyRankRoundBody =>
      'Use as setas para ver as rodadas anteriores.';

  @override
  String get tourFantasyRankMineTitle => 'Sua posição';

  @override
  String get tourFantasyRankMineBody => 'Onde você está e quantos pontos fez.';

  @override
  String get tourDrawerFantasyTitle => 'Arena Fantasy';

  @override
  String get tourDrawerFantasyBody =>
      'Monte seu time com os atletas do campeonato e dispute com a região.';

  @override
  String get settingsHelpSection => 'Ajuda';

  @override
  String get settingsReplayTours => 'Rever tutoriais';

  @override
  String get settingsReplayToursHint =>
      'As dicas de cada tela aparecem de novo';

  @override
  String get settingsReplayToursDone =>
      'Pronto! As dicas vão aparecer de novo.';

  @override
  String get albumTabRanking => 'Ranking';

  @override
  String get albumRankingHint =>
      'Quem tem mais figurinhas diferentes coladas. Empate: quem chegou primeiro.';

  @override
  String get albumRankingRefresh => 'Atualizar';

  @override
  String get albumRankingEmpty =>
      'Ninguém abriu pacotinho ainda. Seja o primeiro!';

  @override
  String get albumRankingYou => 'Você';

  @override
  String get albumRankingComplete => 'Completo ✓';

  @override
  String get albumRankingMyPosition => 'Sua posição';

  @override
  String get albumRankingNotYet =>
      'Abra seu primeiro pacotinho para entrar no ranking.';

  @override
  String get albumRareTag => 'RARA';

  @override
  String get albumRareLabel => 'Rara';

  @override
  String get albumStickerRareNew => 'RARA!';

  @override
  String albumStatRares(int total) {
    return 'raras de $total';
  }

  @override
  String get albumAdminStickerRare => 'Figurinha rara';

  @override
  String get albumAdminStickerRareHint =>
      'Sai bem menos no pacotinho e tem a moldura dourada.';

  @override
  String get regionPickerTitle => 'Escolha a região';

  @override
  String get regionPickerSearch => 'Buscar região';

  @override
  String get regionPickerRecent => 'Recentes';

  @override
  String get regionPickerAll => 'Todas as regiões';

  @override
  String get regionPickerChange => 'Trocar';

  @override
  String get regionPickerEmpty => 'Nenhuma região com esse nome';

  @override
  String albumAdminGenerateTitle(String team) {
    return 'Gerar figurinhas do $team';
  }

  @override
  String get albumAdminGenerateWhich =>
      'De qual elenco? Quem já tem figurinha não é repetido.';

  @override
  String get albumAdminGenerateAll => 'Elenco geral';

  @override
  String get albumAdminGenerateConfirm => 'Gerar';

  @override
  String playerRequestAlreadyInChampionship(String team, String championship) {
    return 'Você já está no elenco do $team na $championship. Na mesma competição só dá para jogar por um time; escolha outra competição.';
  }

  @override
  String get playerRequestsMergeTitle => 'Juntar os cadastros?';

  @override
  String playerRequestsMergeMessage(String current, String team, int goals,
      String claimed, String claimedTeam) {
    String _temp0 = intl.Intl.pluralLogic(
      goals,
      locale: localeName,
      other: '$goals gols',
      one: '1 gol',
    );
    return 'Esta conta já é do atleta $current ($team · $_temp0). Juntar com $claimed ($claimedTeam)? Fica um atleta só, com o time e os números de cada competição; o cadastro de $current some.';
  }

  @override
  String get playerRequestsMergeConfirm => 'Juntar';

  @override
  String playerRequestsMerged(String name) {
    return 'Cadastros juntados: $name agora está ligado à conta.';
  }

  @override
  String get albumBadgeOpen => 'Abrir!';

  @override
  String get albumAdminModeOff => 'Desligado';

  @override
  String get albumAdminModeTest => 'Teste (só admin)';

  @override
  String get albumAdminModeAll => 'Para todos';

  @override
  String get albumAdminTesting => 'Álbum em teste: só você (admin) vê.';

  @override
  String get albumAdminTestTag => 'TESTE';

  @override
  String get albumPackTapToOpen => 'Toque ou arraste para abrir';

  @override
  String get albumPackTapNext => 'Toque para continuar';

  @override
  String get albumPackSkipAll => 'Pular';

  @override
  String albumPackCounter(int index, int total) {
    return '$index de $total';
  }

  @override
  String albumPackStickers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count figurinhas',
      one: '1 figurinha',
    );
    return '$_temp0';
  }

  @override
  String albumPackNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novas',
      one: '1 nova',
    );
    return '$_temp0';
  }

  @override
  String albumPackRepeatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repetidas',
      one: '1 repetida',
    );
    return '$_temp0';
  }

  @override
  String albumDetailPosition(int index, int total) {
    return '$index de $total coladas';
  }

  @override
  String albumDetailPage(int page, int total) {
    return 'Página $page de $total';
  }

  @override
  String get albumDetailCrest => 'Escudo';

  @override
  String get albumDetailAthlete => 'Atleta';

  @override
  String albumDetailYouHave(int count) {
    return 'Você tem ×$count';
  }

  @override
  String get albumDetailSeeAthlete => 'Ver atleta';

  @override
  String get albumDetailShare => 'Compartilhar';

  @override
  String albumDetailShareText(int number, String name, String event) {
    return 'Tirei a figurinha Nº $number – $name no álbum $event!';
  }

  @override
  String get albumPackReady => 'Seu pacotinho chegou!';

  @override
  String get albumPackReadyHint => '5 figurinhas grátis, todo dia.';

  @override
  String get albumPackDone => 'Pacotinho de hoje aberto';

  @override
  String albumNextPackIn(String time) {
    return 'Próximo pacote em $time';
  }

  @override
  String get albumTabTeams => 'Times';

  @override
  String albumTabDuplicates(int count) {
    return 'Repetidas ($count)';
  }

  @override
  String get albumNoDuplicates => 'Nenhuma repetida ainda.';

  @override
  String get albumCompleted => 'completo';

  @override
  String get albumStatCollected => 'coladas';

  @override
  String get albumStatMissing => 'faltam';

  @override
  String get albumStatDuplicates => 'repetidas';

  @override
  String get albumPageCompleteStamp => 'PÁGINA COMPLETA';

  @override
  String albumStickerCaption(int number, String team) {
    return 'Nº $number · $team';
  }

  @override
  String get albumAdminNewEventMessage =>
      'Dê um nome ao álbum. Depois você escolhe os times e gera as figurinhas.';

  @override
  String get albumAdminEventTitleShort =>
      'O nome precisa de pelo menos 3 letras.';

  @override
  String get albumTitle => 'Álbum de figurinhas';

  @override
  String get albumNoEvent => 'Nenhum álbum ativo no momento.';

  @override
  String get albumEmpty => 'O álbum ainda não tem figurinhas.';

  @override
  String albumProgress(int collected, int total) {
    return '$collected de $total figurinhas';
  }

  @override
  String albumDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repetidas',
      one: '1 repetida',
    );
    return '$_temp0';
  }

  @override
  String get albumOpenPack => 'Abrir pacotinho do dia';

  @override
  String get albumComeBackTomorrow => 'Novo pacotinho amanhã';

  @override
  String get albumPackOpeningShort => 'Abrindo…';

  @override
  String get albumPackBadge => '1 pacote!';

  @override
  String get albumPackLabel => 'Pacotinho\nArena';

  @override
  String get albumPackOpening => 'Abrindo o pacotinho…';

  @override
  String albumPackResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count figurinhas novas!',
      one: '1 figurinha nova!',
      zero: 'Só repetidas desta vez!',
    );
    return '$_temp0';
  }

  @override
  String get albumPackStick => 'Colar no álbum';

  @override
  String get albumPackSkip => 'Toque para ver todas';

  @override
  String get albumPackFailed =>
      'Não foi possível abrir o pacotinho. Tente de novo.';

  @override
  String get albumStickerNew => 'NOVA!';

  @override
  String get albumStickerRepeated => 'Repetida';

  @override
  String albumPageProgress(int collected, int total) {
    return '$collected de $total';
  }

  @override
  String get albumPageComplete => 'Completa';

  @override
  String get albumAdminTitle => 'Álbum de figurinhas';

  @override
  String get albumAdminIntro =>
      'Crie o evento, escolha os times e gere as figurinhas do elenco. Ligado, aparece para todos com o pacotinho grátis do dia. Um evento ativo por vez.';

  @override
  String get albumAdminEmpty => 'Nenhum evento criado.';

  @override
  String get albumAdminNewEvent => 'Novo evento';

  @override
  String get albumAdminCreate => 'Criar';

  @override
  String get albumAdminEventTitle => 'Nome do evento';

  @override
  String get albumAdminEventTitleHint => 'Ex.: Copa Floresta 2026';

  @override
  String get albumAdminEventDescription => 'Descrição (opcional)';

  @override
  String get albumAdminEventData => 'Evento';

  @override
  String albumAdminEventInfo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
      zero: 'Nenhum time',
    );
    return '$_temp0';
  }

  @override
  String get albumAdminTeams => 'Times do álbum (páginas)';

  @override
  String albumAdminTeamStickers(String team, int count) {
    return '$team · $count figurinhas';
  }

  @override
  String get albumAdminGenerate => 'Gerar do elenco';

  @override
  String get albumAdminAddSticker => 'Nova figurinha';

  @override
  String albumAdminEditSticker(int number) {
    return 'Figurinha $number';
  }

  @override
  String get albumAdminPhoto => 'Foto';

  @override
  String get albumAdminStickerName => 'Nome na figurinha';

  @override
  String get albumAdminStickerOrder => 'Ordem na página';

  @override
  String get albumAdminSaved => 'Evento salvo.';

  @override
  String get albumAdminActivated => 'Álbum ligado: já aparece para todos.';

  @override
  String get albumAdminDeactivated => 'Álbum desligado.';

  @override
  String get albumAdminDeleted => 'Evento apagado.';

  @override
  String albumAdminGenerated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count figurinhas criadas.',
      one: '1 figurinha criada.',
      zero: 'Nenhuma figurinha nova (o elenco já está no álbum).',
    );
    return '$_temp0';
  }

  @override
  String get albumAdminStickerSaved => 'Figurinha salva.';

  @override
  String get albumAdminStickerDeleted => 'Figurinha apagada.';

  @override
  String get albumAdminSelectAll => 'Selecionar todas';

  @override
  String get albumAdminUnselectAll => 'Desmarcar todas';

  @override
  String albumAdminSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionadas',
      one: '1 selecionada',
    );
    return '$_temp0';
  }

  @override
  String albumAdminDeleteStickersTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count figurinhas?',
      one: 'Excluir 1 figurinha?',
    );
    return '$_temp0';
  }

  @override
  String get albumAdminDeleteStickersMessage =>
      'Quem já colou essas figurinhas deixa de vê-las no álbum. Os números são refeitos em sequência.';

  @override
  String albumAdminStickersDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count figurinhas excluídas.',
      one: '1 figurinha excluída.',
    );
    return '$_temp0';
  }

  @override
  String get albumAdminSyncPhotos => 'Atualizar fotos dos atletas';

  @override
  String get albumAdminSyncPhotosMessage =>
      'Copia a foto atual de cada atleta para as figurinhas dele. Fotos enviadas só para a figurinha serão substituídas.';

  @override
  String albumAdminPhotosSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count figurinhas atualizadas.',
      one: '1 figurinha atualizada.',
      zero: 'As fotos já estão em dia.',
    );
    return '$_temp0';
  }

  @override
  String albumAdminDeleteTitle(String title) {
    return 'Apagar o evento $title?';
  }

  @override
  String get albumAdminDeleteMessage =>
      'O evento e as figurinhas somem do app. As coleções dos torcedores ficam guardadas, mas sem o álbum.';

  @override
  String get achievementMetricAlbumStickers =>
      'Figurinhas diferentes coladas no álbum';

  @override
  String get achievementMetricAlbumPages =>
      'Páginas de time completas no álbum';

  @override
  String get achievementMetricAlbumComplete => 'Álbum completo';

  @override
  String get recompressTitle => 'Recomprimir imagens';

  @override
  String get recompressIntro =>
      'Recomprime as imagens enviadas antes da otimização (notícias, destaques, escudos, atletas, campeonatos e fotos de conta), no mesmo padrão do upload atual. Os links continuam valendo. Roda no servidor, em lotes: pode fechar a tela.';

  @override
  String get recompressIdle => 'Ainda não rodou.';

  @override
  String get recompressRequested => 'Pedido enviado, começando…';

  @override
  String recompressRunning(String folder) {
    return 'Recomprimindo a pasta $folder…';
  }

  @override
  String get recompressDone => 'Concluído.';

  @override
  String recompressError(String error) {
    return 'Parou com erro: $error';
  }

  @override
  String recompressStats(int seen, int rewritten) {
    return '$seen arquivos vistos · $rewritten regravados';
  }

  @override
  String recompressSaved(String saved, String before) {
    return '$saved MB economizados (de $before MB)';
  }

  @override
  String get recompressStart => 'Recomprimir';

  @override
  String get recompressAgain => 'Rodar de novo';

  @override
  String get recompressConfirmTitle => 'Recomprimir as imagens antigas?';

  @override
  String get recompressConfirmMessage =>
      'O servidor percorre o Storage e regrava menores as imagens grandes, no mesmo endereço. Pode levar alguns minutos.';

  @override
  String get athleteRecentMatches => 'Últimas partidas';

  @override
  String athleteChartTooltip(String opponent, int goals, int assists) {
    return 'Contra $opponent: $goals gols, $assists assist.';
  }

  @override
  String athleteAwardsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Craque da partida · $count vezes',
      one: 'Craque da partida · 1 vez',
    );
    return '$_temp0';
  }

  @override
  String get athleteAwardLabel => 'Craque da partida';

  @override
  String get athleteHistory => 'Histórico';

  @override
  String athleteHistorySeason(String season, String team) {
    return 'Temporada $season · $team';
  }

  @override
  String athleteHistoryStats(int goals, int assists, int awards) {
    String _temp0 = intl.Intl.pluralLogic(
      awards,
      locale: localeName,
      other: '$awards troféus',
      one: '1 troféu',
      zero: 'nenhum troféu',
    );
    return '$goals gols · $assists assist. · $_temp0';
  }

  @override
  String get athleteStatsUnassigned => 'Sem competição';

  @override
  String get athleteStatsUnassignedHint => 'Registrados antes das competições';

  @override
  String athleteUnassignedSummary(int goals, int assists) {
    String _temp0 = intl.Intl.pluralLogic(
      goals,
      locale: localeName,
      other: '$goals gols',
      one: '1 gol',
    );
    String _temp1 = intl.Intl.pluralLogic(
      assists,
      locale: localeName,
      other: '$assists assistências',
      one: '1 assistência',
    );
    return '$_temp0 e $_temp1 sem competição';
  }

  @override
  String get athleteAssign => 'Atribuir';

  @override
  String get athleteAssignTitle => 'Atribuir os números sem competição';

  @override
  String get athleteAssignNoEnrollment =>
      'O atleta não está inscrito em competição. Para atribuir a uma, inscreva-o pelo troféu no \"Elenco geral\".';

  @override
  String get partnerNewsLimitTitle => 'Limite de notícias de hoje';

  @override
  String partnerNewsLimitMessage(int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: 'Você já publicou as $limit notícias de hoje.',
      one: 'Você já publicou a notícia de hoje.',
    );
    return '$_temp0 Enviar esta para o admin aprovar?';
  }

  @override
  String get partnerNewsSendForApproval => 'Enviar para aprovação';

  @override
  String get partnerNewsSentForApproval =>
      'Notícia enviada para o admin aprovar.';

  @override
  String partnerUsageNews(int used, int limit) {
    return '$used de $limit notícias hoje';
  }

  @override
  String partnerLimitNews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notícias por dia',
      one: '1 notícia por dia',
    );
    return '$_temp0';
  }

  @override
  String get partnerPendingNewsTitle => 'Aguardando o admin';

  @override
  String get partnerPendingNewsWaiting => 'Esperando aprovação';

  @override
  String get partnerPendingNewsRejected => 'Não aprovada';

  @override
  String get partnerPendingNewsDeleted => 'Notícia apagada.';

  @override
  String get partnerTabNews => 'Notícias';

  @override
  String get partnerPanelEmptyNews => 'Nenhuma notícia esperando aprovação.';

  @override
  String get partnerNewsPublish => 'Publicar';

  @override
  String get partnerNewsApproved => 'Notícia publicada no feed.';

  @override
  String get partnerNewsRejected => 'Notícia rejeitada.';

  @override
  String get partnerNewsRejectTitle => 'Rejeitar a notícia?';

  @override
  String get partnerNewsPerDayLabel =>
      'Notícias por dia (as demais passam por você)';

  @override
  String get pushActionPartnerNews => 'Notícia de parceiro para aprovar';

  @override
  String get pushActionPartnerNewsHint =>
      'Para os admins · parceiro passou do limite de notícias do dia';

  @override
  String get pushActionPartnerNewsAnswer => 'Resposta da notícia do parceiro';

  @override
  String get pushActionPartnerNewsAnswerHint =>
      'Para o parceiro · notícia publicada ou rejeitada';

  @override
  String get partnerClaimTitle => 'Algum destes destaques é seu?';

  @override
  String get partnerClaimHint =>
      'São destaques sem dono no app. Marque os seus: o admin confirma e eles passam a ser seus, na sua região.';

  @override
  String get partnerClaimPending => 'Vínculo pedido · aguardando o admin';

  @override
  String get partnerUnlinkedTitle => 'Destaques sem dono';

  @override
  String get partnerLinkRequested => 'Pedido de vínculo enviado ao admin.';

  @override
  String partnerLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count destaques vinculados.',
      one: '1 destaque vinculado.',
      zero: 'Nenhum destaque vinculado (já tinham dono).',
    );
    return '$_temp0';
  }

  @override
  String get partnerLinksCleared => 'Pedido de vínculo recusado.';

  @override
  String partnerLinkTitle(String name) {
    return 'Vincular os destaques a $name?';
  }

  @override
  String partnerLinkMessage(String region) {
    return 'Eles passam a ser do parceiro, só na região $region, e contam no limite dele (o limite sobe se faltar vaga). Links compartilhados antigos desses destaques deixam de abrir.';
  }

  @override
  String get partnerLinkConfirm => 'Vincular';

  @override
  String get partnerLinkRefuse => 'Recusar';

  @override
  String partnerClaimedList(String titles) {
    return 'Pediu vínculo: $titles';
  }

  @override
  String partnerClaimedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pediu vínculo de $count destaques',
      one: 'Pediu vínculo de 1 destaque',
    );
    return '$_temp0';
  }

  @override
  String get partnerClaimOnApprove => 'Aprovar também vincula.';

  @override
  String get partnerClaimActiveHint =>
      'Confirme se os destaques são mesmo dele.';

  @override
  String get partnerMenu => 'Sou parceiro';

  @override
  String get partnerMenuApproved => 'Área do parceiro';

  @override
  String get partnerRequestTitle => 'Sou parceiro';

  @override
  String get partnerRequestIntro =>
      'Tem uma página, loja ou veículo de esporte na região? Peça para ser parceiro e publique notícias, destaques e publicidade no app.';

  @override
  String get partnerNameLabel => 'Nome do parceiro (página, loja, veículo)';

  @override
  String get partnerNameRequired => 'Informe o nome (mínimo de 3 letras)';

  @override
  String get partnerContactInfo =>
      'Só o admin vê o seu WhatsApp, para combinar a parceria.';

  @override
  String get partnerRequestSubmit => 'Enviar pedido';

  @override
  String get partnerRequestSent => 'Pedido enviado! O admin vai analisar.';

  @override
  String get partnerRequestCancelled => 'Pedido cancelado.';

  @override
  String get partnerPendingInfo =>
      'Seu pedido está com o admin. Você recebe um aviso quando ele responder.';

  @override
  String get partnerRejectedInfo =>
      'O admin não aprovou o pedido. Você pode corrigir e enviar de novo.';

  @override
  String get partnerRemovedInfo =>
      'O admin encerrou a sua parceria. Você pode pedir de novo.';

  @override
  String get partnerResubmit => 'Enviar de novo';

  @override
  String get partnerEdit => 'Editar pedido';

  @override
  String get partnerCancel => 'Cancelar pedido';

  @override
  String get partnerCancelTitle => 'Cancelar o pedido?';

  @override
  String partnerCancelMessage(String name) {
    return 'O pedido de $name será apagado.';
  }

  @override
  String get partnerLoadError =>
      'Não foi possível carregar os pedidos de parceiro.';

  @override
  String partnerApprovedTitle(String region) {
    return 'Parceiro em $region';
  }

  @override
  String get partnerCanPublish => 'Você pode publicar';

  @override
  String get partnerNothingAllowed =>
      'No momento o admin não liberou publicações para você.';

  @override
  String get partnerNothingAllowedShort => 'Nada liberado';

  @override
  String partnerNewsDetail(String region) {
    return 'Notícias no feed de $region';
  }

  @override
  String partnerLimitHighlights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count destaques',
      one: '1 destaque',
    );
    return '$_temp0';
  }

  @override
  String partnerLimitAds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicidades por dia',
      one: '1 publicidade por dia',
    );
    return '$_temp0';
  }

  @override
  String partnerUsageHighlights(int used, int limit) {
    return '$used de $limit destaques em uso';
  }

  @override
  String partnerUsageAds(int used, int limit) {
    return '$used de $limit publicidades hoje';
  }

  @override
  String get partnerMyHighlights => 'Meus destaques';

  @override
  String get partnerNoHighlights => 'Você ainda não publicou destaques.';

  @override
  String get partnerHighlightHidden => 'Oculto';

  @override
  String partnerHighlightDeleteTitle(String title) {
    return 'Apagar o destaque $title?';
  }

  @override
  String get partnerHighlightDeleted => 'Destaque apagado.';

  @override
  String get partnerHighlightLimit =>
      'Você já usa todos os seus destaques. Apague um para publicar outro.';

  @override
  String get partnerAdLimit => 'Você já publicou a publicidade de hoje.';

  @override
  String get partnerPanelTitle => 'Parceiros';

  @override
  String get partnerTabActive => 'Ativos';

  @override
  String get partnerPanelEmptyPending => 'Nenhum pedido de parceiro pendente.';

  @override
  String get partnerPanelEmptyActive => 'Nenhum parceiro ativo.';

  @override
  String get partnerPanelEmptyAnswered => 'Nenhum pedido respondido.';

  @override
  String partnerApproveTitle(String name) {
    return 'Aprovar $name?';
  }

  @override
  String partnerApproveMessage(String region) {
    return 'Vai publicar em $region: 3 notícias por dia (as demais passam por você), até 2 destaques e 1 publicidade por dia. Você ajusta depois em Permissões.';
  }

  @override
  String partnerApproved(String name) {
    return '$name agora é parceiro.';
  }

  @override
  String partnerRejectTitle(String name) {
    return 'Rejeitar $name?';
  }

  @override
  String get partnerRevoke => 'Remover parceiro';

  @override
  String partnerRevokeTitle(String name) {
    return 'Remover $name dos parceiros?';
  }

  @override
  String get partnerRevoked => 'Parceria encerrada.';

  @override
  String partnerRequestedBy(String name) {
    return 'Pedido de $name';
  }

  @override
  String get partnerPermissions => 'Permissões';

  @override
  String get partnerPermNews => 'Notícias';

  @override
  String get partnerPermHighlights => 'Destaques';

  @override
  String get partnerPermAds => 'Publicidade';

  @override
  String get partnerHighlightLimitLabel => 'Destaques ao mesmo tempo';

  @override
  String get partnerAdsPerDayLabel => 'Publicidades por dia';

  @override
  String get partnerPermissionsSaved => 'Permissões salvas.';

  @override
  String standingsAutomaticLegend(String criteria) {
    return 'Atualizada sozinha ao fim de cada partida. Desempate: $criteria.';
  }

  @override
  String get standingsCriterionWins => 'vitórias';

  @override
  String get standingsCriterionGoalDifference => 'saldo de gols';

  @override
  String get standingsCriterionGoalsFor => 'gols pró';

  @override
  String get standingsCriterionHeadToHead => 'confronto direto';

  @override
  String get standingsCriterionFewestGoalsAgainst => 'menos gols sofridos';

  @override
  String get championshipTiebreakTitle => 'Desempate';

  @override
  String get championshipTiebreakHint =>
      'Depois dos pontos, nesta ordem. Arraste para reordenar e desmarque o que não vale.';

  @override
  String get championshipTiebreakReset => 'Usar o padrão';

  @override
  String get championshipRecomputeTables => 'Recalcular tabelas';

  @override
  String get championshipRecomputeRequested =>
      'Recálculo pedido: as tabelas atualizam em instantes.';

  @override
  String get achievementCategoryPredictions => 'Bolão';

  @override
  String get achievementMetricPredictions => 'Palpites pontuados';

  @override
  String get achievementMetricExactPredictions => 'Placares exatos';

  @override
  String get drawerPredictions => 'Bolão';

  @override
  String get predictionAction => 'Palpitar';

  @override
  String get predictionSheetTitle => 'Seu palpite';

  @override
  String predictionRules(int exact, int diff, int winner) {
    return 'Placar exato: $exact pts · vencedor e saldo: $diff · vencedor: $winner';
  }

  @override
  String get predictionDeadline => 'Vale até o início da partida.';

  @override
  String get predictionSave => 'Salvar palpite';

  @override
  String get predictionSaved => 'Palpite salvo!';

  @override
  String get predictionClosed => 'Palpites encerrados: a partida já começou.';

  @override
  String get predictionLoginRequired => 'Entre na sua conta para palpitar.';

  @override
  String get predictionLogin => 'Entrar';

  @override
  String get predictionSectionTitle => 'Palpite';

  @override
  String get predictionNone => 'Você ainda não palpitou nesta partida.';

  @override
  String get predictionMissed => 'Você não palpitou nesta partida.';

  @override
  String get predictionEdit => 'Alterar palpite';

  @override
  String get predictionLocked => 'Travado: a partida começou.';

  @override
  String get predictionPending => 'Aguardando a pontuação.';

  @override
  String predictionPoints(int points) {
    return '+$points pts';
  }

  @override
  String get predictionExact => 'Placar exato!';

  @override
  String get predictionMiss => 'Não pontuou desta vez.';

  @override
  String get predictionLate => 'Feito depois do prazo: não vale pontos.';

  @override
  String predictionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palpites nesta partida',
      one: '1 palpite nesta partida',
      zero: 'Ninguém palpitou',
    );
    return '$_temp0';
  }

  @override
  String get predictionRankingTitle => 'Bolão';

  @override
  String get predictionHubHeroTitle => 'SEU BOLÃO';

  @override
  String get predictionHubStatPoints => 'pts';

  @override
  String get predictionHubStatExact => 'exatos';

  @override
  String get predictionHubStatPicks => 'palpites';

  @override
  String predictionHubPlace(String region) {
    return 'lugar em $region';
  }

  @override
  String predictionHubChase(int points, String name) {
    return 'Faltam $points pts para passar $name';
  }

  @override
  String get predictionHubLeader => 'Você lidera o bolão!';

  @override
  String get predictionHubNoPoints =>
      'Palpite nos jogos e dispute com a sua região!';

  @override
  String get predictionHubGuest =>
      'Entre para palpitar e disputar o ranking da sua região.';

  @override
  String get predictionHubSignIn => 'ENTRAR';

  @override
  String get predictionHubHowTitle => 'Como pontua';

  @override
  String get predictionHubExact => 'Placar exato';

  @override
  String get predictionHubWinnerDiff => 'Vencedor + saldo';

  @override
  String get predictionHubWinner => 'Só o vencedor';

  @override
  String get predictionHubTabPlay => 'Palpitar';

  @override
  String get predictionHubTabRanking => 'Ranking';

  @override
  String get predictionHubUpcoming => 'Próximos jogos';

  @override
  String get predictionHubNoUpcoming =>
      'Nenhum jogo aberto para palpite na região agora.';

  @override
  String predictionHubClosesIn(String time) {
    return 'Fecha em $time';
  }

  @override
  String get predictionHubPredict => 'PALPITAR';

  @override
  String get predictionHubYourPick => 'Seu palpite';

  @override
  String get predictionHubChange => 'Alterar';

  @override
  String get predictionHubLive => 'AO VIVO';

  @override
  String get predictionHubHalfTime => 'INTERVALO';

  @override
  String get predictionHubWaiting => 'AGUARDANDO';

  @override
  String get predictionHubClosed => 'Palpites encerrados';

  @override
  String get predictionHubRecent => 'Seus últimos palpites';

  @override
  String get predictionHubRecentEmpty =>
      'Os seus palpites dos jogos encerrados aparecem aqui.';

  @override
  String get predictionHubPending => 'Aguardando apuração';

  @override
  String get predictionHubExactChip => 'Exato';

  @override
  String predictionHubYouSaid(int home, int away) {
    return 'Você: $home × $away';
  }

  @override
  String predictionHubHitRate(int percent) {
    return '$percent% de aproveitamento';
  }

  @override
  String get predictionHubChallenge => 'Desafiar amigos';

  @override
  String predictionHubChallengeText(int position, String region, String link) {
    return 'Tô em $positionº no bolão do Arena Football em $region! Vem palpitar e tenta me passar ⚽\n$link';
  }

  @override
  String predictionHubChallengeTextNoRank(String region, String link) {
    return 'Vem palpitar comigo no bolão do Arena Football em $region! ⚽\n$link';
  }

  @override
  String get predictionHubPredictors => 'Palpiteiros';

  @override
  String get predictionRankingEmpty =>
      'Ninguém pontuou ainda nesta região. Palpite nas próximas partidas!';

  @override
  String get predictionRankingError =>
      'Não foi possível carregar o ranking do bolão.';

  @override
  String get predictionRankingYou => 'Sua posição';

  @override
  String get predictionRankingNotRanked =>
      'Você ainda não pontuou. Palpite nas partidas!';

  @override
  String predictionRankingPoints(int points) {
    return '$points pts';
  }

  @override
  String predictionRankingStats(int exact, int count) {
    return '$exact exatos · $count palpites';
  }

  @override
  String get drawerFanSection => 'Torcida';

  @override
  String get drawerOnFieldSection => 'Em campo';

  @override
  String get drawerPlayerHint => 'Peça para jogar num time';

  @override
  String get drawerPlayerHintApproved => 'Seu perfil e seus números';

  @override
  String get drawerOwnerHint => 'Cadastre e gerencie seu time';

  @override
  String get drawerOwnerHintApproved => 'Elenco, pedidos e escudo';

  @override
  String get drawerPartnerHint => 'Publique na sua região';

  @override
  String get drawerPartnerHintApproved => 'Suas publicações e vagas';

  @override
  String get drawerOrganizerHint => 'Monte o seu campeonato';

  @override
  String get pushActionAchievement => 'Conquista desbloqueada';

  @override
  String get pushActionAchievementHint => 'Para quem ganhou · medalha e XP';

  @override
  String get pushActionAlbumPack => 'Pacotinho liberado';

  @override
  String get pushActionAlbumPackHint =>
      'Para quem coleciona · 24 h depois do último pacote';

  @override
  String get achievementUnlockedTitle => 'CONQUISTA DESBLOQUEADA!';

  @override
  String get achievementSeeAll => 'Ver conquistas';

  @override
  String get achievementCelebrationClose => 'Continuar';

  @override
  String get matchClockFirstHalf => '1º TEMPO';

  @override
  String get matchClockSecondHalf => '2º TEMPO';

  @override
  String get matchClockHalfTime => 'INTERVALO';

  @override
  String get matchHalfTime => 'Intervalo';

  @override
  String get matchStartSecondHalf => 'Iniciar 2º tempo';

  @override
  String get voteCallBadge => 'VOTE NO CRAQUE';

  @override
  String get voteCallClosedBadge => 'VOTAÇÃO ENCERRADA';

  @override
  String get voteCallAction => 'Votar agora';

  @override
  String get voteCallResult => 'Ver resultado';

  @override
  String get voteClosedTitle => 'Resultado disponível';

  @override
  String voteClosedText(String home, String away) {
    return 'Confira quem foi eleito o craque de $home × $away.';
  }

  @override
  String get voteClosedBestPlayer => 'CRAQUE DA PARTIDA';

  @override
  String voteClosedVotes(int votes, int percent) {
    return '$votes votos · $percent%';
  }

  @override
  String get voteClosedNoWinner => 'Sem craque eleito';

  @override
  String get voteClosedNoWinnerText =>
      'A votação não atingiu o mínimo de votos para eleger o craque.';

  @override
  String get resultCardFullTime => 'FIM DE JOGO';

  @override
  String get resultCardFriendly => 'Amistoso';

  @override
  String get resultCardSeeMatch => 'Ver partida';

  @override
  String get athleteStatsFriendly => 'Amistosos';

  @override
  String get athleteStatsFriendlyHint =>
      'Ajusta os amistosos (contagem à parte, fora do geral).';

  @override
  String get athleteStatsTotalSumHint =>
      'O geral é a soma das competições: ajuste na aba da competição.';

  @override
  String get teamPlayersFriendly => 'Amistosos';

  @override
  String get seasonsRepairTotals => 'Corrigir números dos atletas';

  @override
  String get seasonsRepairTotalsHint =>
      'O geral de cada atleta volta a ser a soma das competições, e os gols de amistosos (partidas sem competição) passam a ser contados à parte. Pode rodar de novo.';

  @override
  String seasonsRepairTotalsDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atletas corrigidos',
      one: '1 atleta corrigido',
      zero: 'Nenhum atleta precisou de correção',
    );
    return '$_temp0';
  }

  @override
  String get matchCardFinished => 'ENCERRADA';

  @override
  String get matchCardLiveShort => 'AO VIVO';

  @override
  String get matchCardHalfTimeShort => 'INT';

  @override
  String get matchCardFinishedShort => 'FIM';

  @override
  String get achievementsAlmostThere => 'QUASE LÁ';

  @override
  String get achievementsSeeAll => 'Ver todas';

  @override
  String get achievementsStatMedals => 'medalhas';

  @override
  String get achievementsStatXp => 'XP';

  @override
  String get achievementsStatStreak => 'dias seguidos';

  @override
  String get drawerAchievements => 'Minhas conquistas';

  @override
  String get achievementsTitle => 'Minhas conquistas';

  @override
  String achievementsXp(int xp) {
    return '$xp XP';
  }

  @override
  String achievementsNextLevel(int left, String level) {
    return 'Faltam $left XP para $level';
  }

  @override
  String get achievementsMaxLevel => 'Nível máximo alcançado!';

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked de $total conquistas';
  }

  @override
  String get achievementsRecent => 'Recentes';

  @override
  String get achievementsAll => 'Todas';

  @override
  String get achievementsEmpty => 'Nenhuma conquista por aqui ainda';

  @override
  String get achievementsSecret => 'Conquista secreta';

  @override
  String get achievementsSecretHint => 'Continue usando o app para descobrir.';

  @override
  String achievementsUnlockedOn(String date) {
    return 'Conquistada em $date';
  }

  @override
  String get achievementsUnlocked => 'Conquistada!';

  @override
  String achievementsProgress(int current, int goal) {
    return '$current de $goal';
  }

  @override
  String achievementsPoints(int points) {
    return '+$points XP';
  }

  @override
  String get achievementCategoryFan => 'Torcida';

  @override
  String get achievementCategoryVoting => 'Votação';

  @override
  String get achievementCategorySharing => 'Compartilhar';

  @override
  String get achievementCategoryNews => 'Notícias';

  @override
  String get achievementCategoryAthlete => 'Atleta';

  @override
  String get achievementTierBronze => 'Bronze';

  @override
  String get achievementTierSilver => 'Prata';

  @override
  String get achievementTierGold => 'Ouro';

  @override
  String get achievementTierLegend => 'Lenda';

  @override
  String get fanLevelFan => 'Torcedor';

  @override
  String get fanLevelLoyal => 'Fiel';

  @override
  String get fanLevelRoots => 'Raiz';

  @override
  String get fanLevelUltra => 'Ultra';

  @override
  String get fanLevelLegend => 'Lenda';

  @override
  String get achievementMetricVotes => 'Votos em partidas';

  @override
  String get achievementMetricShares => 'Compartilhamentos';

  @override
  String get achievementMetricNewsRead => 'Notícias lidas';

  @override
  String get achievementMetricActiveDays => 'Dias de uso';

  @override
  String get achievementMetricBestStreak => 'Dias seguidos (maior sequência)';

  @override
  String get achievementMetricFavoriteTeam => 'Escolheu o time do coração';

  @override
  String get achievementMetricCardPhoto => 'Foto na carteirinha';

  @override
  String get achievementMetricAthlete => 'Conta ligada a atleta';

  @override
  String get achievementMetricAthleteGoals => 'Gols do atleta (temporada)';

  @override
  String get achievementMetricAthleteAssists =>
      'Assistências do atleta (temporada)';

  @override
  String get achievementMetricTeamOwner => 'Dono de time aprovado';

  @override
  String get achievementsManageTitle => 'Conquistas';

  @override
  String get achievementsNew => 'Nova conquista';

  @override
  String get achievementsEdit => 'Editar conquista';

  @override
  String get achievementsCreateSuggested => 'Criar conquistas sugeridas';

  @override
  String get achievementsSuggestedCreated => 'Conquistas sugeridas criadas';

  @override
  String get achievementsManageEmpty => 'Nenhuma conquista cadastrada';

  @override
  String get achievementFieldTitle => 'Título';

  @override
  String get achievementFieldDescription => 'Descrição (como ganhar)';

  @override
  String get achievementFieldCategory => 'Categoria';

  @override
  String get achievementFieldTier => 'Nível da medalha';

  @override
  String get achievementFieldIcon => 'Ícone';

  @override
  String get achievementFieldMetric => 'O que conta';

  @override
  String get achievementFieldGoal => 'Meta';

  @override
  String get achievementFieldPoints => 'Pontos (XP)';

  @override
  String get achievementFieldSecret => 'Secreta (bloqueada aparece como ?)';

  @override
  String get achievementFieldActive => 'Ativa';

  @override
  String get achievementSave => 'Salvar conquista';

  @override
  String get achievementSaved => 'Conquista salva';

  @override
  String achievementDeleteConfirm(String title) {
    return 'Excluir a conquista \"$title\"?';
  }

  @override
  String get achievementDeleted => 'Conquista excluída';

  @override
  String get achievementTitleRequired => 'Informe o título';

  @override
  String get achievementInactive => 'Inativa';

  @override
  String get achievementPreview => 'Prévia';

  @override
  String get matchDetailsVotingEnded => 'Votação encerrada';

  @override
  String get votingNoWinnerTitle => 'Sem melhor da partida';

  @override
  String votingNoWinnerNotEnough(int min, int total) {
    return 'Mínimo de $min votos não atingido ($total votos).';
  }

  @override
  String votingNoWinnerNoMajority(int percent, int leader) {
    return 'Ninguém chegou a $percent% dos votos (o mais votado teve $leader%).';
  }

  @override
  String get votingNoWinnerTie => 'Empate no primeiro lugar.';

  @override
  String votingRulesHint(int min, int percent) {
    return 'Para eleger o melhor da partida: no mínimo $min votos e o mais votado com $percent% ou mais, à frente do segundo.';
  }

  @override
  String get votingSelfBlocked => 'Você não pode votar em si';

  @override
  String get votingSeeResult => 'Ver resultado';

  @override
  String get votingRulesTitle => 'Regras da votação';

  @override
  String get votingRulesSubtitle =>
      'Mínimo de votos e porcentagem do mais votado';

  @override
  String get votingRulesMinVotes => 'Mínimo de votos';

  @override
  String get votingRulesMinPercent => 'Porcentagem mínima do mais votado';

  @override
  String get votingRulesSave => 'Salvar regras';

  @override
  String get votingRulesSaved => 'Regras da votação salvas';

  @override
  String get matchCardLive => 'EM ANDAMENTO';

  @override
  String get matchStart => 'Iniciar partida';

  @override
  String get matchFinish => 'Encerrar partida';

  @override
  String get matchFormDuration => 'Duração';

  @override
  String matchFormDurationMinutes(int n) {
    return '$n min';
  }

  @override
  String get matchDetailsTitle => 'Partida';

  @override
  String get matchDetailsFinished => 'ENCERRADO';

  @override
  String get matchDetailsNoScorers => 'Autores dos gols não informados';

  @override
  String get matchDetailsNotStarted => 'A bola ainda não rolou';

  @override
  String get matchDetailsNoGoals => 'Sem gols';

  @override
  String get matchDetailsUnknownScorer => 'Gol';

  @override
  String get matchDetailsBestPlayer => 'Melhor da partida';

  @override
  String matchDetailsVotes(String count) {
    return '$count votos';
  }

  @override
  String get matchDetailsVotingOpen =>
      'Votação aberta: escolha o craque do jogo';

  @override
  String get matchDetailsVotingClosed => 'Votação ainda não aberta';

  @override
  String get matchDetailsSquads => 'Elencos';

  @override
  String get matchPitchTitle => 'Escalações';

  @override
  String get matchPitchSubbedIn => 'Entrou';

  @override
  String get matchDetailsNoSquad => 'Nenhum atleta inscrito';

  @override
  String get matchDetailsGoalCard => 'Lançar card de gol';

  @override
  String get matchDetailsDeleted => 'Esta partida foi excluída';

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
  String get matchFormSavedOffline =>
      'Sem conexão: a partida foi salva no aparelho e será enviada quando a internet voltar.';

  @override
  String get matchFormDuplicateTitle => 'Partida repetida?';

  @override
  String matchFormDuplicateMessage(
      String home, String away, String date, String time) {
    return 'Já existe $home × $away em $date às $time. Cadastrar mesmo assim?';
  }

  @override
  String get matchFormDuplicateConfirm => 'Cadastrar mesmo assim';

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
  String get loginWelcomeTitle => 'Bem-vindo de volta';

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
  String get loginWithAppleButton => 'ENTRAR COM APPLE';

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
  String get chooseTeamKeepCurrent => 'Manter meu time atual';

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
  String get adminPanelTitle => 'Painel do admin';

  @override
  String get adminPanelContent => 'Conteúdo';

  @override
  String get adminPanelCompetition => 'Competição';

  @override
  String get adminPanelSettings => 'Configurações';

  @override
  String get drawerClose => 'Fechar menu';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAccountSection => 'Conta';

  @override
  String get profileTitle => 'Meu perfil';

  @override
  String get profileMenu => 'Editar perfil';

  @override
  String get profileNameLabel => 'Nome';

  @override
  String profileNameTooLong(int max) {
    return 'O nome pode ter no máximo $max caracteres';
  }

  @override
  String get profileNameSaved => 'Nome atualizado!';

  @override
  String get profileEmailLabel => 'E-mail';

  @override
  String get profileFavoriteTeam => 'Time do coração';

  @override
  String get profileNoTeam => 'Nenhum time escolhido';

  @override
  String get profilePhotoHint =>
      'Sua foto aparece no menu e na carteirinha de torcedor.';

  @override
  String get profileAccountSection => 'Dados da conta';

  @override
  String get profileEmailLocked => 'Não é possível alterar o e-mail';

  @override
  String get profileChangeTeam => 'Trocar';

  @override
  String get drawerAdmin => 'Administração';

  @override
  String get drawerLogout => 'Sair da conta';

  @override
  String get drawerDeleteAccount => 'Excluir conta';

  @override
  String get deleteAccountTitle => 'Excluir sua conta?';

  @override
  String get deleteAccountMessage =>
      'Apagamos a sua conta de login, o seu perfil (nome, e-mail, foto e time do coração), os seus votos e os seus pedidos de jogador ou de dono de time. Se você joga num time, os seus gols e assistências continuam no elenco, sem vínculo com a conta. Não dá para desfazer.';

  @override
  String get deleteAccountConfirmPassword =>
      'Digite a sua senha para confirmar.';

  @override
  String get deleteAccountConfirmGoogle =>
      'Para confirmar, entre de novo com a sua conta Google.';

  @override
  String get deleteAccountConfirmApple =>
      'Para confirmar, entre de novo com a sua conta Apple.';

  @override
  String get deleteAccountPasswordRequired => 'Digite a sua senha.';

  @override
  String get deleteAccountButton => 'EXCLUIR CONTA';

  @override
  String get deleteAccountSuccess => 'Sua conta foi excluída.';

  @override
  String get drawerChooseTeam => 'Escolher meu time';

  @override
  String get drawerSignIn => 'Entrar ou criar conta';

  @override
  String get drawerGuestSubtitle =>
      'Entre para salvar seu time e votar no melhor da partida.';

  @override
  String homeGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String get homeGreetingGuest => 'Bem-vindo ao Arena';

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
  String get enrollTeamMenu => 'Inscrever em competição';

  @override
  String get enrollTeamTitle => 'Competições do time';

  @override
  String enrollTeamSubtitle(String team) {
    return 'Marque as competições da temporada em que o $team joga. Os atletas são inscritos um a um.';
  }

  @override
  String get enrollNoChampionships => 'Nenhuma competição na temporada.';

  @override
  String get enrollSaved => 'Inscrições salvas.';

  @override
  String get enrollLoadError => 'Não foi possível carregar as competições.';

  @override
  String get enrollPlayerTitle => 'Competições do atleta';

  @override
  String get linkPlayerMenu => 'Vincular atleta';

  @override
  String get linkPlayerToTeamMenu => 'Vincular a time/competição';

  @override
  String linkPlayerSearchTitle(String team) {
    return 'Vincular atleta ao $team';
  }

  @override
  String get linkPlayerSearchHint => 'Buscar atleta pelo nome';

  @override
  String get linkPlayerNoTeam => 'Sem time';

  @override
  String get linkPlayerHasAccount => 'com conta';

  @override
  String get linkPlayerEmpty => 'Nenhum atleta encontrado.';

  @override
  String linkPlayerFilterAll(int count) {
    return 'Todos ($count)';
  }

  @override
  String linkPlayerFilterAccount(int count) {
    return 'Com conta ($count)';
  }

  @override
  String linkPlayerFilterNoAccount(int count) {
    return 'Sem conta ($count)';
  }

  @override
  String linkPlayerShowing(int shown, int total) {
    return 'Mostrando $shown de $total';
  }

  @override
  String linkPlayerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atletas',
      one: '1 atleta',
    );
    return '$_temp0';
  }

  @override
  String get linkPlayerLoadMore => 'Carregar mais';

  @override
  String linkPlayerOptionsTitle(String player, String team) {
    return 'Vincular $player ao $team';
  }

  @override
  String get linkPlayerOptionsHint =>
      'Escolha as competições em que ele vai jogar pelo time. Sem nenhuma, ele entra no elenco geral com este como time principal.';

  @override
  String get linkPlayerMakeMain => 'Tornar time principal';

  @override
  String get linkPlayerMakeMainHint =>
      'O time que aparece no perfil do atleta e no ranking geral.';

  @override
  String get linkPlayerAlready => 'Já joga por este time';

  @override
  String get linkPlayerTransfer => 'Transferir';

  @override
  String get linkPlayerTransferTitle => 'Confirmar transferência?';

  @override
  String linkPlayerTransferMessage(String player, String championships) {
    return '$player deixa de jogar pelo time antigo em: $championships. Os números dele nessas competições continuam.';
  }

  @override
  String get linkPlayerSave => 'VINCULAR';

  @override
  String linkPlayerDone(String player, String team) {
    return '$player vinculado ao $team!';
  }

  @override
  String get linkPlayerPickTeam => 'Escolha o time';

  @override
  String get linkPlayerNoChampionships =>
      'O time não está inscrito em nenhuma competição da temporada: o atleta entra no elenco geral.';

  @override
  String enrollPlayerSubtitle(String name, String team) {
    return 'Em quais competições $name joga pelo $team?';
  }

  @override
  String enrollPlayerOtherTeam(String team) {
    return 'Joga pelo $team nesta competição';
  }

  @override
  String enrollPlayerSaved(String name) {
    return 'Inscrições de $name salvas.';
  }

  @override
  String get playersGeneralSquad => 'Elenco geral';

  @override
  String get playersEmptyChampionship =>
      'Nenhum atleta deste time nesta competição.';

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
  String get standingsColGoalDiff => 'SG';

  @override
  String get standingsColPoints => 'PTS';

  @override
  String groupsTeamsCount(int count) {
    return '$count times';
  }

  @override
  String groupsGamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jogos',
      one: '1 jogo',
      zero: '0 jogos',
    );
    return '$_temp0';
  }

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
  String get standingsLeader => 'Líder';

  @override
  String get standingsNoGamesYet => 'A bola ainda não rolou neste grupo';

  @override
  String standingsGoalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gols',
      one: '1 gol',
      zero: '0 gols',
    );
    return '$_temp0';
  }

  @override
  String standingsRecord(int wins, int draws, int losses) {
    return '${wins}V ${draws}E ${losses}D';
  }

  @override
  String get athletePlaysFor => 'Atua por';

  @override
  String athleteChampionshipFallback(int id) {
    return 'Competição $id';
  }

  @override
  String athleteEnrollmentStats(int goals, int assists) {
    return '$goals G · $assists A';
  }

  @override
  String get athleteStatsTotal => 'Total';

  @override
  String get athleteStatsTotalHint =>
      'Ajusta só o total (números de antes das competições).';

  @override
  String get athleteStatsChampionshipHint =>
      'Ajusta a competição; o total acompanha.';

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
  String athleteClaimTitle(String name) {
    return 'É você, $name?';
  }

  @override
  String get athleteClaimHint =>
      'Peça para vincular este cadastro à sua conta: os gols e as assistências dele passam a ser seus.';

  @override
  String get athleteClaimAction => 'Sou eu, pedir vínculo';

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
  String get playerRequestClaimTitle => 'Já está no elenco?';

  @override
  String get playerRequestClaimHint =>
      'Estes atletas do time ainda não têm conta. Se um deles é você, toque nele para pedir o vínculo e ficar com os seus números.';

  @override
  String get playerRequestClaimNotListed =>
      'Não está na lista? Preencha abaixo como jogador novo.';

  @override
  String playerRequestClaimSelected(String name) {
    return 'Você vai pedir o vínculo com o atleta $name.';
  }

  @override
  String playerRequestClaimStatus(String name) {
    return 'Pedido de vínculo com o atleta $name';
  }

  @override
  String playerRequestsClaimBadge(String name, int goals) {
    return 'Diz ser o atleta $name · $goals gols';
  }

  @override
  String playerRequestsApproveClaimMessage(String name) {
    return 'A conta será ligada ao atleta $name, que mantém os gols e as assistências.';
  }

  @override
  String get playerRequestClaimPlaceholder =>
      'Sou um destes atletas (opcional)';

  @override
  String get playerRequestClaimSearch => 'Buscar pelo nome';

  @override
  String get playerRequestClaimNoResults => 'Nenhum atleta com esse nome';

  @override
  String playerRequestClaimGoals(int goals) {
    return '$goals gols';
  }

  @override
  String get playerRequestChampionshipLabel => 'Competição';

  @override
  String get playerRequestChampionshipChoose => 'Escolha a competição';

  @override
  String get playerRequestChampionshipRequired =>
      'Escolha a competição em que você joga por esse time.';

  @override
  String get playerRequestAnotherChampionship => 'Jogar em outra competição';

  @override
  String get playerRequestIntro =>
      'Jogue pelo seu time da região: envie a solicitação e um administrador vai analisar.';

  @override
  String get playerRequestTeamRequired => 'Escolha o time em que você joga.';

  @override
  String get playerRequestOwnPlayerTitle => 'Seu cadastro de atleta';

  @override
  String get playerRequestOwnPlayerMessage =>
      'O pedido usa o seu cadastro: seus números continuam.';

  @override
  String get playerRequestSameNameHeader => 'Atleta encontrado';

  @override
  String playerRequestSameNameTitle(String name, String team) {
    return 'Você é o $name do $team?';
  }

  @override
  String get playerRequestSameNameMessage =>
      'Já existe um atleta com o seu nome neste elenco, ainda sem conta. Se for você, o pedido liga a sua conta a ele e os números dele continuam.';

  @override
  String get playerRequestSameNameMergeMessage =>
      'Já existe um atleta com o seu nome neste elenco, ainda sem conta. Se for você, o admin junta esse cadastro com o seu e os números somam.';

  @override
  String playerRequestOwnPlayerClaimed(String name) {
    return 'Você disse ser o $name do elenco: o admin junta os dois cadastros na aprovação.';
  }

  @override
  String get playerRequestSameNameYes => 'Sou eu';

  @override
  String get playerRequestSameNameNo => 'Não sou eu';

  @override
  String playerRequestPlayerNumbers(int goals, int assists) {
    return '$goals gols · $assists assist.';
  }

  @override
  String get playerRequestNameTooLong => 'Use até 40 letras no nome';

  @override
  String get playerRequestNoTeams =>
      'Nenhum time disponível nesta região para a competição escolhida';

  @override
  String get playerRequestChampionshipsError =>
      'Não foi possível carregar as competições da região';

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
  String get playerPositionDefensiveMidfielder => 'Volante';

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
  String get rejectReasonMessage =>
      'O motivo é opcional e aparece para quem fez o pedido.';

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
  String get championshipScopeMunicipal => 'Municipal';

  @override
  String get championshipScopeIntermunicipal => 'Intermunicipal';

  @override
  String championshipScopeMunicipalHint(String region) {
    return 'Só times de $region.';
  }

  @override
  String get championshipScopeIntermunicipalHint =>
      'Times de qualquer região. O campeonato aparece em todas as regiões dos times.';

  @override
  String championshipScopeRemoved(int count, String region) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times de fora de $region saíram da seleção.',
      one: '1 time de fora de $region saiu da seleção.',
    );
    return '$_temp0';
  }

  @override
  String championshipScopeOutsideError(String region) {
    return 'Campeonato municipal só aceita times de $region.';
  }

  @override
  String get championshipScopeNoRegion => 'Sem região';

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
  String get championshipClosedBadge => 'ENCERRADA';

  @override
  String get championshipClose => 'Encerrar competição';

  @override
  String get championshipReopen => 'Reabrir competição';

  @override
  String championshipCloseTitle(String title) {
    return 'Encerrar $title';
  }

  @override
  String get championshipCloseHint =>
      'Escolha o campeão (e o vice, se quiser). Encerrada, ninguém cria partidas nem inscreve times ou atletas nela; as partidas que já existem continuam editáveis.';

  @override
  String get championshipCloseNoTeams =>
      'A competição não tem times inscritos.';

  @override
  String get championshipChampionLabel => 'Campeão';

  @override
  String get championshipRunnerUpLabel => 'Vice';

  @override
  String get championshipCloseConfirm => 'ENCERRAR';

  @override
  String championshipClosedDone(String team) {
    return 'Competição encerrada! $team é o campeão.';
  }

  @override
  String get championshipReopenTitle => 'Reabrir a competição?';

  @override
  String get championshipReopenMessage =>
      'O campeão sai e o card de campeão some do feed. Partidas e inscrições voltam a ser liberadas.';

  @override
  String get championshipReopenDone => 'Competição reaberta.';

  @override
  String get championshipChampionTitle => 'CAMPEÃO';

  @override
  String championshipRunnerUp(String team) {
    return 'Vice: $team';
  }

  @override
  String championshipClosedChip(String team) {
    return 'Encerrada · $team';
  }

  @override
  String get championshipClosedShort => 'Encerrada';

  @override
  String championCardSeason(String season) {
    return 'Temporada $season';
  }

  @override
  String get championCardAction => 'Ver competição';

  @override
  String get championshipsPrevious => 'Anteriores';

  @override
  String get championshipTabOverview => 'Visão geral';

  @override
  String get championshipTabMatches => 'Jogos';

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
  String get matchFormNoChampionship => 'Sem campeonato (amistoso)';

  @override
  String get matchFormNoChampionshipHint =>
      'Nenhum campeonato na região nesta temporada; cadastre em Painel do admin → Campeonatos.';

  @override
  String get matchFormPickChampionship => 'Campeonato da partida';

  @override
  String get matchFormChampionshipSearch => 'Buscar campeonato';

  @override
  String get matchFormChampionshipNoResults =>
      'Nenhum campeonato com esse nome';

  @override
  String get matchFormChampionship => 'Campeonato';

  @override
  String get matchRoundTitle => 'Fase';

  @override
  String get matchRoundPick => 'Fase da partida';

  @override
  String get matchRoundNone => 'Sem fase definida';

  @override
  String get matchRoundGroupsSection =>
      'Fase de grupos · conta na tabela do grupo';

  @override
  String get matchRoundKnockoutSection => 'Mata-mata · não conta na tabela';

  @override
  String matchRoundGroup(String name) {
    return 'Grupo $name';
  }

  @override
  String get matchRoundSuggested =>
      'Sugerido pelos times: os dois estão nesse grupo.';

  @override
  String matchRoundMismatch(String group) {
    return 'Os times não estão no $group: a partida não vai contar na tabela.';
  }

  @override
  String get matchStageRoundOf16 => 'Oitavas de final';

  @override
  String get matchStageQuarterFinal => 'Quartas de final';

  @override
  String get matchStageSemiFinal => 'Semifinal';

  @override
  String get matchStageThirdPlace => 'Disputa de 3º lugar';

  @override
  String get matchStageFinal => 'Final';

  @override
  String get matchStageOther => 'Outra fase (mata-mata)';

  @override
  String get matchStageBadgeRoundOf16 => 'OITAVAS';

  @override
  String get matchStageBadgeQuarterFinal => 'QUARTAS';

  @override
  String get matchStageBadgeSemiFinal => 'SEMIFINAL';

  @override
  String get matchStageBadgeThirdPlace => '3º LUGAR';

  @override
  String get matchStageBadgeFinal => 'FINAL';

  @override
  String get matchStageBadgeOther => 'MATA-MATA';

  @override
  String get matchdayTitle => 'Rodada';

  @override
  String get matchdayNone => 'Sem rodada';

  @override
  String matchdayValue(int number) {
    return '$numberª rodada';
  }

  @override
  String matchdayBadge(int number) {
    return 'RODADA $number';
  }

  @override
  String get matchdaySuggested =>
      'Rodada sugerida pelos jogos da competição perto dessa data.';

  @override
  String get matchdayLess => 'Rodada anterior';

  @override
  String get matchdayMore => 'Próxima rodada';

  @override
  String get fantasyTitle => 'Arena Fantasy';

  @override
  String get fantasyActive => 'Fantasy ativado';

  @override
  String get fantasyActiveOn =>
      'Torcedores podem entrar e montar o time nas rodadas abertas deste campeonato.';

  @override
  String get fantasyActiveOff =>
      'Desligado: ninguém entra nem troca a escalação. Nada é apagado (histórico e pontos ficam).';

  @override
  String fantasyParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
    );
    return '$_temp0';
  }

  @override
  String get fantasyParams => 'Pontuação';

  @override
  String get fantasyMinMinutes => 'Mínimo para pontuar';

  @override
  String get fantasyMinMinutesHint =>
      'Abaixo disso o atleta não pontua na rodada.';

  @override
  String get fantasyDefenseMinutes => 'Mínimo para o bônus defensivo';

  @override
  String get fantasyDefenseMinutesHint =>
      'Jogo sem sofrer gols só vale com esse tempo em campo.';

  @override
  String get fantasyCaptain => 'Multiplicador do capitão';

  @override
  String get fantasyCaptainHint => 'Vale também para pontuação negativa.';

  @override
  String fantasyMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get fantasyRestoreDefaults =>
      'Restaurar padrões (20 min · 45 min · 1,5×)';

  @override
  String get fantasyParamsNote =>
      'Os parâmetros valem para as próximas rodadas: cada rodada guarda os seus ao fechar, e rodadas fechadas não mudam.';

  @override
  String get fantasySave => 'Salvar';

  @override
  String get fantasySaved => 'Arena Fantasy salvo.';

  @override
  String get fantasySaveError => 'Não foi possível salvar o Arena Fantasy.';

  @override
  String get fantasyErrorRange => 'Os minutos vão de 0 a 120.';

  @override
  String get fantasyErrorDefenseBelowMin =>
      'O mínimo do bônus defensivo não pode ser menor que o mínimo para pontuar.';

  @override
  String get fantasyErrorCaptain => 'O capitão vai de 1× a 3×.';

  @override
  String get fantasySlotGoalkeeper => 'GOL';

  @override
  String get fantasySlotDefender => 'ZAG';

  @override
  String get fantasySlotMidfielder => 'MEI';

  @override
  String get fantasySlotForward => 'ATA';

  @override
  String get fantasySlotFlex => 'LIVRE';

  @override
  String get fantasyPickGoalkeeper => 'Escolha o goleiro';

  @override
  String get fantasyPickDefender => 'Escolha o zagueiro';

  @override
  String get fantasyPickMidfielder => 'Escolha o meio-campista';

  @override
  String get fantasyPickForward => 'Escolha o atacante';

  @override
  String get fantasyPickFlex => 'Escolha o atleta da vaga livre';

  @override
  String get fantasyRoundLocked => 'Travada';

  @override
  String fantasyClosesIn(String time) {
    return 'Fecha em $time';
  }

  @override
  String get fantasyCaptainShort => 'C';

  @override
  String get fantasyFilterTeam => 'Filtrar por time';

  @override
  String get fantasySearchAthlete => 'Buscar atleta';

  @override
  String get fantasyFilterAll => 'Todos';

  @override
  String get fantasyFilterAllTeams => 'Todos os times';

  @override
  String get fantasyNoAthletes => 'Nenhum atleta inscrito nessa posição.';

  @override
  String get fantasyInLineup => 'na escalação';

  @override
  String fantasyAthleteStats(int goals, int assists) {
    return '$goals G · $assists A';
  }

  @override
  String get fantasySwapAthlete => 'Trocar atleta';

  @override
  String get fantasyMakeCaptain => 'Tornar capitão';

  @override
  String get fantasyRemoveAthlete => 'Tirar da escalação';

  @override
  String fantasyErrorIncomplete(int count) {
    return 'Preencha as $count vagas.';
  }

  @override
  String get fantasyErrorCaptainMissing =>
      'Escolha o capitão: toque no \"C\" de um atleta.';

  @override
  String get fantasyErrorDuplicate =>
      'O mesmo atleta não pode ocupar duas vagas.';

  @override
  String get fantasyErrorPosition =>
      'Algum atleta está fora da posição da vaga.';

  @override
  String get fantasyJoined => 'Você entrou no Arena Fantasy!';

  @override
  String get fantasyLineupSaved => 'Escalação confirmada.';

  @override
  String get fantasyLineupSaveError => 'Não foi possível salvar a escalação.';

  @override
  String get fantasyConfirmLineup => 'Confirmar escalação';

  @override
  String get fantasyInactive =>
      'O Arena Fantasy deste campeonato está desligado.';

  @override
  String get fantasyGuest => 'Entre na sua conta para jogar o Arena Fantasy.';

  @override
  String get fantasyNoOpenRound =>
      'Nenhuma rodada aberta agora. A próxima abre quando as partidas da rodada forem cadastradas.';

  @override
  String get fantasyNoOpenRoundShort => 'Sem rodada';

  @override
  String get fantasyCopiedLineup =>
      'Escalação copiada da rodada anterior. Troque o que quiser até o prazo.';

  @override
  String get fantasyLockedNotice =>
      'Prazo encerrado: a escalação desta rodada está travada.';

  @override
  String fantasyCaptainTip(String mult) {
    return 'Toque no \"C\" para escolher o capitão: ele pontua $mult.';
  }

  @override
  String get fantasyDiscard => 'Desfazer alterações';

  @override
  String fantasyRoundTitle(int number) {
    return 'Rodada $number';
  }

  @override
  String get fantasyJoinTitle => 'Monte seu time no Arena Fantasy';

  @override
  String fantasyJoinText(int count) {
    return 'Escolha $count atletas do campeonato e um capitão. Eles pontuam pelo desempenho real nas partidas. Você joga a partir da próxima rodada aberta.';
  }

  @override
  String get fantasyJoin => 'Entrar no Arena Fantasy';

  @override
  String get fantasyEntrySubtitle =>
      'Monte seu time com os atletas do campeonato';

  @override
  String fantasyEntryRound(int number) {
    return 'Rodada $number aberta · monte seu time';
  }

  @override
  String get fantasyEntryAction => 'Jogar';

  @override
  String get fantasyBadgePlay => 'Escalar!';

  @override
  String get fantasyBadgeIdle => 'Fantasy';

  @override
  String fantasyBadgeRoundOpen(int number) {
    return 'Rodada $number aberta';
  }

  @override
  String get fantasyBadgeNoRound => 'Sem rodada aberta';

  @override
  String get fantasyRankingTitle => 'Ranking do Fantasy';

  @override
  String get fantasyTabRound => 'Rodada';

  @override
  String get fantasyTabOverall => 'Geral';

  @override
  String get fantasyTabHistory => 'Histórico';

  @override
  String get fantasyNoClosedRound =>
      'Nenhuma rodada fechada ainda. O ranking da rodada aparece depois do prazo.';

  @override
  String get fantasyRoundPartial => 'Parcial: ainda há partidas da rodada';

  @override
  String get fantasyAwaitingScore => 'Aguardando apuração';

  @override
  String get fantasyRankingEmpty => 'Ninguém pontuou ainda.';

  @override
  String get fantasyNotPlayedRound => 'Você não escalou nesta rodada.';

  @override
  String get fantasyNotJoined =>
      'Você ainda não entrou no Arena Fantasy deste campeonato.';

  @override
  String get fantasyHistoryEmpty => 'Você ainda não jogou nenhuma rodada.';

  @override
  String get fantasyMyPosition => 'Sua posição';

  @override
  String get fantasyChampionTitle => 'CAMPEÃO DO ARENA FANTASY';

  @override
  String get fantasyChampionsTitle => 'CAMPEÕES DO ARENA FANTASY';

  @override
  String fantasyPointsValue(String points) {
    return '$points pts';
  }

  @override
  String get fantasyUnknownAthlete => 'Atleta';

  @override
  String get fantasyMyTotal => 'Seu total no Fantasy';

  @override
  String get fantasySeeRanking => 'Ver ranking';

  @override
  String get fantasyFollowTitle => 'Acompanhar';

  @override
  String get fantasyFollowRounds => 'Rodadas e apuração';

  @override
  String get fantasyFollowParticipants => 'Participantes';

  @override
  String get fantasyAdminRounds => 'Rodadas';

  @override
  String get fantasyAdminParticipants => 'Participantes';

  @override
  String get fantasyAdminNoRounds =>
      'Nenhuma rodada ainda. Marque a rodada nas partidas do campeonato.';

  @override
  String get fantasyAdminNoParticipants => 'Ninguém entrou ainda.';

  @override
  String get fantasyAdminNoLineups => 'Sem escalação em rodada fechada.';

  @override
  String get fantasyStatusOpen => 'ABERTA';

  @override
  String get fantasyStatusClosed => 'FECHADA';

  @override
  String get fantasyStatusEmpty => 'SEM PARTIDAS';

  @override
  String get fantasyStatusFinished => 'FINALIZADA';

  @override
  String fantasyAdminDeadline(String when) {
    return 'Prazo: $when';
  }

  @override
  String fantasyAdminMatches(int finished, int total) {
    return 'Partidas terminadas: $finished de $total';
  }

  @override
  String fantasyAdminLineups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escalações apuradas',
      one: '1 escalação apurada',
    );
    return '$_temp0';
  }

  @override
  String fantasyAdminScoredAt(String when) {
    return 'Apurada em $when';
  }

  @override
  String get fantasyAdminNotScored => 'Ainda não apurada';

  @override
  String fantasyAdminParams(int min, int defense, String captain) {
    return 'Parâmetros: $min min · $defense min · $captain';
  }

  @override
  String fantasyAdminSince(int round) {
    return 'Desde a rodada $round';
  }

  @override
  String get fantasyAdminSinceStart => 'Desde o início';

  @override
  String get fantasyLoadMore => 'Carregar mais';

  @override
  String get fantasyRescore => 'Reapurar rodadas';

  @override
  String get fantasyRescoreTitle => 'Reapurar as rodadas?';

  @override
  String get fantasyRescoreText =>
      'Todas as rodadas fechadas são recalculadas pela súmula atual. Os pontos só mudam onde a súmula ou os cadastros mudaram; nada é somado duas vezes.';

  @override
  String get fantasyRescoreRequested =>
      'Reapuração pedida. Pode levar alguns segundos.';

  @override
  String get fantasyRescoreError => 'Não foi possível pedir a reapuração.';

  @override
  String get fantasyCancel => 'Cancelar';

  @override
  String get fantasyRuleBase => 'Pontuação-base';

  @override
  String get fantasyRuleGoal => 'Gols';

  @override
  String get fantasyRuleAssist => 'Assistências';

  @override
  String get fantasyRuleWin => 'Vitória';

  @override
  String get fantasyRuleLoss => 'Derrota';

  @override
  String get fantasyRuleDraw => 'Empate';

  @override
  String get fantasyRuleYellow => 'Cartão amarelo';

  @override
  String get fantasyRuleRed => 'Cartão vermelho';

  @override
  String get fantasyRuleConceded => 'Gols sofridos';

  @override
  String get fantasyRuleTeamGoals => 'Gols da equipe';

  @override
  String get fantasyRuleCleanSheet => 'Sem sofrer gols';

  @override
  String get fantasyRulesTitle => 'Regras e pontuação';

  @override
  String get fantasyRulesSeeRules => 'Ver regras';

  @override
  String get fantasyRulesDefaultsNote =>
      'Os minutos e o multiplicador do capitão abaixo são os padrões e podem variar por campeonato.';

  @override
  String get fantasyRulesHowToPlay => 'Como jogar';

  @override
  String fantasyRulesHowToPlayText(int count) {
    return 'Escale $count atletas, um em cada vaga, e escolha 1 capitão. Só entram atletas inscritos no campeonato.';
  }

  @override
  String get fantasyRulesSlotGoalkeeper => 'Goleiro';

  @override
  String get fantasyRulesSlotDefender => 'Zagueiro ou lateral';

  @override
  String get fantasyRulesSlotMidfielder => 'Volante ou meia';

  @override
  String get fantasyRulesSlotForward => 'Atacante';

  @override
  String get fantasyRulesSlotFlex => 'Qualquer posição';

  @override
  String get fantasyRulesFlexNote =>
      'Na vaga LIVRE, o atleta pontua pela posição dele no cadastro.';

  @override
  String get fantasyRulesRound => 'Rodada e prazo';

  @override
  String get fantasyRulesRoundLock =>
      'A escalação trava quando começa o 1º jogo da rodada.';

  @override
  String get fantasyRulesRoundCopy =>
      'Não mexeu na escalação? Ela é copiada para a próxima rodada.';

  @override
  String get fantasyRulesRoundPoints =>
      'Os pontos saem depois dos jogos, pela súmula oficial da partida.';

  @override
  String get fantasyRulesScoring => 'Pontuação';

  @override
  String get fantasyRulesPlay => 'Lance';

  @override
  String get fantasyRulesPoints => 'Pontos';

  @override
  String get fantasyRulesScoringNote =>
      'Gols e assistências contam cada um. O 2º amarelo vira o vermelho e o amarelo não conta de novo.';

  @override
  String get fantasyRulesByPosition => 'Por posição';

  @override
  String get fantasyRulesPosition => 'Posição';

  @override
  String get fantasyRulesConcededEach => 'Gols sofridos (por gol)';

  @override
  String get fantasyRulesPositionNote =>
      'Gols sofridos e gols da equipe contam só com o atleta em campo.';

  @override
  String get fantasyRulesMinutes => 'Minutos em campo';

  @override
  String fantasyRulesMinutesShort(int min) {
    return 'Com menos de $min min, contam só gols, assistências e cartões.';
  }

  @override
  String fantasyRulesMinutesDefense(int min) {
    return 'Sem sofrer gols só com $min min ou mais em campo.';
  }

  @override
  String get fantasyRulesCaptain => 'Capitão';

  @override
  String fantasyRulesCaptainText(String mult) {
    return 'O capitão pontua $mult, inclusive na pontuação negativa.';
  }

  @override
  String get fantasyRulesRanking => 'Ranking';

  @override
  String get fantasyRulesRankingText =>
      'Há o ranking de cada rodada e o geral, com a soma das rodadas.';

  @override
  String get fantasyRulesRankingTies => 'Mesmo total = mesma posição.';

  @override
  String get fantasyRulesRankingChampion =>
      'Campeão: o maior total geral ao fim da competição; empate = todos campeões.';

  @override
  String fantasyReasonShort(int min, int played) {
    return 'Não atingiu o mínimo de $min minutos (jogou $played): só valem gols, assistências e cartões.';
  }

  @override
  String fantasyReasonNoBonus(int min) {
    return 'Menos de $min minutos em campo: sem o bônus de não sofrer gols.';
  }

  @override
  String get fantasyReasonNotOnField => 'Não entrou em campo.';

  @override
  String get fantasyReasonNoLineup => 'A súmula não tem a escalação do time.';

  @override
  String get fantasyReasonSubNoMinute => 'Substituição sem o minuto na súmula.';

  @override
  String get fantasyReasonEstimated =>
      'Minutos estimados pela súmula (jogo inteiro).';

  @override
  String get fantasyReasonNoPosition => 'Atleta sem posição no cadastro.';

  @override
  String get fantasyReasonDidNotPlay => 'Não jogou nesta rodada.';

  @override
  String get fantasyReasonNoMatches =>
      'Nenhuma partida da rodada terminou ainda.';

  @override
  String fantasyMinutesPlayed(int minutes) {
    return '$minutes min em campo';
  }

  @override
  String fantasyMinutesEstimated(int minutes) {
    return '$minutes min em campo (estimados)';
  }

  @override
  String get fantasyScoreTotal => 'Total individual';

  @override
  String fantasyScoreCaptain(String mult) {
    return 'Capitão ($mult)';
  }

  @override
  String get fantasyScoreNotes => 'Observações';

  @override
  String get fantasyHomeEmpty => 'Nenhum Arena Fantasy ativo na sua região.';

  @override
  String get fantasyHomeIntro =>
      'Monte seu time com os atletas do campeonato e pontue pelo desempenho real nas partidas.';

  @override
  String get fantasyHomeJoin => 'Entre e monte seu time';

  @override
  String get fantasyHomePickTeam => 'Monte seu time desta rodada';

  @override
  String get fantasyHomeCopied => 'Escalação copiada da rodada anterior';

  @override
  String get fantasyHomeConfirmed => 'Escalação confirmada';

  @override
  String fantasyHomePosition(int position) {
    return 'pts · $positionº';
  }

  @override
  String get fantasyHomePlay => 'Escalar';

  @override
  String get fantasyHomeEnter => 'Entrar';

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
  String get pushActionPartnerRequest => 'Novo pedido de parceiro';

  @override
  String get pushActionPartnerRequestHint =>
      'Para os admins · \"Fulano quer ser parceiro: Loja X\"';

  @override
  String get pushActionPartnerRequestAnswer => 'Resposta do pedido de parceiro';

  @override
  String get pushActionPartnerRequestAnswerHint =>
      'Para quem pediu · aprovado, rejeitado ou parceria encerrada';

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

  @override
  String get fanCardMenu => 'Minha carteirinha';

  @override
  String get fanCardTitle => 'Carteirinha de torcedor';

  @override
  String get eventPollTag => 'EVENTO';

  @override
  String get eventPollMenu => 'Evento de votação';

  @override
  String get eventPollFormTitleNew => 'Novo evento de votação';

  @override
  String get eventPollFormTitleEdit => 'Editar evento';

  @override
  String get eventPollFormIntro =>
      'Crie uma votação para a torcida: gol mais bonito da rodada, defesa do mês, melhor torcida…';

  @override
  String get eventPollSectionEvent => 'Evento';

  @override
  String get eventPollSectionVoting => 'Votação';

  @override
  String get eventPollSectionOptions => 'Opções';

  @override
  String get eventPollFieldTitle => 'Título do evento';

  @override
  String get eventPollFieldTitleHint => 'Ex.: Gol mais bonito da rodada';

  @override
  String get eventPollFieldDescription => 'Descrição (opcional)';

  @override
  String get eventPollCoverAdd => 'Adicionar capa (opcional)';

  @override
  String get eventPollCoverChange => 'Trocar capa';

  @override
  String get eventPollCoverRemove => 'Remover capa';

  @override
  String get eventPollClosesDate => 'Data do encerramento';

  @override
  String get eventPollClosesTime => 'Horário do encerramento';

  @override
  String get eventPollShowPartial => 'Mostrar resultado parcial';

  @override
  String get eventPollShowPartialHint =>
      'Quem já votou vê a parcial. Desligado, o resultado só aparece no encerramento.';

  @override
  String eventPollOptionLabel(int number) {
    return 'Opção $number';
  }

  @override
  String get eventPollOptionTitle => 'Título da opção';

  @override
  String get eventPollOptionTitleHint => 'Ex.: Gol do Dudu';

  @override
  String get eventPollOptionSubtitle => 'Detalhe (opcional)';

  @override
  String get eventPollOptionSubtitleHint => 'Ex.: Lava Jato x Volta, 2º tempo';

  @override
  String get eventPollOptionLink => 'Link do vídeo (opcional)';

  @override
  String get eventPollOptionLinkHint => 'Instagram, YouTube, TikTok…';

  @override
  String get eventPollOptionPhoto => 'Foto';

  @override
  String get eventPollAddOption => 'Adicionar opção';

  @override
  String get eventPollOptionsLocked =>
      'Já há votos: as opções não podem mais ser alteradas.';

  @override
  String get eventPollErrorTitle => 'Informe o título do evento.';

  @override
  String get eventPollErrorRegion => 'Escolha a região.';

  @override
  String get eventPollErrorClosesAt => 'O encerramento precisa ser no futuro.';

  @override
  String get eventPollErrorFewOptions =>
      'O evento precisa de pelo menos 2 opções.';

  @override
  String eventPollErrorOptionTitle(int number) {
    return 'Dê um título à opção $number.';
  }

  @override
  String eventPollErrorOptionLink(int number) {
    return 'O link da opção $number não é válido.';
  }

  @override
  String get eventPollPublish => 'PUBLICAR EVENTO';

  @override
  String get eventPollSaveChanges => 'SALVAR ALTERAÇÕES';

  @override
  String get eventPollPublished => 'Evento publicado!';

  @override
  String get eventPollSaved => 'Evento atualizado!';

  @override
  String eventPollEndsIn(String time) {
    return 'Encerra em $time';
  }

  @override
  String get eventPollEnded => 'Encerrado';

  @override
  String get eventPollVoteNow => 'VOTAR';

  @override
  String get eventPollSeeResult => 'VER RESULTADO';

  @override
  String get eventPollSeeOptions => 'VER OPÇÕES';

  @override
  String eventPollOptionsCount(int count) {
    return '$count opções';
  }

  @override
  String eventPollVotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
      zero: 'nenhum voto',
    );
    return '$_temp0';
  }

  @override
  String eventPollWatchOn(String network) {
    return 'Ver no $network';
  }

  @override
  String get eventPollOpenLink => 'Ver vídeo';

  @override
  String eventPollVoteFor(String option) {
    return 'VOTAR EM $option';
  }

  @override
  String eventPollConfirmTitle(String option) {
    return 'Votar em $option?';
  }

  @override
  String get eventPollConfirmMessage =>
      'O voto é único e não pode ser trocado depois.';

  @override
  String get eventPollConfirm => 'Votar';

  @override
  String get eventPollVoted => 'Voto registrado!';

  @override
  String get eventPollYourVote => 'Seu voto';

  @override
  String get eventPollHiddenResult =>
      'Voto registrado. O resultado sai no encerramento.';

  @override
  String get eventPollWinner => 'VENCEDOR';

  @override
  String get eventPollTie => 'EMPATE';

  @override
  String get eventPollNoVotes => 'Nenhum voto registrado.';

  @override
  String get eventPollSignIn => 'Entre na sua conta para votar.';

  @override
  String get eventPollTapToVote => 'Escolha uma opção e confirme o seu voto.';

  @override
  String get eventPollClosedNotice => 'Votação encerrada.';

  @override
  String get eventPollCloseNow => 'Encerrar agora';

  @override
  String get eventPollCloseConfirm => 'Encerrar a votação agora?';

  @override
  String get eventPollCloseMessage =>
      'Ninguém mais poderá votar e o resultado aparece para todos.';

  @override
  String get eventPollNotFound => 'Este evento não está mais disponível.';

  @override
  String get eventPollPartial => 'Parcial';

  @override
  String get eventPollFinal => 'Resultado final';

  @override
  String get eventPollShareResult => 'Compartilhar resultado';

  @override
  String get eventArtTitle => 'Arte do resultado';

  @override
  String get eventArtResultSeal => 'RESULTADO';

  @override
  String eventArtClosedOn(String date) {
    return 'Encerrado em $date';
  }

  @override
  String get eventArtTemplateChampion => 'Campeão';

  @override
  String get eventArtTemplatePodium => 'Pódio';

  @override
  String get eventArtTemplateRanking => 'Ranking';

  @override
  String eventArtShareText(
      String event, String winner, int percent, String link) {
    return '🏆 Resultado: $event — $winner venceu com $percent%!\n$link';
  }

  @override
  String eventArtShareTie(String event, String names, String link) {
    return '🏆 Resultado: $event — empate entre $names!\n$link';
  }

  @override
  String get fanCardMember => 'SÓCIO TORCEDOR';

  @override
  String get fanCardFlipHint => 'Toque no cartão para virar';

  @override
  String fanCardValidSeason(String season) {
    return 'Válida na temporada $season';
  }

  @override
  String get fanCardBackCta => 'Baixe o Arena e torça junto';

  @override
  String get fanCardSignature => 'Assinatura do torcedor';

  @override
  String get fanCardLevelSection => 'Seu nível de torcedor';

  @override
  String get fanCardSeeAchievements => 'Ver conquistas';

  @override
  String get fanCardActionShare => 'Compartilhar';

  @override
  String get fanCardActionPhoto => 'Foto';

  @override
  String get fanCardActionTeam => 'Time';

  @override
  String fanCardBackStats(String level, int xp, int count) {
    return '$level · $xp XP · $count conquistas';
  }

  @override
  String get fanCardMaxLevel => 'Nível máximo alcançado!';

  @override
  String get fanCardLabel => 'CARTEIRINHA DE TORCEDOR';

  @override
  String fanCardFanOf(String team) {
    return 'Torcedor do $team';
  }

  @override
  String get fanCardNoTeam => 'Sem time do coração';

  @override
  String fanCardSince(String year) {
    return 'Torcedor desde $year';
  }

  @override
  String fanCardNumber(String number) {
    return 'Nº $number';
  }

  @override
  String get fanCardChangePhoto => 'Trocar foto';

  @override
  String get fanCardAddPhoto => 'Adicionar foto';

  @override
  String get fanCardPhotoSaved => 'Foto atualizada!';

  @override
  String get fanCardHint => 'Mostre a sua carteirinha nos jogos do seu time.';

  @override
  String get fanCardShare => 'COMPARTILHAR CARTEIRINHA';

  @override
  String get fanCardShareTitle => 'Compartilhar carteirinha';

  @override
  String get shareInstagramStories => 'Instagram Stories';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareMoreOptions => 'Mais opções';

  @override
  String fanCardShareText(String team) {
    return 'Sou torcedor do $team no Arena Football! ⚽';
  }

  @override
  String get fanCardShareTextNoTeam =>
      'Minha carteirinha de torcedor no Arena Football! ⚽';

  @override
  String get fanCardChangeTeam => 'Trocar de time';

  @override
  String fanCardChangeTeamNextAt(String date) {
    return 'Próxima troca de time a partir de $date';
  }

  @override
  String get teamChangeLockedTitle => 'Troca de time bloqueada';

  @override
  String teamChangeLockedMessage(String date) {
    return 'Você só pode trocar de time a cada 15 dias. A próxima troca fica liberada em $date.';
  }

  @override
  String get teamChangeLockedMessageNoDate =>
      'Você só pode trocar de time a cada 15 dias. Tente de novo mais tarde.';

  @override
  String chooseTeamConfirmChangeTitle(String team) {
    return 'Trocar para $team?';
  }

  @override
  String get chooseTeamConfirmChangeMessage =>
      'Depois de trocar, a próxima troca de time só fica liberada daqui a 15 dias.';

  @override
  String get chooseTeamConfirmChange => 'Trocar';

  @override
  String get shareFooter => 'Arena Football · o futebol amador da sua região';

  @override
  String get athleteShareTitle => 'Compartilhar atleta';

  @override
  String get athleteCardLabel => 'ATLETA';

  @override
  String athleteCardSeason(String season) {
    return 'Temporada $season';
  }

  @override
  String athleteCardParticipations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participações em gols',
      one: '1 participação em gol',
      zero: 'Nenhuma participação em gol',
    );
    return '$_temp0';
  }

  @override
  String get teamEdit => 'Editar time';

  @override
  String get teamEditTitle => 'Editar time';

  @override
  String get teamEditSaved => 'Time atualizado.';

  @override
  String get teamEditRegionLabel => 'Região';

  @override
  String get teamEditRegionChangeTitle => 'Trocar a região?';

  @override
  String teamEditRegionChangeMessage(String team, String region) {
    return '$team passa a aparecer na aba Times e na classificação de $region. Os grupos da região antiga não mudam.';
  }

  @override
  String get teamEditNameLocked =>
      'O nome do time não pode ser alterado (ele está nas partidas, no elenco e na votação).';

  @override
  String get votingShareTitle => 'Compartilhar craque';

  @override
  String get votingCardLabel => 'CRAQUE DA PARTIDA';

  @override
  String get votingCardTopVotes => 'Mais votados';

  @override
  String get votingCardSeasonStats => 'Na temporada';

  @override
  String get teamLinksTitle => 'Vincular times por id';

  @override
  String get teamLinksInfo =>
      'Grava o id do time ao lado do nome em jogadores, partidas, grupos, campeonatos, pedidos \"Sou jogador\" e cards de gol da temporada (na atual, também no time do coração das contas) e copia os votos antigos para as partidas. Só completa o que falta: pode rodar de novo.';

  @override
  String teamLinksRun(String season) {
    return 'Vincular $season';
  }

  @override
  String teamLinksDone(String season, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos atualizados',
      one: '1 documento atualizado',
      zero: 'nada a atualizar',
    );
    return '$season: $_temp0';
  }

  @override
  String teamLinksVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos copiados para as partidas',
      one: '1 voto copiado para a partida',
    );
    return '$_temp0';
  }

  @override
  String get teamLinksUnmatched =>
      'Nomes sem time na temporada (não vinculados):';

  @override
  String get teamLinksAmbiguous =>
      'Nomes usados por mais de um time (não vinculados):';

  @override
  String get teamLinksSkippedVotes =>
      'Votos não copiados (confronto repetido na temporada):';

  @override
  String get teamLinksPlayers => 'Jogadores';

  @override
  String get teamLinksMatches => 'Partidas';

  @override
  String get teamLinksGroups => 'Grupos';

  @override
  String get teamLinksChampionships => 'Campeonatos';

  @override
  String get teamLinksPlayerRequests => 'Pedidos \"Sou jogador\"';

  @override
  String get teamLinksGoalCards => 'Cards de gol';

  @override
  String get teamLinksUsers => 'Time do coração';

  @override
  String get regionsManageTitle => 'Regiões';

  @override
  String regionsTeamsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times nesta temporada',
      one: '1 time nesta temporada',
      zero: 'Nenhum time nesta temporada',
    );
    return '$_temp0';
  }

  @override
  String get regionsCreate => 'Nova região';

  @override
  String get regionsNameLabel => 'Nome da região';

  @override
  String get regionsNameHint =>
      'A região aparece para todos na hora, na home e nos cadastros.';

  @override
  String regionsCreated(String name) {
    return 'Região \"$name\" criada!';
  }

  @override
  String get regionsDuplicate => 'Já existe uma região com esse nome.';

  @override
  String get regionsNameTooShort => 'Use pelo menos 3 letras.';

  @override
  String get regionsEmpty =>
      'Nenhuma região cadastrada. Toque em + para criar.';

  @override
  String get regionsLoadError => 'Não foi possível carregar as regiões.';

  @override
  String get commonOk => 'Ok';

  @override
  String get regionsRename => 'Renomear';

  @override
  String get regionsRenameTitle => 'Renomear região';

  @override
  String get regionsRenameHint =>
      'Times, partidas, notícias e campeonatos continuam na região e passam a mostrar o novo nome.';

  @override
  String regionsRenamed(String previous, String name) {
    return '\"$previous\" agora é \"$name\".';
  }

  @override
  String regionsDeleteTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get regionsDeleteMessage =>
      'A região está vazia e sai da lista para todos.';

  @override
  String regionsDeleted(String name) {
    return 'Região \"$name\" excluída.';
  }

  @override
  String get regionsDeleteBlockedTitle => 'Região com conteúdo';

  @override
  String regionsDeleteBlockedMessage(String name, String usage) {
    return '\"$name\" ainda tem $usage. Só dá para excluir uma região vazia; se quiser mudar o nome, use \"Renomear\".';
  }

  @override
  String get regionsLastRegion => 'Esta é a única região: não dá para excluir.';

  @override
  String regionsUsageTeams(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String regionsUsageMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '1 partida',
    );
    return '$_temp0';
  }

  @override
  String regionsUsageNews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notícias',
      one: '1 notícia',
    );
    return '$_temp0';
  }

  @override
  String regionsUsageChampionships(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count campeonatos',
      one: '1 campeonato',
    );
    return '$_temp0';
  }

  @override
  String regionsUsageGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
    );
    return '$_temp0';
  }

  @override
  String get regionsLinkTitle => 'Vincular regiões por id';

  @override
  String get regionsLinkHint =>
      'Grava o id da região nos times, partidas, notícias, campeonatos, grupos e pedidos antigos, de todas as temporadas. Rode uma vez depois de atualizar o app; pode rodar de novo, só completa o que falta.';

  @override
  String get regionsLinkRun => 'Vincular agora';

  @override
  String get regionsLinkConfirm =>
      'Isso percorre a base inteira e pode levar alguns minutos. Continuar?';

  @override
  String regionsLinkDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos vinculados.',
      one: '1 documento vinculado.',
    );
    return '$_temp0';
  }

  @override
  String get regionsLinkNothing => 'Tudo já estava vinculado.';

  @override
  String regionsLinkUnmatched(String names) {
    return 'Nomes que não batem com nenhuma região (ficaram sem id): $names';
  }

  @override
  String get statsShortcut => 'Artilharia e assistências';

  @override
  String get statsShortcutGoalsHint => 'Quem mais marcou';

  @override
  String get statsShortcutAssistsHint => 'Quem mais serviu';

  @override
  String get alertHeaderConfirm => 'Confirmação';

  @override
  String get alertHeaderNotice => 'Aviso';

  @override
  String get newsShareTitle => 'Compartilhar notícia';

  @override
  String get newsShareCardFooter => 'Leia no app · arenasoccerflutter.web.app';

  @override
  String get newsNotFound => 'Esta notícia não está mais disponível.';

  @override
  String get deepLinkAlbumClosed =>
      'O álbum de figurinhas não está aberto agora.';

  @override
  String get deepLinkMatchNotFound => 'Esta partida não está mais disponível.';

  @override
  String get deepLinkHighlightNotFound =>
      'Este destaque não está mais disponível.';

  @override
  String fantasyTopAthletesTitle(int round) {
    return 'Craques da rodada $round';
  }

  @override
  String get fantasyTopAthletesEmpty => 'Nenhum atleta pontuou nesta rodada.';

  @override
  String get fantasySeeAll => 'Ver todos';

  @override
  String get fantasyTabAthletes => 'Atletas';

  @override
  String fantasyCardBadge(int round) {
    return 'ARENA FANTASY · RODADA $round';
  }

  @override
  String get fantasyCardTitle => 'Craques da rodada';

  @override
  String get fantasyCardAction => 'Escalar meu time';

  @override
  String fantasyCardPoints(String points) {
    return '$points pts';
  }

  @override
  String get pushActionFantasyRound => 'Arena Fantasy';

  @override
  String get pushActionFantasyRoundHint =>
      'Região · craques da rodada quando ela é apurada';

  @override
  String get reportStartersFull =>
      'Já há 11 titulares. Tire um titular para escalar outro.';

  @override
  String get reportConfirmLineups => 'Confirmar escalações';

  @override
  String get reportLineupsConfirmed => 'Escalações confirmadas';

  @override
  String get reportConfirmLineupsNeedStarters =>
      'Confirme com pelo menos um titular em cada time';

  @override
  String get reportLineupsConfirmedSaveHint =>
      'Escalações confirmadas. Salve a súmula para mostrar o campinho.';

  @override
  String get reportFormation => 'Formação';

  @override
  String get reportFormationFree => 'Livre';

  @override
  String get reportFormationFreeHint =>
      'Sem formação: o campinho arruma pela posição do cadastro';

  @override
  String get reportFormationSuggest => 'Sugerir pela posição';

  @override
  String get reportFormationNeedStarters =>
      'Escolha 11, 7 ou 5 titulares para usar uma formação';

  @override
  String reportFormationSheetTitle(String team) {
    return 'Formação do $team';
  }

  @override
  String reportFormationEmptySlots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vagas vazias na formação',
      one: '1 vaga vazia na formação',
    );
    return '$_temp0';
  }

  @override
  String reportFormationUnplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titulares sem vaga',
      one: '1 titular sem vaga',
    );
    return '$_temp0';
  }

  @override
  String reportSlotPickTitle(String slot) {
    return 'Quem joga nesta vaga ($slot)?';
  }

  @override
  String get reportSlotEmpty => 'Vaga livre';

  @override
  String get reportSlotNone => 'Sem vaga';

  @override
  String get formationSlotGoalkeeper => 'GOL';

  @override
  String get formationSlotFullBack => 'LAT';

  @override
  String get formationSlotCenterBack => 'ZAG';

  @override
  String get formationSlotDefensiveMid => 'VOL';

  @override
  String get formationSlotMidfielder => 'MEI';

  @override
  String get formationSlotForward => 'ATA';

  @override
  String fantasyRoundInProgress(int round) {
    return 'Rodada $round em andamento. A próxima rodada abre quando todos os jogos terminarem.';
  }

  @override
  String get fantasyRoundInProgressShort => 'Em andamento';

  @override
  String fantasyRoundScoreTitle(int round) {
    return 'Sua pontuação na rodada $round';
  }

  @override
  String fantasyRoundPartialCount(int done, int total) {
    return 'Parcial · $done de $total jogos';
  }

  @override
  String get fantasyRoundFinal => 'Final';

  @override
  String get fantasySwitchResult => 'Resultado';

  @override
  String get fantasySwitchPick => 'Escalar';

  @override
  String get fantasyResetMenu => 'Zerar pontuações (testes)';

  @override
  String get fantasyResetTitle => 'Zerar as pontuações deste Fantasy?';

  @override
  String get fantasyResetText =>
      'Para a fase de testes: o total de todos os participantes volta a 0, as escalações perdem os pontos, a pontuação de cada atleta nas rodadas é apagada, o campeão sai e os cards \"Craques da rodada\" saem do feed. Participantes, escalações e rodadas continuam. Os pontos só voltam com \"Reapurar rodadas\" ou quando uma partida da rodada terminar de novo.';

  @override
  String get fantasyResetContinue => 'Continuar';

  @override
  String get fantasyResetSureTitle => 'Tem certeza?';

  @override
  String get fantasyResetSureText => 'Não dá para desfazer.';

  @override
  String get fantasyResetAction => 'Zerar pontuações';

  @override
  String get fantasyResetRequested =>
      'Pedido enviado: as pontuações serão zeradas em instantes.';

  @override
  String get fantasyResetError =>
      'Não foi possível pedir para zerar as pontuações.';

  @override
  String get matchFormTest => 'Partida de teste';

  @override
  String get matchFormTestHint =>
      'Só o admin vê · pushes só para os admins · não conta na classificação nem nos números dos atletas';

  @override
  String get matchTestBadge => 'TESTE';

  @override
  String get homeModeFan => 'Modo torcedor';

  @override
  String get homeModeFanBanner =>
      'Modo torcedor: você vê o app como um usuário comum';

  @override
  String get fantasyRoundClose => 'Fechar agora';

  @override
  String get fantasyRoundReopen => 'Reabrir';

  @override
  String fantasyRoundCloseTitle(int round) {
    return 'Fechar a rodada $round agora?';
  }

  @override
  String get fantasyRoundCloseText =>
      'As escalações travam na hora (os parâmetros desta rodada são congelados) e são copiadas para a próxima rodada. Para voltar, use \"Reabrir\".';

  @override
  String get fantasyRoundCloseRequested =>
      'Pedido enviado: a rodada será fechada em instantes.';

  @override
  String get fantasyRoundOpenRequested =>
      'Pedido enviado: a rodada será reaberta em instantes.';

  @override
  String get fantasyRoundActionError => 'Não foi possível mudar a rodada.';

  @override
  String get fantasyRoundDeadlinePast => 'Escolha um prazo no futuro.';

  @override
  String get fantasyRoundManualDeadline => 'Prazo definido pelo admin';

  @override
  String get fantasyRoundManualClosed => 'Fechada pelo admin';

  @override
  String get athleteInviteAction => 'Conheço esse jogador';

  @override
  String athleteInviteTitle(String name) {
    return '⚽ $name, você já está no Arena Football!';
  }

  @override
  String athleteInviteTeam(String team) {
    return 'do $team';
  }

  @override
  String athleteInviteTeamIn(String team, String championship) {
    return 'do $team na $championship';
  }

  @override
  String athleteInviteStats(int goals, int assists) {
    return 'e seus números já estão lá: $goals gols e $assists assistências. 🔥';
  }

  @override
  String get athleteInviteNoStats =>
      'e sua página de atleta já está esperando por você. 🔥';

  @override
  String athleteInviteBody(String name, String where, String numbers) {
    return 'O atleta $name $where parece ser você — $numbers';
  }

  @override
  String get athleteInviteBenefits =>
      'Crie sua conta grátis, diga \"Sou eu\" e tenha sua carreira na palma da mão:\n📊 seus gols e assistências em cada competição\n🏆 concorra a craque da partida\n🎴 sua figurinha no álbum\n🖼️ artes de atleta pra postar';

  @override
  String get athleteInviteCta =>
      '👉 Toque no link, baixe o app e confirme que é você:';

  @override
  String get athleteInviteCardTitle => 'Você está no Arena Football!';

  @override
  String get athleteInviteCardGoals => 'GOLS';

  @override
  String get athleteInviteCardAssists => 'ASSISTÊNCIAS';

  @override
  String get athleteInviteCardCta => 'Crie sua conta e diga: \"Sou eu!\"';

  @override
  String get athleteInviteSheetTitle => 'Convidar atleta';

  @override
  String get fantasyStatusPartial => 'PARCIAL';

  @override
  String get fantasyStatusFinal => 'FINAL';

  @override
  String get fantasyStatusAwaiting => 'AGUARDANDO APURAÇÃO';

  @override
  String get fantasyYou => 'VOCÊ';

  @override
  String fantasyChase(String points, String name) {
    return 'Faltam $points pts para passar $name';
  }

  @override
  String get fantasyLeading => 'Você lidera!';

  @override
  String get fantasyHeroPoints => 'seus pts';

  @override
  String get fantasyHeroPosition => 'sua posição';

  @override
  String get fantasyHeroParticipants => 'participantes';

  @override
  String get fantasyOverallTitle => 'CLASSIFICAÇÃO GERAL';

  @override
  String get fantasyTopAthletesHeader => 'Os que mais pontuaram';

  @override
  String get fantasyTiedShort => 'empate';

  @override
  String fantasyGapBehind(String points, int position) {
    return '$points pts atrás do $positionº';
  }

  @override
  String get appUpdateRequiredTitle => 'Atualize o Arena Football';

  @override
  String get appUpdateRequiredText =>
      'Esta versão do app não é mais suportada. Atualize para continuar usando.';

  @override
  String get appUpdateRecommendedTitle => 'Nova versão disponível!';

  @override
  String get appUpdateRecommendedText =>
      'Atualize o app para ter as novidades e as correções mais recentes.';

  @override
  String get appUpdateNow => 'Atualizar agora';

  @override
  String get appUpdateAction => 'Atualizar';

  @override
  String get appUpdateLater => 'Depois';

  @override
  String get appVersionTitle => 'Versão do app';

  @override
  String get appVersionIntro =>
      'Quem estiver abaixo do build recomendado vê o aviso \"Nova versão disponível\" (pode adiar). Abaixo do mínimo, o app fica bloqueado até atualizar.';

  @override
  String appVersionInstalled(String platform, String name, int build) {
    return 'Este aparelho: $platform $name (build $build)';
  }

  @override
  String get appVersionUseInstalled => 'Usar como recomendado';

  @override
  String get appVersionRecommended => 'Build recomendado';

  @override
  String get appVersionRecommendedHint => 'Sugere atualizar (pode adiar)';

  @override
  String get appVersionMinimum => 'Build mínimo';

  @override
  String get appVersionMinimumHint => 'Abaixo dele, o app fica bloqueado';

  @override
  String get appVersionMessage => 'Mensagem do aviso (opcional)';

  @override
  String get appVersionMessageHint => 'Ex.: chegou o Arena Fantasy!';

  @override
  String get appVersionHelp =>
      'O build é o número depois do \"+\" no pubspec (2.0.18+43 → 43), o mesmo no Android e no iOS. Android: aparece na Play Console como 43 (2.0.18). iOS: no App Store Connect/TestFlight como 1.0.18 (43) — a App Store pública mostra só o nome. Publique a versão na loja antes de subir estes números.';

  @override
  String get appVersionSave => 'Salvar';

  @override
  String get appVersionSaved => 'Versões salvas.';

  @override
  String get appVersionSaveError => 'Não foi possível salvar as versões.';

  @override
  String get appVersionRaiseTitle => 'Subir a versão mínima?';

  @override
  String appVersionRaiseText(int android, int ios) {
    return 'Quem estiver abaixo do build $android (Android) ou $ios (iOS) fica bloqueado até atualizar o app.';
  }

  @override
  String get achievementFieldPacks => 'Prêmio: pacotinhos de figurinhas';

  @override
  String achievementPacksPill(int count) {
    return '🎁 +$count';
  }

  @override
  String achievementPacksWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🎁 Você ganhou $count pacotinhos de figurinhas! Abra no álbum.',
      one: '🎁 Você ganhou 1 pacotinho de figurinhas! Abra no álbum.',
    );
    return '$_temp0';
  }

  @override
  String get achievementOpenAlbum => 'Abrir o álbum';

  @override
  String get fantasyResetTeamsMenu => 'Zerar pontos de times…';

  @override
  String get fantasyResetTeamsTitle => 'Zerar pontos de times';

  @override
  String get fantasyResetTeamsText =>
      'Os atletas destes times perdem os pontos em todas as rodadas deste Fantasy, e o total de quem os escalou é recalculado. Se as partidas de teste continuarem existindo, os pontos voltam na próxima apuração da rodada: apague-as (ou tire a rodada delas) antes.';

  @override
  String get fantasyResetTeamsPick => 'Escolha o time';

  @override
  String get fantasyResetTeamsAdd => 'Adicionar time';

  @override
  String get fantasyResetTeamsAction => 'Zerar pontos';

  @override
  String get scoringTitle => 'Pontuações';

  @override
  String get scoringMenu => 'Pontuações (Fantasy e bolão)';

  @override
  String get scoringTabFantasy => 'Arena Fantasy';

  @override
  String get scoringTabBolao => 'Bolão';

  @override
  String get scoringFantasyIntro =>
      'Tabela padrão do Arena Fantasy: vale para todo campeonato sem tabela própria (a própria fica na engrenagem do Fantasy de cada campeonato).';

  @override
  String get scoringFantasyNote =>
      'Vale para as rodadas que fecharem depois de salvar. As rodadas já fechadas guardam a tabela delas (o \"Reapurar\" usa a da rodada).';

  @override
  String get scoringBolaoIntro =>
      'Pontos de cada palpite: exato ≥ vencedor e saldo ≥ vencedor.';

  @override
  String get scoringBolaoNote =>
      'Vale para as partidas que terminarem depois de salvar. Palpites já pontuados seguem com os pontos de quando foram contados.';

  @override
  String get scoringBolaoExact => 'Placar exato';

  @override
  String get scoringBolaoDiff =>
      'Vencedor e saldo (ou empate com outro placar)';

  @override
  String get scoringBolaoWinner => 'Só o vencedor';

  @override
  String get scoringRestore => 'Restaurar padrões';

  @override
  String get scoringSave => 'Salvar';

  @override
  String get scoringSaved => 'Pontuação salva.';

  @override
  String get scoringSaveError => 'Não foi possível salvar a pontuação.';

  @override
  String get fantasyScoringSection => 'Pontuação';

  @override
  String get fantasyScoringOwn => 'Tabela própria deste campeonato';

  @override
  String get fantasyScoringOwnOn =>
      'Os valores abaixo valem só para este campeonato, nas rodadas que fecharem depois.';

  @override
  String get fantasyScoringOwnOff =>
      'Usa a tabela padrão (painel do admin → Pontuações).';

  @override
  String get fantasyFormationSection => 'Escalação';

  @override
  String fantasyFormationTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atletas',
      one: '1 atleta',
    );
    return '$_temp0';
  }

  @override
  String get fantasyFormationHint =>
      'Quantos atletas de cada posição o torcedor escala (de 3 a 7 no total). Vale para a rodada aberta e as próximas; as escalações e pontuações já feitas são mantidas.';

  @override
  String get fantasyErrorFormationTotal => 'A escalação tem de 3 a 7 atletas.';

  @override
  String get fantasyFormationConfirmTitle => 'Mudar a escalação?';

  @override
  String fantasyFormationConfirmBody(int count) {
    return 'As escalações e pontuações já feitas são mantidas. O novo formato ($count atletas) vale para as escalações a partir de agora.';
  }

  @override
  String get fantasyFormationConfirm => 'Mudar';

  @override
  String fantasyFormationChanged(int count) {
    return 'O formato da escalação mudou para $count atletas. Sua escalação anterior continua valendo; ajuste o time e confirme para usar o novo formato.';
  }

  @override
  String albumTradeText(int count) {
    return 'Troque $count repetidas diferentes por 1 pacotinho';
  }

  @override
  String albumTradeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você tem $count trocas hoje',
      one: 'Você tem 1 troca hoje',
    );
    return '$_temp0';
  }

  @override
  String get albumTradeNoneLeft => 'Trocas de hoje usadas. Volte amanhã!';

  @override
  String albumTradeNeedMore(int have, int need) {
    return 'Você tem $have de $need repetidas diferentes.';
  }

  @override
  String get albumTradeChoose => 'Escolher para trocar';

  @override
  String get albumTradeAuto => 'Escolher automático';

  @override
  String albumTradeSelected(int selected, int size) {
    return '$selected de $size escolhidas';
  }

  @override
  String get albumTradeAction => 'Trocar';

  @override
  String albumTradeConfirmTitle(int count) {
    return 'Trocar $count repetidas?';
  }

  @override
  String get albumTradeConfirmBody =>
      'Cada figurinha escolhida perde 1 cópia e continua colada no álbum. Você ganha 1 pacotinho.';

  @override
  String albumTradeFull(int count) {
    return 'Você já escolheu $count figurinhas.';
  }

  @override
  String get albumTradeRefusedLimit => 'Você já usou as trocas de hoje.';

  @override
  String get albumTradeRefusedOff => 'A troca de repetidas foi desligada.';

  @override
  String get albumTradeRefused =>
      'Não deu para trocar: confira as repetidas e tente de novo.';

  @override
  String get albumTradeSettings => 'Troca de repetidas';

  @override
  String get albumTradeSize => 'Repetidas por pacotinho';

  @override
  String get albumTradeSizeHint =>
      'Repetidas diferentes que a pessoa entrega por 1 pacotinho (cada uma perde 1 cópia).';

  @override
  String get albumTradeOffValue => 'Desligada';

  @override
  String get albumTradesPerDay => 'Trocas por dia';

  @override
  String get albumTradesPerDayHint => 'Quantas trocas cada pessoa faz por dia.';

  @override
  String get fantasyCardShare => 'Compartilhar';

  @override
  String get fantasyArtTitle => 'Compartilhar craques da rodada';

  @override
  String get fantasyArtTemplateMvp => 'Craque';

  @override
  String get fantasyArtCta => 'Monte seu time grátis no Arena Fantasy';

  @override
  String fantasyArtPoints(String points) {
    return '$points pts';
  }

  @override
  String fantasyArtShareText(
      int round, String championship, String podium, String link) {
    return '⚽ Craques da rodada $round do Arena Fantasy · $championship: $podium. Monte seu time grátis e dispute o ranking: $link';
  }

  @override
  String get fantasyGuestLogin => 'Entrar';

  @override
  String get deepLinkFantasyClosed =>
      'Esse Arena Fantasy não está disponível agora.';
}
