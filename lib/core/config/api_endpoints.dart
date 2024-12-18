import 'environment_config.dart';

/// Class to centralize all API endpoints
class ApiEndpoints {
  /// Private constructor to prevent instantiation
  ApiEndpoints._();

  /// Endpoint for audio analysis
  static String get analyzeAudio => EnvironmentConfig.analyzeAudioEndpoint;
}
