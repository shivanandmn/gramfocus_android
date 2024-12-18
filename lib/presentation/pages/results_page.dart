import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/grammar_models.dart';
import '../providers/recording_state.dart';
import '../widgets/correction_card.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.results),
      ),
      body: Consumer<RecordingState>(
        builder: (context, state, child) {
          final analysis = state.analysisResponse?.analysis;
          
          if (analysis == null) {
            return const Center(
              child: Text(AppStrings.noCorrections),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Section
                _buildOverviewSection(analysis.overview),
                
                // Corrections by Category
                _buildCorrectionsSection(analysis.corrections),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection(String overview) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.overview,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            overview,
            style: AppTextStyles.body1,
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionsSection(List<GrammarCorrection> corrections) {
    // Group corrections by mistake class
    final groupedCorrections = <String, List<GrammarCorrection>>{};
    for (var correction in corrections) {
      groupedCorrections.putIfAbsent(correction.mistakeClass, () => []);
      groupedCorrections[correction.mistakeClass]!.add(correction);
    }

    return ExpansionPanelList.radio(
      elevation: 1,
      children: groupedCorrections.entries.map((entry) {
        return ExpansionPanelRadio(
          value: entry.key, // Unique value for each panel
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(
                entry.key,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
              ),
              subtitle: Text(
                '${entry.value.length} ${entry.value.length == 1 ? 'correction' : 'corrections'}',
                style: AppTextStyles.caption,
              ),
            );
          },
          body: Column(
            children: entry.value
                .map((correction) => CorrectionCard(correction: correction))
                .toList(),
          ),
        );
      }).toList(),
    );
  }
}
