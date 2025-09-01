import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock data factories
class MockUserProfile {
  static Map<String, dynamic> valid() => {
    'uid': 'test_uid',
    'name': 'Test User',
    'email': 'test@example.com',
    'city': 'New York',
    'walletBalance': 100.0,
    'totalWins': 5,
    'stepCount': 10000,
    'level': 3,
    'createdAt': DateTime.now(),
    'lastActive': DateTime.now(),
  };
}

// Firebase emulator setup
void setupFirebaseEmulator() {
  // Use Firebase CLI to start emulators before running tests
  // Configure test environment to use localhost
}

// Location simulation utilities
class MockLocation {
  static double latitude = 40.7128;
  static double longitude = -74.0060;
}

// Automated screenshot testing
Future<void> takeScreenshot(WidgetTester tester, String name) async {
  // Placeholder: integrate with screenshot testing tools
}
