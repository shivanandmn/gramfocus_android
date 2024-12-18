// Models that represent the grammar analysis response from the API
class GrammarCorrection {
  final String original;
  final String correction;
  final String reason;
  final String mistakeTitle;
  final String mistakeClass;

  GrammarCorrection({
    required this.original,
    required this.correction,
    required this.reason,
    required this.mistakeTitle,
    required this.mistakeClass,
  });

  factory GrammarCorrection.fromJson(Map<String, dynamic> json) {
    return GrammarCorrection(
      original: json['original'] as String,
      correction: json['correction'] as String,
      reason: json['reason'] as String,
      mistakeTitle: json['mistake_title'] as String,
      mistakeClass: json['mistake_class'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'original': original,
        'correction': correction,
        'reason': reason,
        'mistake_title': mistakeTitle,
        'mistake_class': mistakeClass,
      };
}

class GrammarAnalysis {
  final List<GrammarCorrection> corrections;
  final String improvedVersion;
  final String overview;

  GrammarAnalysis({
    required this.corrections,
    required this.improvedVersion,
    required this.overview,
  });

  factory GrammarAnalysis.fromJson(Map<String, dynamic> json) {
    return GrammarAnalysis(
      corrections: (json['corrections'] as List)
          .map((e) => GrammarCorrection.fromJson(e as Map<String, dynamic>))
          .toList(),
      improvedVersion: json['improved_version'] as String,
      overview: json['overview'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'corrections': corrections.map((e) => e.toJson()).toList(),
        'improved_version': improvedVersion,
        'overview': overview,
      };
}
