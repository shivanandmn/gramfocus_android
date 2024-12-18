import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/recording_state.dart';

class RecordingVisualizer extends StatelessWidget {
  const RecordingVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingState>(
      builder: (context, state, child) {
        if (state.status != RecordingStatus.recording) {
          return const Center(
            child: Icon(
              Icons.mic,
              size: 64,
              color: AppColors.primary,
            ),
          );
        }

        return CustomPaint(
          painter: VisualizerPainter(
            amplitude: state.currentAmplitude.clamp(0.0, 1.0),
          ),
          child: Container(),
        );
      },
    );
  }
}

class VisualizerPainter extends CustomPainter {
  final double amplitude;
  static const int barsCount = 30;
  final Random random = Random();
  
  VisualizerPainter({required this.amplitude});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.8)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    final width = size.width;
    final height = size.height;
    final barWidth = width / (barsCount * 2);
    
    // Ensure amplitude is valid and apply smoothing
    final safeAmplitude = amplitude.isNaN ? 0.0 : amplitude.clamp(0.0, 1.0);
    
    // Calculate base height (minimum height when there's no sound)
    final baseHeight = height * 0.1;  // 10% of total height

    for (var i = 0; i < barsCount; i++) {
      // Create a smooth wave effect
      final waveEffect = sin(i * 0.2 + DateTime.now().millisecondsSinceEpoch * 0.002);
      
      // Add controlled randomness
      final randomFactor = 0.9 + random.nextDouble() * 0.2;
      
      // Calculate dynamic height
      final dynamicHeight = height * 0.4 * safeAmplitude * randomFactor;
      
      // Combine base height, wave effect, and dynamic height
      final totalHeight = baseHeight + 
                         (dynamicHeight * (0.8 + 0.2 * waveEffect.abs()));

      // Calculate x position with slight randomness
      final baseX = width / 2 + (i - barsCount / 2) * barWidth * 2;
      final x = (baseX + random.nextDouble() * 2 - 1).clamp(0.0, width);
      
      // Calculate y positions
      final centerY = height / 2;
      final y1 = (centerY + totalHeight / 2).clamp(0.0, height);
      final y2 = (centerY - totalHeight / 2).clamp(0.0, height);

      // Draw with varying opacity based on height
      paint.color = AppColors.primary.withOpacity(
        0.4 + (totalHeight / height) * 0.6
      );

      canvas.drawLine(
        Offset(x, y1),
        Offset(x, y2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(VisualizerPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude;
  }
}
