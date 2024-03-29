// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_new_team_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegisterNewTeamController on _ControleBase, Store {
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

  late final _$controllerTimeNomeAtom =
      Atom(name: '_ControleBase.controllerTimeNome', context: context);

  @override
  TextEditingController get controllerTimeNome {
    _$controllerTimeNomeAtom.reportRead();
    return super.controllerTimeNome;
  }

  @override
  set controllerTimeNome(TextEditingController value) {
    _$controllerTimeNomeAtom.reportWrite(value, super.controllerTimeNome, () {
      super.controllerTimeNome = value;
    });
  }

  late final _$controllerDescricaoAtom =
      Atom(name: '_ControleBase.controllerDescricao', context: context);

  @override
  TextEditingController get controllerDescricao {
    _$controllerDescricaoAtom.reportRead();
    return super.controllerDescricao;
  }

  @override
  set controllerDescricao(TextEditingController value) {
    _$controllerDescricaoAtom.reportWrite(value, super.controllerDescricao, () {
      super.controllerDescricao = value;
    });
  }

  late final _$urlDownloadImageAtom =
      Atom(name: '_ControleBase.urlDownloadImage', context: context);

  @override
  String? get urlDownloadImage {
    _$urlDownloadImageAtom.reportRead();
    return super.urlDownloadImage;
  }

  @override
  set urlDownloadImage(String? value) {
    _$urlDownloadImageAtom.reportWrite(value, super.urlDownloadImage, () {
      super.urlDownloadImage = value;
    });
  }

  late final _$idAtualAtom =
      Atom(name: '_ControleBase.idAtual', context: context);

  @override
  int get idAtual {
    _$idAtualAtom.reportRead();
    return super.idAtual;
  }

  @override
  set idAtual(int value) {
    _$idAtualAtom.reportWrite(value, super.idAtual, () {
      super.idAtual = value;
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
controllerTimeNome: ${controllerTimeNome},
controllerDescricao: ${controllerDescricao},
urlDownloadImage: ${urlDownloadImage},
idAtual: ${idAtual},
timeSelecionadoCasa: ${timeSelecionadoCasa},
timeSelecionadoFora: ${timeSelecionadoFora},
cidadeSelecionada: ${cidadeSelecionada}
    ''';
  }
}
