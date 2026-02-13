import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/anime.dart';
import '../../state/anime_controller.dart';
import '../../animations/premium_transitions.dart';
import 'tournoi_match_page.dart';
import 'tournoi_history_page.dart';

class TournamentStartPage extends StatefulWidget {
  const TournamentStartPage({super.key});

  @override
  State<TournamentStartPage> createState() => _TournamentStartPageState();
}

class _TournamentStartPageState extends State<TournamentStartPage> {
  static const _prefKeyOnboarding = 'tournament_onboarding_seen';
  
  bool _showOnboarding = false;
  int _onboardingStep = 0;
  
  // GlobalKey pour obtenir la position du bouton historique
  final GlobalKey _historyButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadOnboardingFlag();
  }

  Future<void> _loadOnboardingFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_prefKeyOnboarding) ?? false;
    
    // Afficher le tutoriel UNIQUEMENT si jamais vu
    if (mounted && !seen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Masquer la navbar pendant le tutoriel
          context.read<AnimeController>().setNavBarVisibility(false);
          setState(() {
            _showOnboarding = true;
            _onboardingStep = 0;
          });
        }
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyOnboarding, true);
    if (mounted) {
      // Réafficher la navbar
      context.read<AnimeController>().setNavBarVisibility(true);
      setState(() => _showOnboarding = false);
    }
  }

  void _nextOnboardingStep() {
    if (_onboardingStep < 3) {
      setState(() => _onboardingStep++);
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    // Ensure navbar is visible when leaving this page
    // We defer this slightly to avoid conflicts if navigating away
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // Only restore if we are still mounted or just as a safety global reset
       // But since we can't context read easily if unmounted, we try-catch or ensure logic
    });
    // Actually efficient way: just call it.
    // However, we need context. We can't use context in dispose safely if unmounted.
    // Instead, rely on `_completeOnboarding` for normal flow.
    // For forced exit (tab switch), the widget is NOT disposed (IndexedStack).
    // The widget IS disposed if we pop it (but we removed the back button).
    // So usually `dispose` isn't called on tab switch.
    // BUT if the user navigates to another page (push) and this gets disposed? 
    // No, IndexedStack keeps it alive.
    // Wait, if users click another tab in `MainScreen` bottom nav, this widget remains in IndexedStack.
    // The navbar is shared.
    // So if the navbar is HIDDEN, the user CANNOT click another tab!
    // So the only way out is completing the tutorial.
    // Or if there was a back button (removed).
    // Or system back button?
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animeController = context.watch<AnimeController>();
    final List<Anime> favorites = animeController.favorites;
    
    // Theme colors
    final isDark = animeController.isDarkMode;
    final bgColor = isDark ? const Color(0xFF17171F) : const Color(0xFFF2E8D5);
    final cardColor = isDark ? const Color(0xFF252836) : const Color(0xFFFAF6ED);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [


                      // Title
                      Text(
                        "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      // History, Help & Theme toggle
                      Row(
                        children: [
                          Container(
                            key: _historyButtonKey,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.history_rounded, color: textColor, size: 22),
                              onPressed: () => Navigator.push(
                                context,
                                PremiumPageRoute(page: const TournamentHistoryPage()),
                              ),
                            ),
                          ),
                          // Tutorial help button
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.help_outline_rounded, color: textColor, size: 22),
                              tooltip: 'Relancer le tutoriel',
                              onPressed: () {
                                context.read<AnimeController>().setNavBarVisibility(false);
                                setState(() {
                                  _showOnboarding = true;
                                  _onboardingStep = 0;
                                });
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: textColor,
                                size: 22,
                              ),
                              onPressed: animeController.toggleTheme,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "${favorites.length} favoris sélectionnés",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Ajoute au moins 8 animes en favoris pour lancer un tournoi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Grid of favorites
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: favorites.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 160,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final anime = favorites[index];
                        return _animeTile(anime, cardColor);
                      },
                    ),
                  ),
                ),

                // Launch button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A5ACD),
                        disabledBackgroundColor: isDark 
                            ? Colors.grey[800] 
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: favorites.length >= 8 ? 12 : 0,
                      ),
                      onPressed: favorites.length < 8
                          ? null
                          : () {
                              // Shuffle and pick 8 random favorites
                              final shuffled = List<Anime>.from(favorites)..shuffle();
                              final selectedParticipants = shuffled.take(8).toList();

                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      TournamentMatchPage(
                                        animeList: selectedParticipants,
                                      ),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                                          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                                        ),
                                        child: child,
                                      ),
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 600),
                                ),
                              );
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            favorites.length >= 8 
                                ? "Lancer le tournoi" 
                                : "Il manque ${8 - favorites.length} favoris",
                            style: TextStyle(
                              color: favorites.length >= 8 ? Colors.white : Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Onboarding overlay
          if (_showOnboarding)
            Positioned.fill(child: _buildOnboardingOverlay()),
        ],
      ),
    );
  }

  // Anime tile
  Widget _animeTile(Anime anime, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                anime.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cardColor,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),

            // Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),

            // Title
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                anime.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildOnboardingOverlay() {
    // Step 2: spotlight effect to highlight the button
    final overlayOpacity = _onboardingStep == 2 ? 0.85 : 0.75;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _nextOnboardingStep,
      child: Stack(
        children: [
          // Custom painted background with cutout for history button on step 2
          if (_onboardingStep == 2)
            CustomPaint(
              painter: _SpotlightPainter(buttonKey: _historyButtonKey),
              child: Container(),
            )
          else
            Container(
              color: Colors.black.withOpacity(overlayOpacity),
            ),
          
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: _buildOnboardingContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent() {
    switch (_onboardingStep) {
      case 0:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 64),
            const SizedBox(height: 20),
            const Text(
              'Bienvenue au Mode Tournoi !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Affrontez vos animes favoris dans un tournoi à élimination directe et découvrez votre champion absolu !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Touchez pour continuer',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        );

      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_tree_rounded, color: Colors.blue, size: 56),
            const SizedBox(height: 20),
            const Text(
              'Comment ça marche ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '8 animes s\'affrontent en duel.\nVous choisissez le gagnant de chaque match jusqu\'à la finale.\n\nLe dernier debout devient votre champion !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Touchez pour continuer',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        );

      case 2:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 3),
              ),
              child: const Icon(Icons.history_rounded, color: Colors.amber, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'Consultez votre historique',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cliquez sur le bouton en haut à droite pour revoir tous vos tournois passés et leurs champions !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Touchez pour continuer',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        );

      case 3:
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
            const SizedBox(height: 20),
            const Text(
              'Vous êtes prêt !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ajoutez au moins 8 animes en favoris,\npuis lancez votre premier tournoi !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Touchez pour commencer',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        );
    }
  }
}

// Custom painter to create a spotlight effect with a rectangular cutout
class _SpotlightPainter extends CustomPainter {
  final GlobalKey buttonKey;

  _SpotlightPainter({required this.buttonKey});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    // Create path for the entire screen
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Get button position from GlobalKey
    final RenderBox? renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    
    RRect buttonRect;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final buttonSize = renderBox.size;
      
      // Create rounded rectangle cutout based on actual button position
      buttonRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          position.dx - 2,
          position.dy,
          buttonSize.width - 4,
          buttonSize.height,
        ),
        const Radius.circular(12),
      );
    } else {
      // Fallback position if button not yet rendered
      buttonRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width - 100, 38),
          width: 60,
          height: 52,
        ),
        const Radius.circular(12),
      );
    }

    // Add rounded rectangle to path (this will be the cutout)
    final rectPath = Path()
      ..addRRect(buttonRect);

    // Subtract rectangle from main path to create cutout
    final finalPath = Path.combine(PathOperation.difference, path, rectPath);

    canvas.drawPath(finalPath, paint);

    // Draw glow border around the cutout
    final glowPaint = Paint()
      ..color = Colors.amber.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawRRect(buttonRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) => false;
}
