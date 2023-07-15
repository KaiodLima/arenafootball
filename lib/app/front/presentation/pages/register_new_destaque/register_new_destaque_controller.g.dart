// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_new_destaque_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegisterNewDestaqueController on _ControleBase, Store {
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

  late final _$controllerTitleAtom =
      Atom(name: '_ControleBase.controllerTitle', context: context);

  @override
  TextEditingController get controllerTitle {
    _$controllerTitleAtom.reportRead();
    return super.controllerTitle;
  }

  @override
  set controllerTitle(TextEditingController value) {
    _$controllerTitleAtom.reportWrite(value, super.controllerTitle, () {
      super.controllerTitle = value;
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
controllerTitle: ${controllerTitle},
controllerLink: ${controllerLink},
controllerExibir: ${controllerExibir},
urlDownloadImage: ${urlDownloadImage}
    ''';
  }
}
