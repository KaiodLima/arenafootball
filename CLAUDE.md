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

## Features (16 módulos em `lib/features/`)

| Feature | Conteúdo |
|---------|----------|
| `splash` | Restaura a sessão (auto-login) e decide entre home e login |
| `auth` | Login, cadastro de usuário, `SessionCubit` (global) |
| `regions` | Regiões (`competicao`) + região/temporada escolhidas, `RegionCubit` (global) |
| `home` | Casca: AppBar, drawer, barra inferior com as 4 abas, atalhos do admin |
| `news` | Feed (aba HOME), detalhe, cadastro/edição, notificação de gol, anúncio |
| `highlights` | Carrossel de destaques, detalhe, cadastro |
| `teams` | Aba TIMES, cadastro de time (+ linha na classificação) |
| `players` | Elenco do time, edição de gols/assistências/foto, cadastro de jogador |
| `player_requests` | "Sou jogador": usuário pede para entrar num time; painel do admin aprova (cria o jogador vinculado), rejeita ou edita |
| `stats` | Ranking de artilharia/assistências (uma tela, `StatsRankingType`) |
| `championships` | Aba CAMPEONATOS, detalhe, grupos, classificação |
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
| `usuarios` | idUsuario, nome, email, time, admin (bool). Contas antigas têm `senha` em texto puro — não gravar mais |
| `noticias` | id, data (Timestamp), titulo, descricao, urlImagem, link, exibir ("true"/"false" **string**), fk_competicao, time_casa, time_fora, gol_time_casa, gol_time_fora, tag ("gol", "publicidade", título de destaque...), images[]. Cards de gol, opcionais: autor_gol_id, autor_gol, assistencia_id, assistencia (id/nome em `jogadores{ano}`), temporada, time_marcador, escudo_marcador (URL) |
| `destaques` | id, title, link, urlImagem, exibir (string), priority |
| `competicao` | nome (as "regiões": Floresta, Santo inacio...) |
| `times{ano}` | id_partida (é o id do **time**, nome errado), nome, descricao, fk_competicao, urlImagem |
| `classificacao{ano}` | campos do time + vitorias, derrotas, empates, gols_feitos, gols_sofridos, pontos, saldo_gols, fk_grupo |
| `jogadores{ano}` | idJogador, nome, time, urlImagem, nGols, nAssistencias. Opcionais: idUsuario (conta vinculada pelo "Sou jogador"), posicao (goleiro/zagueiro/lateral/meia/atacante) |
| `partidas{ano}` | id_partida, dataRegistro, timeC, timeF, horario, data, local, id_campeonato, fk_competicao, golTimeCasa, golTimeFora, votacao (string), tituloVotacao, melhorJogador, quantidadeVotos |
| `campeonatos` | titulo, descricao, urlImagem, premio1-3, premioArtilheiro, premioGoleiro, regras, fk_competicao, id_campeonato |
| `grupos{ano}` | descricao, fk_competicao |
| `melhorjogador{timeC}{timeF}` | um doc por votante (id = uid): nome, time |
| `config/notificacoes` | liga/desliga por ação de push: gol, noticia, partida, votacao_aberta, votacao_encerrada, jogo_do_dia, aviso (bool; ausente = padrão das functions) |
| `notificacoes_envios` | histórico gravado pelas Cloud Functions (id = evento): tipo, titulo, corpo, alvo, regiao, data, status (enviado/desligado/erro), erro, origem |
| `solicitacoes_jogador` | pedido "Sou jogador", id = uid (um por usuário): uid, nome_usuario, email, nome, time, regiao, temporada, posicao, mensagem, urlImagem, status (pendente/aprovada/rejeitada), motivo, idJogador, data, atualizado_em. Aprovar = batch que cria o jogador e marca o pedido |
| `push_avisos` | aviso manual do admin (titulo, corpo, regiao vazia = todos, data); a function envia |

`{ano}`: a temporada corrente (`SeasonCollection.currentSeason`, hoje **2023**) fica nas coleções sem sufixo; as anteriores usam o ano como sufixo (`times2022`). Não comparar com o ano do relógio. Para abrir uma temporada nova: copiar as coleções sem sufixo para `<nome><ano>`, limpar as sem sufixo e atualizar `currentSeason`/`seasons`.
Storage: `noticias/`, `destaques/`, `times/`, `jogadores/` (ver `StorageFolder`).

## Notificações push (FCM)

- **Envio:** Cloud Functions em `functions/` (TypeScript, região `us-central1`, a mesma do Firestore `nam5`). Gatilhos em `noticias`, `partidas` (temporada corrente), `push_avisos` e `solicitacoes_jogador`, mais o agendamento diário `dailyGames` (9h, Brasília). Mensagens e alvos em `functions/src/messages.ts` (funções puras, `npm test`).
- **Tópicos:** `todos`, `regiao_<slug>`, `time_<slug>`, `usuario_<uid>` (logado) e `admins` (conta admin). O slug de `lib/core/utils/push_topics.dart` e o de `messages.ts` precisam ser iguais.
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
- `solicitacoes_jogador`: o dono cria/corrige/reenvia o próprio pedido sempre como `pendente` (campos limitados), nunca se aprova; o admin lê e responde.
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
