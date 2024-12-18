import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AudioRecorderService {
  final _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;

  Future<bool> hasPermission() async {
    try {
      // Check microphone permission first
      final micStatus = await Permission.microphone.status;
      print('Microphone permission status: $micStatus');
      
      if (!micStatus.isGranted) {
        final micResult = await Permission.microphone.request();
        print('Microphone permission request result: $micResult');
        if (!micResult.isGranted) {
          return false;
        }
      }

      // Check storage permissions based on Android version
      if (Platform.isAndroid) {
        if (await _isAndroid13OrHigher()) {
          final audioStatus = await Permission.audio.status;
          print('Audio permission status (Android 13+): $audioStatus');
          if (!audioStatus.isGranted) {
            final audioResult = await Permission.audio.request();
            print('Audio permission request result: $audioResult');
            if (!audioResult.isGranted) {
              return false;
            }
          }
        } else {
          final storageStatus = await Permission.storage.status;
          print('Storage permission status (Android <13): $storageStatus');
          if (!storageStatus.isGranted) {
            final storageResult = await Permission.storage.request();
            print('Storage permission request result: $storageResult');
            if (!storageResult.isGranted) {
              return false;
            }
          }
        }
      }

      // Double check recorder permissions
      final recorderPermission = await _audioRecorder.hasPermission();
      print('Recorder permission check: $recorderPermission');
      
      return recorderPermission;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  Future<void> startRecording() async {
    bool hasPermissions = await hasPermission();
    if (!hasPermissions) {
      throw Exception('Microphone and storage permissions are required for recording. Please grant them in app settings.');
    }

    try {
      if (await _audioRecorder.isRecording()) {
        throw Exception('Already recording');
      }

      // Ensure we have permissions before proceeding
      if (!await _audioRecorder.hasPermission()) {
        throw Exception('Recording permissions not available. Please check app settings.');
      }

      final directory = await getApplicationDocumentsDirectory();
      _currentRecordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacHe,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: _currentRecordingPath!,
      );
    } catch (e) {
      print('Recording error: $e');
      throw Exception('Failed to start recording. Please check permissions and try again.');
    }
  }

  Future<File> stopRecording() async {
    try {
      if (!await _audioRecorder.isRecording()) {
        throw Exception('Not recording');
      }

      await _audioRecorder.stop();

      if (_currentRecordingPath == null) {
        throw Exception('Recording path not found');
      }

      final file = File(_currentRecordingPath!);
      if (!await file.exists()) {
        throw Exception('Recording file not found');
      }

      return file;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }

  Future<double> getAmplitude() async {
    try {
      if (!await _audioRecorder.isRecording()) {
        return 0.0;
      }

      final amplitude = await _audioRecorder.getAmplitude();
      
      // Improved normalization with noise floor consideration
      const double MIN_DB = -60.0;  // Noise floor
      const double RANGE_DB = 60.0;  // Range from noise floor to 0dB
      
      // Normalize with noise floor consideration
      final double normalizedValue = ((amplitude.current - MIN_DB) / RANGE_DB)
          .clamp(0.0, 1.0);
      
      // Apply slight smoothing
      return normalizedValue * 0.95;  // Slight damping to reduce jumps
      
    } catch (e) {
      return 0.0;
    }
  }
}
