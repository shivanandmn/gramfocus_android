enum LLMProvider {
  openai('openai'),
  gemini('gemini');

  final String value;
  const LLMProvider(this.value);
}

enum TranscriptionProvider {
  openai('openai'),
  google('google');

  final String value;
  const TranscriptionProvider(this.value);
}

class ProviderInfo {
  final String provider;
  final String? model;

  ProviderInfo({
    required this.provider,
    this.model,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      provider: json['provider'] as String,
      model: json['model'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'model': model,
      };
}

class ProvidersInfo {
  final ProviderInfo transcription;
  final ProviderInfo analysis;

  ProvidersInfo({
    required this.transcription,
    required this.analysis,
  });

  factory ProvidersInfo.fromJson(Map<String, dynamic> json) {
    return ProvidersInfo(
      transcription: ProviderInfo.fromJson(json['transcription'] as Map<String, dynamic>),
      analysis: ProviderInfo.fromJson(json['analysis'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'transcription': transcription.toJson(),
        'analysis': analysis.toJson(),
      };
}
