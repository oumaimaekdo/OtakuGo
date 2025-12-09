import 'package:flutter/material.dart';
import '../models/anime.dart';
import 'anime_image.dart';

class SwipeableAnimeCard extends StatelessWidget {
  const SwipeableAnimeCard({
    super.key,
    required this.anime,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  final Anime anime;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  Color _getGenreColor(String tag) {
    final t = tag.toLowerCase();
    if (t.contains('action')) return Colors.red;
    if (t.contains('aventure') || t.contains('adventure')) return Colors.blue;
    if (t.contains('comedie') || t.contains('comedy')) return Colors.orange;
    if (t.contains('drame') || t.contains('drama')) return Colors.purple;
    if (t.contains('fantastique') || t.contains('fantasy')) return Colors.pink;
    if (t.contains('romance')) return Colors.pinkAccent;
    if (t.contains('sci-fi') || t.contains('science')) return Colors.cyan;
    if (t.contains('mystere') || t.contains('mystery')) return Colors.indigo;
    if (t.contains('horreur') || t.contains('horror')) return Colors.deepPurple;
    if (t.contains('sport')) return Colors.green;
    if (t.contains('slice') || t.contains('vie')) return Colors.teal;
    if (t.contains('supernatural') || t.contains('surnaturel')) return Colors.deepPurple;
    if (t.contains('psychologique')) return Colors.blueGrey;
    if (t.contains('thriller')) return Colors.redAccent;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final genreColors = anime.tags.take(3).map(_getGenreColor).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimeImage(
                    url: anime.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.black.withOpacity(0.35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            anime.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: anime.tags.take(3).map((tag) {
                              final color = _getGenreColor(tag);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color(0xFFF7F7F7)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: genreColors.isNotEmpty ? genreColors : [Colors.blueGrey, Colors.blueGrey]),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Synopsis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          anime.synopsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.6,
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
}
