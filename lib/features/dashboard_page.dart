import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/anime_controller.dart';
import '../pages/favorites_page.dart';
import '../widgets/reset_dialog.dart';
import 'performance_page.dart';
import '../animations/premium_transitions.dart';
import '../widgets/treasure_chest_icon.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and dark mode toggle
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
                      // Menu button (settings & reset)
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
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'reset_all':
                                showDialog(
                                  context: context,
                                  builder: (_) => const ResetDialog(resetType: ResetType.all),
                                );
                                break;
                              case 'reset_favorites':
                                showDialog(
                                  context: context,
                                  builder: (_) => const ResetDialog(resetType: ResetType.favorites),
                                );
                                break;
                              case 'reset_tierlist':
                                showDialog(
                                  context: context,
                                  builder: (_) => const ResetDialog(resetType: ResetType.tierlist),
                                );
                                break;
                              case 'reset_tournament':
                                showDialog(
                                  context: context,
                                  builder: (_) => const ResetDialog(resetType: ResetType.tournament),
                                );
                                break;
                              case 'reset_genres':
                                showDialog(
                                  context: context,
                                  builder: (_) => const ResetDialog(resetType: ResetType.genres),
                                );
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'reset_tierlist',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.list_alt_rounded, size: 18, color: Color(0xFF3B82F6)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tier List',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                                            ),
                                            Text(
                                              'Vider uniquement',
                                              style: TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'reset_genres',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.category_rounded, size: 18, color: Color(0xFF10B981)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Préférences genres',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                                            ),
                                            Text(
                                              'Remettre à zéro',
                                              style: TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'reset_favorites',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.favorite_rounded, size: 18, color: Color(0xFFF59E0B)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Favoris',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                                            ),
                                            Text(
                                              'Supprimer tous',
                                              style: TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'reset_tournament',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B5CF6).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.emoji_events_rounded, size: 18, color: Color(0xFF8B5CF6)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Historique tournois',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                                            ),
                                            Text(
                                              'Effacer l\'historique',
                                              style: TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'reset_all',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFFEF4444)),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'TOUT RÉINITIALISER',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: Color(0xFFEF4444),
                                              ),
                                            ),
                                            Text(
                                              'Supprimer toutes les données',
                                              style: TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          color: cardColor,
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          tooltip: 'Options de réinitialisation',
                          icon: Icon(Icons.more_vert_rounded, color: textColor, size: 22),
                        ),
                      ),
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
                            color: textColor,
                            size: 22,
                          ),
                          tooltip: 'Coffre',
                          onPressed: () => Navigator.push(
                            context,
                            PremiumPageRoute(page: const FavoritesPage()),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Statistics Card
                    _buildStatisticsCard(controller, cardColor, textColor, subtitleColor),
                    const SizedBox(height: 20),
                    
                    // Preferred Genres Section
                    _buildGenresSection(controller, cardColor, textColor, subtitleColor),
                    const SizedBox(height: 28),
                    
                    // Performance Button
                    _buildPerformanceButton(context),
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

  /// Builds the statistics card with Favoris and Swipes counts
  Widget _buildStatisticsCard(
    AnimeController controller,
    Color cardColor,
    Color textColor,
    Color? subtitleColor,
  ) {
    final totalFavorites = controller.favorites.length;
    final totalSwipes = controller.shownCount;

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
                  color: _primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: _primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Mes statistiques',
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
          
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  totalFavorites.toString(),
                  'Favoris',
                  textColor,
                  subtitleColor,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: subtitleColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  totalSwipes.toString(),
                  'Swipes',
                  textColor,
                  subtitleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Individual stat item (number + label)
  Widget _buildStatItem(String value, String label, Color textColor, Color? subtitleColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  /// Builds the preferred genres section with progress bars
  Widget _buildGenresSection(
    AnimeController controller,
    Color cardColor,
    Color textColor,
    Color? subtitleColor,
  ) {
    // Count genres from favorites
    final genreCount = <String, int>{};
    for (var anime in controller.favorites) {
      for (var genre in anime.tags) {
        genreCount[genre] = (genreCount[genre] ?? 0) + 1;
      }
    }

    final sortedGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sortedGenres.isNotEmpty ? sortedGenres.first.value : 1;

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
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Genres préférés',
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

          // Genre list with progress bars
          if (sortedGenres.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Pas encore de données.\nLikez des animes pour voir vos genres préférés !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                    height: 1.5,
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
                  child: _buildGenreProgressBar(
                    genre.key,
                    genre.value,
                    progress,
                    color,
                    textColor,
                    subtitleColor,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Get semantic color for genre progress bar
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
    // Fallback colors based on hash if needed, or default
    return const Color(0xFF6C5DD3);
  }

  /// Individual genre row with progress bar
  Widget _buildGenreProgressBar(
    String genre,
    int count,
    double progress,
    Color barColor,
    Color textColor,
    Color? subtitleColor,
  ) {
    return Row(
      children: [
        // Bullet point
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
              // Background
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // Filled progress
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        barColor,
                        barColor.withOpacity(0.8),
                      ],
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

  /// Builds the performance button
  Widget _buildPerformanceButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _accentPurple.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            PremiumPageRoute(page: const PerformancePage()),
          );
        },
        icon: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Voir mes performances',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentPurple,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
