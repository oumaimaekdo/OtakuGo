import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/anime_controller.dart';
import '../models/anime.dart';
import '../widgets/anime_details_dialog.dart';
import '../widgets/treasure_chest_icon.dart';
import 'favorites_page.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  // Design colors
  static const Color _primaryBlue = Color(0xFF4A90E2);
  static const Color _accentPurple = Color(0xFF6C5DD3);

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
        child: Column(
          children: [
            // Modern header
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
                            MaterialPageRoute(builder: (_) => const FavoritesPage()),
                          ),
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

            // Scrollable content
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: 80 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            context,
                            'Tendances',
                            Icons.local_fire_department_rounded,
                            Colors.orange,
                            controller.trendingAnimes,
                            controller,
                            cardColor,
                            textColor,
                            isDark,
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            context,
                            'Top notés',
                            Icons.star_rounded,
                            Colors.amber,
                            controller.topRatedAnimes,
                            controller,
                            cardColor,
                            textColor,
                            isDark,
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            context,
                            'Nouveaux de la semaine',
                            Icons.new_releases_rounded,
                            _primaryBlue,
                            controller.newThisWeek,
                            controller,
                            cardColor,
                            textColor,
                            isDark,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    List<Anime> animes,
    AnimeController controller,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: animes.isEmpty
              ? Center(
                  child: Text(
                    'Aucun anime disponible',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: animes.length,
                  itemBuilder: (context, index) {
                    final anime = animes[index];
                    return _buildAnimeCard(
                      context,
                      anime,
                      controller,
                      cardColor,
                      textColor,
                      isDark,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAnimeCard(
    BuildContext context,
    Anime anime,
    AnimeController controller,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AnimeDetailsDialog(anime: anime),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with score badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.asset(
                    anime.image,
                    height: 160,
                    width: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        width: 160,
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: isDark ? Colors.grey[600] : Colors.grey[500],
                        ),
                      );
                    },
                  ),
                ),
                // Score badge - top left
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(anime.score),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _getScoreColor(anime.score).withOpacity(0.4),
                          blurRadius: 6,
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
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          anime.score.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    // Genre tags with colors
                    if (anime.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: anime.tags.take(2).toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final tag = entry.value;
                          final tagColor = _getGenreColor(tag, index);
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: tagColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 9,
                                color: tagColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
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

  /// Get color for genre tag
  Color _getGenreColor(String genre, int index) {
    final g = genre.toLowerCase();
    
    // Specific genre colors
    if (g.contains('action')) return const Color(0xFFEF4444); // Red
    if (g.contains('adventure')) return const Color(0xFF3B82F6); // Blue
    if (g.contains('comedy')) return const Color(0xFFF59E0B); // Amber
    if (g.contains('drama')) return const Color(0xFF8B5CF6); // Purple
    if (g.contains('fantasy')) return const Color(0xFF10B981); // Green
    if (g.contains('romance')) return const Color(0xFFEC4899); // Pink
    if (g.contains('sci-fi')) return const Color(0xFF06B6D4); // Cyan
    if (g.contains('mystery')) return const Color(0xFF6366F1); // Indigo
    if (g.contains('horror')) return const Color(0xFF374151); // Dark gray
    if (g.contains('sport')) return const Color(0xFF22C55E); // Light green
    if (g.contains('supernatural')) return const Color(0xFF7C3AED); // Violet
    if (g.contains('slice')) return const Color(0xFF14B8A6); // Teal
    if (g.contains('suspense')) return const Color(0xFFDC2626); // Dark red
    if (g.contains('award')) return const Color(0xFFEAB308); // Gold
    
    // Default colors based on index
    final colors = [
      const Color(0xFF4A90E2), // Blue
      const Color(0xFF6C5DD3), // Purple
      const Color(0xFF10B981), // Green
    ];
    return colors[index % colors.length];
  }

  Color _getScoreColor(double score) {
    if (score >= 9.0) {
      return const Color(0xFF10B981); // Green - excellent
    } else if (score >= 8.0) {
      return const Color(0xFF3B82F6); // Blue - very good
    } else if (score >= 7.0) {
      return const Color(0xFFF59E0B); // Orange - good
    } else {
      return const Color(0xFF6B7280); // Gray - average
    }
  }
}
