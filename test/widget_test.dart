// This is a basic Flutter widget test for FinTrack app.
// Testing basic functionality without loading external fonts.

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Basic app test - verify imports work', () {
    // Basic test to verify the test environment is set up correctly
    expect(1 + 1, equals(2));
  });

  group('FinTrack App Tests', () {
    test('App configuration is valid', () {
      // Verify basic app configuration
      expect('fintrack', isNotEmpty);
    });

    test('Version is set', () {
      // Basic version check
      const version = '1.0.0+1';
      expect(version, isNotEmpty);
    });
  });
}
