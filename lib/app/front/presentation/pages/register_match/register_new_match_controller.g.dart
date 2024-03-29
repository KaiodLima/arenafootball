// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_new_match_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegisterNewMatchController on _ControleBase, Store {
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

  late final _$controllerIdPartidaAtom =
      Atom(name: '_ControleBase.controllerIdPartida', context: context);

  @override
  TextEditingController get controllerIdPartida {
    _$controllerIdPartidaAtom.reportRead();
    return super.controllerIdPartida;
  }

  @override
  set controllerIdPartida(TextEditingController value) {
    _$controllerIdPartidaAtom.reportWrite(value, super.controllerIdPartida, () {
      super.controllerIdPartida = value;
    });
  }

  late final _$controllerTimeCAtom =
      Atom(name: '_ControleBase.controllerTimeC', context: context);

  @override
  TextEditingController get controllerTimeC {
    _$controllerTimeCAtom.reportRead();
    return super.controllerTimeC;
  }

  @override
  set controllerTimeC(TextEditingController value) {
    _$controllerTimeCAtom.reportWrite(value, super.controllerTimeC, () {
      super.controllerTimeC = value;
    });
  }

  late final _$controllerTimeFAtom =
      Atom(name: '_ControleBase.controllerTimeF', context: context);

  @override
  TextEditingController get controllerTimeF {
    _$controllerTimeFAtom.reportRead();
    return super.controllerTimeF;
  }

  @override
  set controllerTimeF(TextEditingController value) {
    _$controllerTimeFAtom.reportWrite(value, super.controllerTimeF, () {
      super.controllerTimeF = value;
    });
  }

  late final _$controllerHorarioAtom =
      Atom(name: '_ControleBase.controllerHorario', context: context);

  @override
  TextEditingController get controllerHorario {
    _$controllerHorarioAtom.reportRead();
    return super.controllerHorario;
  }

  @override
  set controllerHorario(TextEditingController value) {
    _$controllerHorarioAtom.reportWrite(value, super.controllerHorario, () {
      super.controllerHorario = value;
    });
  }

  late final _$controllerLocalAtom =
      Atom(name: '_ControleBase.controllerLocal', context: context);

  @override
  TextEditingController get controllerLocal {
    _$controllerLocalAtom.reportRead();
    return super.controllerLocal;
  }

  @override
  set controllerLocal(TextEditingController value) {
    _$controllerLocalAtom.reportWrite(value, super.controllerLocal, () {
      super.controllerLocal = value;
    });
  }

  late final _$controllerDataAtom =
      Atom(name: '_ControleBase.controllerData', context: context);

  @override
  TextEditingController get controllerData {
    _$controllerDataAtom.reportRead();
    return super.controllerData;
  }

  @override
  set controllerData(TextEditingController value) {
    _$controllerDataAtom.reportWrite(value, super.controllerData, () {
      super.controllerData = value;
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
controllerIdPartida: ${controllerIdPartida},
controllerTimeC: ${controllerTimeC},
controllerTimeF: ${controllerTimeF},
controllerHorario: ${controllerHorario},
controllerLocal: ${controllerLocal},
controllerData: ${controllerData},
timeSelecionadoCasa: ${timeSelecionadoCasa},
timeSelecionadoFora: ${timeSelecionadoFora},
cidadeSelecionada: ${cidadeSelecionada}
    ''';
  }
}
