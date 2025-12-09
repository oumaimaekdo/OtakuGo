import 'package:flutter/material.dart';
import '../services/anime_loader.dart';

class AnimeListPage extends StatelessWidget {
  final List<dynamic> animeData;

  const AnimeListPage({super.key, required this.animeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Anime List"),
        backgroundColor: Colors.redAccent,
      ),

      body: FutureBuilder<List<dynamic>>(
        future: loadAnimeData(),
        builder: (context, snapshot) {
          // Chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // Erreur lors du chargement
          if (snapshot.hasError) {
            print("Erreur FutureBuilder : ${snapshot.error}");
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Pas de données
          if (!snapshot.hasData) {
            print("⚠ snapshot.hasData = false");
            return const Center(
              child: Text(
                "Aucune donnée",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final animes = snapshot.data!;
          print("${animes.length} animes chargés");

          //Liste vide
          if (animes.isEmpty) {
            return const Center(
              child: Text("Liste vide", style: TextStyle(color: Colors.white)),
            );
          }

          // Affichage de la liste
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: animes.length,
            itemBuilder: (context, index) {
              final anime = animes[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        (anime["image_url"] ?? "") as String,
                        width: 100,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 130,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        (anime["name"] ?? "Sans titre") as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
