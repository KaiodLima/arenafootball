// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arena_dropdown_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ControllerArenaDropdownButton on _ControleBase, Store {
  late final _$selectedItemAtom =
      Atom(name: '_ControleBase.selectedItem', context: context);

  @override
  String? get selectedItem {
    _$selectedItemAtom.reportRead();
    return super.selectedItem;
  }

  @override
  set selectedItem(String? value) {
    _$selectedItemAtom.reportWrite(value, super.selectedItem, () {
      super.selectedItem = value;
    });
  }

  @override
  String toString() {
    return '''
selectedItem: ${selectedItem}
    ''';
  }
}
