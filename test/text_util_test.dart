import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookfx_mz/src/utils/text.dart';

void main() {
  testWidgets('TextUtil text height calculation', (WidgetTester tester) async {
    // Build our test widget
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            // Test text height calculation
            final height = TextUtil.calculateTextHeight(
              'Test text',
              16.0,
              fontHeight: 1.4,
              maxWidth: 300.0,
              padding: const EdgeInsets.all(20.0),
            );

            // Verify height is calculated
            expect(height, isPositive);
            
            // Test max text position calculation
            final maxPos = TextUtil.calculateTextMaxTextPos(
              'Long test text that should span multiple lines when rendered',
              16.0,
              fontHeight: 1.4,
              maxWidth: 300.0,
              padding: const EdgeInsets.all(20.0),
              maxLines: 2,
            );

            // Verify position is calculated
            expect(maxPos, isNonNegative);

            return Container(); // Return any widget
          },
        ),
      ),
    );
  });

  test('TextUtil static methods exist', () {
    expect(TextUtil.calculateTextHeight, isNotNull);
    expect(TextUtil.calculateTextMaxTextPos, isNotNull);
  });
} 