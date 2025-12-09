import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/anime_controller.dart';
import '../models/anime.dart';
import '../widgets/anime_details_dialog.dart';
import '../widgets/treasure_chest_icon.dart';

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
    final favorites = controller.favorites;
    
    // Extract all unique genres from favorites
    final allGenres = <String>{};
    for (final anime in favorites) {
      for (final tag in anime.tags) {
        allGenres.add(tag);
      }
    }
    final sortedGenres = allGenres.toList()..sort();

    // Filter favorites (AND logic: show if anime has ALL selected genres)
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TreasureChestIcon(size: 28, color: Colors.black87),
            SizedBox(width: 8),
            Text(
              'Mon Coffre-Fort',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          if (favorites.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un anime...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6C5DD3)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF6C5DD3), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          
          // Genre Filter
          if (favorites.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('Tout', _selectedGenres.isEmpty, () {
                    setState(() => _selectedGenres.clear());
                  }),
                  ...sortedGenres.map((genre) => _buildFilterChip(
                    genre,
                    _selectedGenres.contains(genre),
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
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun favori pour le moment',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFavorites.length,
                    itemBuilder: (context, index) {
                      final anime = filteredFavorites[index];
                      return _buildFavoriteCard(anime, controller);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[100],
        selectedColor: const Color(0xFF6C5DD3).withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF6C5DD3) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildFavoriteCard(Anime anime, AnimeController controller) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AnimeDetailsDialog(anime: anime),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 140,
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1D2B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: anime.tags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F2FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6C5DD3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Supprimer des favoris ?"),
                    content: Text("Voulez-vous vraiment supprimer \"${anime.title}\" de vos favoris ?"),
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
}
