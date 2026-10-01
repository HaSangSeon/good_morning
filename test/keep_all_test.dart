import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_morning/widgets/keep_all_text.dart';

void main() {
  test('Test TextPainter line metrics', () {
    final raw = "복되고 좋은 아침, 언제나 당신을 마음 깊이 응원합니다! 🙏";
    final tp = TextPainter(
      text: TextSpan(
        text: raw.keepAll,
        style: const TextStyle(fontSize: 32.0, height: 1.42, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout(maxWidth: 296.7);
    final lines = tp.computeLineMetrics();
    print('Total lines: ${lines.length}');
    for (int i = 0; i < lines.length; i++) {
      print('Line $i: width=${lines[i].width}');
    }
  });
}
