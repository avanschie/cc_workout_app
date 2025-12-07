import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Base robot class that provides common testing utilities
///
/// All specific robots should extend this class to get access to common
/// functionality like waiting for animations, finding widgets, etc.
abstract class BaseRobot {
  const BaseRobot(this.tester);

  final WidgetTester tester;

  /// Common finders
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get progressIndicator => find.byType(LinearProgressIndicator);
  Finder get errorSnackBar => find.byType(SnackBar);
  Finder get appBar => find.byType(AppBar);
  Finder get scaffold => find.byType(Scaffold);

  /// Wait for all animations and microtasks to complete
  Future<void> waitForAnimations() async {
    await tester.pumpAndSettle();
  }

  /// Wait for a specific duration (useful for testing timers)
  Future<void> waitFor(Duration duration) async {
    await tester.pump(duration);
  }

  /// Scroll a scrollable widget
  Future<void> scroll(Finder finder, Offset offset) async {
    await tester.drag(finder, offset);
    await waitForAnimations();
  }

  /// Scroll down in a list
  Future<void> scrollDown(Finder finder, {double amount = 300.0}) async {
    await scroll(finder, Offset(0, -amount));
  }

  /// Scroll up in a list
  Future<void> scrollUp(Finder finder, {double amount = 300.0}) async {
    await scroll(finder, Offset(0, amount));
  }

  /// Long press on a widget
  Future<void> longPress(Finder finder) async {
    await tester.longPress(finder);
    await waitForAnimations();
  }

  /// Tap and hold for a specific duration
  Future<void> tapAndHold(Finder finder, Duration duration) async {
    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump(duration);
    await gesture.up();
    await waitForAnimations();
  }

  /// Enter text with a delay between characters (simulates real typing)
  Future<void> typeText(Finder finder, String text, {Duration? delay}) async {
    await tester.tap(finder);
    await waitForAnimations();

    if (delay != null) {
      for (int i = 0; i < text.length; i++) {
        await tester.enterText(finder, text.substring(0, i + 1));
        await tester.pump(delay);
      }
    } else {
      await tester.enterText(finder, text);
    }
    await waitForAnimations();
  }

  /// Clear text field
  Future<void> clearText(Finder finder) async {
    await tester.tap(finder);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await waitForAnimations();
  }

  /// Verify that a widget exists
  void expectToFind(Finder finder, {String? reason}) {
    expect(finder, findsOneWidget, reason: reason);
  }

  /// Verify that a widget doesn't exist
  void expectNotToFind(Finder finder, {String? reason}) {
    expect(finder, findsNothing, reason: reason);
  }

  /// Verify that multiple widgets exist
  void expectToFindMultiple(Finder finder, int count, {String? reason}) {
    expect(finder, findsNWidgets(count), reason: reason);
  }

  /// Verify that at least one widget exists
  void expectToFindAtLeastOne(Finder finder, {String? reason}) {
    expect(finder, findsAtLeastNWidgets(1), reason: reason);
  }

  /// Verify that a widget is enabled
  void expectWidgetEnabled(Finder finder) {
    final widget = tester.widget(finder);
    if (widget is ElevatedButton) {
      expect(widget.onPressed, isNotNull, reason: 'Button should be enabled');
    } else if (widget is TextButton) {
      expect(widget.onPressed, isNotNull, reason: 'Button should be enabled');
    } else if (widget is OutlinedButton) {
      expect(widget.onPressed, isNotNull, reason: 'Button should be enabled');
    } else if (widget is IconButton) {
      expect(widget.onPressed, isNotNull, reason: 'Button should be enabled');
    } else {
      throw ArgumentError(
        'Widget type ${widget.runtimeType} not supported for enabled check',
      );
    }
  }

  /// Verify that a widget is disabled
  void expectWidgetDisabled(Finder finder) {
    final widget = tester.widget(finder);
    if (widget is ElevatedButton) {
      expect(widget.onPressed, isNull, reason: 'Button should be disabled');
    } else if (widget is TextButton) {
      expect(widget.onPressed, isNull, reason: 'Button should be disabled');
    } else if (widget is OutlinedButton) {
      expect(widget.onPressed, isNull, reason: 'Button should be disabled');
    } else if (widget is IconButton) {
      expect(widget.onPressed, isNull, reason: 'Button should be disabled');
    } else {
      throw ArgumentError(
        'Widget type ${widget.runtimeType} not supported for disabled check',
      );
    }
  }

  /// Verify loading state
  void expectLoadingState() {
    expectToFind(
      loadingIndicator,
      reason: 'Loading indicator should be visible',
    );
  }

  /// Verify no loading state
  void expectNoLoadingState() {
    expectNotToFind(
      loadingIndicator,
      reason: 'Loading indicator should not be visible',
    );
  }

  /// Verify error message
  void expectErrorMessage(String message) {
    expectToFind(
      find.text(message),
      reason: 'Error message should be displayed',
    );
  }

  /// Verify success message
  void expectSuccessMessage(String message) {
    expectToFind(
      find.text(message),
      reason: 'Success message should be displayed',
    );
  }

  /// Verify that text field has specific value
  void expectTextFieldValue(Finder finder, String expectedValue) {
    final textField = tester.widget<TextField>(finder);
    expect(textField.controller?.text, equals(expectedValue));
  }

  /// Verify that text field is empty
  void expectTextFieldEmpty(Finder finder) {
    expectTextFieldValue(finder, '');
  }

  /// Verify app bar title
  void expectAppBarTitle(String title) {
    expectToFind(
      find.descendant(of: appBar, matching: find.text(title)),
      reason: 'App bar should have title: $title',
    );
  }

  /// Take a screenshot for debugging
  Future<void> takeScreenshot(String name) async {
    // Screenshot functionality would be implemented here
    // Currently not available in flutter_test
    debugPrint('Screenshot requested: $name');
  }
}
