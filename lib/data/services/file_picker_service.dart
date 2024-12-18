import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/file_validator.dart';

class FilePickerService {
  Future<PickedAudioFile?> pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: FileValidator.validAudioExtensions,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final validationResult = FileValidator.validateAudioFile(file);

        if (!validationResult.isValid) {
          return PickedAudioFile(
            file: null,
            error: validationResult.error,
          );
        }

        return PickedAudioFile(file: file);
      }
      return null;
    } catch (e) {
      return PickedAudioFile(
        file: null,
        error: 'Error picking audio file: $e',
      );
    }
  }
}

class PickedAudioFile {
  final File? file;
  final String? error;

  PickedAudioFile({
    this.file,
    this.error,
  });
}
