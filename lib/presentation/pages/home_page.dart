import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../providers/recording_state.dart';
import '../widgets/recording_visualizer.dart';
import '../widgets/audio_preview.dart';
import 'results_page.dart';
import 'package:app_settings/app_settings.dart';
import '../../core/utils/error_handler.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<bool> _requestPermissions() async {
    try {
      print('Starting permission check...');
      
      // Check each permission individually for better debugging
      final micStatus = await Permission.microphone.status;
      print('Initial microphone status: $micStatus');
      
      final storageStatus = await Permission.storage.status;
      print('Initial storage status: $storageStatus');
      
      final audioStatus = await Permission.audio.status;
      print('Initial audio status: $audioStatus');

      // Request permissions if not granted
      if (!micStatus.isGranted) {
        final micResult = await Permission.microphone.request();
        print('Microphone permission request result: $micResult');
      }

      if (Platform.isAndroid) {
        if (await _isAndroid13OrHigher()) {
          if (!audioStatus.isGranted) {
            final audioResult = await Permission.audio.request();
            print('Audio permission request result: $audioResult');
          }
        } else {
          if (!storageStatus.isGranted) {
            final storageResult = await Permission.storage.request();
            print('Storage permission request result: $storageResult');
          }
        }
      }

      // Final check of all permissions
      final finalMicStatus = await Permission.microphone.status;
      final finalStorageStatus = await Permission.storage.status;
      final finalAudioStatus = await Permission.audio.status;

      print('Final permission status:');
      print('Microphone: $finalMicStatus');
      print('Storage: $finalStorageStatus');
      print('Audio: $finalAudioStatus');

      bool hasAllPermissions = finalMicStatus.isGranted && 
        (Platform.isAndroid ? 
          (await _isAndroid13OrHigher() ? finalAudioStatus.isGranted : finalStorageStatus.isGranted) 
          : true);

      print('Has all required permissions: $hasAllPermissions');
      return hasAllPermissions;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      print('Android SDK version: $sdkInt');
      return sdkInt >= 33;
    }
    return false;
  }

  Future<void> _checkAndRequestPermissions(BuildContext context) async {
    try {
      bool hasPermissions = await _requestPermissions();
      if (!hasPermissions && context.mounted) {
        ErrorHandler.showError(
          context,
          'Microphone and storage permissions are required for recording',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Request permissions when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: Consumer<RecordingState>(
        builder: (context, recordingState, child) {
          // Show error message if there's one
          if (recordingState.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ErrorHandler.showError(context, recordingState.error!);
              // Clear the error after showing
              recordingState.clearError();
            });
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Recording Visualizer or Audio Preview
                      if (recordingState.status == RecordingStatus.recording)
                        const SizedBox(
                          height: 200,
                          child: RecordingVisualizer(),
                        )
                      else if (recordingState.audioFile != null)
                        AudioPreview(
                          audioFile: recordingState.audioFile!,
                          onDelete: recordingState.reset,
                        )
                      else
                        const SizedBox(
                          height: 200,
                          child: Center(
                            child: Icon(
                              Icons.mic,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      // Recording Status
                      Text(
                        _getStatusText(recordingState.status),
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 20),
                      // Error Message if any
                      if (recordingState.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            recordingState.errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 40),
                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMainActionButton(context, recordingState),
                            const SizedBox(height: 16),
                            if (recordingState.status == RecordingStatus.stopped)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                  onPressed: recordingState.isLoading
                                      ? null
                                      : () => _analyzeRecording(context, recordingState),
                                  child: const Text(AppStrings.submit),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Loading Overlay
              if (recordingState.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _getStatusText(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.initial:
        return 'Ready to Record';
      case RecordingStatus.recording:
        return AppStrings.recording;
      case RecordingStatus.stopped:
        return 'Recording Complete';
      case RecordingStatus.processing:
        return AppStrings.processing;
      case RecordingStatus.completed:
        return 'Analysis Complete';
      case RecordingStatus.error:
        return 'Error';
    }
  }

  Widget _buildMainActionButton(BuildContext context, RecordingState state) {
    final isRecording = state.status == RecordingStatus.recording;
    
    return FloatingActionButton.extended(
      onPressed: () => _handleRecordingAction(context, state),
      backgroundColor: isRecording ? AppColors.recording : AppColors.primary,
      icon: Icon(isRecording ? Icons.stop : Icons.mic),
      label: Text(isRecording ? AppStrings.stopRecording : AppStrings.startRecording),
    );
  }

  void _handleRecordingAction(BuildContext context, RecordingState state) {
    if (state.status == RecordingStatus.recording) {
      state.stopRecording();
    } else {
      state.startRecording();
    }
  }

  void _analyzeRecording(BuildContext context, RecordingState state) async {
    await state.analyzeRecording();
    if (state.status == RecordingStatus.completed && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultsPage(),
        ),
      );
    }
  }
}
