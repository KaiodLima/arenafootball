// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_new_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegisterNewController on _ControleBase, Store {
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

  late final _$controllerIdNoticiaAtom =
      Atom(name: '_ControleBase.controllerIdNoticia', context: context);

  @override
  TextEditingController get controllerIdNoticia {
    _$controllerIdNoticiaAtom.reportRead();
    return super.controllerIdNoticia;
  }

  @override
  set controllerIdNoticia(TextEditingController value) {
    _$controllerIdNoticiaAtom.reportWrite(value, super.controllerIdNoticia, () {
      super.controllerIdNoticia = value;
    });
  }

  late final _$controllerTituloAtom =
      Atom(name: '_ControleBase.controllerTitulo', context: context);

  @override
  TextEditingController get controllerTitulo {
    _$controllerTituloAtom.reportRead();
    return super.controllerTitulo;
  }

  @override
  set controllerTitulo(TextEditingController value) {
    _$controllerTituloAtom.reportWrite(value, super.controllerTitulo, () {
      super.controllerTitulo = value;
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

  late final _$controllerLinkAtom =
      Atom(name: '_ControleBase.controllerLink', context: context);

  @override
  TextEditingController get controllerLink {
    _$controllerLinkAtom.reportRead();
    return super.controllerLink;
  }

  @override
  set controllerLink(TextEditingController value) {
    _$controllerLinkAtom.reportWrite(value, super.controllerLink, () {
      super.controllerLink = value;
    });
  }

  late final _$controllerExibirAtom =
      Atom(name: '_ControleBase.controllerExibir', context: context);

  @override
  TextEditingController get controllerExibir {
    _$controllerExibirAtom.reportRead();
    return super.controllerExibir;
  }

  @override
  set controllerExibir(TextEditingController value) {
    _$controllerExibirAtom.reportWrite(value, super.controllerExibir, () {
      super.controllerExibir = value;
    });
  }

  late final _$controllerTagAtom =
      Atom(name: '_ControleBase.controllerTag', context: context);

  @override
  TextEditingController get controllerTag {
    _$controllerTagAtom.reportRead();
    return super.controllerTag;
  }

  @override
  set controllerTag(TextEditingController value) {
    _$controllerTagAtom.reportWrite(value, super.controllerTag, () {
      super.controllerTag = value;
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

  late final _$listaCidadesFirebaseAtom =
      Atom(name: '_ControleBase.listaCidadesFirebase', context: context);

  @override
  ObservableList<String> get listaCidadesFirebase {
    _$listaCidadesFirebaseAtom.reportRead();
    return super.listaCidadesFirebase;
  }

  @override
  set listaCidadesFirebase(ObservableList<String> value) {
    _$listaCidadesFirebaseAtom.reportWrite(value, super.listaCidadesFirebase,
        () {
      super.listaCidadesFirebase = value;
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
  void adicionarString(String novaString) {
    final _$actionInfo = _$_ControleBaseActionController.startAction(
        name: '_ControleBase.adicionarString');
    try {
      return super.adicionarString(novaString);
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
controllerIdNoticia: ${controllerIdNoticia},
controllerTitulo: ${controllerTitulo},
controllerDescricao: ${controllerDescricao},
controllerUrlImagem: ${controllerUrlImagem},
controllerLink: ${controllerLink},
controllerExibir: ${controllerExibir},
controllerTag: ${controllerTag},
cidadeSelecionada: ${cidadeSelecionada},
listaCidadesFirebase: ${listaCidadesFirebase}
    ''';
  }
}
