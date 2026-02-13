import '../../models/anime.dart';

class TournamentEngine {
  /// Sélectionne 8 animes optimisés pour le tournoi
  static List<Anime> selectParticipants({
    required List<Anime> allAnimes,
    required List<Anime> favorites,
  }) {
    final List<Anime> selected = [];

    // 1️ - Priorité aux favoris (max 4)
    final favSorted = [...favorites]
      ..sort((a, b) => b.score.compareTo(a.score));

    for (final anime in favSorted) {
      if (selected.length >= 4) break;
      selected.add(anime);
    }

    // 2 - Complétion avec diversité de genres
    final usedGenres = <String>{};
    for (final anime in selected) {
      if (anime.tags.isNotEmpty) {
        usedGenres.add(anime.tags.first.toLowerCase());
      }
    }

    final remaining = allAnimes
        .where((a) => !selected.contains(a))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    for (final anime in remaining) {
      if (selected.length >= 8) break;

      final genre =
          anime.tags.isNotEmpty ? anime.tags.first.toLowerCase() : '';

      if (!usedGenres.contains(genre) || usedGenres.length < 4) {
        selected.add(anime);
        if (genre.isNotEmpty) usedGenres.add(genre);
      }
    }

    // 3 - Sécurité : toujours 8
    if (selected.length < 8) {
      for (final anime in remaining) {
        if (selected.length >= 8) break;
        if (!selected.contains(anime)) {
          selected.add(anime);
        }
      }
    }

    return selected.take(8).toList();
  }

  /// Libellé du tour
  static String roundLabel(int count) {
    switch (count) {
      case 8:
        return "Quarts de finale";
      case 4:
        return "Demi-finale";
      case 2:
        return "Finale";
      default:
        return "";
    }
  }

  /// Couleur associée au tour
  static int roundColor(int count) {
    switch (count) {
      case 8:
        return 0xFF6A5ACD; // violet
      case 4:
        return 0xFFFFA500; // orange
      case 2:
        return 0xFFFF3B3B; // rouge
      default:
        return 0xFFCCCCCC;
    }
  }
}
