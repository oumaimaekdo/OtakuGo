import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../data/anime_repository.dart';
import '../models/anime.dart';

class AnimeController extends ChangeNotifier {
  AnimeController({required this.repository});
  final AnimeRepository repository;
  final Random _random = Random();

  List<Anime> _all = [];
  Anime? _current;
  Anime? _lastSelection;
  bool _loading = true;
  String? _error;

  final Set<String> _preferredTags = {};
  final Set<String> _seenTags = {};
  final Set<String> _visitedTitles = {};
  final int _explorationLimit = 10;
  int _shownCount = 0;

  List<Anime> get currentOptions => _current == null ? [] : [_current!];
  Anime? get current => _current;
  Anime? get lastSelection => _lastSelection;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get inExploration => _shownCount < _explorationLimit;
  int get shownCount => _shownCount;
  int get explorationLimit => _explorationLimit;

  Future<void> load() async {
    try {
      _loading = true;
      notifyListeners();
      _all = await repository.loadFromAsset('assets/anime_1000.json');
      _preferredTags.clear();
      _seenTags.clear();
      _visitedTitles.clear();
      _shownCount = 0;
      _current = _drawNext(initial: true);
      _loading = false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
    } finally {
      notifyListeners();
    }
  }

  void likeCurrent() {
    if (_current == null || _all.isEmpty) return;
    _lastSelection = _current;
    _preferredTags.addAll(_current!.tags.map((t) => t.toLowerCase()));
    _seenTags.addAll(_current!.tags.map((t) => t.toLowerCase()));
    _visitedTitles.add(_current!.title);
    _shownCount += 1;
    _current = _drawNext();
    notifyListeners();
  }

  void skipCurrent() {
    if (_current == null || _all.isEmpty) return;
    _seenTags.addAll(_current!.tags.map((t) => t.toLowerCase()));
    _visitedTitles.add(_current!.title);
    _shownCount += 1;
    _current = _drawNext();
    notifyListeners();
  }

  Anime? _drawNext({bool initial = false}) {
    if (_all.isEmpty) return null;

    final excluded = <String>{..._visitedTitles};
    if (!initial && _current != null) excluded.add(_current!.title);

    final candidates = _all.where((a) => !excluded.contains(a.title)).toList();
    if (candidates.isEmpty) return null;

    // Phase exploration: montrer des tags jamais vus sur les 10 premi�res cartes.
    if (_shownCount < _explorationLimit) {
      final unseen = _collectAllTags().difference(_seenTags).where((t) => t.isNotEmpty).toList();
      unseen.shuffle(_random);
      for (final tag in unseen) {
        final pick = _pickByTags(candidates, {tag});
        if (pick != null) return pick;
      }
    }

    // 80%: privil�gier les tags lik�s.
    final usePreferred = _preferredTags.isNotEmpty && _random.nextDouble() < 0.8;
    if (usePreferred) {
      final scored = candidates
          .map((a) => MapEntry(a, _matchScore(a, _preferredTags)))
          .where((e) => e.value > 0)
          .toList();
      if (scored.isNotEmpty) {
        scored.shuffle(_random);
        scored.sort((b, a) => a.value.compareTo(b.value));
        return scored.first.key;
      }
    }

    // 20% ou aucun match c'est aléatoire.
    return candidates[_random.nextInt(candidates.length)];
  }

  Set<String> _collectAllTags() {
    final tags = <String>{};
    for (final a in _all) {
      tags.addAll(a.tags.map((t) => t.toLowerCase()));
    }
    return tags;
  }

  Anime? _pickByTags(List<Anime> pool, Set<String> tags) {
    final matches = pool
        .where((a) => a.tags.map((t) => t.toLowerCase()).any(tags.contains))
        .toList();

    if (matches.isEmpty) return null;
    matches.shuffle(_random);
    return matches.first;
  }

  final List<Anime> _favorites = [];
  List<Anime> get favorites => List.unmodifiable(_favorites);

  void toggleFavorite(Anime anime) {
    if (_favorites.contains(anime)) {
      _favorites.remove(anime);
    } else {
      _favorites.add(anime);
    }
    notifyListeners();
  }

  bool isFavorite(Anime anime) => _favorites.contains(anime);

  List<String> get favoriteGenres {
    final genres = <String>{};
    for (final anime in _favorites) {
      genres.addAll(anime.tags);
    }
    return genres.toList();
  }

  List<Anime> _specialOptionsFor(String title) {
    const mapping = {
      'Attack on Titan': ['Kingdom', 'Demon Slayer'],
      'Naruto': ['Bleach', 'Boruto'],
    };
    final targets = mapping[title];
    if (targets == null) return [];
    return targets
        .map((name) => _all.firstWhere(
              (a) => a.title.toLowerCase() == name.toLowerCase(),
              orElse: () => _all.first,
            ))
        .toList();
  }


  int _matchScore(Anime anime, Set<String> tags) {
    return anime.tags.map((t) => t.toLowerCase()).where(tags.contains).length;
  }

  // Dynamic Theming
  Color getGenreColor(Anime anime) {
    if (anime.tags.isEmpty) return const Color(0xFF6C5DD3); // Default Purple

    final genre = anime.tags.first.toLowerCase();
    
    if (genre.contains('action') || genre.contains('adventure')) {
      return const Color(0xFFFF6B6B); // Red/Orange
    } else if (genre.contains('romance') || genre.contains('drama')) {
      return const Color(0xFFFF9FF3); // Pink
    } else if (genre.contains('sci-fi') || genre.contains('tech')) {
      return const Color(0xFF54A0FF); // Blue
    } else if (genre.contains('fantasy') || genre.contains('magic')) {
      return const Color(0xFF1DD1A1); // Green
    } else if (genre.contains('horror') || genre.contains('thriller')) {
      return const Color(0xFF2D3436); // Dark
    } else if (genre.contains('comedy')) {
      return const Color(0xFFFECA57); // Yellow
    }
    
    return const Color(0xFF6C5DD3); // Default Purple
  }
}
