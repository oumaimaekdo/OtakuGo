import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/anime_controller.dart';
import '../models/anime.dart';
import '../pages/favorites_page.dart';
import '../widgets/treasure_chest_icon.dart';
import '../animations/premium_transitions.dart';

class TierListPage extends StatefulWidget {
  const TierListPage({super.key});

  @override
  State<TierListPage> createState() => _TierListPageState();
}

class _TierListPageState extends State<TierListPage> {
  bool _showTutorial = false;
  bool _isUnrankedExpanded = true;

  final List<String> _tiers = ['Z', 'S', 'A', 'B', 'C', 'D'];
  final Map<String, Color> _tierColors = {
    'Z': const Color(0xFF000000),
    'S': const Color(0xFFFF7F7F),
    'A': const Color(0xFFFFBF7F),
    'B': const Color(0xFFFFFF7F),
    'C': const Color(0xFF7FFF7F),
    'D': const Color(0xFF7F7FFF),
  };

  @override
  void initState() {
    super.initState();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('tierlist_tutorial_seen') ?? false;
    if (!seen) {
      // Hide navbar for tutorial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AnimeController>().setNavBarVisibility(false);
      });
      setState(() => _showTutorial = true);
      await prefs.setBool('tierlist_tutorial_seen', true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();
    final isDark = controller.isDarkMode;
    final bgColor = isDark ? const Color(0xFF17171F) : const Color(0xFFF2E8D5);
    final cardColor = isDark ? const Color(0xFF252836) : const Color(0xFFFAF6ED);
    final textColor = isDark ? Colors.white : Colors.black87;
    
    final favorites = controller.favorites;
    final tierListCount = controller.tierList;

    bool isRanked(Anime a) {
      for (var list in tierListCount.values) {
        if (list.any((ranked) => ranked.title == a.title)) return true;
      }
      return false;
    }

    final unranked = favorites.where((a) => !isRanked(a)).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Unified Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
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
                          // Vault button
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
                          // Help button
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
                                Icons.help_outline_rounded,
                                color: textColor,
                                size: 22,
                              ),
                              onPressed: () {
                                context.read<AnimeController>().setNavBarVisibility(false);
                                setState(() => _showTutorial = true);
                              },
                            ),
                          ),
                          // Dark mode toggle
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
                              onPressed: controller.toggleTheme,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tier Rows
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Column(
                      children: _tiers.map((tier) {
                        final animeInTier = tierListCount[tier] ?? [];
                        return _buildTierRow(tier, animeInTier, controller, cardColor, textColor, isDark);
                      }).toList(),
                    ),
                  ),
                ),

                // Unranked Area - Fixed at bottom
                Container(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: DragTarget<Object>(
                    onWillAcceptWithDetails: (details) => details.data is Anime,
                    onAcceptWithDetails: (details) {
                      if (details.data is Anime) {
                        controller.removeFromTier(details.data as Anime);
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          border: candidateData.isNotEmpty
                              ? Border.all(color: const Color(0xFF6C5DD3), width: 2)
                              : null,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            InkWell(
                              onTap: () => setState(() => _isUnrankedExpanded = !_isUnrankedExpanded),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                child: Row(
                                  children: [
                                    Text(
                                      "À classer (${unranked.length})",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: textColor.withOpacity(0.7),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      _isUnrankedExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                      color: textColor.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // List
                            if (_isUnrankedExpanded)
                              SizedBox(
                                height: 100,
                                child: unranked.isEmpty
                                    ? Center(
                                        child: Text(
                                          "Tout est classé !",
                                          style: TextStyle(color: textColor.withOpacity(0.5)),
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                        itemCount: unranked.length,
                                        itemBuilder: (context, index) {
                                          return _buildDraggableAnime(unranked[index]);
                                        },
                                      ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

            // Tutorial Overlay
            if (_showTutorial)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    context.read<AnimeController>().setNavBarVisibility(true);
                    setState(() => _showTutorial = false);
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.85),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.touch_app, color: Colors.white, size: 64),
                            const SizedBox(height: 24),
                            const Text(
                              "Bienvenue dans votre Tier List !",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "• Faites défiler la liste du bas normalement.\n• Maintenez appuyé sur un anime pour le saisir.\n• Glissez-le dans un rang (S, A, B...) pour le classer.",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                context.read<AnimeController>().setNavBarVisibility(true);
                                setState(() => _showTutorial = false);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                backgroundColor: const Color(0xFF6C5DD3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text("C'est parti !", style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
    );
  }

  Widget _buildTierRow(String tier, List<Anime> animes, AnimeController controller, Color cardColor, Color textColor, bool isDark) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) => details.data is Anime,
      onAcceptWithDetails: (details) {
        if (details.data is Anime) {
          controller.updateTier(details.data as Anime, tier);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 100,
          child: Row(
            children: [
              // Tier Label
              Container(
                width: 70,
                decoration: BoxDecoration(
                  color: tier == 'Z' ? null : _tierColors[tier],
                  gradient: tier == 'Z'
                      ? const LinearGradient(
                          colors: [Colors.orange, Colors.yellow, Colors.red],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    tier,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Content Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isHovered
                        ? Border.all(color: const Color(0xFF6C5DD3), width: 2)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: animes.isEmpty
                      ? (isHovered
                          ? const Center(child: Icon(Icons.add_circle_outline, color: Color(0xFF6C5DD3), size: 28))
                          : null)
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: animes.length,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          itemBuilder: (context, index) {
                            return _buildDraggableAnime(animes[index], inRow: true);
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableAnime(Anime anime, {bool inRow = false}) {
    final child = Container(
      width: inRow ? 65 : 75,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          if (!inRow)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          anime.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );

    return LongPressDraggable<Anime>(
      data: anime,
      delay: const Duration(milliseconds: 300),
      hapticFeedbackOnStart: true,
      feedback: IgnorePointer(
        child: Opacity(
          opacity: 0.9,
          child: SizedBox(
            width: 85,
            height: 110,
            child: child,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      child: child,
    );
  }
}
