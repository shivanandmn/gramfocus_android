import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/audio_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/audio_recorder_service.dart';
import 'presentation/providers/recording_state.dart';
import 'presentation/pages/home_page.dart';
import 'core/config/api_endpoints.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => ApiService(
            baseUrl: ApiEndpoints.analyzeAudio,
          ),
        ),
        Provider(
          create: (_) => AudioRecorderService(),
        ),
        ProxyProvider<ApiService, AudioRepository>(
          update: (_, apiService, __) => AudioRepository(
            apiService: apiService,
          ),
        ),
        ChangeNotifierProxyProvider2<AudioRecorderService, AudioRepository,
            RecordingState>(
          create: (context) {
            final recorderService = Provider.of<AudioRecorderService>(context, listen: false);
            final audioRepository = Provider.of<AudioRepository>(context, listen: false);
            return RecordingState(
              recorderService: recorderService,
              audioRepository: audioRepository,
            );
          },
          update: (_, recorderService, audioRepository, previous) =>
              previous!..updateServices(
                recorderService: recorderService,
                audioRepository: audioRepository,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'GramFocus',
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
