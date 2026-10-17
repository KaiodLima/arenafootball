import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:arena_soccer/features/auth/domain/team_change_policy.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_favorite_team_usecase.dart';

class _FakeAuth implements IAuthRepository {
  final saves = <({String team, String teamId, bool stamp})>[];
  Failure? fail;

  @override
  Future<Either<Failure, void>> updateFavoriteTeam({
    required String userId,
    required String team,
    required String teamId,
    bool stampChange = false,
  }) async {
    if (fail != null) return Left(fail!);
    saves.add((team: team, teamId: teamId, stamp: stampChange));
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _noTeam = UserDTO(id: 'u1', name: 'Kaio', email: 'k@x.com');
const _lavaJato = UserDTO(id: 'u1', name: 'Kaio', email: 'k@x.com', favoriteTeam: 'Lava Jato', favoriteTeamId: '1');
final _now = DateTime(2026, 10, 16, 12);

void main() {
  group('TeamChangePolicy', () {
    test('sem time ou sem troca anterior: liberado', () {
      expect(TeamChangePolicy.canChange(_noTeam.copyWith(teamChangedAt: _now), _now), isTrue);
      expect(TeamChangePolicy.canChange(_lavaJato, _now), isTrue);
      expect(TeamChangePolicy.nextChangeAt(_lavaJato), isNull);
    });

    test('travado por 15 dias depois da troca', () {
      final user = _lavaJato.copyWith(teamChangedAt: _now);
      expect(TeamChangePolicy.nextChangeAt(user), _now.add(const Duration(days: 15)));
      expect(TeamChangePolicy.canChange(user, _now.add(const Duration(days: 14, hours: 23))), isFalse);
      expect(TeamChangePolicy.canChange(user, _now.add(const Duration(days: 15))), isTrue);
    });

    test('troca = sair de um time para outro (pelo id; sem id, pelo nome)', () {
      expect(TeamChangePolicy.isChange(_noTeam, team: 'Volta', teamId: '2'), isFalse);
      expect(TeamChangePolicy.isChange(_lavaJato, team: 'Lava Jato', teamId: '1'), isFalse);
      expect(TeamChangePolicy.isChange(_lavaJato, team: 'Volta', teamId: '2'), isTrue);
      const old = UserDTO(id: 'u1', name: 'K', email: '', favoriteTeam: 'Lava Jato');
      expect(TeamChangePolicy.isChange(old, team: 'Lava Jato', teamId: '1'), isFalse);
    });
  });

  group('UpdateFavoriteTeamUseCase', () {
    late _FakeAuth auth;
    late UpdateFavoriteTeamUseCase useCase;

    setUp(() {
      auth = _FakeAuth();
      useCase = UpdateFavoriteTeamUseCase(auth);
    });

    test('primeira escolha grava sem carimbo', () async {
      final response = await useCase(user: _noTeam, team: 'Volta', teamId: '2', now: _now);
      expect(response.right, isNull);
      expect(auth.saves.single, (team: 'Volta', teamId: '2', stamp: false));
    });

    test('mesmo time não grava; doc antigo sem id completa o id sem carimbo', () async {
      await useCase(user: _lavaJato, team: 'Lava Jato', teamId: '1', now: _now);
      expect(auth.saves, isEmpty);
      const old = UserDTO(id: 'u1', name: 'K', email: '', favoriteTeam: 'Lava Jato');
      await useCase(user: old, team: 'Lava Jato', teamId: '1', now: _now);
      expect(auth.saves.single.stamp, isFalse);
    });

    test('troca liberada grava com carimbo e devolve a hora', () async {
      final response = await useCase(user: _lavaJato, team: 'Volta', teamId: '2', now: _now);
      expect(response.right, _now);
      expect(auth.saves.single.stamp, isTrue);
    });

    test('troca antes do prazo: falha com a data, sem gravar', () async {
      final user = _lavaJato.copyWith(teamChangedAt: _now.subtract(const Duration(days: 3)));
      final response = await useCase(user: user, team: 'Volta', teamId: '2', now: _now);
      expect((response.left as TeamChangeLockedFailure).nextAt, _now.add(const Duration(days: 12)));
      expect(auth.saves, isEmpty);
    });

    test('servidor recusou a troca (regra): mesma falha de bloqueado', () async {
      auth.fail = ErrorWithMessage('negado', code: 'permission-denied');
      final response = await useCase(user: _lavaJato, team: 'Volta', teamId: '2', now: _now);
      expect(response.left, isA<TeamChangeLockedFailure>());
    });
  });
}
