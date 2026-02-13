import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/anime_controller.dart';

class PerformancePage extends StatelessWidget {
  const PerformancePage({super.key});

  // Design colors - same as dashboard
  static const Color _primaryBlue = Color(0xFF4A90E2);
  static const Color _accentPurple = Color(0xFF6C5DD3);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();
    final isDark = controller.isDarkMode;
    final bgColor = isDark ? const Color(0xFF17171F) : const Color(0xFFF2E8D5);
    final cardColor = isDark ? const Color(0xFF252836) : const Color(0xFFFAF6ED);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final totalSwipes = controller.shownCount;
    final totalLikes = controller.favorites.length;
    final totalDislikes = totalSwipes - totalLikes;
    final accuracy = totalSwipes == 0 ? 0.0 : (totalLikes / totalSwipes);

    // Count genres
    final genreCount = <String, int>{};
    for (var anime in controller.favorites) {
      for (var g in anime.tags) {
        genreCount[g] = (genreCount[g] ?? 0) + 1;
      }
    }
    final sortedGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxGenreCount = sortedGenres.isNotEmpty ? sortedGenres.first.value : 1;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: textColor,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  // Title
                  Expanded(
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -0.3,
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
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Accuracy Card
                    _buildAccuracyCard(accuracy, cardColor, textColor, subtitleColor),
                    const SizedBox(height: 20),

                    // Likes/Dislikes Card
                    _buildLikesDisklikesCard(
                      totalLikes,
                      totalDislikes,
                      totalSwipes,
                      cardColor,
                      textColor,
                      subtitleColor,
                    ),
                    const SizedBox(height: 20),

                    // Dominant Genres Card
                    _buildGenresCard(
                      sortedGenres,
                      maxGenreCount,
                      cardColor,
                      textColor,
                      subtitleColor,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Accuracy card with circular progress indicator
  Widget _buildAccuracyCard(
    double accuracy,
    Color cardColor,
    Color textColor,
    Color? subtitleColor,
  ) {
    final percentage = (accuracy * 100);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  color: _accentPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Précision de la recommandation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Circular progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: accuracy,
                  strokeWidth: 10,
                  backgroundColor: _accentPurple.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(_accentPurple),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'de likes',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Likes/Dislikes distribution card
  Widget _buildLikesDisklikesCard(
    int likes,
    int dislikes,
    int total,
    Color cardColor,
    Color textColor,
    Color? subtitleColor,
  ) {
    final likesRatio = total == 0 ? 0.0 : likes / total;
    final dislikesRatio = total == 0 ? 0.0 : dislikes / total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Répartition likes / dislikes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Combined progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(
                    flex: (likesRatio * 100).toInt().clamp(1, 100),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF34D399)],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (dislikesRatio * 100).toInt().clamp(1, 100),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                'Likes',
                likes,
                const Color(0xFF10B981),
                textColor,
                subtitleColor,
              ),
              _buildLegendItem(
                'Dislikes',
                dislikes,
                const Color(0xFFEF4444),
                textColor,
                subtitleColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Legend item for likes/dislikes
  Widget _buildLegendItem(
    String label,
    int value,
    Color color,
    Color textColor,
    Color? subtitleColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Dominant genres card with progress bars
  Widget _buildGenresCard(
    List<MapEntry<String, int>> sortedGenres,
    int maxCount,
    Color cardColor,
    Color textColor,
    Color? subtitleColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: _primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Genres dominants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Genre list
          if (sortedGenres.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Pas encore de données.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Column(
              children: sortedGenres.take(5).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final genre = entry.value;
                final progress = genre.value / maxCount;
                final color = _getGenreColor(genre.key);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildGenreBar(
                    genre.key,
                    genre.value,
                    progress,
                    color,
                    textColor,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Get semantic color for genre
  Color _getGenreColor(String genre) {
    final g = genre.toLowerCase();
    if (g.contains('action')) return const Color(0xFFEF4444);
    if (g.contains('adventure')) return const Color(0xFF3B82F6);
    if (g.contains('comedy')) return const Color(0xFFF59E0B);
    if (g.contains('drama')) return const Color(0xFF8B5CF6);
    if (g.contains('fantasy')) return const Color(0xFF10B981);
    if (g.contains('romance')) return const Color(0xFFEC4899);
    if (g.contains('sci-fi')) return const Color(0xFF06B6D4);
    if (g.contains('mystery')) return const Color(0xFF6366F1);
    if (g.contains('horror')) return const Color(0xFF374151);
    if (g.contains('sport')) return const Color(0xFF22C55E);
    if (g.contains('supernatural')) return const Color(0xFF7C3AED);
    if (g.contains('slice')) return const Color(0xFF14B8A6);
    if (g.contains('suspense')) return const Color(0xFFDC2626);
    if (g.contains('award')) return const Color(0xFFEAB308);
    return const Color(0xFF6C5DD3);
  }

  /// Individual genre progress bar
  Widget _buildGenreBar(
    String genre,
    int count,
    double progress,
    Color barColor,
    Color textColor,
  ) {
    return Row(
      children: [
        // Bullet
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: textColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),

        // Genre name
        SizedBox(
          width: 90,
          child: Text(
            genre,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),

        // Progress bar
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [barColor, barColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Count
        SizedBox(
          width: 24,
          child: Text(
            count.toString(),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
