import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/anime_controller.dart';
import '../models/anime.dart';


class TierListPage extends StatefulWidget {
  const TierListPage({super.key});

  @override
  State<TierListPage> createState() => _TierListPageState();
}

class _TierListPageState extends State<TierListPage> {


  final List<String> _tiers = ['Z', 'S', 'A', 'B', 'C', 'D'];
  final Map<String, Color> _tierColors = {
    'Z': const Color(0xFF000000), // Black for "The Goat" tier?
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
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            useRootNavigator: true,
            builder: (_) => const TierListTutorialDialog(),
          ).then((_) => prefs.setBool('tierlist_tutorial_seen', true));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();
    final favorites = controller.favorites;
    final tierListCount = controller.tierList;

    // Filter unranked anime (favorites not in tier list)
    final unranked = favorites.where((a) => !tierListCount.containsKey(a.title)).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 20, bottom: 20, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        controller.isDarkMode ? 'assets/icon/logo-otaku-Header-Black.png' : 'assets/icon/logo-otaku-Header.png',
                        height: 35,
                        fit: BoxFit.contain,
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () => showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (_) => const TierListTutorialDialog(),
                        ),
                      )
                    ],
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          children: [
                            // Tier Rows
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 150),
                                child: Column(
                                  children: _tiers.map((tier) {
                                    final animeInTier = favorites
                                        .where((a) => tierListCount[a.title] == tier)
                                        .toList();
                                    return _buildTierRow(tier, animeInTier, controller);
                                  }).toList(),
                                ),
                              ),
                            ),

                            // Unranked / Staging Area
                            Container(
                              height: 140,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: DragTarget<Anime>(
                                      onWillAccept: (data) => true,
                                      onAccept: (anime) {
                                        controller.removeFromTier(anime);
                                      },
                                      builder: (context, candidateData, rejectedData) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: candidateData.isNotEmpty
                                                ? Colors.grey.withOpacity(0.2)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: unranked.isEmpty
                                              ? const Center(child: Text("Tout est classé !"))
                                              : ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  itemCount: unranked.length,
                                                  itemBuilder: (context, index) {
                                                    return _buildDraggableAnime(unranked[index]);
                                                  },
                                                ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildTierRow(String tier, List<Anime> animes, AnimeController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      height: 100,
      child: Row(
        children: [
          // Tier Header (Label)
          Container(
            width: 80,
            decoration: tier == 'Z'
                ? const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.yellow, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  )
                : BoxDecoration(color: _tierColors[tier]),
            child: Center(
              child: Text(
                tier,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Droppable Area
          Expanded(
            child: DragTarget<Anime>(
              onWillAccept: (data) => true,
              onAccept: (anime) {
                controller.updateTier(anime, tier);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  color: Colors.grey[900], // Dark background like the example
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: animes.length,
                    padding: const EdgeInsets.all(2), // Little padding
                    itemBuilder: (context, index) {
                      return _buildDraggableAnime(animes[index], inRow: true);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableAnime(Anime anime, {bool inRow = false}) {
    // Only show title if not in row to save space? Or just image.
    // Example image shows just the image in the row.
    
    final child = Container(
      width: inRow ? 70 : 80,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          anime.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.grey),
        ),
      ),
    );

    return Draggable<Anime>(
      data: anime,
      feedback: Opacity(
        opacity: 0.8,
        child: SizedBox(
          width: 80,
          height: 110,
          child: child,
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

class TierListTutorialDialog extends StatelessWidget {
  const TierListTutorialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
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
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Faites glisser vos animes préférés depuis la zone du bas vers les rangs (S, A, B...) pour les classer.\n\nVous pouvez les déplacer à tout moment.",
                    style: TextStyle(color: Colors.white70, fontSize: 16, decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      backgroundColor: const Color(0xFF6C5DD3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("C'est parti !",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
