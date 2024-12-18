import 'dart:io';
import 'package:dio/dio.dart';
import '../models/audio_analysis_response.dart';
import '../models/provider_models.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({required String baseUrl})
      : baseUrl = baseUrl,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 300),
          // Increase maximum size for multipart data
          maxRedirects: 5,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ));

  Future<AudioAnalysisResponse> analyzeAudio({
    required File audioFile,
    Function(double)? onProgress,
    TranscriptionProvider? transcriptionProvider,
    String? transcriptionModel,
    LLMProvider? analysisProvider,
    String? analysisModel,
  }) async {
    try {
      // Create form data with the file
      final formData = FormData.fromMap({
        'audio_file': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
          // Enable streaming upload for large files
        ),
        if (transcriptionProvider != null)
          'transcription_provider': transcriptionProvider.value,
        if (transcriptionModel != null)
          'transcription_model': transcriptionModel,
        if (analysisProvider != null)
          'analysis_provider': analysisProvider.value,
        if (analysisModel != null) 'analysis_model': analysisModel,
      });

      // Make API call with progress tracking
      final response = await _dio.post(
        '/analyze-audio',
        data: formData,
        onSendProgress: onProgress != null 
            ? (sent, total) => onProgress(sent / total)
            : null,
        options: Options(
          // Increase timeout for large files
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 10),
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AudioAnalysisResponse.fromJson(response.data);
      } else if (response.statusCode == 413) {
        throw Exception(
          'File size exceeds server limit. Please try using a smaller file or contact support.',
        );
      } else {
        throw Exception('Failed to analyze audio: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        throw Exception(
          'File size exceeds server limit. Please try using a smaller file or contact support.',
        );
      }
      throw Exception('Failed to analyze audio: ${e.message}');
    } catch (e) {
      throw Exception('Failed to analyze audio: $e');
    }
  }
}
