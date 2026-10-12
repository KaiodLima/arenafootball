import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

void main() {
  test('paleta: 12 cores, nenhuma repetida', () {
    final hexes = TeamColor.values.map((c) => c.hex).toSet();
    expect(TeamColor.values.length, 12);
    expect(hexes.length, TeamColor.values.length);
  });

  test('hex ida e volta, e busca na paleta sem diferenciar caixa', () {
    expect(colorToHex(const Color(0xFF2E7D32)), '#2E7D32');
    expect(colorFromHex('#2e7d32'), const Color(0xFF2E7D32));
    expect(colorFromHex('verde'), isNull);
    expect(TeamColor.fromHex('#2e7d32'), TeamColor.green);
    expect(TeamColor.fromHex('#123456'), isNull);
  });

  test('time grava as cores só quando informadas', () {
    const team = TeamDTO(id: '1', name: 'Volta', primaryColor: '#2E7D32', secondaryColor: '#FFFFFF');
    expect(team.toMap()['corPrimaria'], '#2E7D32');
    expect(team.toStandingsMap()['corSecundaria'], '#FFFFFF');
    const plain = TeamDTO(id: '2', name: 'Lava Jato');
    expect(plain.toMap().containsKey('corPrimaria'), isFalse);
  });

  test('pedido de time envia as cores', () {
    const request = TeamRequestDTO(
      userId: 'u',
      name: 'Riacho',
      region: 'Floresta',
      primaryColor: '#1A237E',
      secondaryColor: '#FBC02D',
    );
    final map = request.toSubmitMap();
    expect(map['corPrimaria'], '#1A237E');
    expect(map['corSecundaria'], '#FBC02D');
  });
}
