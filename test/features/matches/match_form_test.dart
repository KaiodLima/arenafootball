import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_form_hints.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/create_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

const _existing = [
  MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta', date: '18/10', time: '16:45', venue: 'Arena Orlandão', region: 'Floresta'),
  MatchDTO(homeTeam: 'X-9', awayTeam: 'Risadinha', date: '18/10', time: '15:45', venue: 'Arena Orlandão', region: 'Floresta'),
  MatchDTO(homeTeam: 'Riacho', awayTeam: 'Nova Era', date: '19/10', time: '15:45', venue: 'Campo do Riacho', region: 'Floresta'),
  MatchDTO(homeTeam: 'A', awayTeam: 'B', date: '19/10', time: '17:45', venue: 'Arena Orlandão', region: 'Santo inacio'),
];

class _FakeRepository implements IMatchesRepository {
  final created = <MatchDTO>[];

  @override
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season}) => Stream.value(const Right(_existing));

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

class _FakeRegions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta', 'Santo inacio']);
}

class _FakeTeams implements GetTeamsUseCase {
  @override
  Future<Either<Failure, List<TeamDTO>>> call({String? region, String? season}) async => const Right([
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
      expect(conflicts, const [MatchConflict(type: MatchConflictType.teamSameDay, subject: 'Lava Jato', times: ['16:45'])]);
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
    late MatchFormCubit cubit;

    setUp(() async {
      repository = _FakeRepository();
      cubit = MatchFormCubit(
        CreateMatchUseCase(repository),
        _FakeRegions(),
        _FakeTeams(),
        GetRegionMatchesUseCase(repository),
      );
      await cubit.load(initialRegion: 'Floresta', now: DateTime(2026, 10, 18));
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
}
