import 'package:flutter/widgets.dart';

/// Espaço do fim de uma lista somado ao da barra de navegação do sistema
/// (Android de ponta a ponta: a barra fica por cima do app).
double safeBottom(BuildContext context, [double base = 0]) => base + MediaQuery.paddingOf(context).bottom;
