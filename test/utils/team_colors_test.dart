import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
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

  group('TeamPalette', () {
    final white = TeamColor.white.hex;
    final yellow = TeamColor.yellow.hex;
    final navy = TeamColor.navy.hex;
    final green = TeamColor.green.hex;
    final black = TeamColor.black.hex;

    test('principal nos cantos (acento), secundária no fundo', () {
      final palette = TeamPalette.fromHex(green, white)!;
      expect(palette.accent, TeamColor.green.color);
      expect(palette.background, TeamColor.white.color);
      expect(palette.ring, TeamColor.green.color);
    });

    test('acento branco: anel e filete no tom escuro (não somem no branco)', () {
      final palette = TeamPalette.fromHex(TeamColor.white.hex, TeamColor.black.hex)!;
      expect(palette.ring, palette.accentDark);
      expect(palette.line, palette.accentDark);
    });

    test('contraste: texto do centro pelo fundo, chips/barra pelo acento', () {
      final greenWhite = TeamPalette.fromHex(green, white)!;
      expect(greenWhite.onBackground, AppColors.textPrimary);
      expect(greenWhite.onAccent, AppColors.white);

      final navyYellow = TeamPalette.fromHex(navy, yellow)!;
      expect(navyYellow.onBackground, AppColors.textPrimary);
      expect(navyYellow.onAccent, AppColors.white);

      final yellowBlack = TeamPalette.fromHex(yellow, black)!;
      expect(yellowBlack.onBackground, AppColors.white);
      expect(yellowBlack.onAccent, AppColors.textPrimary);
      expect(yellowBlack.isBarLight, isTrue);
    });

    test('só uma cor: ela é o acento e o fundo é um tom claro dela', () {
      final onlyPrimary = TeamPalette.fromHex(green, '')!;
      expect(onlyPrimary.accent, TeamColor.green.color);
      expect(onlyPrimary.background, lightTint(TeamColor.green.color));

      final onlySecondary = TeamPalette.fromHex('', navy)!;
      expect(onlySecondary.accent, TeamColor.navy.color);
      expect(onlySecondary.background, lightTint(TeamColor.navy.color));
    });

    test('cores parecidas demais: fundo vira o tom claro da principal', () {
      final palette = TeamPalette.fromHex('#1A237E', '#1B2580')!;
      expect(palette.background, lightTint(palette.accent));
    });

    test('sem cores: nulo (cabeçalho verde do app)', () {
      expect(TeamPalette.fromHex('', ''), isNull);
      expect(TeamPalette.fromHex('verde', ''), isNull);
    });
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
