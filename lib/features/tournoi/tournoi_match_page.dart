import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/anime.dart';
import '../../state/anime_controller.dart';
import 'tournoi_resultat_page.dart';
import 'tournoi_bracket_widget.dart';

class TournamentMatchPage extends StatefulWidget {
  final List<Anime> animeList;

  const TournamentMatchPage({super.key, required this.animeList});

  @override
  State<TournamentMatchPage> createState() => _TournamentMatchPageState();
}

class _TournamentMatchPageState extends State<TournamentMatchPage>
    with TickerProviderStateMixin {
  late List<Anime> currentRound;
  final List<Anime> winners = [];
  
  // Track all rounds for bracket display
  late List<List<Anime>> allRounds;
  late List<List<Anime?>> roundWinners;

  Anime? selected;
  late AnimationController _scaleAnim;
  late AnimationController _slideAnim;
  
  bool _showBracket = false;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    currentRound = List.from(widget.animeList);
    
    // Initialize bracket tracking
    allRounds = [List.from(widget.animeList)];
    roundWinners = [List.filled(4, null)]; // 4 matches in quarter finals

    _scaleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.95,
      upperBound: 1.05,
    );
    
    _slideAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _scaleAnim.dispose();
    _slideAnim.dispose();
    super.dispose();
  }

  // 🎯 Sélection du gagnant with premium depth transition
  void _selectWinner(Anime anime) async {
    if (_isTransitioning) return;
    
    setState(() {
      selected = anime;
      _isTransitioning = true;
    });
    
    // Phase 1: Winner feedback (scale up)
    await _scaleAnim.forward();
    
    // Phase 2: Transition
    // Winners zooms forward, Loser shrinks away
    await _slideAnim.forward();

    winners.add(anime);
    
    // Update bracket winners
    final matchIndex = winners.length - 1;
    final roundIndex = allRounds.length - 1;
    if (roundIndex < roundWinners.length) {
      roundWinners[roundIndex][matchIndex] = anime;
    }
    
    selected = null;

    if (winners.length == currentRound.length ~/ 2) {
      if (winners.length == 1) {
        // Build bracket data for saving
        final bracketData = <List<String>>[];
        for (final round in allRounds) {
          bracketData.add(round.map((a) => '${a.title}|${a.image}').toList());
        }
        // Add the final winner
        bracketData.add(['${winners.first.title}|${winners.first.image}']);
        
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                TournamentResultPage(
                  winner: winners.first,
                  bracketData: bracketData,
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        setState(() {
          currentRound = List.from(winners);
          allRounds.add(List.from(winners));
          roundWinners.add(List.filled(winners.length ~/ 2, null));
          winners.clear();
        });
      }
    } else {
      setState(() {});
    }
    
    // Reset and prepare for NEXT match entry animation
    _slideAnim.value = 1.0; // Stay at "full"
    _scaleAnim.reverse();
    
    // Brief delay before zoom-in of next match
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Phase 3: Zoom-in next match
    _slideAnim.duration = const Duration(milliseconds: 500);
    await _slideAnim.reverse();
    _slideAnim.duration = const Duration(milliseconds: 700); // Reset for next interaction
    
    setState(() => _isTransitioning = false);
  }

  // 🏆 Nom du tour
  String get _roundLabel {
    switch (currentRound.length) {
      case 8:
        return "QUARTS DE FINALE";
      case 4:
        return "DEMI-FINALE";
      case 2:
        return "FINALE";
      default:
        return "";
    }
  }

  // 🎨 Couleur selon le tour
  Color get _roundColor {
    switch (currentRound.length) {
      case 8:
        return Colors.redAccent;
      case 4:
        return Colors.orangeAccent;
      case 2:
        return const Color(0xFF6A5ACD);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();
    final isDark = controller.isDarkMode;
    final bgColor = isDark ? const Color(0xFF17171F) : const Color(0xFFF2E8D5);
    final textColor = isDark ? Colors.white : Colors.black87;
    
    final index = winners.length * 2;
    
    // Safety check for round transition
    if (index >= currentRound.length) {
      return Scaffold(backgroundColor: bgColor, body: const Center(child: CircularProgressIndicator()));
    }

    final topAnime = currentRound[index];
    final bottomAnime = currentRound[index + 1];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                const SizedBox(height: 14),

                // Header with bracket toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      // 🏆 TITRE DU TOUR
                      Column(
                        children: [
                          Text(
                            _roundLabel,
                            style: TextStyle(
                              color: _roundColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 64,
                            height: 3,
                            decoration: BoxDecoration(
                              color: _roundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          _showBracket ? Icons.close : Icons.account_tree_rounded,
                          color: textColor,
                        ),
                        onPressed: () => setState(() => _showBracket = !_showBracket),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 🔼 CARTE HAUT with premium depth
                Expanded(
                  flex: 4,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _slideAnim,
                      builder: (context, child) {
                        final isWinner = selected == topAnime;
                        final isLoser = selected != null && !isWinner;
                        
                        double scale = 1.0;
                        double opacity = 1.0;
                        double blur = 0.0;
                        
                        if (_slideAnim.value > 0) {
                          if (isWinner) {
                            scale = 1.0 + (0.4 * _slideAnim.value);
                            opacity = 1 - _slideAnim.value;
                          } else if (isLoser) {
                            scale = 1.0 - (0.6 * _slideAnim.value);
                            opacity = 1 - _slideAnim.value;
                            blur = _slideAnim.value * 5;
                          } else {
                            // Zoom in entry for next match
                            scale = 0.8 + (0.2 * (1 - _slideAnim.value));
                            opacity = 1 - _slideAnim.value;
                          }
                        }

                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity.clamp(0, 1),
                            child: child,
                          ),
                        );
                      },
                      child: _animeCard(topAnime, isDark, textColor),
                    ),
                  ),
                ),

                // ⚔️ VS
                SizedBox(
                  height: 48,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _slideAnim,
                      builder: (context, child) {
                        return Opacity(
                          opacity: (1 - _slideAnim.value * 2).clamp(0, 1),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bgColor,
                          boxShadow: [
                            BoxShadow(
                              color: _roundColor.withOpacity(0.9),
                              blurRadius: 22,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "VS",
                          style: TextStyle(
                            color: _roundColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔽 CARTE BAS with premium depth
                Expanded(
                  flex: 4,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _slideAnim,
                      builder: (context, child) {
                        final isWinner = selected == bottomAnime;
                        final isLoser = selected != null && !isWinner;
                        
                        double scale = 1.0;
                        double opacity = 1.0;
                        
                        if (_slideAnim.value > 0) {
                          if (isWinner) {
                            scale = 1.0 + (0.4 * _slideAnim.value);
                            opacity = 1 - _slideAnim.value;
                          } else if (isLoser) {
                            scale = 1.0 - (0.6 * _slideAnim.value);
                            opacity = 1 - _slideAnim.value;
                          } else {
                            // Zoom in entry
                            scale = 0.8 + (0.2 * (1 - _slideAnim.value));
                            opacity = 1 - _slideAnim.value;
                          }
                        }

                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity.clamp(0, 1),
                            child: child,
                          ),
                        );
                      },
                      child: _animeCard(bottomAnime, isDark, textColor),
                    ),
                  ),
                ),
              ],
            ),
            
            // Bracket overlay
            if (_showBracket)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showBracket = false),
                  child: Container(
                    color: bgColor.withOpacity(0.95),
                    child: TournamentBracketWidget(
                      initialParticipants: widget.animeList,
                      allRounds: allRounds,
                      roundWinners: roundWinners,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🎴 Carte Anime (responsive)
  Widget _animeCard(Anime anime, bool isDark, Color textColor) {
    final isSelected = selected == anime;
    final cardShadow = isDark ? Colors.black54 : Colors.black26;

    return GestureDetector(
      onTap: () => _selectWinner(anime),
      child: ScaleTransition(
        scale: isSelected ? _scaleAnim : const AlwaysStoppedAnimation(1),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 450, maxWidth: 400),
          child: AspectRatio(
            aspectRatio: 0.85,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: cardShadow,
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                  Positioned.fill(
                    child: Image.asset(
                      anime.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? const Color(0xFF252836) : const Color(0xFFFAF6ED),
                        child: const Center(
                          child: Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                  // 🎥 Gradient bas
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🏷️ Titre
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 14,
                    child: Text(
                      anime.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
