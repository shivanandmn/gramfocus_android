import 'dart:io';
import '../models/audio_analysis_response.dart';
import '../models/provider_models.dart';
import '../services/api_service.dart';

class AudioRepository {
  final ApiService _apiService;

  AudioRepository({required ApiService apiService}) : _apiService = apiService;

  Future<AudioAnalysisResponse> analyzeAudio({
    required File audioFile,
    TranscriptionProvider? transcriptionProvider,
    String? transcriptionModel,
    LLMProvider? analysisProvider,
    String? analysisModel,
  }) async {
    try {
      final response = await _apiService.analyzeAudio(
        audioFile: audioFile,
        transcriptionProvider: transcriptionProvider,
        transcriptionModel: transcriptionModel,
        analysisProvider: analysisProvider,
        analysisModel: analysisModel,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to analyze audio in repository: $e');
    }
  }
}
