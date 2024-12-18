import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/services/audio_recorder_service.dart';
import '../../data/services/file_picker_service.dart';
import '../../data/repositories/audio_repository.dart';
import '../../data/models/audio_analysis_response.dart';
import '../../core/config/api_endpoints.dart';

enum RecordingStatus {
  initial,
  recording,
  stopped,
  processing,
  completed,
  error
}

class RecordingState extends ChangeNotifier {
  AudioRecorderService _recorderService;
  AudioRepository _audioRepository;
  FilePickerService _filePickerService;
  
  RecordingStatus _status = RecordingStatus.initial;
  String? _errorMessage;
  File? _audioFile;
  AudioAnalysisResponse? _analysisResponse;
  Timer? _amplitudeTimer;
  double _currentAmplitude = 0.0;
  bool _isLoading = false;
  String? _error;

  RecordingState({
    required AudioRecorderService recorderService,
    required AudioRepository audioRepository,
    required FilePickerService filePickerService,
  })  : _recorderService = recorderService,
        _audioRepository = audioRepository,
        _filePickerService = filePickerService;

  // Getters
  RecordingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  File? get audioFile => _audioFile;
  AudioAnalysisResponse? get analysisResponse => _analysisResponse;
  double get currentAmplitude => _currentAmplitude;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    _error = error;
    
    // Don't show settings button for analysis or network errors
    if (!error.toLowerCase().contains('permission') &&
        !error.toLowerCase().contains('microphone') &&
        !error.toLowerCase().contains('storage')) {
      _error = error.replaceAll('Please check permissions and try again.', '');
    }
    
    notifyListeners();
  }

  Future<void> startRecording() async {
    try {
      await _recorderService.startRecording();
      _status = RecordingStatus.recording;
      _errorMessage = null;
      _error = null;
      notifyListeners();

      // Start monitoring amplitude
      _amplitudeTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) async {
          try {
            final rawAmplitude = await _recorderService.getAmplitude();
            // Ensure amplitude is a valid number between 0 and 1
            _currentAmplitude = rawAmplitude.isNaN ? 0.0 : rawAmplitude.clamp(0.0, 1.0);
            notifyListeners();
          } catch (e) {
            // If there's an error getting amplitude, default to 0
            _currentAmplitude = 0.0;
            setError(e.toString());
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _status = RecordingStatus.error;
      setError(e.toString());
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    try {
      _amplitudeTimer?.cancel();
      _audioFile = await _recorderService.stopRecording();
      _status = RecordingStatus.stopped;
      _errorMessage = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _status = RecordingStatus.error;
      setError(e.toString());
      notifyListeners();
    }
  }

  Future<void> pickAudioFile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _filePickerService.pickAudioFile();
      
      if (result != null) {
        if (result.error != null) {
          _status = RecordingStatus.error;
          setError(result.error!);
        } else if (result.file != null) {
          _audioFile = result.file;
          _status = RecordingStatus.stopped;
          _errorMessage = null;
          _error = null;
        }
      }
    } catch (e) {
      _status = RecordingStatus.error;
      setError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeRecording() async {
    if (_audioFile == null) {
      setError('No recording available');
      notifyListeners();
      return;
    }

    try {
      _status = RecordingStatus.processing;
      _isLoading = true;
      notifyListeners();

      _analysisResponse = await _audioRepository.analyzeAudio(
        audioFile: _audioFile!,
      );

      _status = RecordingStatus.completed;
      _errorMessage = null;
      _error = null;
    } catch (e) {
      _status = RecordingStatus.error;
      setError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _amplitudeTimer?.cancel();
    _audioFile = null;
    _status = RecordingStatus.initial;
    _errorMessage = null;
    _error = null;
    _currentAmplitude = 0.0;
    _isLoading = false;
    notifyListeners();
  }

  // Update services method for ProxyProvider
  void updateServices({
    required AudioRecorderService recorderService,
    required AudioRepository audioRepository,
    required FilePickerService filePickerService,
  }) {
    // No need to update if services are the same
    if (_recorderService == recorderService &&
        _audioRepository == audioRepository &&
        _filePickerService == filePickerService) {
      return;
    }
    
    // Update the services
    _recorderService = recorderService;
    _audioRepository = audioRepository;
    _filePickerService = filePickerService;
    notifyListeners();
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _recorderService.dispose();
    super.dispose();
  }
}
