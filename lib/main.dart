import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'data/anime_repository.dart';
import 'state/anime_controller.dart';
import 'pages/anime_recommendation_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AnimeController(repository: AnimeRepository(rootBundle))..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Anime Recommendations',
        debugShowCheckedModeBanner: false,
        theme: baseTheme.copyWith(
          scaffoldBackgroundColor: const Color(0xFFF4F2FB),
          textTheme: baseTheme.textTheme.apply(
            bodyColor: const Color(0xFF1F1D2B),
            displayColor: const Color(0xFF1F1D2B),
          ),
        ),
        home: const AnimeRecommendationPage(),
      ),
    );
  }
}

