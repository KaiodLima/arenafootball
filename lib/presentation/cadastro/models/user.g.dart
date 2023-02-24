// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$User on _UserBase, Store {
  late final _$nomeAtom = Atom(name: '_UserBase.nome', context: context);

  @override
  String? get nome {
    _$nomeAtom.reportRead();
    return super.nome;
  }

  @override
  set nome(String? value) {
    _$nomeAtom.reportWrite(value, super.nome, () {
      super.nome = value;
    });
  }

  late final _$emailAtom = Atom(name: '_UserBase.email', context: context);

  @override
  String? get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String? value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$senhaAtom = Atom(name: '_UserBase.senha', context: context);

  @override
  String? get senha {
    _$senhaAtom.reportRead();
    return super.senha;
  }

  @override
  set senha(String? value) {
    _$senhaAtom.reportWrite(value, super.senha, () {
      super.senha = value;
    });
  }

  late final _$imagePlayerAtom =
      Atom(name: '_UserBase.imagePlayer', context: context);

  @override
  String? get imagePlayer {
    _$imagePlayerAtom.reportRead();
    return super.imagePlayer;
  }

  @override
  set imagePlayer(String? value) {
    _$imagePlayerAtom.reportWrite(value, super.imagePlayer, () {
      super.imagePlayer = value;
    });
  }

  late final _$nGolsAtom = Atom(name: '_UserBase.nGols', context: context);

  @override
  int get nGols {
    _$nGolsAtom.reportRead();
    return super.nGols;
  }

  @override
  set nGols(int value) {
    _$nGolsAtom.reportWrite(value, super.nGols, () {
      super.nGols = value;
    });
  }

  late final _$nAssistenciasAtom =
      Atom(name: '_UserBase.nAssistencias', context: context);

  @override
  int get nAssistencias {
    _$nAssistenciasAtom.reportRead();
    return super.nAssistencias;
  }

  @override
  set nAssistencias(int value) {
    _$nAssistenciasAtom.reportWrite(value, super.nAssistencias, () {
      super.nAssistencias = value;
    });
  }

  late final _$_UserBaseActionController =
      ActionController(name: '_UserBase', context: context);

  @override
  dynamic changeName(String value) {
    final _$actionInfo =
        _$_UserBaseActionController.startAction(name: '_UserBase.changeName');
    try {
      return super.changeName(value);
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeEmail(String value) {
    final _$actionInfo =
        _$_UserBaseActionController.startAction(name: '_UserBase.changeEmail');
    try {
      return super.changeEmail(value);
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeSenha(String value) {
    final _$actionInfo =
        _$_UserBaseActionController.startAction(name: '_UserBase.changeSenha');
    try {
      return super.changeSenha(value);
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic addImagePlayer(String? value) {
    final _$actionInfo = _$_UserBaseActionController.startAction(
        name: '_UserBase.addImagePlayer');
    try {
      return super.addImagePlayer(value);
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setGol(int value) {
    final _$actionInfo =
        _$_UserBaseActionController.startAction(name: '_UserBase.setGol');
    try {
      return super.setGol(value);
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic addGol() {
    final _$actionInfo =
        _$_UserBaseActionController.startAction(name: '_UserBase.addGol');
    try {
      return super.addGol();
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic removeGol() {
    final _$actionInfo =
        _$_UserBaseActionController.startAction(name: '_UserBase.removeGol');
    try {
      return super.removeGol();
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setAssistencia(int value) {
    final _$actionInfo = _$_UserBaseActionController.startAction(
        name: '_UserBase.setAssistencia');
    try {
      return super.setAssistencia(value);
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic addAssistencia() {
    final _$actionInfo = _$_UserBaseActionController.startAction(
        name: '_UserBase.addAssistencia');
    try {
      return super.addAssistencia();
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic removeAssistencia() {
    final _$actionInfo = _$_UserBaseActionController.startAction(
        name: '_UserBase.removeAssistencia');
    try {
      return super.removeAssistencia();
    } finally {
      _$_UserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
nome: ${nome},
email: ${email},
senha: ${senha},
imagePlayer: ${imagePlayer},
nGols: ${nGols},
nAssistencias: ${nAssistencias}
    ''';
  }
}
