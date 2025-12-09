import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/anime_controller.dart';
import '../widgets/swipeable_anime_card.dart';
import '../widgets/treasure_chest_icon.dart';
import 'favorites_page.dart';

class AnimeRecommendationPage extends StatefulWidget {
  const AnimeRecommendationPage({super.key});
  @override
  State<AnimeRecommendationPage> createState() => _AnimeRecommendationPageState();
}

class _AnimeRecommendationPageState extends State<AnimeRecommendationPage> with SingleTickerProviderStateMixin {
  static const _prefKeyOnboarding = 'onboarding_seen';

  bool _showOnboarding = false;
  int _onboardingStep = 0;
  bool _cardAnimRight = true;

  Offset _cardOffset = Offset.zero;
  double _cardRotation = 0;
  bool _isDragging = false;
  bool _showSwipeHint = true;

  @override
  void initState() {
    super.initState();
    _loadOnboardingFlag();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showSwipeHint = false);
    });
  }

  Future<void> _loadOnboardingFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_prefKeyOnboarding) ?? false;
    if (mounted) {
      setState(() {
        _showOnboarding = !seen;
        _onboardingStep = 0;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyOnboarding, true);
    if (mounted) setState(() => _showOnboarding = false);
  }

  void _nextOnboardingStep() {
    if (_onboardingStep < 2) {
      setState(() {
        _onboardingStep++;
        _cardAnimRight = true;
      });
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.current == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Text(
            'Pas assez de donnees pour afficher des recommandations.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final currentAnime = controller.current!;
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeStrength = (_cardOffset.dx.abs() / screenWidth).clamp(0.0, 1.0);
    final swipeRight = _cardOffset.dx > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Decouvrez votre anime',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const TreasureChestIcon(size: 28),
            tooltip: 'Mon coffre-fort',
            onPressed: () async {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // fond reactif au swipe
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  gradient: _buildSwipeGradient(swipeStrength, swipeRight),
                ),
              ),
            ),

            if (controller.inExploration)
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.lightbulb_outline, color: Color(0xFF0D47A1)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Phase decouverte des genres',
                              style: TextStyle(
                                color: Color(0xFF0D47A1),
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Carte ${controller.shownCount + 1} / ${controller.explorationLimit} : on explore tous les genres, vos likes affineront ensuite les recommandations.',
                        style: const TextStyle(
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (controller.shownCount / controller.explorationLimit).clamp(0, 1),
                          minHeight: 6,
                          color: const Color(0xFF0D47A1),
                          backgroundColor: const Color(0xFF0D47A1).withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Carte actuelle
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: controller.inExploration ? 90 : 16),
                child: GestureDetector(
                  onPanStart: (_) {
                    setState(() {
                      _isDragging = true;
                      _showSwipeHint = false;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _cardOffset += details.delta;
                      _cardRotation = _cardOffset.dx / 1000;
                    });
                  },
                  onPanEnd: (details) {
                    setState(() => _isDragging = false);
                    if (_cardOffset.dx.abs() > screenWidth * 0.3) {
                      _animateCardOffScreen(_cardOffset.dx > 0, controller);
                    } else {
                      setState(() {
                        _cardOffset = Offset.zero;
                        _cardRotation = 0;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    transform: Matrix4.translationValues(_cardOffset.dx, _cardOffset.dy, 0)
                      ..rotateZ(_cardRotation),
                    child: SwipeableAnimeCard(
                      anime: currentAnime,
                      onSwipeLeft: () {},
                      onSwipeRight: () {},
                    ),
                  ),
                ),
              ),
            ),

            // Overlay tuto au-dessus de tout (3 slides)
            if (_showOnboarding)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _nextOnboardingStep,
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 120),
                            child: _buildOnboardingHeader(),
                          ),
                        ),
                        Center(child: _buildOnboardingSlide()),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: _buildDots(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Indicateur de swipe
            if (_showSwipeHint && !_showOnboarding)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.3, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, double opacity, child) {
                      return Opacity(opacity: opacity, child: child);
                    },
                    onEnd: () {
                      if (mounted) setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_back_rounded, color: Colors.red, size: 26),
                          SizedBox(width: 16),
                          Text(
                            'Swipe pour choisir',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.arrow_forward_rounded, color: Colors.green, size: 26),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LinearGradient _buildSwipeGradient(double strength, bool right) {
    if (strength <= 0.01) {
      return const LinearGradient(
        colors: [Colors.white, Colors.white],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    final alpha = (0.25 + 0.35 * strength).clamp(0.0, 0.6);
    return right
        ? LinearGradient(
            colors: [Colors.white, Colors.white, Colors.green.withOpacity(alpha)],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : LinearGradient(
            colors: [Colors.red.withOpacity(alpha), Colors.white, Colors.white],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );
  }

  Widget _buildOnboardingHeader() {
    switch (_onboardingStep) {
      case 0:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Bienvenue dans OtakuGo', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text("Touchez l'ecran pour continuer", style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        );
      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Comprendre le swipe', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text("Touchez l'ecran pour continuer", style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        );
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('A vous de jouer !', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('Decouvrez vos recommandations maintenant.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        );
    }
  }

  Widget _buildOnboardingSlide() {
    if (_onboardingStep == 0) {
      return const SizedBox();
    }
    if (_onboardingStep == 1) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: _cardAnimRight ? 0 : 1, end: _cardAnimRight ? 1 : 0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        onEnd: () {
          if (mounted) setState(() => _cardAnimRight = !_cardAnimRight);
        },
        builder: (context, value, child) {
          final dx = (value - 0.5) * 180;
          final bg = Color.lerp(Colors.red.withOpacity(0.3), Colors.green.withOpacity(0.3), value) ?? Colors.green;
          return Container(
            width: 260,
            height: 360,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: Transform.rotate(
                angle: dx / 1000,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        dx >= 0 ? Icons.thumb_up_alt_rounded : Icons.thumb_down_alt_rounded,
                        color: dx >= 0 ? Colors.green : Colors.red,
                        size: 46,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dx >= 0 ? "J'aime" : "Je n'aime pas",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    // step 2
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text("C'est parti !", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        SizedBox(height: 8),
        Text("Touchez l'ecran pour commencer.", style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildDots() {
    Widget dot(bool active) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white24,
            shape: BoxShape.circle,
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot(_onboardingStep == 0),
        dot(_onboardingStep == 1),
        dot(_onboardingStep == 2),
      ],
    );
  }

  void _animateCardOffScreen(bool liked, AnimeController controller) async {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      _cardOffset = Offset(liked ? screenWidth * 1.5 : -screenWidth * 1.5, 0);
      _cardRotation = liked ? 0.3 : -0.3;
    });
    await Future.delayed(const Duration(milliseconds: 350));
    if (liked) {
      // Ajouter aux favoris quand on swipe à droite
      if (controller.current != null && !controller.isFavorite(controller.current!)) {
        controller.toggleFavorite(controller.current!);
      }
      controller.likeCurrent();
    } else {
      controller.skipCurrent();
    }
    setState(() {
      _cardOffset = Offset.zero;
      _cardRotation = 0;
    });
  }
}
