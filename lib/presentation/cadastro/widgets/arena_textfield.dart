import 'package:flutter/material.dart';

class ArenaTextField extends StatefulWidget {
  final String? labelText;
  final Function(String)? onChaged;
  String? Function() errorText;
  final Icon? icon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool? obscureText;

  ArenaTextField({
    Key? key,
    this.labelText,
    this.onChaged,
    required this.errorText,
    this.icon,
    this.keyboardType,
    this.controller,
    this.obscureText
  }) : super(key: key);

  @override
  State<ArenaTextField> createState() => _ArenaTextFieldState();
}

class _ArenaTextFieldState extends State<ArenaTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChaged,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder( //quando a borda é selecionada
          borderSide: BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
          borderSide: BorderSide(
            color: widget.errorText != null ? Colors.green: Colors.red,
          ),
        ),
        labelText: widget.labelText,
        errorText: widget.errorText == null ? null : widget.errorText(),
        icon: widget.icon,
      ),
      obscureText: widget.obscureText == null ? false : widget.obscureText!,
    );
  }
}