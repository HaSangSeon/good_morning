import 'package:flutter/material.dart';

extension KeepAllStringExtension on String {
  /// 한국어 텍스트가 어절(단어) 단위로만 줄바꿈되도록 강제합니다.
  /// 공백을 기준으로 단어를 나누고, 각 단어 안의 글자들을 Word Joiner(\u2060)로 결합하여
  /// 단어 중간 줄바꿈을 방지합니다. (이모지 깨짐 방지를 위해 characters 사용)
  String get keepAll {
    return split(' ').map((word) {
      // 이모티콘이나 기호에 Word Joiner(\u2060)가 삽입되면 플러터 텍스트 엔진 렌더링 버그(까맣게 변함)가 발생합니다.
      // 따라서 한글, 영문, 숫자 등 일반 텍스트 덩어리에만 \u2060를 적용합니다.
      return word.replaceAllMapped(RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]+'), (match) {
        return match.group(0)!.characters.join('\u2060');
      });
    }).join(' ');
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
