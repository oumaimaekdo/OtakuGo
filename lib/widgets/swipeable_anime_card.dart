import 'package:flutter/material.dart';
import '../models/anime.dart';
import 'anime_image.dart';

/// Swipeable anime card matching the "Paprika" style design.
/// Uses dynamic dominant color extracted from the anime's cover image.
class SwipeableAnimeCard extends StatelessWidget {
  const SwipeableAnimeCard({
    super.key,
    required this.anime,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.dominantColor,
    this.isDarkMode = false,
  });

  final Anime anime;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final Color? dominantColor;
  final bool isDarkMode;

  Color get _accentColor => dominantColor ?? const Color(0xFF6C5DD3);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF252836) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // Image section with gradient overlay
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Anime cover image
                  AnimeImage(
                    url: anime.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay using dominant color
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.6),
                          _accentColor.withOpacity(0.85),
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Title and tags overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Anime title
                          Text(
                            anime.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          // Genre tags
                          _buildGenreTags(),
                        ],
                      ),
                    ),
                  ),
                  // Score badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildScoreBadge(),
                  ),
                ],
              ),
            ),
            // Synopsis section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF252836) : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Synopsis header with colored bar
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Synopsis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? const Color(0xFFF2E8D5) : Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Synopsis text
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          anime.synopsis.isNotEmpty 
                              ? anime.synopsis 
                              : 'Aucun synopsis disponible pour cet anime.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                            height: 1.65,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the genre tags with dynamic colors
  Widget _buildGenreTags() {
    if (anime.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: anime.tags.take(5).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        
        // Different opacity for each tag to create visual hierarchy
        final opacity = index == 0 ? 1.0 : (index == 1 ? 0.85 : 0.7);
        final bgColor = _getTagColor(tag, index);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Gets a color for the tag based on its position and accent color
  Color _getTagColor(String tag, int index) {
    // Use accent color variations for tags
    final hsl = HSLColor.fromColor(_accentColor);
    
    switch (index) {
      case 0:
        // First tag: accent color
        return _accentColor;
      case 1:
        // Second tag: complementary hue shift
        return HSLColor.fromAHSL(
          1.0,
          (hsl.hue + 30) % 360,
          hsl.saturation * 0.9,
          hsl.lightness,
        ).toColor();
      case 2:
        // Third tag: another hue shift
        return HSLColor.fromAHSL(
          1.0,
          (hsl.hue + 60) % 360,
          hsl.saturation * 0.8,
          hsl.lightness * 0.9,
        ).toColor();
      case 3:
        return HSLColor.fromAHSL(
          1.0,
          (hsl.hue + 90) % 360,
          hsl.saturation * 0.75,
          hsl.lightness * 0.9,
        ).toColor();
      case 4:
        return HSLColor.fromAHSL(
          1.0,
          (hsl.hue + 120) % 360,
          hsl.saturation * 0.7,
          hsl.lightness * 0.85,
        ).toColor();
      default:
        return _accentColor.withOpacity(0.7);
    }
  }

  /// Builds the score badge
  Widget _buildScoreBadge() {
    final scoreColor = _getScoreColor(anime.score);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scoreColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            anime.score.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Gets the appropriate color for the score badge
  Color _getScoreColor(double score) {
    if (score >= 9.0) {
      return const Color(0xFF10B981); // Excellent - Green
    } else if (score >= 8.0) {
      return const Color(0xFF3B82F6); // Very good - Blue
    } else if (score >= 7.0) {
      return const Color(0xFFF59E0B); // Good - Orange
    } else {
      return const Color(0xFF6B7280); // Average - Gray
    }
  }
}
