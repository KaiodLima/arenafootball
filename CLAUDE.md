# Arena Football - Guia do Projeto

App de futebol amador regional: notícias, destaques, times, jogadores, partidas, tabelas de classificação, artilharia, votação de melhor jogador e resultados globais (web scraping).

- **Pacote Dart:** `arena_soccer` — **Application ID:** `com.caiolima.arenafootball` (namespace/pacote Kotlin seguem `com.cdevel.arena_football`)
- **Versão:** ver `version:` no `pubspec.yaml`
- **Backend:** Firebase (Auth, Firestore, Storage). Não há API REST própria.
- **Plataforma alvo:** Android (iOS/Windows existem mas não são mantidos)
- **Idiomas:** PT-BR (principal, template) e EN via l10n (ARB files)

## Documentação detalhada

| Área | Arquivo | Quando abrir |
|------|---------|--------------|
| Arquitetura e padrões de código | `.claude/architecture.md` | Cubit/State, UseCase, Repository, DataSource, DI, rotas, Firestore |

## Stack

- Flutter 3.38 / Dart `>=3.0.0 <4.0.0`
- State: **BLoC/Cubit** (`flutter_bloc`) — Cubits globais no `MultiBlocProvider` de `lib/blocs_load.dart`; os de uma tela só, em route-level no `lib/arena_app.dart`
- DI: **get_it** — shorthand `sl()`. Registro modular por feature, orquestrado por `init()` em `lib/injection_container.dart`
- Dados: `cloud_firestore`, `firebase_auth`, `firebase_storage` (instâncias injetadas pelo get_it)
- Erros: `Either<Failure, T>` via `either_dart`
- Navegação: constantes em `lib/app_routes.dart`, registradas no `routes:` de `lib/arena_app.dart`
- Storage local: `shared_preferences` via `PreferencesService` (região e temporada escolhidas)
- Web scraping: `http` + `beautiful_soup_dart` (soccerstats.com)
- Android: AGP 8.9, Kotlin 2.2, Gradle 8.11, Java 17, minSdk 23

## Arquitetura

Clean Architecture por feature (`data/` -> `domain/` -> `presentation/`), detalhe em `.claude/architecture.md`:

```
UI (Page) -> Cubit -> UseCase -> Repository (impl) -> DataSource -> Firestore/Auth/Storage
```

## Features (22 módulos em `lib/features/`)

| Feature | Conteúdo |
|---------|----------|
| `splash` | Restaura a sessão (auto-login) e decide entre home e login |
| `auth` | Login (e-mail, Google e Apple; Apple só no iOS), cadastro de usuário, excluir conta (menu; reautentica e apaga no Auth, a function `onUserDeleted` limpa os dados), `SessionCubit` (global) |
| `regions` | Regiões (`competicao`) + região/temporada escolhidas, `RegionCubit` (global); painel do admin "Regiões" (criar, renomear, excluir só vazia e a manutenção "Vincular regiões por id") |
| `home` | Casca: AppBar, drawer, barra inferior com as 4 abas, atalhos do admin |
| `news` | Feed (aba HOME), detalhe, cadastro/edição, notificação de gol, anúncio |
| `highlights` | Carrossel de destaques, detalhe, cadastro |
| `teams` | Aba TIMES, cadastro de time (+ linha na classificação), edição pelo admin (escudo, descrição, cores e região; o nome é fixo), exclusão pelo admin (no elenco do time: jogadores com conta ficam sem time, os sem vínculo saem junto; partidas ficam) |
| `players` | Elenco do time, edição de gols/assistências/foto, cadastro de jogador |
| `player_requests` | "Sou jogador": usuário pede para entrar num time; painel do admin aprova (cria o jogador vinculado), rejeita ou edita |
| `team_requests` | "Sou dono de time": usuário pede para criar o time; admin aprova (cria o time com `idDono`). Aprovado, "Meu time": elenco, pedidos "Sou jogador" do time e edição de escudo/descrição. `OwnedTeamCubit` (global) diz de qual time a conta é dono |
| `partner_requests` | "Sou parceiro" (sub admin): usuário pede, admin aprova no painel "Parceiros" (pendentes, ativos com as **permissões** — notícias/destaques/publicidade liga-desliga, destaques ao mesmo tempo e publicidades por dia — e remover). Aprovado, publica na **região dele** (formulários de notícia, publicidade e destaque em modo parceiro: região travada, `idAutor`) e edita/apaga só o que é dele; área do parceiro com as vagas usadas e "Meus destaques". `PartnerCubit` (global) diz se a conta é parceira; limites por vaga de id fixo (`PartnerSlots`) |
| `seasons` | Temporada atual/lista em `config/temporadas`; painel do admin "Temporadas" (iniciar a próxima) e a manutenção "Vincular times por id" (completa os ids de time nos docs antigos e copia os votos antigos; pode rodar de novo) |
| `stats` | Ranking de artilharia/assistências (uma tela, `StatsRankingType`) |
| `championships` | Aba CAMPEONATOS, detalhe (regulamento PDF, times, premiação), grupos, classificação (automática: lê `tabelas{ano}/{idGrupo}`, sem ela a manual antiga), cadastro/edição do admin (com o desempate, `StandingsCriteriaEditor`) e "Recalcular tabelas" |
| `matches` | Aba TABELAS, lista de partidas (hoje/todas), cadastro, placar, votação on/off |
| `voting` | Votar no melhor jogador, contagem de votos, jogador eleito |
| `global_results` | Resultados pelo mundo (scraping do soccerstats.com; parser em `data/parsers/`) |
| `achievements` | "Minhas conquistas" (drawer): medalhas, nível/XP, comemoração ao desbloquear e vitrine na carteirinha; `AchievementsCubit` (global, seguido pelo `AchievementsSync`); admin → "Conquistas" (catálogo e as sugeridas) |
| `fan_ranking` | Ranking de torcidas (drawer): times da região com mais torcedores entre os usuários, lido de `ranking_torcidas/{temporada}` (uma leitura, com cache) |
| `predictions` | Bolão grátis: palpite de placar antes do jogo (pílula "Palpitar" no card, folha com −/+, seção "Palpite" nos detalhes com os pontos ganhos) e o ranking de palpiteiros da região (drawer "Bolão": pódio, top 50 e "Sua posição" fixa) |
| `notifications` | Painel de push do admin (liga/desliga por ação, histórico, aviso manual) + sincronia de tópicos |

## Fluxo para feature ou tela nova

1. Criar as pastas da feature (`data/{datasources,repositories,dtos}`, `domain/{repositories,usecases}`, `presentation/{bloc,page,widgets}`, `di/`).
2. Implementar de baixo para cima: DTO -> DataSource -> Repository (interface no `domain`, impl no `data`) -> UseCase -> Cubit + State.
3. Registrar DataSource/Repository/UseCase em `lib/features/<feature>/di/<feature>_injection.dart` com `registerLazySingleton`, e chamar `registerXxxDependencies()` no `init()` de `lib/injection_container.dart`.
4. Cubit **não** vai no DI: global em `lib/blocs_load.dart`, ou route-level com `BlocProvider` na rota em `lib/arena_app.dart`.
5. Adicionar a constante em `lib/app_routes.dart` e a rota em `lib/arena_app.dart`.
6. Strings novas nos dois ARBs (`lib/l10n/app_pt.arb` e `app_en.arb`) + `flutter gen-l10n`.
7. `flutter analyze` sem erros.

## Regras invioláveis

**Código**
- Erros sempre em `Either<Failure, T>` — nunca `throw`. DataSource captura e converte com `mapFirebaseError` (`lib/core/errors/firebase_error.dart`)
- Streams do Firestore: `.toEither(...)` de `lib/core/firebase/either_stream.dart` (nunca deixar o erro do stream escapar)
- Coleções por temporada: **sempre** `SeasonCollection.name('partidas', season)` — nunca montar `"partidas$ano"` na mão
- Vínculo com a região é pelo **id** (doc de `competicao`, campo `idRegiao`); `fk_competicao`/`regiao` é só cópia do nome. Tudo passa pelo `RegionRegistry` (`lib/core/firebase/region_registry.dart`): `fieldsFor` ao gravar, `nameFromDoc` ao ler (nome atual pelo id) e `where` nas consultas. Nunca filtrar/gravar `fk_competicao` na mão
- Vínculo com time é pelo **id** (doc de `times{ano}`); o nome gravado ao lado é só cópia para exibir. Gravar sempre os dois; buscar/comparar pelo id com fallback no nome para docs antigos (`sameTeam`/`TeamDirectory` em `lib/core/utils/team_key.dart`)
- Firestore só dentro de DataSource. Widget e Cubit nunca importam `cloud_firestore`
- Sessão (usuário/admin) vem do `SessionCubit`; região/temporada do `RegionCubit`. Não passar por construtor
- `async/await`, nunca `.then()` em cascata
- Código (classes, variáveis, métodos) em inglês; comentários e textos em português
- Imports absolutos (`package:arena_soccer/...`); sem barrel files
- Logs via `AppLogger` — nunca `print`

**UI**
- Espaçamento e fontSize sempre `AppSizes.sXX`; cor sempre `AppColors`
- Snackbar via `showSnackBar(...)` de `lib/utils/components/show_snackbar.dart`
- Botões/campos: `ArenaButton` (`.primary`/`.outlined`) e `ArenaTextField`
- Toda string visível via `AppLocalizations.of(context)`

## Schema do Firestore (não mudar sem migração)

| Coleção | Campos principais |
|---------|-------------------|
| `usuarios` | idUsuario, nome, email, time (nome, cópia), idTime (time do coração), admin (bool), urlImagem (opcional: foto da carteirinha; conta Google usa a foto do Google até trocar; conta Apple não tem foto), trocaTimeEm (opcional: hora do servidor da última troca de time; a 1ª escolha não grava; 1 troca a cada 15 dias, `TeamChangePolicy` + regras). Contas antigas têm `senha` em texto puro — não gravar mais |
| `noticias` | id, data (Timestamp), titulo, descricao, urlImagem, link, exibir ("true"/"false" **string**), fk_competicao, time_casa, time_fora, gol_time_casa, gol_time_fora, tag ("gol", "publicidade", título de destaque...), images[], idAutor (uid de quem publicou, notícias novas; o parceiro só mexe nas dele; sem o campo = só o admin). Notícia/publicidade do parceiro: id = vaga do dia `not<n>_<uid>_<a>-<m>-<d>` (n < `limiteNoticiasDia`) ou `pub<n>_…` (n < `limitePublicidadeDia`), Brasília, sem zero à esquerda; gravada no mesmo lote do marcador `vagas_parceiro/{id da vaga}` ({idAutor, criadoEm}; o parceiro não apaga), então apagar a publicação não devolve a vaga. Passou do limite de notícias: vai para `noticias_pendentes`. Cards de gol, opcionais: autor_gol_id, autor_gol, assistencia_id, assistencia (id/nome em `jogadores{ano}`), temporada, time_marcador, escudo_marcador (URL), id_time_casa, id_time_fora, id_time_marcador, cor_marcador, cor_marcador_secundaria (hex do time que marcou: fundo do card), id_campeonato (competição do gol; o gol soma também na inscrição dela). **Card de resultado** (`tag: "resultado"`, doc `resultado_<idPartida>`, gravado pelas functions ao fim da partida; `ResultCard` no feed): id_partida, temporada, escudo_casa/escudo_fora, cor_casa/cor_fora, campeonato (título; vazio = amistoso), id_campeonato, gols e times como acima; título/texto das frases de `functions/src/match_result.ts`. **Card "Vote no craque"** (`tag: "votacao"`, doc `votacao_<idPartida>`, ~15 min antes do fim ou ao encerrar; abre a votação se estiver fechada; `VoteCallCard`): os mesmos campos + votacao ("true"/"false", acompanha a da partida: "Votar agora" / "Ver resultado"); frases em `functions/src/vote_card.ts` |
| `destaques` | id, title, link, urlImagem, exibir (string), priority. Do parceiro: regiao/idRegiao (só aparece no carrossel dessa região; sem região = todas, `highlightsForRegion`), idAutor, id = vaga `dest<n>_<uid>` (n < `limiteDestaques`; apagar libera) e priority "900" (depois dos do admin; só o admin reordena) |
| `competicao` | nome (as "regiões": Floresta, Santo inacio...). O **id do doc** é o vínculo: os docs de conteúdo e os pedidos gravam `idRegiao` ao lado do nome (`fk_competicao`/`regiao`, só cópia). Renomear = trocar só o `nome` |
| `times{ano}` | id_partida (é o id do **time**, nome errado), nome, descricao, fk_competicao, urlImagem, idDono (opcional: uid do dono, times do "Sou dono de time"), corPrimaria/corSecundaria (opcionais, hex "#RRGGBB"; paleta em `lib/utils/constants/team_colors.dart`) |
| `classificacao{ano}` | campos do time + vitorias, derrotas, empates, gols_feitos, gols_sofridos, pontos, saldo_gols, fk_grupo. Nos grupos com campeonato, as functions **espelham** aqui os números da tabela calculada (para o app antigo); time em dois grupos ao mesmo tempo fica com o último cálculo |
| `tabelas{ano}/{idGrupo}` | **classificação automática**, gravada só pelas functions (`functions/src/standings.ts`) para os grupos com `fk_campeonato`: idCampeonato, grupo, idRegiao, criterios, atualizadoEm, linhas[] em ordem {idTime, nome, posicao, jogos, vitorias, empates, derrotas, golsPro, golsContra, saldo, pontos}. Contam as partidas do campeonato entre dois times do grupo e terminadas (`status: "encerrada"` ou com `resultadoNoticia`); vitória 3, empate 1; depois dos pontos, o `desempate` do campeonato e, por fim, o nome. Refeita do zero a cada mudança |
| `jogadores{ano}` | idJogador, nome, time (nome, cópia) + idTime = **time principal**, urlImagem, nGols, nAssistencias = **Geral da temporada = soma das competições** (o app lê nunca abaixo da soma; atleta antigo sem inscrições: o número gravado), nGolsAmistoso, nAssistenciasAmistoso (opcionais: gols/assistências em **amistosos**, partida sem competição; contagem à parte, fora do Geral; chip "Amistosos" = `PlayerDTO.friendlyId`). Manutenção do admin em Temporadas → "Corrigir números dos atletas" (`RepairPlayerTotalsUseCase`: Geral = soma, amistosos contados pela lista `gols` das partidas sem competição; e as inscrições sobem/são criadas pelos gols contados nas listas `gols` das partidas com competição, `championshipCounts` + `PlayerDTO.repairedEnrollments`, com o time do lado do gol). **Sem competição**: o que está no Geral acima da soma das inscrições (`unassignedGoals`/`unassignedAssists`; atleta antigo = o Geral inteiro) aparece na tela do atleta e o admin atribui ("Atribuir" no editor, chip Geral) a uma competição do atleta — soma só na inscrição — ou aos amistosos — sai do Geral (`assignUnassigned`). Opcionais: idUsuario (conta vinculada pelo "Sou jogador"), posicao (goleiro/zagueiro/lateral/volante/meia/atacante), inscricoes (mapa `c<id_campeonato>` → {idTime, time, nGols, nAssistencias}: por qual time joga e os números em cada competição), idsTimes (ids dos times das inscrições). Ver "Atletas por competição" |
| `partidas{ano}` | id_partida, dataRegistro, timeC, timeF (nomes, cópia), idTimeC, idTimeF, horario, data, local, id_campeonato, fk_competicao, golTimeCasa, golTimeFora, votacao (string), tituloVotacao, melhorJogador, quantidadeVotos, gols (opcional: lista {id, lado casa/fora, idJogador, jogador, idAssistencia, assistencia}; "Editar placar" edita a lista, o placar é a contagem dela e os números dos atletas acompanham pela diferença; o card de gol acrescenta o gol nela), idsRegioes (opcional: partida entre times de regiões diferentes, aparece na aba TABELAS das duas; índice `idsRegioes` + `dataRegistro` por coleção de temporada), duracao (int, minutos; sem o campo = 90: "EM ANDAMENTO" do horário até horário + duração), status (opcional: "andamento"/"intervalo"/"encerrada", marcado pelo admin, vale mais que o horário; `statusEm` = hora do servidor da última mudança; `MatchCardStatus`), inicioEm/intervaloEm/segundoTempoEm (opcionais, hora do servidor: relógio de jogo local `MatchClock` — 1º tempo, intervalo parado, 2º tempo a partir da metade da duração, acréscimo do 1º tempo até +10 sem o intervalo marcado; `SetMatchPhaseUseCase`). Iniciada na mão e esquecida em andamento/intervalo encerra sozinha 30 min depois do fim esperado (`MatchClock.expectedEnd` no app, `expectedEnd`/`shouldAutoFinish` em `functions/src/voting_close.ts`; o `closeVotings` grava `status: "encerrada"`), resultadoNoticia / votacaoNoticia (ids dos cards de resultado e de votação já postados; gravados pelas functions). craque (opcional: {nome, idJogador, idTime, votos, percentual}; o eleito pelos votos, gravado pela function quando `votacao` fecha — `functions/src/best_player.ts`, mesmas regras do `VotingOutcome`; sem eleito, sem o campo; só votações fechadas depois da mudança). Perfil do atleta: troféus = partidas com `craque.idJogador` (índice automático), "Últimas partidas" = gráfico das listas `gols` (`PlayerMatchStats`) e "Histórico" por temporada pelo `idUsuario` (só atleta com conta). Subcoleção `votos/{uid}` (melhor jogador): nome, time, idTime |
| `campeonatos` | titulo, descricao, urlImagem, premio1-3, premioArtilheiro, premioGoleiro, regras (resumo em texto), fk_competicao, id_campeonato (int; novo = maior + 1), ano, times[] (nomes, cópia), ids_times[] (ids, mesma ordem; '' = sem id), regulamentoUrl, regulamentoNome (PDF no Storage), abrangencia (`municipal`, padrão sem o campo: só times da região-sede; `intermunicipal`: times de qualquer região), idsRegioes (regiões dos times + a sede; o intermunicipal aparece em todas: consultas por região usam `RegionRegistry.whereRegionOrIn`). desempate (opcional: lista ordenada de `vitorias`, `saldo`, `golsPro`, `confronto`, `menosGolsContra`; vazio/sem o campo = vitórias, saldo, gols pró; `StandingsCriterion`), recalcularEm (hora do servidor: o "Recalcular tabelas" do admin). Cadastro pelo admin em "Campeonatos"; partidas pegam o id_campeonato do campeonato da região na temporada corrente (senão, a tabela fixa do `CreateMatchUseCase`) |
| `grupos{ano}` | descricao, fk_competicao, time1-4 (nomes), idTime1-4, fk_campeonato (opcional: `id_campeonato`; sem ele = grupo antigo, mostrado no campeonato que não tiver grupos próprios) |
| `melhorjogador{timeC}{timeF}` | **legado** (votos antigos, sem temporada): um doc por votante (id = uid): nome, time. Ainda lido como fallback; votos novos vão para `partidas{ano}/{id}/votos` |
| `config/temporadas` | atual (temporada em andamento), lista (seletor) |
| `config/votacao` | regras da votação de melhor jogador (admin → "Regras da votação"; leitura pública): minVotos (padrão 20), percentualMinimo (padrão 35). Sem o doc, os padrões. Apuração no app (`VotingOutcome`): só há eleito com o mínimo de votos, o mais votado com a % mínima e à frente do 2º (empate = sem eleito); voto no próprio atleta (`idUsuario` do atleta = id do voto) não conta |
| `config/notificacoes` | liga/desliga por ação de push: gol, noticia, partida, votacao_aberta, votacao_encerrada, jogo_do_dia, aviso (bool; ausente = padrão das functions) |
| `notificacoes_envios` | histórico gravado pelas Cloud Functions (id = evento): tipo, titulo, corpo, alvo, regiao, data, status (enviado/desligado/erro), erro, origem |
| `solicitacoes_jogador` | pedido "Sou jogador", id = uid (um por usuário): uid, nome_usuario, email, nome, time, idTime, regiao, temporada, posicao, mensagem, urlImagem, status (pendente/aprovada/rejeitada/removido), motivo, idJogador, data, atualizado_em, idCampeonato/campeonato (opcional: competição em que quer jogar pelo time; aprovar acrescenta a inscrição e não tira o atleta das outras; aprovado pode mandar pedido novo), idJogadorVinculo (opcional: atleta já cadastrado sem conta que o usuário diz ser; a tela lista os sem `idUsuario` do time escolhido). Aprovar = batch que cria o jogador (ou reaproveita o atleta da conta, mantendo os números; com `idJogadorVinculo`, liga a conta a esse atleta, recusando se ele já tem outra conta ou se a conta já tem outro atleta) e marca o pedido. Atleta vinculado não é excluído: "remover do elenco" zera o `time` e o pedido vira `removido` |
| `solicitacoes_time` | pedido "Sou dono de time", id = uid (um por usuário): uid, nome_usuario, email, nome (do time), regiao, descricao, urlImagem, corPrimaria, corSecundaria, contato (WhatsApp), mensagem, temporada, status (pendente/aprovada/rejeitada), motivo, idTime, data, atualizado_em. Aprovado = registro de dono que as regras consultam (`ownedTeam()`); o nome do time só o admin muda |
| `solicitacoes_parceiro` | pedido "Sou parceiro", id = uid (um por usuário): uid, nome_usuario, email, nome (página/loja/veículo), regiao/idRegiao, contato (WhatsApp), mensagem, status (pendente/aprovada/rejeitada/removido), motivo, data, atualizado_em, idsDestaquesVinculo (opcional, até 9: destaques **sem dono** e visíveis (`exibir` "true") que o usuário diz serem dele — marcados no pedido ou, aprovado, na área do parceiro; o parceiro aprovado só mexe nessa lista). O admin vincula (aprovar já vincula; parceiro ativo: "Vincular"/"Recusar") com `linkHighlights`: cada destaque ainda sem dono vira uma cópia na vaga livre `dest<n>_<uid>` (região do parceiro, `idAutor`, priority "900"), o antigo é apagado (o link `/destaque/<id antigo>` deixa de abrir; as notícias seguem pelo título), o `limiteDestaques` sobe para caber (`HighlightLinkPlan`) e a lista é limpa. **Permissões** (só o admin grava; padrão ao aprovar): podeNoticias, podeDestaques, podePublicidade (bool), limiteDestaques (2), limitePublicidadeDia (1), limiteNoticiasDia (3; as demais do dia vão para aprovação), 0..9. Aprovado = registro que as regras consultam (`partner()`) |
| `noticias_pendentes` | notícia do parceiro **além do limite do dia** (`limiteNoticiasDia`): campos da notícia + status (pendente/aprovada/rejeitada), motivo, criadoEm, idNoticia. O parceiro cria (confirmação "Enviar para aprovação" no formulário), lê e apaga as dele ("Aguardando o admin" na área do parceiro); o admin aprova (lote: cria em `noticias` com id automático, hora do servidor e o `idAutor`; marca `aprovada` + `idNoticia`) ou rejeita com motivo, na aba "Notícias" do painel "Parceiros" (`PendingNewsUseCase`) |
| `vagas_parceiro` | marcadores das vagas do dia usadas pelo parceiro (id = id da vaga, {idAutor, criadoEm}); gravados com a notícia/publicidade; o parceiro não apaga |
| `ranking_torcidas/{temporada}` | gravado de hora em hora pela function `fanRanking` (o app só lê): temporada, atualizado_em, total, times[] (id, nome, idRegiao, regiao, urlImagem, corPrimaria, corSecundaria, torcedores), em ordem do ranking |
| `conquistas` | catálogo de conquistas (admin → "Conquistas"; leitura pública): titulo, descricao, categoria, icone, nivel (bronze/prata/ouro/lenda), metrica, meta, pontos (XP), secreta, ativa, ordem. Métricas iguais no app (`AchievementMetric`) e nas functions (`functions/src/achievements.ts`) |
| `usuarios/{uid}/progresso/contadores` | contadores das conquistas. O app soma +1 só nos dele (compartilhamentos, noticiasLidas, diasAtivos/sequenciaDias/melhorSequencia/ultimoAcesso — regra no `firestore.rules`); o servidor grava votos (`onVoteCreated`), timeCoracao/fotoCarteirinha (`onUserProfileWritten`), atleta/golsAtleta/assistenciasAtleta (`onPlayerWritten`, jogadores da temporada atual), donoTime (`onTeamRequestWritten`) e `desbloqueadas` (ids já ganhos). Conta antiga sem os campos do servidor: o `onProgressWritten` preenche com uma leitura de cada |
| `usuarios/{uid}/conquistas/{id}` | desbloqueio gravado pelo `onProgressWritten` (em, vista); push `conquista` para `usuario_<uid>`; o app comemora as `vista: false` e marca `true` (com vibração); tocar no push (`data.tela = conquista`) abre "Minhas conquistas" e a comemoração dela (a já vista também). A 1ª avaliação de cada conta entra vista e sem push. `onUserDeleted` apaga as duas subcoleções |
| `partidas{ano}/{id}/palpites/{uid}` | bolão: golsCasa, golsFora, nome (cópia), atualizadoEm (hora do servidor); o dono grava só esses campos enquanto a partida não está andamento/intervalo/encerrada. Ao fim da partida (e a cada placar corrigido) as functions gravam pontos, exato e valido (feito depois do horário marcado ou do `inicioEm` = inválido, 0). Pontos: exato **10**, vencedor + saldo (ou empate com outro placar) **7**, só o vencedor **5** (`functions/src/predictions.ts`) |
| `palpites_ranking{ano}` | só as functions gravam (delta a cada pontuação), doc `<idRegiao>_<uid>`: uid, nome, idRegiao, pontos, exatos, palpites. O app lê o top 50 da região (desempate exatos e palpites no app) e a posição da conta por `count()`. Índices `idRegiao` + `pontos` (desc e asc) por coleção de temporada |
| `push_avisos` | aviso manual do admin (titulo, corpo, regiao vazia = todos, data); a function envia |

`{ano}`: **2023 é a única temporada sem sufixo** (legado: `times`, `partidas`...); todas as outras usam o ano (`times2022`, `times2024`). A temporada **atual** fica em `config/temporadas` (`atual`, `lista`; leitura pública, escrita do admin), carregada no `RegionCubit.load()` e aplicada em `SeasonCollection.configure`. Sem a config, vale 2023. Para abrir a temporada nova: admin → **Temporadas** → "Iniciar temporada" (opcionalmente copia os times com a classificação zerada); nada é copiado à mão nem renomeado, e os cadastros passam a ir para as coleções do ano novo. Não comparar com o ano do relógio.
Storage: `noticias/`, `destaques/`, `times/`, `jogadores/`, `campeonatos/` (banner e regulamento em PDF), `usuarios/` (foto da conta) (ver `StorageFolder`).

## Atletas por competição

- Cada região tem vários campeonatos; um time joga vários ao mesmo tempo; o mesmo atleta pode jogar pelo time A na competição X e pelo B na Y. O vínculo é a **inscrição** (`jogadores{ano}.inscricoes.c<id_campeonato>`, `PlayerEnrollment`), com o time e os números daquela competição; `idsTimes` lista os times (consultas e regras).
- `time`/`idTime` continuam como **time principal** (apps antigos, link público, ranking geral) e `nGols`/`nAssistencias` como **total**: todo gol soma nos dois (`incrementStats` com a inscrição). Atleta antigo sem `inscricoes` conta como inscrito, com 0, em toda competição do time principal (`PlayerDTO.playsIn`); nada é migrado.
- Elenco do time: "Elenco geral" (`watchTeamPlayers`: `idsTimes` array-contains, `idTime` ou nome) + uma chip por competição do time (filtro no app). Card de gol e votação filtram os elencos pela competição da partida; o ranking tem "Geral" + competições (`orderBy inscricoes.c<id>.<campo>`, índice automático).
- Inscrever: o admin põe o **time** numa competição pelo menu do elenco ("Inscrever em competição": municipais da região + intermunicipais; `ChampionshipsDataSource.setTeamEnrollment`, só o time entra); o admin/dono inscreve cada **atleta** nas competições do time pelo troféu no "Elenco geral" (`PlayersDataSource.enrollmentChanges`; atleta antigo vira inscrições reais só quando algo muda).
- Sair do elenco é por competição (`removeFromSquad(championshipId)`); sem inscrição sobrando, fica sem time. As inscrições nunca são apagadas do doc (só esvaziadas): a regra `keepsEnrollments` barra o `set` do app antigo.
- Function `onPlayerRequestWritten`: completa a inscrição de pedidos com competição aprovados pelo app antigo (`missingEnrollmentFix`).

## Regiões por id (implantação)

Índices compostos versionados em `firestore.indexes.json` (feed e classificação por `idRegiao`; a classificação precisa de um índice por coleção de temporada, então ao abrir uma temporada nova acrescente o `classificacao<ano>` e os dois do `palpites_ranking<ano>`). Ordem para publicar a mudança das regiões para id:
1. `firebase deploy --only "firestore:rules,firestore:indexes,functions"` (esperar os índices ficarem prontos no console).
2. Instalar o app novo no aparelho do admin e rodar **Regiões → Vincular regiões por id** (preenche o `idRegiao` nos docs antigos; pode repetir).
3. Só então liberar o app para os usuários (até o passo 2, as consultas por id não acham o conteúdo antigo).

Push: tópico `regiaoid_<id>` (o app assina também o `regiao_<slug>` do nome na transição; as functions mandam para o do id quando o doc tem `idRegiao`).

## Notificações push (FCM)

- **Envio:** Cloud Functions em `functions/` (TypeScript, região `us-central1`, a mesma do Firestore `nam5`). Gatilhos em `noticias`, `partidas` da temporada atual (gatilho em `{colecao}/{id}` filtrando a coleção de partidas da `config/temporadas`), `push_avisos`, `solicitacoes_jogador` (avisa admins, quem pediu e o dono do time) e `solicitacoes_time`, mais o agendamento diário `dailyGames` (9h, Brasília), o `closeVotings` (a cada 15 min: posta o card "Vote no craque" ~15 min antes do fim, `functions/src/vote_card.ts`; fecha a votação aberta 24h depois do fim da partida, data + horário + `duracao`; lógica em `functions/src/voting_close.ts`; na mesma rodada posta o **card de resultado** das partidas de hoje/ontem que acabaram, `functions/src/match_result.ts`; o `onMatchUpdated` posta na hora quando o admin encerra e atualiza o card se o placar mudar) e a classificação automática (`recomputeGroups`: no `postResult`/`updateResult`, partida terminada apagada, grupo criado/editado/apagado — tratados nos mesmos gatilhos curinga das partidas, sem gatilho novo de escrita — e `onChampionshipUpdated` quando mudam `desempate` ou `recalcularEm`), a pontuação do bolão (`scorePredictions`, chamada no `postResult` e no `updateResult`: pontos nos palpites, delta no `palpites_ranking{ano}` e as métricas `palpites`/`palpitesExatos` das conquistas) e o `fanRanking` (de hora em hora: conta os torcedores de cada time com `count()` em `usuarios` e grava `ranking_torcidas/{temporada}`; lógica em `functions/src/fan_ranking.ts`). `onPartnerRequestWritten` (`solicitacoes_parceiro`): pedido novo avisa `admins` (aba `solicitacoes_parceiro`); aprovado/rejeitado/parceria encerrada avisa quem pediu (aba `parceiro`); parceiro aprovado que pede vínculo de destaque avisa `admins`; `onPendingNewsWritten` (`noticias_pendentes`): pendente nova avisa `admins` (aba `noticias_pendentes`), publicada/rejeitada avisa o parceiro (ações `noticia_parceiro`/`noticia_parceiro_resposta`); ações `solicitacao_parceiro`/`solicitacao_parceiro_resposta` no painel de push. No mesmo gatilho dos pedidos "Sou jogador", a reconciliação de vínculo (`functions/src/claim_reconcile.ts`) corrige aprovações feitas por app antigo: se o pedido aprovado tem `idJogadorVinculo` diferente do `idJogador`, liga a conta ao atleta reivindicado (somando os números), apaga o atleta criado e aponta o pedido e os cards de gol para o reivindicado. Fora do push, `onUserDeleted` (gatilho v1 do Auth) apaga perfil, foto, pedidos (jogador, time e parceiro), notícias pendentes do parceiro e votos da conta excluída e tira o `idUsuario`/`idDono` dos atletas e times (regras de varredura em `functions/src/account_cleanup.ts`). Mensagens e alvos em `functions/src/messages.ts` (funções puras, `npm test`).
- **Tópicos:** `todos`, `regiao_<slug>`, `timeid_<idTime>` (time do coração pelo id), `usuario_<uid>` (logado) e `admins` (conta admin). `time_<slug do nome>` é o tópico antigo: o app novo só assina quando a conta ainda não tem `idTime`, e as functions mandam para os dois na transição. O slug/`teamIdTopic` de `lib/core/utils/push_topics.dart` e o de `messages.ts` precisam ser iguais.
- **App:** `PushService` (`lib/core/services/push_service.dart`) faz permissão, exibição em primeiro plano e toque: `PushTarget` (`data.aba` + `data.tela`/`id`/`temporada`, montados pelo `openData` das functions). Com tela, a home abre a partida (gol ligado à partida — o card grava `id_partida` —, partida cadastrada, jogo do dia), a votação dela (votar se aberta, o eleito se encerrada; `HomeCubit.findMatch`) ou a notícia; partida não achada ou sem tela = a aba. O `PushTopicsListener` (em `blocs_load.dart`) mantém os tópicos de acordo com a região e o time do coração.
- **Deploy das functions:** `cd functions && npm install`, depois `firebase deploy --only functions`.

## Cache local e economia de leituras

- **Leituras únicas (`get`)**: cache Hive no padrão do Relove + validade. `CacheStore` (`lib/core/cache/cache_store.dart`, box `arenaCache`, JSON `{savedAt, data}`), chaves em `cache_keys.dart`, validades em `cache_ttl.dart`. Por dado: repositório com `getCachedX`/`saveXCache`/`deleteXCache`, trio de use cases e um `XCacheFirstUseCase` que usa `cacheFirst` (`lib/core/cache/cache_first.dart`): cache válido = não busca; vencido = mostra e atualiza; `force: true` ignora a validade. Gravações invalidam o cache **no repositório**. Logout limpa tudo; mudar `CacheStore.schemaVersion` limpa ao abrir. DTOs em cache têm `toCache()`/`fromCache()` (região guardada por id e resolvida pelo `RegionRegistry`).
- **Streams** ficam no cache do próprio Firestore (persistência ilimitada). Para gastar menos: feed ao vivo só das 20 mais recentes + páginas antigas por `get` (`loadMore`); partidas filtradas por região no servidor; ranking só o top 50 (`getTopPlayers`, `whereIn` de ids de time); cubits das abas (feed, campeonatos, partidas) vivem na rota da home e não reabrem a consulta ao trocar de aba.
- Leitura nova: siga o mesmo padrão (não chame o Firestore direto do cubit, nem leia uma coleção inteira para filtrar no app).

## Links compartilhados e deep links

- **Links públicos:** `https://arenasoccerflutter.web.app/noticia/<id>`, `/atleta/<temporada>/<idJogador>`, `/destaque/<id>` e `/app` (montados em `lib/core/utils/share_links.dart`; todo texto de compartilhar termina com um deles).
- **Página do link:** Hosting (`hosting/public`) reescreve essas rotas para a function `sharePage` (`functions/src/share_page.ts`), que devolve HTML com Open Graph (prévia no WhatsApp) e o botão `intent://…` que abre o app (`arenafootball://<caminho>`) ou a Play Store. Cache de 10 min no CDN (`s-maxage=600`).
- **App:** `DeepLinkService` (`lib/core/services/deep_link_service.dart`, pacote `app_links`) recebe o link (App Links `https://arenasoccerflutter.web.app` + esquema `arenafootball://`, no `AndroidManifest`) e a home abre a tela. `hosting/public/.well-known/assetlinks.json` precisa do SHA-256 da chave de debug **e** do da assinatura da Play Store.
- **Deploy:** `firebase deploy --only "hosting,functions"`.

## Security Rules

Versionadas no repo: `firestore.rules` e `storage.rules` (projeto em `.firebaserc`). Qualquer mudança passa por esses arquivos e é publicada com:

```
firebase deploy --only "firestore:rules,firestore:indexes,storage"
```

- Leitura pública do conteúdo (inclui o modo convidado); `usuarios` só pelo dono ou admin.
- `usuarios`: trocar de um time do coração para outro exige `trocaTimeEm` = `request.time` e 15 dias desde a troca anterior; a primeira escolha é livre.
- Escrita de conteúdo só do admin (`usuarios/{uid}.admin == true`); o usuário não consegue gravar `admin` no próprio perfil.
- Votos (`melhorjogador*`): cada usuário logado grava só o doc com o próprio uid.
- `solicitacoes_jogador` / `solicitacoes_time` / `solicitacoes_parceiro`: o dono cria/corrige/reenvia o próprio pedido sempre como `pendente` (campos limitados; o parceiro nunca grava as permissões), nunca se aprova; o admin lê e responde.
- Parceiro (`partner()` = `solicitacoes_parceiro/{uid}` aprovado): cria em `noticias`/`destaques` com `idAutor` = uid e o `idRegiao` do pedido, dentro das permissões; notícia sem tags reservadas (gol/resultado/votacao) nem campos de gol; notícia só na vaga `not<n>_<uid>_<hoje>` e publicidade na `pub<n>_<uid>_<hoje>` (dia em Brasília), com o marcador `vagas_parceiro` no mesmo lote (`existsAfter`; marcador já existente = vaga usada); a notícia além do limite vai para `noticias_pendentes` (cria pendente, lê/apaga a dele; só o admin responde); destaque só na vaga `dest<n>_<uid>` com priority "900". Edita/apaga só o que tem o `idAutor` dele (publicidade continua publicidade; destaque não muda a priority). Casos testados no emulador do Firestore.
- Palpites: `partidas{ano}/{id}/palpites/{uid}` (leitura pública; o dono grava só golsCasa/golsFora 0-99, nome e `atualizadoEm == request.time`, com a partida ainda não iniciada pelo status); `palpites_ranking*` só leitura.
- Votos: `partidas{ano}/{id}/votos/{uid}` (leitura pública; cada logado grava só o próprio, campos nome/time/idTime). Os antigos `melhorjogador*` seguem as regras do conteúdo.
- Dono de time (`ownedTeam()` = `solicitacoes_time/{uid}` aprovado; compara pelo `idTime`, pelo nome em doc antigo sem id, e pelo `idsTimes` do atleta; aprova o "Sou jogador" de atleta de outro time só acrescentando a inscrição no dele, `joinsOwnedTeam`): cria/edita/apaga `jogadores*` do próprio time (ou sem time), troca só `descricao`/`urlImagem`/cores do time com `idDono` = uid, e responde (status/motivo/idJogador) os pedidos "Sou jogador" do time. Casos cobertos testados no emulador do Firestore.
- Erro `PERMISSION_DENIED` no logcat = regra negando; ajuste as regras, não o app.

## Débito técnico conhecido

- `usuarios.senha` em texto puro nas contas antigas (o app não grava mais; falta limpar a base)
- Booleanos gravados como string (`exibir`, `votacao`)

## Arquivos críticos

| Arquivo | Propósito |
|---------|-----------|
| `lib/main.dart` | Init Firebase, DI, runApp |
| `lib/arena_app.dart` | MaterialApp, rotas, tema, l10n, Cubits route-level |
| `lib/app_routes.dart` | Constantes de rota + `AppSession` (navigatorKey) |
| `lib/blocs_load.dart` | Cubits globais (`SessionCubit`, `RegionCubit`) |
| `lib/injection_container.dart` | `init()` orquestra `_registerExternal()` + `register*Dependencies()` |
