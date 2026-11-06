import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';
import 'package:arena_soccer/features/organizer_requests/domain/repositories/organizer_requests_repository_interface.dart';
import 'package:arena_soccer/features/organizer_requests/domain/usecases/organizer_request_usecases.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_request_cubit.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_request_state.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';

class _Repo implements IOrganizerRequestsRepository {
  final submitted = <OrganizerRequestDTO>[];
  ChampionshipDTO? approved;
  OrganizerRequestDTO? current;

  @override
  Stream<Either<Failure, OrganizerRequestDTO?>> watchMyRequest(String userId) => Stream.value(Right(current));

  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> watchMyChampionships(String userId) =>
      Stream.value(const Right([ChampionshipDTO(id: 'c1', title: 'Copa Verde', organizerId: 'org1')]));

  @override
  Future<Either<Failure, void>> submit(OrganizerRequestDTO request) async {
    submitted.add(request);
    return const Right(null);
  }

  @override
  Future<Either<Failure, ChampionshipDTO>> approve({
    required OrganizerRequestDTO request,
    required ChampionshipDTO championship,
  }) async {
    approved = championship;
    return Right(championship.copyWith(id: 'novo', championshipId: 12));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Regions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Colônia', 'Floresta']);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Storage implements StorageUploadService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

OrganizerRequestCubit _cubit(_Repo repo) => OrganizerRequestCubit(
      WatchMyOrganizerRequestUseCase(repo),
      WatchMyChampionshipsUseCase(repo),
      SubmitOrganizerRequestUseCase(repo, _Storage()),
      CancelOrganizerRequestUseCase(repo),
      _Regions(),
    );

void main() {
  setUp(() => RegionRegistry.configure(const [RegionRef(id: 'co', name: 'Colônia'), RegionRef(id: 'fl', name: 'Floresta')]));
  tearDown(RegionRegistry.reset);

  const request = OrganizerRequestDTO(
    userId: 'org1',
    userName: 'Ana',
    name: ' Copa Verde ',
    region: 'Colônia',
    scope: ChampionshipScope.intermunicipal,
    description: 'Final em dezembro',
    imageUrl: 'https://x/logo.png',
    contact: '89999999999',
  );

  test('pedido: campos do envio e o campeonato criado na aprovação', () {
    final map = request.toSubmitMap();
    expect(map['status'], 'pendente');
    expect(map['abrangencia'], 'intermunicipal');
    expect(map['idRegiao'], 'co');
    expect(map.containsKey('idCampeonato'), isFalse);

    final championship = request.toChampionship('2026');
    expect(championship.title, 'Copa Verde');
    expect(championship.organizerId, 'org1');
    expect(championship.season, '2026');
    expect(championship.scope, ChampionshipScope.intermunicipal);
    expect(championship.regionIds, ['co']);
    expect(championship.toMap()[ChampionshipDTO.organizerField], 'org1');
    // Campeonato sem organizador não grava o campo (o admin não apaga ninguém).
    expect(const ChampionshipDTO(id: 'x').toMap().containsKey(ChampionshipDTO.organizerField), isFalse);
  });

  test('aprovar cria o campeonato com o organizador', () async {
    final repo = _Repo();
    final created = (await ApproveOrganizerRequestUseCase(repo)(request)).right;
    expect(repo.approved?.organizerId, 'org1');
    expect(created.championshipId, 12);
  });

  test('cubit: valida, envia e mostra os campeonatos da conta', () async {
    final repo = _Repo();
    final cubit = _cubit(repo);
    await cubit.start(userId: 'org1', userName: 'Ana', email: 'a@x.com', initialRegion: 'Floresta');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.form.selectedRegion, 'Floresta');
    expect(cubit.state.championships.single.title, 'Copa Verde');
    expect(cubit.state.showForm, isTrue);

    cubit.changeName('Co');
    expect(cubit.state.form.error, OrganizerRequestFormError.name);
    cubit
      ..changeName('Copa da Serra')
      ..changeContact('(89) 9999-9999')
      ..selectScope(ChampionshipScope.intermunicipal);
    expect(cubit.state.form.error, isNull);

    await cubit.submit();
    expect(cubit.state, isA<SubmittedOrganizerRequestState>());
    final sent = repo.submitted.single;
    expect(sent.name, 'Copa da Serra');
    expect(sent.region, 'Floresta');
    expect(sent.scope, ChampionshipScope.intermunicipal);
    expect(sent.status, PlayerRequestStatus.pending);
    await cubit.close();
  });

  test('aprovado: "Pedir outro campeonato" abre o formulário em branco com o contato', () async {
    final repo = _Repo()..current = request.copyWith(status: PlayerRequestStatus.approved);
    final cubit = _cubit(repo);
    await cubit.start(userId: 'org1', userName: 'Ana', email: 'a@x.com', initialRegion: 'Colônia');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.showForm, isFalse);
    cubit.startNewRequest();
    expect(cubit.state.showForm, isTrue);
    expect(cubit.state.form.name, '');
    expect(cubit.state.form.contact, '89999999999');
    await cubit.close();
  });

  test('envio sem logo nova mantém a que já estava e limpa o nome', () async {
    final repo = _Repo();
    await SubmitOrganizerRequestUseCase(repo, _Storage())(request);
    expect(repo.submitted.single.imageUrl, 'https://x/logo.png');
    expect(repo.submitted.single.name, 'Copa Verde');
  });
}
