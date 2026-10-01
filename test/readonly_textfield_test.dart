import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test readOnly TextField inside GestureDetector', (tester) async {
    bool tapped = false;
    final controller = TextEditingController(text: '오늘 하루도 정말 수고 많으셨습니다. 편안한 밤 되세요 🌙');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              tapped = true;
            },
            child: IgnorePointer(
              child: SizedBox(
                width: 300,
                height: 300,
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    await tester.tap(find.byType(TextField), warnIfMissed: false);
    await tester.pump();

    expect(tapped, isTrue);
    print('Tapped successfully through IgnorePointer!');
  });
}
