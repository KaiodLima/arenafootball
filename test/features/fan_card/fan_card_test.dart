import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_account_created_at_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_user_photo_usecase.dart';
import 'package:arena_soccer/features/fan_card/domain/fan_card_number.dart';
import 'package:arena_soccer/features/fan_card/presentation/bloc/fan_card_cubit.dart';
import 'package:arena_soccer/features/fan_card/presentation/bloc/fan_card_state.dart';
import 'package:arena_soccer/features/fan_card/presentation/widgets/fan_card.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_cache_first_usecase.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

class _FakeTeam implements GetTeamByNameCacheFirstUseCase {
  @override
  Stream<Either<Failure, TeamDTO?>> call(String name, {String id = '', bool force = false}) => Stream.value(Right(
        TeamDTO(id: '1', name: name, region: 'Floresta', primaryColor: TeamColor.navy.hex),
      ));
}

class _FakePhoto implements UpdateUserPhotoUseCase {
  @override
  Future<Either<Failure, String>> call({required String userId, required File photo}) async =>
      const Right('https://img/foto.png');
}

class _FakeCreatedAt implements GetAccountCreatedAtUseCase {
  @override
  DateTime? call() => DateTime(2022, 5, 1);
}

void main() {
  test('número da carteirinha: 8 caracteres do uid em dois blocos', () {
    expect(fanCardNumber('aB3d-9Xy7Zq'), 'AB3D·9XY7');
    expect(fanCardNumber('abc'), 'ABC0·0000');
    expect(fanCardNumber('aB3d9Xy7Zq'), fanCardNumber('aB3d9Xy7Zq'));
  });

  test('cores: as do time; sem time ou sem cores, as do app', () {
    expect(
        FanCard.paletteFor(TeamDTO(id: '1', name: 'X', primaryColor: TeamColor.navy.hex)).accent, TeamColor.navy.color);
    expect(FanCard.paletteFor(null).accent, AppColors.primaryStrong);
    expect(FanCard.paletteFor(const TeamDTO(id: '1', name: 'X')).background, AppColors.white);
  });

  test('cubit: carrega o time e o ano da conta; trocar foto devolve a URL', () async {
    final cubit = FanCardCubit(_FakeTeam(), _FakePhoto(), _FakeCreatedAt());
    await cubit.load(favoriteTeam: 'Lava Jato');
    expect(cubit.state.team?.name, 'Lava Jato');
    expect(cubit.state.memberSince, 2022);
    expect(cubit.state.loading, isFalse);

    await cubit.changePhoto(userId: 'u1', photo: File('foto.png'));
    expect(cubit.state, isA<PhotoSavedFanCardState>().having((s) => s.photoUrl, 'url', 'https://img/foto.png'));
    expect(cubit.state.team?.name, 'Lava Jato');
    await cubit.close();
  });

  test('sem time do coração: não busca time e termina de carregar', () async {
    final cubit = FanCardCubit(_FakeTeam(), _FakePhoto(), _FakeCreatedAt());
    await cubit.load(favoriteTeam: '');
    expect(cubit.state.team, isNull);
    expect(cubit.state.loading, isFalse);
    await cubit.close();
  });
}
