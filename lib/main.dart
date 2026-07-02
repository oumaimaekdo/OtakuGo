import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'data/anime_repository.dart';
import 'state/anime_controller.dart';
import 'pages/anime_recommendation_page.dart';
import 'pages/favorites_page.dart';
import 'pages/splash_screen.dart';
import 'pages/discovery_page.dart';

import 'features/dashboard_page.dart';
import 'features/performance_page.dart';
import 'features/tierlist_page.dart';
import 'features/tournoi/tournoi_depart_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AnimeController(repository: AnimeRepository(rootBundle))..load(),
        ),
      ],
      child: const OtakuGoApp(),
    );
  }
}
dynamic flutter;
class OtakuGoApp extends StatelessWidget {
  const OtakuGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5DD3)),
    );

    final lightTheme = baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF2E8D5), // Beige
      colorScheme: baseTheme.colorScheme.copyWith(
         primary: const Color(0xFF6C5DD3),
         surface: const Color(0xFFF2E8D5),
         brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF2E8D5),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: const Color(0xFF1F1D2B),
        displayColor: const Color(0xFF1F1D2B),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
      ),
    );

    final darkTheme = baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF17171F), // Dark BG
      colorScheme: baseTheme.colorScheme.copyWith(
         primary: const Color(0xFF6C5DD3),
         brightness: Brightness.dark,
         surface: const Color(0xFF252836), // Card color
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF17171F),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: const Color(0xFFF2E8D5), // Beige text
        displayColor: const Color(0xFFF2E8D5),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF252836),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF252836),
      ),
    );

    return Consumer<AnimeController>(
      builder: (context, controller, _) {
        return MaterialApp(
          title: 'Otakugo',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: controller.themeMode,
          builder: (context, child) {
            return Container(
              color: const Color(0xFF17171F),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: child!,
                ),
              ),
            );
          },
          home: const SplashScreen(
            nextScreen: MainScreen(),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = context.read<AnimeController>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      controller.audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (!controller.isMuted) {
        controller.audioPlayer.play();
      }
    }
  }

  final List<Widget> _pages = [
    const AnimeRecommendationPage(),
    const TierListPage(),
    const TournamentStartPage(),
    const DiscoveryPage(),
    const DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isNavBarVisible = context.select<AnimeController, bool>((c) => c.isNavBarVisible);

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        offset: isNavBarVisible ? Offset.zero : const Offset(0, 2.0),
        child: Container(
          margin: EdgeInsets.fromLTRB(12, 0, 12, 8 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5DD3).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Accueil'),
                  _buildNavItem(1, Icons.view_list_outlined, Icons.view_list_rounded, 'Tier List'),
                  _buildNavItem(2, Icons.emoji_events_outlined, Icons.emoji_events_rounded, 'Tournoi'),
                  _buildNavItem(3, Icons.explore_outlined, Icons.explore_rounded, 'Découverte'),
                  _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5DD3).withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF6C5DD3) : Colors.grey[500],
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6C5DD3) : Colors.grey[500],
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

