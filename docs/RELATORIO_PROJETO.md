# Raio-X Arena Football

Relatório técnico do projeto. Levantado no repositório em 02/11/2026, na versão 2.0.12+37, branch `main`, com 181 commits entre fev/2023 e nov/2026. Os números vêm da contagem de arquivos e linhas e dos testes rodados localmente. Nenhum dado de produção foi lido.

Para as regras de código e o schema completo do Firestore, a fonte é o `CLAUDE.md` na raiz. Este relatório resume e avalia.

---

## 1. Resumo

O Arena Football é um app de futebol amador regional em **Flutter + Firebase**, sem API própria. Reúne notícias, times, atletas, partidas com súmula, tabelas automáticas, votação do craque, bolão, conquistas, álbum de figurinhas e indicação de amigos.
- **Alvo:** Android.
- **Idiomas:** pt-BR (principal) e en.

| Métrica | Valor |
|---|---|
| Código Dart do app (sem l10n) | 717 arquivos, ~76 mil linhas |
| Módulos de funcionalidade (`lib/features/`) | 25 |
| Rotas de tela | 55 |
| Textos traduzidos (chaves por idioma) | 1.450 |
| Cloud Functions publicadas | 22 (16 módulos TypeScript, ~3,9 mil linhas) |
| Regras do Firestore (`firestore.rules`) | 699 linhas |
| Índices compostos (`firestore.indexes.json`) | 36 |
| Testes do app | 80 arquivos, 507 testes passando |
| Testes das functions | 15 arquivos, 101 testes passando |
| Testes das regras (emulador) | 4 arquivos, 52 casos passando |

**Situação:**
- O código está organizado, o `flutter analyze` não mostra nenhum aviso e há só 2 TODO/FIXME no código.
- Os testes cobrem bem as regras de negócio.
- Os maiores riscos estão na operação:
  - os deploys são manuais e não há CI;
  - há dados legados (senhas antigas em texto puro);
  - o `functions/src/index.ts` está grande demais.

---

## 2. Produto

O app gira em torno de **regiões** (municípios e bairros, coleção `competicao`) e **temporadas**. Tudo é filtrado pela região escolhida, e cada temporada tem as próprias coleções de times, atletas e partidas.

### Conteúdo
- Feed de notícias ao vivo com paginação, destaques em carrossel e publicidade.
- Cards automáticos de gol, de resultado e "Vote no craque".
- Parceiros (sub-admins) publicam na própria região, com vagas diárias e aprovação do admin acima do limite.
- Links públicos (`/noticia`, `/atleta`, `/destaque`, `/convite`, `/app`) com prévia no WhatsApp e abertura direta no app.

### Competições
- Times com cores e escudo. Atletas inscritos **por competição**: o mesmo atleta pode jogar pelo time A na competição X e pelo B na Y.
- Partidas:
  - relógio de jogo;
  - "Atrasou": +10/+15/+20/+30 minutos, outro horário ou "Começou agora";
  - "Pausar até começar";
  - súmula com gols, cartões, escalação, árbitro e observações.
- Classificação calculada pelo servidor, com critérios de desempate configuráveis.
- Artilharia e assistências: Geral e por competição.
- Campeonatos municipais e intermunicipais.

### Engajamento
- Votação do melhor jogador (mínimo de votos e porcentagem configuráveis).
- Bolão grátis com ranking por região.
- Conquistas com nível/XP e carteirinha do torcedor.
- Álbum de figurinhas: pacotinho a cada 24 h, figurinhas raras e ranking de colecionadores.
- Ranking de torcidas.
- "Indique amigos":
  - código e link de convite;
  - 1 pacotinho extra para quem indica e para o indicado;
  - liga/desliga pelo admin.

### Administração
- Painel único com três grupos: Conteúdo, Competição e Configurações.
- Pedidos "Sou jogador", "Sou dono de time" e "Sou parceiro".
- Push com liga/desliga por tipo, histórico e aviso manual.
- Abertura de temporada, vínculo de regiões e times por id, correção dos números dos atletas e recompressão de imagens do Storage.

---

## 3. Arquitetura

Clean Architecture por funcionalidade. Cada módulo tem `data/` (datasources, repositories, dtos), `domain/` (interfaces de repositório e use cases), `presentation/` (bloc, page, widgets) e `di/`.

```
Página (widgets, l10n)
  -> Cubit (estado da tela)
    -> UseCase (regra de negócio)
      -> Repository (implementação; cache Hive)
        -> DataSource (único lugar com Firestore; Either + AppLogger)
          -> Firebase (Firestore, Auth, Storage)
```

- **Erros:** sempre `Either<Failure, T>` (`either_dart`), nunca `throw`. Streams do Firestore passam por `.toEither(...)` (`lib/core/firebase/either_stream.dart`).
- **Injeção de dependências:**
  - `get_it` (`sl()`);
  - registro por módulo em `lib/features/<f>/di/`, orquestrado por `lib/injection_container.dart`;
  - Cubits não entram no DI.
- **Cubits globais** (`lib/blocs_load.dart`): sessão, região/temporada, dono de time, atleta da conta, parceiro, evento do álbum, conquistas e a config das indicações.
- **Cubits de tela:** criados na rota em `lib/arena_app.dart`.
- **Economia de leituras:**
  - Leituras únicas usam cache Hive com validade, pelo `cacheFirst` (`lib/core/cache/`). Com o cache válido, não busca; com ele vencido, mostra o que tem e atualiza.
  - Streams ficam no cache do próprio Firestore. O feed ao vivo traz só as 20 notícias mais recentes, e as antigas vêm em páginas.
  - As consultas filtram no servidor (região, temporada, top 50). Nunca se lê uma coleção inteira para filtrar no app.

### Visão do sistema

```
App Flutter (Android) --lê/grava--> Firestore / Auth / Storage (regras versionadas, região nam5)
Firestore --gatilhos--> Cloud Functions (22, us-central1, TypeScript)
Cloud Functions --envia--> FCM (tópicos: região, time, usuário, admins) --> aparelho
Hosting (/noticia /atleta /destaque /convite /app) --reescreve--> function sharePage
```

### Stack
- **Base:** Flutter 3.38, Dart >=3.0.0 <4.0.0, Android (AGP 8.9, Kotlin 2.2, Gradle 8.11, Java 17, minSdk 23).
- **Pacotes principais:**
  - Firebase: `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`, `firebase_messaging`;
  - estado e injeção: `flutter_bloc`, `get_it`, `either_dart`;
  - cache local: `hive`, `hive_flutter`, `shared_preferences`;
  - links, compartilhar e login: `app_links`, `share_plus`, `google_sign_in`;
  - notificações e imagens: `flutter_local_notifications`, `flutter_image_compress`;
  - scraping: `http`, `beautiful_soup_dart`.

---

## 4. Módulos

| Módulo | Arquivos | Linhas | Papel |
|---|---:|---:|---|
| matches | 59 | 10.131 | Aba Tabelas, partidas, súmula, relógio, atraso e pausa |
| news | 51 | 6.499 | Feed, detalhe, cadastro, card de gol, publicidade |
| album | 23 | 6.488 | Álbum de figurinhas, pacotinhos, ranking, painel do admin |
| players | 49 | 6.169 | Elenco, perfil do atleta, inscrições, cadastro |
| championships | 56 | 5.101 | Campeonatos, grupos, classificação automática |
| player_requests | 26 | 3.299 | "Sou jogador" e o painel de aprovação |
| voting | 39 | 3.278 | Votação do craque e apuração |
| achievements | 30 | 3.072 | Conquistas, nível/XP, catálogo do admin |
| auth | 44 | 2.889 | Login, cadastro, sessão, excluir conta |
| partner_requests | 23 | 2.803 | Parceiros, permissões, notícias pendentes |
| team_requests | 25 | 2.631 | "Sou dono de time" e "Meu time" |
| highlights | 30 | 2.168 | Destaques do carrossel |
| teams | 33 | 1.972 | Aba Times, cadastro e edição |
| regions | 24 | 1.893 | Regiões, seletor (`RegionSelectTile`) e painel |
| global_results | 25 | 1.715 | Resultados pelo mundo (scraping do soccerstats.com) |
| home | 9 | 1.702 | Casca, drawer, abas, painel admin |
| predictions | 14 | 1.299 | Bolão e ranking de palpiteiros |
| referrals | 12 | 1.166 | Indique amigos e liga/desliga |
| stats | 16 | 1.125 | Artilharia e assistências |
| notifications | 14 | 1.095 | Painel de push e tópicos |
| seasons | 19 | 1.052 | Temporadas e manutenções |
| fan_card | 5 | 688 | Carteirinha do torcedor |
| fan_ranking | 9 | 670 | Ranking de torcidas |
| maintenance | 9 | 385 | Recompressão de imagens |
| splash | 1 | 72 | Abertura e auto-login |

Quatro módulos (matches, news, album, players) concentram cerca de 38% do código.

Arquivos de tela mais longos, candidatos a dividir quando forem alterados:

| Arquivo | Linhas |
|---|---:|
| `players/presentation/page/player_profile_page.dart` | 1.010 |
| `album/presentation/widgets/pack_opening_dialog.dart` | 968 |
| `matches/presentation/widgets/match_card.dart` | 947 |
| `album/presentation/page/sticker_detail_page.dart` | 711 |
| `album/presentation/page/manage_album_page.dart` | 668 |

---

## 5. Dados (Firestore)

Quatro convenções sustentam o modelo. Quebrá-las é a causa mais comum de bug:

1. **Temporada por sufixo:** `partidas2026`, `jogadores2026` etc., montados sempre por `SeasonCollection.name(...)`.
   - 2023 é a única temporada sem sufixo.
   - A temporada atual vem de `config/temporadas`, nunca do relógio.
2. **Vínculo por id:** região (`idRegiao`, doc de `competicao`) e time (`idTime`, doc de `times{ano}`).
   - O nome gravado ao lado é só cópia para exibir.
   - Leituras e consultas passam pelo `RegionRegistry` e pelo `sameTeam`/`TeamDirectory`, com fallback no nome para docs antigos.
3. **Inscrições por competição:** o atleta tem `inscricoes.c<id_campeonato>` com o time e os números daquela competição.
   - O Geral (`nGols`/`nAssistencias`) é a soma das inscrições.
   - Um atleta joga por um time só em cada competição.
4. **Gravado só pelo servidor:** o app só lê, e as regras barram a escrita. Vale para:
   - classificação (`tabelas{ano}`);
   - pontos do bolão;
   - contadores de conquistas;
   - álbum;
   - ranking de torcidas;
   - saldo das indicações.

| Grupo | Coleções |
|---|---|
| Contas | `usuarios` (+ `progresso/contadores`, `conquistas`, `album`), `codigos_indicacao`, `indicacoes` (+ `indicados`) |
| Conteúdo | `noticias`, `destaques`, `noticias_pendentes`, `vagas_parceiro`, `push_avisos` |
| Competição (por temporada) | `times`, `jogadores`, `partidas` (+ `votos`, `palpites`), `grupos`, `classificacao`, `tabelas`, `palpites_ranking` |
| Estrutura | `competicao` (regiões), `campeonatos`, `conquistas`, `album_eventos` (+ `figurinhas`, `ranking`), `album_pacotes` |
| Pedidos | `solicitacoes_jogador`, `solicitacoes_time`, `solicitacoes_parceiro` |
| Config e operação | `config/temporadas`, `config/votacao`, `config/notificacoes`, `config/indicacao`, `notificacoes_envios`, `ranking_torcidas`, `manutencao` |
| Legado | `melhorjogador{timeC}{timeF}` (votos antigos, só leitura) |

Storage: `noticias/`, `destaques/`, `times/`, `jogadores/`, `campeonatos/`, `usuarios/`, `album/`.

---

## 6. Backend (Cloud Functions)

Ficam em `functions/src`. A lógica está dividida em módulos de funções puras testáveis (`match_result`, `vote_card`, `voting_close`, `standings`, `predictions`, `best_player`, `album`, `achievements`, `referrals`, `fan_ranking`, `claim_reconcile`, `account_cleanup`, `recompress`, `share_page`, `messages`). Os gatilhos são ligados num `index.ts` de 1.342 linhas.

| Tipo | Qtd. | Funções |
|---|---:|---|
| Gatilhos do Firestore | 17 | onNewsCreated, onMatchCreated, onMatchUpdated, onMatchOrGroupDeleted, onChampionshipUpdated, onNoticeCreated, onPlayerRequestWritten, onTeamRequestWritten, onPartnerRequestWritten, onPendingNewsWritten, onVoteCreated, onUserProfileWritten, onReferralConfigWritten, onPlayerWritten, onProgressWritten, onRecompressRequested, onAlbumPackRequested |
| Agendamentos | 3 | `dailyGames` (9h, Brasília); `closeVotings` (a cada 15 min: card "Vote no craque", card de resultado, encerramento automático, fechamento de votação, push do pacotinho); `fanRanking` (de hora em hora) |
| HTTP | 1 | `sharePage` (páginas com Open Graph dos links públicos) |
| Auth | 1 | `onUserDeleted` (apaga dados e desfaz vínculos da conta excluída) |

### Segurança e anti-fraude
- A leitura do conteúdo é pública (inclui o modo convidado); `usuarios` só é lido pelo dono ou pelo admin.
- A escrita de conteúdo é só do admin, com papéis delegados:
  - **dono de time:** mexe no próprio time e no elenco dele;
  - **parceiro:** publica na própria região, dentro das permissões e vagas.
- Ninguém grava `admin` no próprio perfil. A troca de time do coração é limitada a uma a cada 15 dias, pela hora do servidor.
- Os contadores sensíveis (votos, gols, álbum, indicações) são gravados só pelo servidor.
- Os ids de vaga e de sequência no próprio id do doc impedem repetição: `not<n>_<uid>_<dia>`, `dest<n>_<uid>`, `<evento>_<uid>_<n>`.
- Regras testadas no emulador em `test/rules/`: atletas, palpites, álbum e indicações.

---

## 7. Qualidade

| Camada | Arquivos | Testes | Como rodar |
|---|---:|---:|---|
| App (unidade e widget) | 80 | 507 | `flutter test` |
| Cloud Functions | 15 | 101 | `cd functions && npm test` |
| Regras do Firestore | 4 | 52 | `firebase emulators:exec --only firestore --project demo-arena "node test/rules/run.mjs"` |

**Pontos fortes:**
- O `flutter analyze` não mostra nenhum aviso.
- As regras de negócio estão em funções puras com testes: `MatchClock`, `MatchReport`, `MatchTime`, `VotingOutcome`, `DelayMatchUseCase`, `packKind`, `referralDecision` e outras.
- Os padrões obrigatórios estão documentados no `CLAUDE.md` e são seguidos: Either, toEither, `AppSizes`/`AppColors`, l10n, imports absolutos, `AppLogger`.
- A tradução pt/en está completa.

**Lacunas:**
- Não há automação (CI): os testes só rodam manualmente.
- Não há testes de integração no aparelho para os fluxos completos (login, súmula, álbum).
- Os testes de regras cobrem quatro áreas; notícias do parceiro, pedidos e votos dependem de verificação manual.
- Não há monitoramento de erros no app (Crashlytics) nem alerta de custo do Firebase.

---

## 8. Riscos e débito técnico

| Severidade | Item | Detalhe |
|---|---|---|
| Alto | Senhas antigas em texto puro | Contas antigas ainda têm `usuarios.senha`. O app não grava mais, mas o dado continua na base: risco de vazamento e de LGPD. |
| Alto | Deploy manual sem CI | Regras, índices, functions e Hosting são publicados à mão. Um passo esquecido (índice da temporada nova, rewrite do Hosting) quebra telas em produção sem aviso. |
| Médio | `functions/src/index.ts` com 1.342 linhas | Concentra todos os gatilhos: mudar uma área arrisca outra. |
| Médio | Índices por temporada | Cada temporada nova precisa de índices novos (`classificacao<ano>` e dois de `palpites_ranking<ano>`). Sem eles, a classificação e o bolão falham. |
| Médio | Scraping do soccerstats.com | "Resultados pelo mundo" depende do HTML de um site externo. |
| Médio | App Links do Android | O `hosting/public/.well-known/assetlinks.json` precisa do SHA-256 da assinatura da Play Store; sem ele, os links abrem no navegador. |
| Baixo | Booleanos gravados como texto | `exibir` e `votacao` valem "true"/"false" em string. |
| Baixo | iOS e Windows sem manutenção | As pastas existem, mas não são testadas. |
| Baixo | Telas muito longas | Perfil do atleta, card da partida e abertura do pacotinho são mais caros de revisar. |

---

## 9. Recomendações

**Agora**
- Apagar o campo `senha` das contas antigas com uma manutenção do admin (function em lotes).
- Criar CI (GitHub Actions) com `flutter analyze`, `flutter test`, `npm test` e os testes de regras.
- Ligar alertas de orçamento no Google Cloud.

**Próximos meses**
- Dividir o `index.ts` por área (partidas, conteúdo, álbum, contas), mantendo a lógica pura onde já está.
- Ativar o Crashlytics no Android.
- Escrever testes de regras para notícias do parceiro, pedidos e votos.
- Montar um checklist de abertura de temporada (índices, config, cópia dos times).

**Longo prazo**
- Migrar os booleanos de texto para bool, lendo os dois formatos durante a transição.
- Decidir entre manter o iOS ou remover a pasta.
- Trocar o scraping por uma API de resultados, se houver orçamento.
- Quebrar as telas acima de 700 linhas quando forem alteradas.

---

## 10. Pendências operacionais (em 02/11/2026)

Mudanças que já estão no código mas dependem de ação para valer em produção:

1. **Publicar:** `firebase deploy --only "firestore:rules,functions,hosting"`. Inclui:
   - a pausa de partida;
   - o "Indique amigos" com pacotinho extra;
   - a página `/convite`;
   - o liga/desliga das indicações.
2. **Gerar uma versão nova do app**, para os links `/convite` abrirem direto no Android (`AndroidManifest` com `pathPrefix="/convite"`).
3. **Ligar as indicações** em Painel → Configurações → Indique amigos. Sem o doc `config/indicacao`, elas ficam desligadas.
4. **Criar as conquistas de indicação** em Painel → Conquistas, com a métrica "Amigos indicados" e as metas 1, 5 e 20.
5. **Recadastrar a partida Puças × Invasão** e apagar os cards antigos dela no feed de Floresta (a região errada vinha do filtro do formulário, já corrigido).
