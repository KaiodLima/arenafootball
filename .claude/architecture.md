# Arquitetura

Clean Architecture por feature, no mesmo padrão do projeto Relove, adaptada para Firebase.

```
UI (Page) -> Cubit -> UseCase -> Repository (interface) -> Repository (impl) -> DataSource -> Firestore/Auth/Storage
```

## Estrutura de `lib/`

```
lib/
├── main.dart                  # Firebase.initializeApp, di.init(), runApp(BlocsLoad(child: ArenaApp()))
├── arena_app.dart             # MaterialApp: routes, tema, l10n, Cubits route-level
├── app_routes.dart            # AppRoutes (constantes) + AppSession (navigatorKey)
├── blocs_load.dart            # MultiBlocProvider dos Cubits globais
├── injection_container.dart   # sl = GetIt.instance; init()
├── core/
│   ├── errors/                # failure.dart (Failure, ErrorWithMessage), firebase_error.dart (mapFirebaseError)
│   ├── firebase/              # season_collection.dart, either_stream.dart
│   ├── services/              # preferences_service.dart, storage_upload_service.dart
│   └── utils/                 # app_logger.dart
├── features/<feature>/        # um módulo por feature (ver abaixo)
├── utils/
│   ├── components/            # ArenaButton, ArenaTextField, showSnackBar...
│   ├── constants/             # AppColors, AppSizes, AppImages
│   └── themes/                # AppTheme
└── l10n/                      # app_pt.arb (template), app_en.arb + gerados
```

Cada feature:

```
features/<feature>/
  data/
    dtos/          <x>_dto.dart                  # XDTO: fromFirestore / toMap / copyWith, Equatable
    datasources/   <x>_datasource.dart           # acesso ao Firebase, devolve Either
    repositories/  <x>_repository_impl.dart      # XRepositoryImpl implements IXRepository
  domain/
    repositories/  <x>_repository_interface.dart # abstract class IXRepository
    usecases/      <verbo>_<x>_usecase.dart      # uma classe por ação, método call()
  presentation/
    bloc/          <x>_cubit.dart + <x>_state.dart
    page/          <x>_page.dart
    widgets/       widgets da feature
  di/              <feature>_injection.dart      # registerXDependencies()
```

## Convenções de nome

| Peça | Arquivo | Classe |
|---|---|---|
| DTO | `team_dto.dart` | `TeamDTO` |
| DataSource | `teams_datasource.dart` | `TeamsDataSource` |
| Contrato | `teams_repository_interface.dart` | `ITeamsRepository` |
| Implementação | `teams_repository_impl.dart` | `TeamsRepositoryImpl` |
| UseCase | `get_teams_usecase.dart` | `GetTeamsUseCase` |
| Cubit/State | `teams_cubit.dart` / `teams_state.dart` | `TeamsCubit`, `TeamsState`, `LoadingTeamsState`, `SuccessTeamsState`, `ErrorTeamsState` |
| Página | `teams_page.dart` | `TeamsPage` |
| DI | `teams_injection.dart` | `registerTeamsDependencies()` |

## Templates

Feature de referência completa: `lib/features/teams/` (data/domain/DI) e `lib/features/auth/` (Cubits, páginas).

### DTO

```dart
class TeamDTO extends Equatable {
  final String id;
  final String name;
  const TeamDTO({required this.id, required this.name});

  factory TeamDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return TeamDTO(
      id: data['id_partida']?.toString() ?? doc.id,
      name: data['nome']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'id_partida': id, 'nome': name};

  @override
  List<Object?> get props => [id, name];
}
```

Regras do DTO:
- Campos em inglês; os nomes do Firestore (português, snake/camel misturados) ficam **só** no `fromFirestore`/`toMap`.
- Tolerante a campo ausente: `?.toString() ?? ''`, `(data['n'] as num?)?.toInt() ?? 0`.
- Booleanos gravados como string (`"true"`): converter no DTO (`data['exibir'] == 'true'`) e gravar de volta como string no `toMap`.

### DataSource

```dart
class TeamsDataSource {
  final FirebaseFirestore _firestore;
  TeamsDataSource(this._firestore);

  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season}) async {
    const fallback = 'Não foi possível carregar os times.';
    try {
      final result = await _firestore
          .collection(SeasonCollection.name('times', season))
          .where('fk_competicao', isEqualTo: region)
          .get();
      return Right(result.docs.map(TeamDTO.fromFirestore).toList());
    } catch (e) {
      AppLogger.e('getTeams region=$region', name: 'TeamsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }

  // Tempo real: o erro do stream vira Left, sem derrubar o stream.
  Stream<Either<Failure, List<TeamDTO>>> watchTeams({String? region, String? season}) {
    return _firestore.collection(SeasonCollection.name('times', season)).snapshots().toEither(
          (snapshot) => snapshot.docs.map(TeamDTO.fromFirestore).toList(),
          fallbackMessage: 'Não foi possível carregar os times.',
          logName: 'TeamsDataSource',
        );
  }
}
```

Para criar documento com id: `final ref = collection.doc(); await ref.set({...dto.toMap(), 'id': ref.id});` — uma escrita só (o código antigo fazia `add()` + `set()`).
Upload de imagem: injetar `StorageUploadService` e chamar `uploadImage(file:, folder: StorageFolder.news)`.

### Repository

```dart
abstract class ITeamsRepository {
  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season});
}

class TeamsRepositoryImpl implements ITeamsRepository {
  final TeamsDataSource _dataSource;
  TeamsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season}) =>
      _dataSource.getTeams(region: region, season: season);
}
```

### UseCase

```dart
class GetTeamsUseCase {
  final ITeamsRepository _repository;
  GetTeamsUseCase(this._repository);

  Future<Either<Failure, List<TeamDTO>>> call({String? region, String? season}) =>
      _repository.getTeams(region: region, season: season);
}
```

Regra de negócio (cálculo de votos, ranking de artilharia, validação) mora no UseCase, não no Cubit nem na página.

### DI

```dart
final _sl = GetIt.instance;

void registerTeamsDependencies() {
  _sl.registerLazySingleton<TeamsDataSource>(() => TeamsDataSource(_sl()));
  _sl.registerLazySingleton<ITeamsRepository>(() => TeamsRepositoryImpl(_sl()));
  _sl.registerLazySingleton(() => GetTeamsUseCase(_sl()));
}
```

Ordem: DataSource -> Repository (pela interface) -> UseCases. Sempre `registerLazySingleton`. `FirebaseFirestore`, `FirebaseAuth`, `FirebaseStorage`, `http.Client`, `PreferencesService` e `StorageUploadService` já são registrados em `_registerExternal()`.

### State

Hierarquia de classes com Equatable; a base carrega o que precisa sobreviver entre estados.

```dart
class TeamsState extends Equatable {
  final List<TeamDTO> teams;
  const TeamsState({this.teams = const []});
  @override
  List<Object?> get props => [teams];
}

class LoadingTeamsState extends TeamsState {
  const LoadingTeamsState({super.teams});
}

class SuccessTeamsState extends TeamsState {
  const SuccessTeamsState({required super.teams});
}

class ErrorTeamsState extends TeamsState {
  final String errorMessage;
  const ErrorTeamsState({required this.errorMessage, super.teams});
  @override
  List<Object?> get props => [teams, errorMessage];
}
```

### Cubit

```dart
class TeamsCubit extends Cubit<TeamsState> {
  final WatchTeamsUseCase watchTeamsUseCase;
  StreamSubscription<Either<Failure, List<TeamDTO>>>? _subscription;

  TeamsCubit(this.watchTeamsUseCase) : super(const LoadingTeamsState());

  void watch({required String region, required String season}) {
    _subscription?.cancel();
    emit(LoadingTeamsState(teams: state.teams));
    _subscription = watchTeamsUseCase(region: region, season: season).listen((response) {
      response.fold(
        (failure) => emit(ErrorTeamsState(errorMessage: failure.toString(), teams: state.teams)),
        (teams) => emit(SuccessTeamsState(teams: teams)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

Construtor recebe os UseCases posicionais, resolvidos com `sl()` na rota: `TeamsCubit(sl())`.

### Página

```dart
class TeamsPage extends StatefulWidget { ... }

class _TeamsPageState extends State<TeamsPage> {
  @override
  void initState() {
    super.initState();
    final region = BlocProvider.of<RegionCubit>(context).state;
    BlocProvider.of<TeamsCubit>(context).watch(region: region.selectedRegion, season: region.selectedSeason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<TeamsCubit, TeamsState>(
      listener: (context, state) {
        if (state is ErrorTeamsState) showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
      },
      builder: (context, state) {
        if (state is LoadingTeamsState && state.teams.isEmpty) return const Center(child: CircularProgressIndicator());
        ...
      },
    );
  }
}
```

- Admin: `context.watch<SessionCubit>().state.isAdmin`.
- Região/temporada: `RegionCubit`. Quando a tela depende delas, reagir com `BlocListener<RegionCubit, RegionState>` (ou key no widget) e chamar o Cubit de novo.
- Abas da home são widgets (`XTab`) que recebem seu Cubit por `BlocProvider` criado na própria aba.

### Rotas

```dart
// lib/app_routes.dart
static const String teamPlayersPage = '/team_players_page';

// lib/arena_app.dart — Cubit route-level + argumentos em Map
AppRoutes.teamPlayersPage: (context) {
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  return BlocProvider<TeamPlayersCubit>(
    create: (_) => TeamPlayersCubit(sl(), sl()),
    child: TeamPlayersPage(team: args?['team'] as TeamDTO),
  );
},

// chamada
Navigator.pushNamed(context, AppRoutes.teamPlayersPage, arguments: {'team': team});
```

Nunca `MaterialPageRoute` direto para telas do app.

## Estado global

| Cubit | Onde | Para quê |
|---|---|---|
| `SessionCubit` | `features/auth` | Usuário logado (`UserDTO?`), `isAdmin`, login/logout/convidado |
| `RegionCubit` | `features/regions` | Lista de regiões, região e temporada selecionadas (persistidas no SharedPreferences) |
