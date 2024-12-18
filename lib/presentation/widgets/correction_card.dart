import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/grammar_models.dart';

class CorrectionCard extends StatelessWidget {
  final GrammarCorrection correction;

  const CorrectionCard({
    super.key,
    required this.correction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              AppStrings.originalText,
              correction.original,
              AppColors.error,
            ),
            const SizedBox(height: 12),
            _buildSection(
              AppStrings.correctedText,
              correction.correction,
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildSection(
              AppStrings.reasonText,
              correction.reason,
              AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: AppTextStyles.body1,
        ),
      ],
    );
  }
}
