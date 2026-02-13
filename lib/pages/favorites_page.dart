import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/anime_controller.dart';
import '../models/anime.dart';
import '../widgets/anime_details_dialog.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Set<String> _selectedGenres = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();
    final isDark = controller.isDarkMode;
    final bgColor = isDark ? const Color(0xFF17171F) : const Color(0xFFF2E8D5);
    final cardColor = isDark ? const Color(0xFF252836) : const Color(0xFFFAF6ED);
    final textColor = isDark ? Colors.white : Colors.black87;
    
    final favorites = controller.favorites;
    
    // Extract all unique genres from favorites
    final allGenres = <String>{};
    for (final anime in favorites) {
      for (final tag in anime.tags) {
        allGenres.add(tag);
      }
    }
    final sortedGenres = allGenres.toList()..sort();

    // Filter favorites
    var filteredFavorites = _selectedGenres.isEmpty
        ? favorites
        : favorites.where((a) => _selectedGenres.every((tag) => a.tags.contains(tag))).toList();
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredFavorites = filteredFavorites
          .where((a) => a.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Unified Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back & Logo
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_rounded, color: textColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
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
                    ],
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

            // Search Bar
            if (favorites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un anime...',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search, color: const Color(0xFF6C5DD3)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: textColor.withOpacity(0.5)),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF6C5DD3), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
          
            // Genre Filter
            if (favorites.isNotEmpty)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip('Tout', _selectedGenres.isEmpty, cardColor, textColor, () {
                      setState(() => _selectedGenres.clear());
                    }),
                    ...sortedGenres.map((genre) => _buildFilterChip(
                      genre,
                      _selectedGenres.contains(genre),
                      cardColor,
                      textColor,
                      () {
                        setState(() {
                          if (_selectedGenres.contains(genre)) {
                            _selectedGenres.remove(genre);
                          } else {
                            _selectedGenres.add(genre);
                          }
                        });
                      },
                    )),
                  ],
                ),
              ),

            // Favorites List
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: textColor.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun favori pour le moment',
                            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final anime = filteredFavorites[index];
                        return _buildFavoriteCard(anime, controller, cardColor, textColor);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color cardColor, Color textColor, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: cardColor,
        selectedColor: const Color(0xFF6C5DD3).withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF6C5DD3) : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF6C5DD3) : Colors.transparent,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildFavoriteCard(Anime anime, AnimeController controller, Color cardColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AnimeDetailsDialog(anime: anime),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'anime_image_${anime.title}',
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Image.asset(
                  anime.image,
                  width: 100,
                  height: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 130,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: anime.tags.take(3).map((tag) {
                        final tagColor = _getGenreColor(tag);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: tagColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Supprimer du coffre-fort ?"),
                    content: Text("Voulez-vous vraiment supprimer \"${anime.title}\" de votre coffre-fort ?"),
                    actions: [
                      TextButton(
                        child: const Text("Annuler", style: TextStyle(color: Colors.black54)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text("Supprimer", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          controller.toggleFavorite(anime);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              },
            ),
          ],
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
    if (g.contains('supernatural')) return const Color(0xFF7C3AED);
    return const Color(0xFF6C5DD3);
  }
}
