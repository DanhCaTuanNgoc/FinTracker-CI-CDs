import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function to load font for testing
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock the asset bundle for google_fonts
  const String fontManifest = '''
  [
    {
      "family": "Roboto",
      "fonts": [
        {
          "asset": "fonts/Roboto-Regular.ttf"
        }
      ]
    }
  ]
  ''';

  // Create a mock asset bundle
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall methodCall) async {
      return '.';
    },
  );
}
