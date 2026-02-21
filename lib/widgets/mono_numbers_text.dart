import 'package:flutter/material.dart';

class MonoNumbersText extends StatelessWidget {
  const MonoNumbersText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  static final RegExp _numericToken = RegExp(r'[0-9٠-٩][0-9٠-٩\/:\-.,٪%]*');

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style.merge(style);
    final monoStyle = baseStyle.copyWith(fontFamily: 'monospace');

    final spans = <InlineSpan>[];
    var start = 0;
    for (final match in _numericToken.allMatches(data)) {
      if (match.start > start) {
        spans.add(TextSpan(text: data.substring(start, match.start)));
      }
      spans.add(
        TextSpan(text: match.group(0), style: monoStyle),
      );
      start = match.end;
    }
    if (start < data.length) {
      spans.add(TextSpan(text: data.substring(start)));
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      softWrap: softWrap,
    );
  }
}
