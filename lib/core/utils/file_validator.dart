import 'dart:io';
import 'package:path/path.dart' as path;

class FileValidator {
  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50MB
  static const List<String> validAudioExtensions = [
    'mp3',
    'm4a',
    'wav',
    'aac',
    'wma',
    'ogg'
  ];

  static ValidationResult validateAudioFile(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      return ValidationResult(
        isValid: false,
        error: 'File does not exist',
      );
    }

    // Check file size
    final size = file.lengthSync();
    if (size > maxFileSizeBytes) {
      return ValidationResult(
        isValid: false,
        error: 'File size must be less than 50MB (${getFileSize(file)})',
      );
    }

    // Check file extension
    final extension =
        path.extension(file.path).toLowerCase().replaceAll('.', '');
    if (!validAudioExtensions.contains(extension)) {
      return ValidationResult(
        isValid: false,
        error:
            'Invalid file type. Supported formats: ${validAudioExtensions.join(", ")}',
      );
    }

    return ValidationResult(isValid: true);
  }

  static String getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String getFileName(File file) {
    return path.basename(file.path);
  }
}

class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult({
    required this.isValid,
    this.error,
  });
}
