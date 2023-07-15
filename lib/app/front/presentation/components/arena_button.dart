import 'package:flutter/material.dart';

class ArenaButton extends StatefulWidget {
  final double? width;
  final double? height;
  final String? title;
  final double? fontSize;
  final Color? textColor;
  final Color? buttonColor;
  final Color? buttonBorderColor;
  final double? borderRadius;
  final bool? isLoading;

  final void Function()? function;
  
  const ArenaButton({
    Key? key,
    required this.height,
    required this.width,
    required this.title,
    this.fontSize,
    this.textColor,
    this.buttonColor,
    this.buttonBorderColor,
    this.borderRadius,
    required this.function,
    this.isLoading,
  }) : super(key: key);

  @override
  State<ArenaButton> createState() => _ArenaButtonState();
}

class _ArenaButtonState extends State<ArenaButton> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: widget.function,
      child: (widget.isLoading??false) == false ? Text(
        "" + widget.title.toString(),
        style: TextStyle(color: widget.textColor ?? Colors.white,
        fontSize: widget.fontSize ?? 14,
        ),
      ) : CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(widget.buttonColor ?? Colors.blue), //essa merda toda pra mudar a cor do botão oporra
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            side: BorderSide(
              color: widget.buttonBorderColor ?? widget.buttonColor ?? Colors.white,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius ?? 0),
            ),
          ),
        ),
        fixedSize: MaterialStateProperty.all<Size>(
          Size(widget.width ?? width, widget.height ?? 47)
        ),
      ),
    );
  }
}