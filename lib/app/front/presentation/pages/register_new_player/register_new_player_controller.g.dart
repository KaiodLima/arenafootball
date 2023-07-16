// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_new_player_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegisterNewPlayerController on _ControleBase, Store {
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

  late final _$controllerNomeAtom =
      Atom(name: '_ControleBase.controllerNome', context: context);

  @override
  TextEditingController get controllerNome {
    _$controllerNomeAtom.reportRead();
    return super.controllerNome;
  }

  @override
  set controllerNome(TextEditingController value) {
    _$controllerNomeAtom.reportWrite(value, super.controllerNome, () {
      super.controllerNome = value;
    });
  }

  late final _$controllerTimeAtom =
      Atom(name: '_ControleBase.controllerTime', context: context);

  @override
  TextEditingController get controllerTime {
    _$controllerTimeAtom.reportRead();
    return super.controllerTime;
  }

  @override
  set controllerTime(TextEditingController value) {
    _$controllerTimeAtom.reportWrite(value, super.controllerTime, () {
      super.controllerTime = value;
    });
  }

  late final _$controllerUrlImagemAtom =
      Atom(name: '_ControleBase.controllerUrlImagem', context: context);

  @override
  TextEditingController get controllerUrlImagem {
    _$controllerUrlImagemAtom.reportRead();
    return super.controllerUrlImagem;
  }

  @override
  set controllerUrlImagem(TextEditingController value) {
    _$controllerUrlImagemAtom.reportWrite(value, super.controllerUrlImagem, () {
      super.controllerUrlImagem = value;
    });
  }

  late final _$controllerBuscaAtom =
      Atom(name: '_ControleBase.controllerBusca', context: context);

  @override
  TextEditingController get controllerBusca {
    _$controllerBuscaAtom.reportRead();
    return super.controllerBusca;
  }

  @override
  set controllerBusca(TextEditingController value) {
    _$controllerBuscaAtom.reportWrite(value, super.controllerBusca, () {
      super.controllerBusca = value;
    });
  }

  late final _$controllerGolsAtom =
      Atom(name: '_ControleBase.controllerGols', context: context);

  @override
  TextEditingController get controllerGols {
    _$controllerGolsAtom.reportRead();
    return super.controllerGols;
  }

  @override
  set controllerGols(TextEditingController value) {
    _$controllerGolsAtom.reportWrite(value, super.controllerGols, () {
      super.controllerGols = value;
    });
  }

  late final _$controllerPassesAtom =
      Atom(name: '_ControleBase.controllerPasses', context: context);

  @override
  TextEditingController get controllerPasses {
    _$controllerPassesAtom.reportRead();
    return super.controllerPasses;
  }

  @override
  set controllerPasses(TextEditingController value) {
    _$controllerPassesAtom.reportWrite(value, super.controllerPasses, () {
      super.controllerPasses = value;
    });
  }

  late final _$timeSelecionadoAtom =
      Atom(name: '_ControleBase.timeSelecionado', context: context);

  @override
  String get timeSelecionado {
    _$timeSelecionadoAtom.reportRead();
    return super.timeSelecionado;
  }

  @override
  set timeSelecionado(String value) {
    _$timeSelecionadoAtom.reportWrite(value, super.timeSelecionado, () {
      super.timeSelecionado = value;
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
controllerNome: ${controllerNome},
controllerTime: ${controllerTime},
controllerUrlImagem: ${controllerUrlImagem},
controllerBusca: ${controllerBusca},
controllerGols: ${controllerGols},
controllerPasses: ${controllerPasses},
timeSelecionado: ${timeSelecionado},
cidadeSelecionada: ${cidadeSelecionada}
    ''';
  }
}
