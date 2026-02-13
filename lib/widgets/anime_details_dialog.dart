import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anime.dart';
import '../state/anime_controller.dart';
import 'anime_image.dart';

class AnimeDetailsDialog extends StatelessWidget {
  final Anime anime;

  const AnimeDetailsDialog({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();
    final primaryColor = controller.getGenreColor(anime);
    final isDark = controller.isDarkMode;
    final isFavorite = controller.isFavorite(anime);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252836) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Image
              SizedBox(
                height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'anime_image_${anime.title}',
                      child: AnimeImage(
                        url: anime.image,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                            primaryColor.withOpacity(0.9),
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anime.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                anime.score.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.movie_filter_rounded, color: Colors.white70, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${anime.episodes} EP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bouton Ajouter au Coffre (fixe sous le header)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: SizedBox(
                        width: double.infinity,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.toggleFavorite(anime);
                              // Animation de feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        isFavorite ? Icons.lock_open_rounded : Icons.lock_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          isFavorite 
                                              ? 'Retiré du coffre' 
                                              : '${anime.title} ajouté au coffre !',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: isFavorite ? Colors.orange : const Color(0xFF6C5DD3),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height - 220,
                                    left: 20,
                                    right: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFavorite 
                                  ? Colors.orange 
                                  : const Color(0xFF6C5DD3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: isFavorite ? 2 : 4,
                            ),
                            icon: Icon(
                              isFavorite ? Icons.lock_open_rounded : Icons.lock_rounded,
                              size: 22,
                            ),
                            label: Text(
                              isFavorite ? 'Retirer du coffre' : 'Ajouter au coffre',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: anime.tags.map((tag) {
                          final color = _getGenreColor(tag);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Text(
                              tag.toUpperCase(),
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'SYNOPSIS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        anime.synopsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
