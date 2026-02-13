import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/anime_controller.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/swipeable_anime_card.dart';
import '../widgets/treasure_chest_icon.dart';
import '../animations/premium_transitions.dart';
import 'favorites_page.dart';

class AnimeRecommendationPage extends StatefulWidget {
  const AnimeRecommendationPage({super.key});
  @override
  State<AnimeRecommendationPage> createState() => _AnimeRecommendationPageState();
}

class _AnimeRecommendationPageState extends State<AnimeRecommendationPage>
    with SingleTickerProviderStateMixin {

  bool _showOnboarding = false;
  int _onboardingStep = 0;
  bool _cardAnimRight = true;

  Offset _cardOffset = Offset.zero;
  double _cardRotation = 0;



  @override
  void initState() {
    super.initState();



    _loadOnboardingFlag();

  }



  @override
  void dispose() {

    super.dispose();
  }
 
  Future<void> _loadOnboardingFlag() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingSeen = prefs.getBool(_prefKeyOnboarding) ?? false;
    
    // Afficher le tuto UNIQUEMENT si jamais vu
    if (mounted && !_onboardingSeen && !_showQcm) {
      // Masquer la navbar (apres le build)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AnimeController>().setNavBarVisibility(false);
      });
      setState(() {
        _showOnboarding = true;
        _onboardingStep = 0;
      });
    } else {
      // Si déjà vu, on vérifie si le QCM doit être affiché
      _loadQcmFlag();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyOnboarding, true);
    
    // Réafficher la navbar
    if (mounted) {
      setState(() {
        _onboardingSeen = true;
        _showOnboarding = false;
      });
      _loadQcmFlag(); // Start QCM after onboarding
    }
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

  static const _prefKeyOnboarding = 'onboarding_seen';
  static const _prefKeyQcm = 'qcm_done_v2';
  static const Color _beige = Color(0xFFF2E8D5);

  static const List<String> _optionsGenres = [
    'Action',
    'Adventure',
    'Avant Garde',
    'Award Winning',
    'Boys Love',
    'Comedy',
    'Drama',
    'Ecchi',
    'Erotica',
    'Fantasy',
    'Girls Love',
    'Gourmet',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Sports',
    'Supernatural',
    'Suspense',
  ];


  bool _onboardingSeen = false;
  bool _isDragging = false;
  bool _showQcm = false;
  bool _isApplyingPreferences = false;
  int _qcmStep = 0;

  // QCM selections
  final Set<String> _qGenres = {};

  Future<void> _loadQcmFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final qcmDone = prefs.getBool(_prefKeyQcm) ?? false;
    
    if (mounted && !qcmDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AnimeController>().setNavBarVisibility(false);
      });
      setState(() {
        _showQcm = true;
        _qcmStep = 0;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AnimeController>().setNavBarVisibility(true);
      });
    }
  }

  Future<void> _completeQcm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyQcm, true);
    if (mounted) {
      setState(() {
        _showQcm = false;
        _qcmStep = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();
    final isDark = controller.isDarkMode;
    final bgColor = isDark ? const Color(0xFF17171F) : _beige;
    final cardColor = isDark ? const Color(0xFF252836) : const Color(0xFFFAF6ED);
    final textColor = isDark ? const Color(0xFFF2E8D5) : Colors.black87;

    if (controller.isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.current == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            'Pas assez de données pour afficher des recommandations.',
            style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey),
          ),
        ),
      );
    }

    final currentAnime = controller.current!;
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeStrength = (_cardOffset.dx.abs() / screenWidth).clamp(0.0, 1.0);
    final swipeRight = _cardOffset.dx > 0;

    final accentColor = controller.currentAnimeColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bgColor,
                      Color.lerp(bgColor, accentColor, 0.08) ?? bgColor,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  gradient: _buildSwipeGradient(swipeStrength, swipeRight, Colors.transparent),
                ),
              ),
            ),

            SafeArea(
              child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        isDark ? 'assets/icon/logo-otaku-Header-Black.png' : 'assets/icon/logo-otaku-Header.png',
                        height: 28,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'OtakuGo',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: TreasureChestIcon(
                                size: 22,
                                color: textColor,
                              ),
                              tooltip: 'Coffre',
                              onPressed: () => Navigator.push(
                                context,
                                PremiumPageRoute(page: const FavoritesPage()),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                controller.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                color: textColor,
                                size: 22,
                              ),
                              tooltip: controller.isMuted ? 'Activer le son' : 'Couper le son',
                              onPressed: controller.toggleMute,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: textColor,
                                size: 22,
                              ),
                              tooltip: isDark ? 'Mode clair' : 'Mode sombre',
                              onPressed: controller.toggleTheme,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onPanStart: (_) {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _cardOffset += details.delta;
                          _cardRotation = _cardOffset.dx / 1000;
                        });
                      },
                      onPanEnd: (_) {
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
                        transform: Matrix4.translationValues(
                          _cardOffset.dx,
                          _cardOffset.dy,
                          0,
                        )..rotateZ(_cardRotation),
                        child: SwipeableAnimeCard(
                          anime: currentAnime,
                          onSwipeLeft: () {},
                          onSwipeRight: () {},
                          dominantColor: controller.currentAnimeColor,
                          isDarkMode: isDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),



            if (_showQcm && !_isApplyingPreferences)
              Positioned.fill(child: _buildQcmOverlay()),

            if (_isApplyingPreferences)
              Positioned.fill(child: _buildLoadingOverlay()),

            if (_showOnboarding)
              Positioned.fill(child: _buildOnboardingOverlay()),
          ],
        ),
    );
  }

  LinearGradient _buildSwipeGradient(double strength, bool right, Color bgColor) {
    if (strength <= 0.01) {
      return LinearGradient(
        colors: [bgColor, bgColor],
      );
    }
    final alpha = (0.25 + 0.35 * strength).clamp(0.0, 0.6);
    return right
        ? LinearGradient(
            colors: [bgColor, bgColor, Colors.green.withOpacity(alpha)],
            stops: const [0.0, 0.5, 1.0],
          )
        : LinearGradient(
            colors: [Colors.red.withOpacity(alpha), bgColor, bgColor],
            stops: const [0.0, 0.5, 1.0],
          );
  }

  Widget _buildOnboardingOverlay() {
    return GestureDetector(
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
    );
  }



  Widget _buildQcmOverlay() {
    final questions = [
      ('Choisis tes genres favoris', _optionsGenres, _qGenres),
    ];

    final total = questions.length;
    final current = questions[_qcmStep];
    final titre = current.$1;
    final options = current.$2;
    final selected = current.$3;

    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Container(
              key: ValueKey(_qcmStep),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Text(
                    'Question ${_qcmStep + 1}/$total',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    titre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tips_and_updates_rounded,
                          color: Colors.amber[800],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Laissez vide pour être surpris !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: options.map((opt) {
                      final isSelected = selected.contains(opt);
                      return ChoiceChip(
                        label: Text(opt),
                        selected: isSelected,
                        onSelected: (_) => _toggleSelection(selected, opt),
                        selectedColor: Colors.green.withOpacity(0.25),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.green.shade800 : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.green.shade600
                              : Colors.green.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (_qcmStep > 0)
                        TextButton(
                          onPressed: () => setState(() => _qcmStep -= 1),
                          child: const Text('Retour'),
                        )
                      else
                        const SizedBox(width: 80),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_qcmStep + 1 >= total) {
                            _finishQcmFlow();
                          } else {
                            setState(() => _qcmStep += 1);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(_qcmStep + 1 >= total ? 'Terminer' : 'Suivant'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSelection(Set<String> target, String value) {
    setState(() {
      if (!target.add(value)) {
        target.remove(value);
      }
    });
  }

  Future<void> _finishQcmFlow() async {
    setState(() => _isApplyingPreferences = true);
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;
    final controller = context.read<AnimeController>();
    controller.appliquerPreferencesQcm(_qGenres);
    await _completeQcm();
    if (mounted) {
      setState(() => _isApplyingPreferences = false);
      context.read<AnimeController>().setNavBarVisibility(true);
    }
  }

  Widget _buildOnboardingHeader() {
    switch (_onboardingStep) {
      case 0:
        return Column(
          children: const [
            Text(
              'Bienvenue dans OtakuGo',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              "Touchez l'écran pour continuer",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        );
      case 1:
        return Column(
          children: const [
            Text(
              'Comprendre le swipe',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text(
              "Touchez l'écran pour continuer",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        );
      default:
        return Column(
          children: const [
            Text(
              'À vous de jouer !',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'Découvrez vos recommandations maintenant.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        );
    }
  }

  Widget _buildOnboardingSlide() {
    if (_onboardingStep == 0) return const SizedBox();
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
          final bg = Color.lerp(
            Colors.red.withOpacity(0.3),
            Colors.green.withOpacity(0.3),
            value,
          )!;
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
                      BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8)),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text("C'est parti !", style: TextStyle(color: Colors.white, fontSize: 22)),
        SizedBox(height: 8),
        Text("Touchez l'écran pour commencer.",
            style: TextStyle(color: Colors.white70, fontSize: 14)),
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
      _cardOffset = Offset(
        liked ? screenWidth * 1.5 : -screenWidth * 1.5,
        0,
      );
      _cardRotation = liked ? 0.3 : -0.3;
    });
    await Future.delayed(const Duration(milliseconds: 350));
    if (liked) {
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

  Widget _buildLoadingOverlay() {
    final hasGenres = _qGenres.isNotEmpty;
    final mainMessage = hasGenres 
        ? "Nous analysons vos goûts..." 
        : "Préparation de vos recommandations...";
    final subMessage = hasGenres 
        ? "Recherche des meilleures pépites pour vous" 
        : "Chargement de suggestions variées";

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value), 
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.explore,
                  color: Colors.amberAccent,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              mainMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}