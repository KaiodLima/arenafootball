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

## Features (18 módulos em `lib/features/`)

| Feature | Conteúdo |
|---------|----------|
| `splash` | Restaura a sessão (auto-login) e decide entre home e login |
| `auth` | Login, cadastro de usuário, `SessionCubit` (global) |
| `regions` | Regiões (`competicao`) + região/temporada escolhidas, `RegionCubit` (global) |
| `home` | Casca: AppBar, drawer, barra inferior com as 4 abas, atalhos do admin |
| `news` | Feed (aba HOME), detalhe, cadastro/edição, notificação de gol, anúncio |
| `highlights` | Carrossel de destaques, detalhe, cadastro |
| `teams` | Aba TIMES, cadastro de time (+ linha na classificação), edição pelo admin (escudo, descrição, cores e região; o nome é fixo), exclusão pelo admin (no elenco do time: jogadores com conta ficam sem time, os sem vínculo saem junto; partidas ficam) |
| `players` | Elenco do time, edição de gols/assistências/foto, cadastro de jogador |
| `player_requests` | "Sou jogador": usuário pede para entrar num time; painel do admin aprova (cria o jogador vinculado), rejeita ou edita |
| `team_requests` | "Sou dono de time": usuário pede para criar o time; admin aprova (cria o time com `idDono`). Aprovado, "Meu time": elenco, pedidos "Sou jogador" do time e edição de escudo/descrição. `OwnedTeamCubit` (global) diz de qual time a conta é dono |
| `seasons` | Temporada atual/lista em `config/temporadas`; painel do admin "Temporadas" (iniciar a próxima) e a manutenção "Vincular times por id" (completa os ids de time nos docs antigos e copia os votos antigos; pode rodar de novo) |
| `stats` | Ranking de artilharia/assistências (uma tela, `StatsRankingType`) |
| `championships` | Aba CAMPEONATOS, detalhe (regulamento PDF, times, premiação), grupos, classificação, cadastro/edição do admin |
| `matches` | Aba TABELAS, lista de partidas (hoje/todas), cadastro, placar, votação on/off |
| `voting` | Votar no melhor jogador, contagem de votos, jogador eleito |
| `global_results` | Resultados pelo mundo (scraping do soccerstats.com; parser em `data/parsers/`) |
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
| `usuarios` | idUsuario, nome, email, time (nome, cópia), idTime (time do coração), admin (bool), urlImagem (opcional: foto da carteirinha; conta Google usa a foto do Google até trocar). Contas antigas têm `senha` em texto puro — não gravar mais |
| `noticias` | id, data (Timestamp), titulo, descricao, urlImagem, link, exibir ("true"/"false" **string**), fk_competicao, time_casa, time_fora, gol_time_casa, gol_time_fora, tag ("gol", "publicidade", título de destaque...), images[]. Cards de gol, opcionais: autor_gol_id, autor_gol, assistencia_id, assistencia (id/nome em `jogadores{ano}`), temporada, time_marcador, escudo_marcador (URL), id_time_casa, id_time_fora, id_time_marcador |
| `destaques` | id, title, link, urlImagem, exibir (string), priority |
| `competicao` | nome (as "regiões": Floresta, Santo inacio...) |
| `times{ano}` | id_partida (é o id do **time**, nome errado), nome, descricao, fk_competicao, urlImagem, idDono (opcional: uid do dono, times do "Sou dono de time"), corPrimaria/corSecundaria (opcionais, hex "#RRGGBB"; paleta em `lib/utils/constants/team_colors.dart`) |
| `classificacao{ano}` | campos do time + vitorias, derrotas, empates, gols_feitos, gols_sofridos, pontos, saldo_gols, fk_grupo |
| `jogadores{ano}` | idJogador, nome, time (nome, cópia), idTime, urlImagem, nGols, nAssistencias. Opcionais: idUsuario (conta vinculada pelo "Sou jogador"), posicao (goleiro/zagueiro/lateral/meia/atacante) |
| `partidas{ano}` | id_partida, dataRegistro, timeC, timeF (nomes, cópia), idTimeC, idTimeF, horario, data, local, id_campeonato, fk_competicao, golTimeCasa, golTimeFora, votacao (string), tituloVotacao, melhorJogador, quantidadeVotos. Subcoleção `votos/{uid}` (melhor jogador): nome, time, idTime |
| `campeonatos` | titulo, descricao, urlImagem, premio1-3, premioArtilheiro, premioGoleiro, regras (resumo em texto), fk_competicao, id_campeonato (int; novo = maior + 1), ano, times[] (nomes, cópia), ids_times[] (ids, mesma ordem; '' = sem id), regulamentoUrl, regulamentoNome (PDF no Storage). Cadastro pelo admin em "Campeonatos"; partidas pegam o id_campeonato do campeonato da região na temporada corrente (senão, a tabela fixa do `CreateMatchUseCase`) |
| `grupos{ano}` | descricao, fk_competicao, time1-4 (nomes), idTime1-4, fk_campeonato (opcional: `id_campeonato`; sem ele = grupo antigo, mostrado no campeonato que não tiver grupos próprios) |
| `melhorjogador{timeC}{timeF}` | **legado** (votos antigos, sem temporada): um doc por votante (id = uid): nome, time. Ainda lido como fallback; votos novos vão para `partidas{ano}/{id}/votos` |
| `config/temporadas` | atual (temporada em andamento), lista (seletor) |
| `config/notificacoes` | liga/desliga por ação de push: gol, noticia, partida, votacao_aberta, votacao_encerrada, jogo_do_dia, aviso (bool; ausente = padrão das functions) |
| `notificacoes_envios` | histórico gravado pelas Cloud Functions (id = evento): tipo, titulo, corpo, alvo, regiao, data, status (enviado/desligado/erro), erro, origem |
| `solicitacoes_jogador` | pedido "Sou jogador", id = uid (um por usuário): uid, nome_usuario, email, nome, time, idTime, regiao, temporada, posicao, mensagem, urlImagem, status (pendente/aprovada/rejeitada/removido), motivo, idJogador, data, atualizado_em. Aprovar = batch que cria o jogador (ou reaproveita o atleta da conta, mantendo os números) e marca o pedido. Atleta vinculado não é excluído: "remover do elenco" zera o `time` e o pedido vira `removido` |
| `solicitacoes_time` | pedido "Sou dono de time", id = uid (um por usuário): uid, nome_usuario, email, nome (do time), regiao, descricao, urlImagem, corPrimaria, corSecundaria, contato (WhatsApp), mensagem, temporada, status (pendente/aprovada/rejeitada), motivo, idTime, data, atualizado_em. Aprovado = registro de dono que as regras consultam (`ownedTeam()`); o nome do time só o admin muda |
| `push_avisos` | aviso manual do admin (titulo, corpo, regiao vazia = todos, data); a function envia |

`{ano}`: **2023 é a única temporada sem sufixo** (legado: `times`, `partidas`...); todas as outras usam o ano (`times2022`, `times2024`). A temporada **atual** fica em `config/temporadas` (`atual`, `lista`; leitura pública, escrita do admin), carregada no `RegionCubit.load()` e aplicada em `SeasonCollection.configure`. Sem a config, vale 2023. Para abrir a temporada nova: admin → **Temporadas** → "Iniciar temporada" (opcionalmente copia os times com a classificação zerada); nada é copiado à mão nem renomeado, e os cadastros passam a ir para as coleções do ano novo. Não comparar com o ano do relógio.
Storage: `noticias/`, `destaques/`, `times/`, `jogadores/`, `campeonatos/` (banner e regulamento em PDF), `usuarios/` (foto da conta) (ver `StorageFolder`).

## Notificações push (FCM)

- **Envio:** Cloud Functions em `functions/` (TypeScript, região `us-central1`, a mesma do Firestore `nam5`). Gatilhos em `noticias`, `partidas` da temporada atual (gatilho em `{colecao}/{id}` filtrando a coleção de partidas da `config/temporadas`), `push_avisos`, `solicitacoes_jogador` (avisa admins, quem pediu e o dono do time) e `solicitacoes_time`, mais o agendamento diário `dailyGames` (9h, Brasília). Mensagens e alvos em `functions/src/messages.ts` (funções puras, `npm test`).
- **Tópicos:** `todos`, `regiao_<slug>`, `timeid_<idTime>` (time do coração pelo id), `usuario_<uid>` (logado) e `admins` (conta admin). `time_<slug do nome>` é o tópico antigo: o app novo só assina quando a conta ainda não tem `idTime`, e as functions mandam para os dois na transição. O slug/`teamIdTopic` de `lib/core/utils/push_topics.dart` e o de `messages.ts` precisam ser iguais.
- **App:** `PushService` (`lib/core/services/push_service.dart`) faz permissão, exibição em primeiro plano e toque (abre a aba do `data.aba`). O `PushTopicsListener` (em `blocs_load.dart`) mantém os tópicos de acordo com a região e o time do coração.
- **Deploy das functions:** `cd functions && npm install`, depois `firebase deploy --only functions`.

## Security Rules

Versionadas no repo: `firestore.rules` e `storage.rules` (projeto em `.firebaserc`). Qualquer mudança passa por esses arquivos e é publicada com:

```
firebase deploy --only firestore:rules,storage
```

- Leitura pública do conteúdo (inclui o modo convidado); `usuarios` só pelo dono ou admin.
- Escrita de conteúdo só do admin (`usuarios/{uid}.admin == true`); o usuário não consegue gravar `admin` no próprio perfil.
- Votos (`melhorjogador*`): cada usuário logado grava só o doc com o próprio uid.
- `solicitacoes_jogador` / `solicitacoes_time`: o dono cria/corrige/reenvia o próprio pedido sempre como `pendente` (campos limitados), nunca se aprova; o admin lê e responde.
- Votos: `partidas{ano}/{id}/votos/{uid}` (leitura pública; cada logado grava só o próprio, campos nome/time/idTime). Os antigos `melhorjogador*` seguem as regras do conteúdo.
- Dono de time (`ownedTeam()` = `solicitacoes_time/{uid}` aprovado; compara pelo `idTime`, e pelo nome em doc antigo sem id): cria/edita/apaga `jogadores*` do próprio time (ou sem time), troca só `descricao`/`urlImagem`/cores do time com `idDono` = uid, e responde (status/motivo/idJogador) os pedidos "Sou jogador" do time. Casos cobertos testados no emulador do Firestore.
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
