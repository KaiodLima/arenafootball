import 'package:flutter/material.dart';

/// Texto com um ícone no começo ou no fim da linha, no lugar de emoji
/// (o iOS não desenha o emoji com as fontes do app; o ícone sai igual nos dois).
class IconText extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;
  final TextStyle? style;
  final bool leading;
  final int? maxLines;
  final TextOverflow? overflow;

  const IconText(
    this.text, {
    super.key,
    required this.icon,
    this.iconColor,
    this.style,
    this.leading = false,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = DefaultTextStyle.of(context).style.merge(style);
    final size = (resolved.fontSize ?? 14) * 1.1;
    final iconSpan = WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: EdgeInsets.only(left: leading ? 0 : size * 0.3, right: leading ? size * 0.3 : 0),
        child: Icon(icon, size: size, color: iconColor ?? resolved.color),
      ),
    );
    return Text.rich(
      TextSpan(children: [if (leading) iconSpan, TextSpan(text: text), if (!leading) iconSpan]),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
