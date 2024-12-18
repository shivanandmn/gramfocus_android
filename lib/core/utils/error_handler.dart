import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:dio/dio.dart';

class ErrorHandler {
  static void showError(BuildContext context, dynamic error) {
    String message;
    bool showSettingsButton = false;

    // Convert error to string for easier handling
    String errorStr = error.toString().toLowerCase();

    if (error is DioException) {
      // Handle API related errors
      message = _handleDioError(error);
    } else if (errorStr.contains('permission') || 
              errorStr.contains('microphone') || 
              errorStr.contains('storage')) {
      // Handle permission related errors
      message = 'Microphone and storage permissions are required for recording';
      showSettingsButton = true;
    } else if (errorStr.contains('file size exceeds')) {
      // Handle file size errors
      message = 'File size is too large. Please try a shorter recording.';
    } else if (errorStr.contains('failed to analyze audio')) {
      // Handle audio analysis errors
      message = 'Unable to analyze the audio. Please try again or use a different file.';
    } else {
      // Handle other generic errors
      message = 'An unexpected error occurred. Please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: showSettingsButton
            ? SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => AppSettings.openAppSettings(),
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Upload timed out. Please try again with a smaller file.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timed out. Please try again.';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 413) {
          return 'File size exceeds server limit. Please try a shorter recording.';
        }
        return 'Server error: ${error.response?.statusCode ?? "Unknown"}';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error occurred. Please check your connection.';
    }
  }
}
