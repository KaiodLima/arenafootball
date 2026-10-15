import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/news/presentation/widgets/goal_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

void main() {
  test('principal branca e secundária escura: o destaque é a secundária (sem cinza)', () {
    // Açaí No Gralle: branco + amarelo.
    final palette = GoalCard.paletteFor('#FFFFFF', '#FBC02D');
    expect(colorToHex(palette.accent), '#FBC02D');
    expect(colorToHex(palette.background), '#FFFFFF');
  });

  test('principal escura: fica como está', () {
    final palette = GoalCard.paletteFor('#111111', '#FFFFFF');
    expect(colorToHex(palette.accent), '#111111');
  });

  test('as duas claras: o tom escuro vem da secundária, não do branco', () {
    final palette = GoalCard.paletteFor('#FFFFFF', '#FFF59D');
    expect(colorToHex(palette.accent), '#FFFFFF');
    final dark = palette.accentDark;
    // Cinza teria R == G == B; o tom vem do amarelo.
    expect((dark.r - dark.b).abs() > 0.1, isTrue);
  });

  test('sem cor: verde padrão', () {
    expect(GoalCard.paletteFor('', '').accent, AppColors.primaryStrong);
  });
}
