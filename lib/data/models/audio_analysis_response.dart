import 'grammar_models.dart';
import 'provider_models.dart';

class AudioAnalysisResponse {
  final String transcription;
  final GrammarAnalysis analysis;
  final ProvidersInfo providers;

  AudioAnalysisResponse({
    required this.transcription,
    required this.analysis,
    required this.providers,
  });

  factory AudioAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AudioAnalysisResponse(
      transcription: json['transcription'] as String,
      analysis: GrammarAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
      providers: ProvidersInfo.fromJson(json['providers'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'transcription': transcription,
        'analysis': analysis.toJson(),
        'providers': providers.toJson(),
      };
}
