import 'package:flutter/material.dart';

extension KeepAllStringExtension on String {
  /// 한국어 텍스트가 어절(단어) 단위로만 줄바꿈되도록 강제합니다.
  /// 공백을 기준으로 단어를 나누고, 각 단어 안의 글자들을 Word Joiner(\u2060)로 결합하여
  /// 단어 중간 줄바꿈을 방지합니다. (이모지 깨짐 방지를 위해 characters 사용)
  String get keepAll {
    return split(' ').map((word) => word.characters.join('\u2060')).join(' ');
  }
}

class KeepAllText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const KeepAllText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.keepAll,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
