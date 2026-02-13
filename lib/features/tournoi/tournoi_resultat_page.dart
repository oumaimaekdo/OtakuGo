import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/anime.dart';
import '../../state/anime_controller.dart';

class TournamentResultPage extends StatefulWidget {
  final Anime winner;
  final List<List<String>>? bracketData;

  const TournamentResultPage({
    super.key, 
    required this.winner,
    this.bracketData,
  });

  @override
  State<TournamentResultPage> createState() => _TournamentResultPageState();
}

class _TournamentResultPageState extends State<TournamentResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _animController.forward();
    
    // Save tournament result safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<AnimeController>();
      controller.saveTournamentResult(widget.winner, 8, bracketData: widget.bracketData);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();
    final isDark = controller.isDarkMode;
    final bgColor = isDark ? const Color(0xFF17171F) : const Color(0xFFF2E8D5);
    final cardColor = isDark ? const Color(0xFF252836) : const Color(0xFFFAF6ED);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy icon with animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "GAGNANT DU TOURNOI",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Winner card with scale animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 280,
                    height: 380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image
                          if (widget.winner.image.isNotEmpty)
                            Image.asset(
                              widget.winner.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: cardColor,
                                child: const Icon(Icons.image, size: 64, color: Colors.grey),
                              ),
                            )
                          else
                            Container(
                                color: cardColor,
                                child: const Icon(Icons.image, size: 64, color: Colors.grey),
                              ),
                          
                          // Gradient overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                          
                          // Winner crown badge
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          
                          // Title
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 20,
                            child: Text(
                              widget.winner.title,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Return button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    icon: const Icon(Icons.home_rounded, color: Colors.white),
                    label: const Text(
                      "Retour à l'accueil",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A5ACD),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
