import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cc_workout_app/main.dart';

void main() {
  testWidgets('App displays main screen content', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));

    expect(find.text('Powerlifting Rep Max Tracker'), findsOneWidget);
    expect(
      find.text('Track your S/B/D lifts and view rep maxes'),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
