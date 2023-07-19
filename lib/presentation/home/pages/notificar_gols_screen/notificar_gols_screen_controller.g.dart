// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notificar_gols_screen_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NotificarGolsScreenController on _ControleBase, Store {
  late final _$titleAtom = Atom(name: '_ControleBase.title', context: context);

  @override
  String? get title {
    _$titleAtom.reportRead();
    return super.title;
  }

  @override
  set title(String? value) {
    _$titleAtom.reportWrite(value, super.title, () {
      super.title = value;
    });
  }

  late final _$isShowAtom =
      Atom(name: '_ControleBase.isShow', context: context);

  @override
  String? get isShow {
    _$isShowAtom.reportRead();
    return super.isShow;
  }

  @override
  set isShow(String? value) {
    _$isShowAtom.reportWrite(value, super.isShow, () {
      super.isShow = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ControleBase.isLoading', context: context);

  @override
  bool? get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool? value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$cidadeSelecionadaAtom =
      Atom(name: '_ControleBase.cidadeSelecionada', context: context);

  @override
  String get cidadeSelecionada {
    _$cidadeSelecionadaAtom.reportRead();
    return super.cidadeSelecionada;
  }

  @override
  set cidadeSelecionada(String value) {
    _$cidadeSelecionadaAtom.reportWrite(value, super.cidadeSelecionada, () {
      super.cidadeSelecionada = value;
    });
  }

  late final _$timeSelecionadoCasaAtom =
      Atom(name: '_ControleBase.timeSelecionadoCasa', context: context);

  @override
  String get timeSelecionadoCasa {
    _$timeSelecionadoCasaAtom.reportRead();
    return super.timeSelecionadoCasa;
  }

  @override
  set timeSelecionadoCasa(String value) {
    _$timeSelecionadoCasaAtom.reportWrite(value, super.timeSelecionadoCasa, () {
      super.timeSelecionadoCasa = value;
    });
  }

  late final _$timeSelecionadoForaAtom =
      Atom(name: '_ControleBase.timeSelecionadoFora', context: context);

  @override
  String get timeSelecionadoFora {
    _$timeSelecionadoForaAtom.reportRead();
    return super.timeSelecionadoFora;
  }

  @override
  set timeSelecionadoFora(String value) {
    _$timeSelecionadoForaAtom.reportWrite(value, super.timeSelecionadoFora, () {
      super.timeSelecionadoFora = value;
    });
  }

  late final _$controllerGolCasaAtom =
      Atom(name: '_ControleBase.controllerGolCasa', context: context);

  @override
  TextEditingController get controllerGolCasa {
    _$controllerGolCasaAtom.reportRead();
    return super.controllerGolCasa;
  }

  @override
  set controllerGolCasa(TextEditingController value) {
    _$controllerGolCasaAtom.reportWrite(value, super.controllerGolCasa, () {
      super.controllerGolCasa = value;
    });
  }

  late final _$controllerGolForaAtom =
      Atom(name: '_ControleBase.controllerGolFora', context: context);

  @override
  TextEditingController get controllerGolFora {
    _$controllerGolForaAtom.reportRead();
    return super.controllerGolFora;
  }

  @override
  set controllerGolFora(TextEditingController value) {
    _$controllerGolForaAtom.reportWrite(value, super.controllerGolFora, () {
      super.controllerGolFora = value;
    });
  }

  late final _$_ControleBaseActionController =
      ActionController(name: '_ControleBase', context: context);

  @override
  dynamic changeTitle(String value) {
    final _$actionInfo = _$_ControleBaseActionController.startAction(
        name: '_ControleBase.changeTitle');
    try {
      return super.changeTitle(value);
    } finally {
      _$_ControleBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeExibition(String value) {
    final _$actionInfo = _$_ControleBaseActionController.startAction(
        name: '_ControleBase.changeExibition');
    try {
      return super.changeExibition(value);
    } finally {
      _$_ControleBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeLoading(bool value) {
    final _$actionInfo = _$_ControleBaseActionController.startAction(
        name: '_ControleBase.changeLoading');
    try {
      return super.changeLoading(value);
    } finally {
      _$_ControleBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
title: ${title},
isShow: ${isShow},
isLoading: ${isLoading},
cidadeSelecionada: ${cidadeSelecionada},
timeSelecionadoCasa: ${timeSelecionadoCasa},
timeSelecionadoFora: ${timeSelecionadoFora},
controllerGolCasa: ${controllerGolCasa},
controllerGolFora: ${controllerGolFora}
    ''';
  }
}
