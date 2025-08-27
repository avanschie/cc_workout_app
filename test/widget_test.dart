import 'package:flutter_test/flutter_test.dart';

import 'package:cc_workout_app/main.dart';

void main() {
  testWidgets('App displays Hello World text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that our app shows the Hello World text.
    expect(find.text('Hello World!'), findsOneWidget);
  });
}
