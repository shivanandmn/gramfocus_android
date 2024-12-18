import 'package:flutter/foundation.dart';

/// Environment configuration class to handle different environments
class EnvironmentConfig {
  /// Private constructor to prevent instantiation
  EnvironmentConfig._();

  /// Get the appropriate API endpoint based on build mode
  static String get analyzeAudioEndpoint {
    if (kDebugMode) {
      return 'https://gramfocus-555118069489.us-central1.run.app/api/v1/test';
    } else {
      return 'https://gramfocus-555118069489.us-central1.run.app/api/v1/analyze-transcript';
    }
  }
}
