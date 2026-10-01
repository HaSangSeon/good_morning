import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_morning/widgets/keep_all_text.dart';

class KeepAllTextEditingController extends TextEditingController {
  KeepAllTextEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return TextSpan(
      style: style,
      text: text.keepAll,
    );
  }
}

void main() {
  testWidgets('Test tap to place cursor at offset', (tester) async {
    final controller = KeepAllTextEditingController(text: '첫째도 건강! 둘째도 건강!');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: controller,
              ),
            ),
          ),
        ),
      ),
    );

    // 텍스트 필드의 오른쪽 끝 부분을 탭해봄
    final center = tester.getCenter(find.byType(TextField));
    await tester.tapAt(Offset(center.dx + 50, center.dy));
    await tester.pump();

    print('Cursor selection after tap: ${controller.selection}');
  });
}
