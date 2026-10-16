import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championship_cache_first_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_form_hints.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/create_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

const _existing = [
  MatchDTO(
      homeTeam: 'Lava Jato',
      awayTeam: 'Volta',
      date: '18/10',
      time: '16:45',
      venue: 'Arena Orlandão',
      region: 'Floresta'),
  MatchDTO(
      homeTeam: 'X-9',
      awayTeam: 'Risadinha',
      date: '18/10',
      time: '15:45',
      venue: 'Arena Orlandão',
      region: 'Floresta'),
  MatchDTO(
      homeTeam: 'Riacho',
      awayTeam: 'Nova Era',
      date: '19/10',
      time: '15:45',
      venue: 'Campo do Riacho',
      region: 'Floresta'),
  MatchDTO(homeTeam: 'A', awayTeam: 'B', date: '19/10', time: '17:45', venue: 'Arena Orlandão', region: 'Santo inacio'),
];

class _FakeRepository implements IMatchesRepository {
  final created = <MatchDTO>[];

  @override
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season, String? region}) =>
      Stream.value(const Right(_existing));

  @override
  Future<Either<Failure, void>> createMatch(MatchDTO match, {String? season}) async {
    created.add(match);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateScore({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
    String? season,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteMatch({required String matchId, String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> setVotingOpen({required String matchId, required bool isOpen, String? season}) async =>
      const Right(null);
}

class _FakeChampionship implements GetRegionChampionshipCacheFirstUseCase {
  /// Campeonato cadastrado da região (nulo = ainda não cadastrado).
  ChampionshipDTO? registered;

  @override
  Stream<Either<Failure, ChampionshipDTO?>> call(
          {required String region, required String season, bool force = false}) =>
      Stream.value(Right(registered));
}

class _FakeRegions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta', 'Santo inacio']);
}

class _FakeChampionships implements GetRegionChampionshipsCacheFirstUseCase {
  List<ChampionshipDTO> list = const [];

  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> call({
    required String region,
    required String season,
    bool force = false,
  }) =>
      Stream.value(Right(list));
}

class _FakeTeams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.fromFuture(_load(region: region, season: season));

  Future<Either<Failure, List<TeamDTO>>> _load({String? region, String? season}) async => const Right([
        TeamDTO(id: '1', name: 'Lava Jato'),
        TeamDTO(id: '2', name: 'Volta'),
        TeamDTO(id: '3', name: 'Riacho'),
      ]);
}

void main() {
  group('MatchFormHints', () {
    final floresta = _existing.where((m) => m.region == 'Floresta').toList();

    test('horários mais usados em ordem cronológica e locais por frequência', () {
      expect(MatchFormHints.frequentTimes(floresta), ['15:45', '16:45']);
      expect(MatchFormHints.frequentVenues(floresta), ['Arena Orlandão', 'Campo do Riacho']);
    });

    test('conflito: time já joga no dia', () {
      final conflicts = MatchFormHints.conflicts(
        floresta,
        home: 'Lava Jato',
        away: 'Riacho',
        date: '18/10',
        time: '19:00',
        venue: 'Campo X',
      );
      expect(conflicts, const [
        MatchConflict(type: MatchConflictType.teamSameDay, subject: 'Lava Jato', times: ['16:45'])
      ]);
    });

    test('conflito: local ocupado no mesmo horário (sem diferenciar caixa)', () {
      final conflicts = MatchFormHints.conflicts(
        floresta,
        home: 'C',
        away: 'D',
        date: '18/10',
        time: '15:45',
        venue: 'arena orlandão',
      );
      expect(conflicts.single.type, MatchConflictType.venueTaken);
    });

    test('atalhos de data: hoje, amanhã, sábado e domingo sem repetir', () {
      // 15/10/2026 é quinta-feira.
      expect(MatchFormHints.quickDates(DateTime(2026, 10, 15)).map((d) => d.day), [15, 16, 17, 18]);
      // Sábado: amanhã já é o domingo.
      expect(MatchFormHints.quickDates(DateTime(2026, 10, 17, 20)).map((d) => d.day), [17, 18]);
    });
  });

  group('MatchFormData', () {
    test('primeiro campo faltante', () {
      expect(const MatchFormData().missing, MatchFormMissing.teams);
      expect(const MatchFormData(homeTeam: 'Volta', awayTeam: 'Volta').missing, MatchFormMissing.sameTeam);
      expect(const MatchFormData(homeTeam: 'Volta', awayTeam: 'Riacho').missing, MatchFormMissing.date);
      expect(const MatchFormData(homeTeam: 'Volta', awayTeam: 'Riacho', date: '18/10').missing, MatchFormMissing.time);
      expect(
        const MatchFormData(homeTeam: 'Volta', awayTeam: 'Riacho', date: '18/10', time: '16:45', selectedRegion: 'F')
            .canSubmit,
        isTrue,
      );
    });
  });

  group('MatchFormCubit', () {
    late _FakeRepository repository;
    late _FakeChampionship championship;
    late MatchFormCubit cubit;

    setUp(() async {
      repository = _FakeRepository();
      championship = _FakeChampionship();
      cubit = MatchFormCubit(
        CreateMatchUseCase(repository, championship),
        _FakeRegions(),
        _FakeTeams(),
        GetRegionMatchesUseCase(repository),
        _FakeChampionships(),
      );
      await cubit.load(initialRegion: 'Floresta', now: DateTime(2026, 10, 18));
    });

    test('vários campeonatos: times do escolhido e id gravado na partida', () async {
      final championships = _FakeChampionships()
        ..list = const [
          ChampionshipDTO(id: 'a', championshipId: 5, title: 'Society', teams: ['Volta', 'Riacho']),
          ChampionshipDTO(id: 'b', championshipId: 6, title: 'Futsal'),
        ];
      final multi = MatchFormCubit(
        CreateMatchUseCase(repository, championship),
        _FakeRegions(),
        _FakeTeams(),
        GetRegionMatchesUseCase(repository),
        championships,
      );
      await multi.load(initialRegion: 'Floresta', now: DateTime(2026, 10, 18));
      expect(multi.state.form.championshipId, 5);
      expect(multi.state.form.teams.map((t) => t.name), ['Volta', 'Riacho']);

      // Campeonato sem times marcados: todos da região.
      multi.selectChampionship(6);
      expect(multi.state.form.teams.length, 3);

      multi
        ..selectTime('20:00')
        ..selectHomeTeam('Lava Jato')
        ..selectAwayTeam('Volta');
      await multi.submit();
      expect(repository.created.last.championshipId, 6);
      await multi.close();
    });

    test('carrega a região: data de hoje, times e local mais usado', () {
      final form = cubit.state.form;
      expect(form.date, '18/10');
      expect([form.homeTeam, form.awayTeam], ['Lava Jato', 'Riacho']);
      expect(form.venue, 'Arena Orlandão');
      expect(form.existing.length, 3);
    });

    test('inverte o mando', () {
      cubit.swapTeams();
      expect([cubit.state.form.homeTeam, cubit.state.form.awayTeam], ['Riacho', 'Lava Jato']);
    });

    test('cadastra, mantém data/hora/local, limpa os times e passa a contar no conflito', () async {
      cubit.selectAwayTeam('Volta');
      cubit.selectTime('19:00');
      await cubit.submit();

      expect(repository.created.single.homeTeam, 'Lava Jato');
      expect(repository.created.single.championshipId, 1);
      final form = cubit.state.form;
      expect(cubit.state, isA<SuccessMatchFormState>());
      expect([form.homeTeam, form.awayTeam], [null, null]);
      expect([form.date, form.time, form.venue], ['18/10', '19:00', 'Arena Orlandão']);
      expect(form.existing.length, 4);
    });

    test('local novo digitado', () {
      cubit.startCustomVenue();
      cubit.changeVenue('Campo Novo');
      expect(cubit.state.form.customVenue, isTrue);
      expect(cubit.state.form.toMatch().venue, 'Campo Novo');
    });
  });

  group('CreateMatchUseCase', () {
    const match = MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta', region: 'Floresta');

    test('usa o id do campeonato cadastrado da região', () async {
      final repository = _FakeRepository();
      final championship = _FakeChampionship()
        ..registered = const ChampionshipDTO(id: 'c', championshipId: 7, region: 'Floresta');
      await CreateMatchUseCase(repository, championship)(match);
      expect(repository.created.single.championshipId, 7);
    });

    test('sem campeonato cadastrado, cai na tabela fixa', () async {
      final repository = _FakeRepository();
      await CreateMatchUseCase(repository, _FakeChampionship())(match);
      expect(repository.created.single.championshipId, 1);
    });
  });
}
