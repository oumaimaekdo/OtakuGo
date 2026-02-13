import 'dart:math';
import 'package:flutter/material.dart';
import '../data/anime_repository.dart';
import '../models/anime.dart';
import '../services/color_extractor_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Contrôleur central de l'application.
/// - Charge les animes depuis l'asset.
/// - Gère la recommandation (poids par genre).
/// - Gère favoris et tier list.
class AnimeController extends ChangeNotifier {
  AnimeController({required this.repository});

  final AnimeRepository repository;
  final Random _aleatoire = Random();
  
  // Color extraction service
  final ColorExtractorService _colorExtractor = ColorExtractorService();
  Color _currentAnimeColor = ColorExtractorService.defaultColor;

  // Audio management
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  double _volume = 0.5;

  // Données et index
  List<Anime> _tousLesAnimes = [];
  final Map<String, List<Anime>> _indexParGenre = {};
  final Map<String, int> _poidsGenres = {};

  // État courant
  Anime? _courant;
  Anime? _dernierChoix;
  bool _chargement = true;
  String? _erreur;

  // Compteur pour l'affichage
  int _shownCount = 0;

  // Préférences utilisateur
  final Set<String> _genresLikes = {};
  final Set<String> _genresVus = {};
  final Set<String> _titresVus = {};

  // Favoris et tier list
  final List<Anime> _favoris = [];
  final Map<String, List<Anime>> _tierList = {};

  // Getters publics (conservent les noms attendus par l'UI)
  List<Anime> get currentOptions => _courant == null ? [] : [_courant!];
  Anime? get current => _courant;
  Anime? get lastSelection => _dernierChoix;
  bool get isLoading => _chargement;
  String? get error => _erreur;
  int get shownCount => _shownCount;
  List<Anime> get favorites => List.unmodifiable(_favoris);
  Map<String, List<Anime>> get tierList =>
      _tierList.map((k, v) => MapEntry(k, List.unmodifiable(v)));

  // Color getter for current anime
  Color get currentAnimeColor => _currentAnimeColor;
  ColorExtractorService get colorExtractor => _colorExtractor;

  // Audio getters
  bool get isMuted => _isMuted;
  double get volume => _volume;
  AudioPlayer get audioPlayer => _audioPlayer;

  // Getters pour la page découverte
  
  // Liste manuelle des animes à afficher dans "Tendances"
  // MODIFIEZ CETTE LISTE pour choisir les animes tendances
  static const List<String> _trendingAnimeTitles = [
    'Chainsaw Man',
    'Jujutsu Kaisen',
    'Kimetsu no Yaiba',
    'Shingeki no Kyojin',
    'Wind Breaker',
    'Sousou no Frieren',
    'Ore dake Level Up na Ken',
    'Kaijuu 8-gou',
    'Mushoku Tensei: Isekai Ittara Honki Dasu',
    'Boku no Hero Academia',
    'Sakamoto Days',
    'Oshi No Ko',
    'Tougen Anki',
    'Dr. Stone',
    'Hunter x Hunter',
    'Chi. Chikyuu no Undou ni Tsuite',
    'Blue Lock',
    'Dandadan',
    'Tu Bian Yingxiong X',
    'Gachiakuta',
  ];
  
  List<Anime> get trendingAnimes {
    // Sélection manuelle des animes tendances
    final trending = <Anime>[];
    for (final title in _trendingAnimeTitles) {
      try {
        final searchLower = title.toLowerCase();
        
        // D'abord on cherche un match EXACT
        Anime? anime;
        try {
          anime = _tousLesAnimes.firstWhere(
            (a) => a.title.toLowerCase() == searchLower,
          );
        } catch (_) {
          // Si pas de match exact, on cherche un anime qui CONTIENT le terme
          anime = _tousLesAnimes.firstWhere(
            (a) => a.title.toLowerCase().contains(searchLower),
          );
        }
        
        trending.add(anime);
      } catch (e) {
        // Anime non trouvé
        continue;
      }
    }
    return trending;
  }


  List<Anime> get topRatedAnimes {
    // Meilleurs animes de tous les temps, triés par score décroissant
    final topRated = List<Anime>.from(_tousLesAnimes)
      ..sort((a, b) => b.score.compareTo(a.score));
    return topRated.take(20).toList();
  }

  // Liste manuelle des animes à afficher dans "Nouveaux de la semaine"
  // MODIFIEZ CETTE LISTE pour choisir les nouveaux animes
  static const List<String> _newThisWeekAnimeTitles = [
    'Enen no Shouboutai: Ni no Shou',
    'Jigokuraku',
    'Sousou no Frieren',
    'Fumetsu no Anata e',
    'Vigilante: Boku no Hero Academia Illegals',
    'Oshi no Ko',
    'Yuusha-kei ni Shosu: Choubatsu Yuusha 9004-tai Keimu Kiroku',
    'Golden Kamuy',
    'The Dangers in My Heart',
  ];

  List<Anime> get newThisWeek {
    // Sélection manuelle des nouveaux animes
    final newOnes = <Anime>[];
    for (final title in _newThisWeekAnimeTitles) {
      try {
        final searchLower = title.toLowerCase();
        
        // D'abord on cherche un match EXACT
        Anime? anime;
        try {
          anime = _tousLesAnimes.firstWhere(
            (a) => a.title.toLowerCase() == searchLower,
          );
        } catch (_) {
          // Si pas de match exact, on cherche un anime qui CONTIENT le terme
          anime = _tousLesAnimes.firstWhere(
            (a) => a.title.toLowerCase().contains(searchLower),
          );
        }
        
        newOnes.add(anime);
      } catch (e) {
        // Anime non trouvé, on continue
        continue;
      }
    }
    return newOnes;
  }

  // Chargement des données
  Future<void> load() async {
    _loadThemePreference(); // Load theme preference
    try {
      _chargement = true;
      notifyListeners();

      _tousLesAnimes = await repository.loadFromAsset('assets/anime_1000.json');
      _construireIndexGenres();
      
      // Charger les données sauvegardées au lieu de tout effacer
      await _loadFavorites();
      await _loadTierList();
      await _loadUserPreferences();
      await loadTournamentHistory();
      
      // Tirer un anime courant qui n'a pas encore été vu
      _courant = _tirerProchaineRecommandation(initial: true);
      
      // Extract color for initial anime
      if (_courant != null) {
        _currentAnimeColor = await _colorExtractor.extractDominantColor(_courant!.image);
      }
      
      _chargement = false;
    } catch (e) {
      _erreur = e.toString();
      _chargement = false;
    } finally {
      notifyListeners();
      // On lance la musique une fois les données prêtes
      _initAudio();
    }
  }

  // --- AUDIO LOGIC ---

  Future<void> _initAudio() async {
    try {
      await _clearAudioCache();
      
      final playlist = ConcatenatingAudioSource(
        children: [
          AudioSource.asset('assets/audio/HowlsMovingCastle.mp3'),
          AudioSource.asset('assets/audio/Violet.mp3'),
          AudioSource.asset('assets/audio/FairysGlitter.mp3'),
          AudioSource.asset('assets/audio/YourName.mp3'),
          AudioSource.asset('assets/audio/FAIRYTAILMainTheme.mp3'),
        ],
      );

      await _audioPlayer.setAudioSource(playlist);
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.setVolume(_isMuted ? 0 : _volume);
      _audioPlayer.play();
    } catch (e) {
      print("Erreur initialisation audio globale : $e");
    }
  }

  Future<void> _clearAudioCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final audioCache = Directory('${cacheDir.path}/just_audio_cache');
      if (await audioCache.exists()) {
        await audioCache.delete(recursive: true);
      }
    } catch (e) {
      print('Erreur vidage cache audio global: $e');
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _audioPlayer.setVolume(_isMuted ? 0 : _volume);
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    if (!_isMuted) {
      _audioPlayer.setVolume(_volume);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Actions swipe
  void likeCurrent() {
    if (_courant == null || _tousLesAnimes.isEmpty) return;
    _dernierChoix = _courant;
    final genres = _genresNormalises(_courant!);
    _genresLikes.addAll(genres);
    _genresVus.addAll(genres);
    _ajouterPoidsGenres(genres, 1);
    _titresVus.add(_courant!.title);
    _shownCount += 1;
    _courant = _tirerProchaineRecommandation();
    _updateCurrentAnimeColor();
    _saveUserPreferences(); // Sauvegarde après swipe
    notifyListeners();
  }

  void skipCurrent() {
    if (_courant == null || _tousLesAnimes.isEmpty) return;
    final genres = _genresNormalises(_courant!);
    _genresVus.addAll(genres);
    _titresVus.add(_courant!.title);
    _shownCount += 1;
    _courant = _tirerProchaineRecommandation();
    _updateCurrentAnimeColor();
    _saveUserPreferences(); // Sauvegarde après swipe
    notifyListeners();
  }

  // Update current anime color asynchronously
  Future<void> _updateCurrentAnimeColor() async {
    if (_courant != null) {
      _currentAnimeColor = await _colorExtractor.extractDominantColor(_courant!.image);
      notifyListeners();
    }
  }

  // Recommandation
  Anime? _tirerProchaineRecommandation({bool initial = false}) {
    if (_tousLesAnimes.isEmpty) return null;

    final exclus = <String>{..._titresVus};
    if (!initial && _courant != null) exclus.add(_courant!.title);

    final candidats = _tousLesAnimes.where((a) => !exclus.contains(a.title)).toList();
    if (candidats.isEmpty) return null;


    // 80% du temps : genres likés/pondérés, sinon aléatoire
    final utiliserGenres =
        _genresLikes.isNotEmpty && _aleatoire.nextDouble() < 0.8;
    if (utiliserGenres) {
      final preferes = _candidatsDepuisGenres(_genresLikes, exclus);
      if (preferes.isNotEmpty) {
        preferes.shuffle(_aleatoire);
        preferes.sort((b, a) => _calculerScoreGenres(a).compareTo(_calculerScoreGenres(b)));
        return preferes.first;
      }
    }

    // Sinon aléatoire
    return candidats[_aleatoire.nextInt(candidats.length)];
  }

  Anime? _choisirSelonGenres(Set<String> genres, Set<String> exclus) {
    final matches = _candidatsDepuisGenres(genres, exclus);
    if (matches.isEmpty) return null;
    matches.shuffle(_aleatoire);
    return matches.first;
  }

  List<Anime> _candidatsDepuisGenres(Set<String> genres, Set<String> exclus) {
    final resultat = <Anime>[];
    final dejaAjoute = <String>{};
    for (final genre in genres) {
      final cle = genre.toLowerCase().trim();
      final liste = _indexParGenre[cle] ?? [];
      for (final anime in liste) {
        if (exclus.contains(anime.title)) continue;
        if (!dejaAjoute.add(anime.title)) continue;
        resultat.add(anime);
      }
    }
    return resultat;
  }

  // Préférences QCM +3 sur les genres choisis
  void appliquerPreferencesQcm(Set<String> genresChoisis) {
    final normalises = genresChoisis.map((g) => g.toLowerCase().trim()).toSet();
    _genresLikes.addAll(normalises);
    _genresVus.addAll(normalises);
    _ajouterPoidsGenres(normalises, 3);
    
    // Tirer un nouvel anime basé sur les préférences choisies
    _courant = _tirerProchaineRecommandation();
    _updateCurrentAnimeColor();
    
    _saveUserPreferences(); // Sauvegarde après QCM
    notifyListeners();
  }

  void _construireIndexGenres() {
    _indexParGenre.clear();
    for (final anime in _tousLesAnimes) {
      for (final genre in _genresNormalises(anime)) {
        if (genre.isEmpty) continue;
        _indexParGenre.putIfAbsent(genre, () => []);
        _indexParGenre[genre]!.add(anime);
      }
    }
  }

  Set<String> _genresNormalises(Anime anime) =>
      anime.tags.map((t) => t.toLowerCase().trim()).toSet();

  void _ajouterPoidsGenres(Set<String> genres, int delta) {
    for (final g in genres) {
      if (g.isEmpty) continue;
      _poidsGenres[g] = (_poidsGenres[g] ?? 0) + delta;
    }
  }

  int _calculerScoreGenres(Anime anime) {
    var score = 0;
    for (final g in _genresNormalises(anime)) {
      final poids = _poidsGenres[g] ?? 0;
      if (poids > 0) {
        score += poids;
      } else if (_genresLikes.contains(g)) {
        score += 1;
      }
    }
    return score;
  }

  // Favoris
  void toggleFavorite(Anime anime) {
    if (_favoris.any((a) => a.title == anime.title)) {
      _favoris.removeWhere((a) => a.title == anime.title);
    } else {
      _favoris.add(anime);
    }
    _saveFavorites(); // Sauvegarde après modification
    notifyListeners();
  }

  bool isFavorite(Anime anime) => _favoris.any((a) => a.title == anime.title);

  List<String> get favoriteGenres {
    final genres = <String>{};
    for (final anime in _favoris) {
      genres.addAll(anime.tags);
    }
    return genres.toList();
  }

  // Tier list
  void updateTier(Anime anime, String tier) {
    for (final entry in _tierList.entries) {
      entry.value.removeWhere((a) => a.title == anime.title);
    }
    _tierList.putIfAbsent(tier, () => []);
    if (!_tierList[tier]!.any((a) => a.title == anime.title)) {
      _tierList[tier]!.add(anime);
    }
    _saveTierList(); // Sauvegarde après modification
    notifyListeners();
  }

  void removeFromTier(Anime anime) {
    var removed = false;
    for (final entry in _tierList.entries) {
      final before = entry.value.length;
      entry.value.removeWhere((a) => a.title == anime.title);
      if (entry.value.length != before) removed = true;
    }
    if (removed) {
      _saveTierList(); // Sauvegarde après modification
      notifyListeners();
    }
  }

  // Couleur selon genre principal
  Color getGenreColor(Anime anime) {
    if (anime.tags.isEmpty) return const Color(0xFF6C5DD3);
    final genre = anime.tags.first.toLowerCase();
    if (genre.contains('action') || genre.contains('adventure')) {
      return const Color(0xFFFF6B6B);
    } else if (genre.contains('romance') || genre.contains('drama')) {
      return const Color(0xFFFF9FF3);
    } else if (genre.contains('sci-fi') || genre.contains('tech')) {
      return const Color(0xFF54A0FF);
    } else if (genre.contains('fantasy') || genre.contains('magic')) {
      return const Color(0xFF1DD1A1);
    } else if (genre.contains('horror') || genre.contains('thriller')) {
      return const Color(0xFF2D3436);
    } else if (genre.contains('comedy')) {
      return const Color(0xFFFECA57);
    } else if (genre.contains('suspense')) {
      return const Color.fromARGB(255, 18, 87, 18);
    } else if (genre.contains('award winning')) {
      return const Color.fromARGB(255, 37, 255, 208);
    }
    return const Color(0xFF6C5DD3);
  }

  // --- Data Persistence ---
  
  /// Sauvegarde les favoris dans SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // On stocke les titres des favoris (clé unique)
      final favoritesTitles = _favoris.map((a) => a.title).toList();
      await prefs.setStringList('favorites_v2', favoritesTitles);
    } catch (e) {
      print('Erreur lors de la sauvegarde des favoris: $e');
    }
  }

  /// Charge les favoris depuis SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesTitles = prefs.getStringList('favorites_v2') ?? [];
      
      // Retrouve les objets Anime complets depuis _tousLesAnimes
      _favoris.clear();
      for (final title in favoritesTitles) {
        try {
          final anime = _tousLesAnimes.firstWhere((a) => a.title == title);
          _favoris.add(anime);
        } catch (e) {
          print('Anime favori non trouvé: $title');
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
    }
  }

  /// Sauvegarde la tier list dans SharedPreferences
  Future<void> _saveTierList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Format: "tier1|||title1;;title2;;title3:::tier2|||title4;;title5"
      final tierData = _tierList.entries
          .map((entry) => '${entry.key}|||${entry.value.map((a) => a.title).join(';')}')
          .join(':::');
      await prefs.setString('tier_list_v2', tierData);
    } catch (e) {
      print('Erreur lors de la sauvegarde de la tier list: $e');
    }
  }

  /// Charge la tier list depuis SharedPreferences
  Future<void> _loadTierList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tierData = prefs.getString('tier_list_v2') ?? '';
      
      _tierList.clear();
      if (tierData.isEmpty) return;
      
      final tiers = tierData.split(':::');
      for (final tierStr in tiers) {
        if (tierStr.isEmpty) continue;
        final parts = tierStr.split('|||');
        if (parts.length != 2) continue;
        
        final tierName = parts[0];
        final titles = parts[1].split(';');
        
        final animes = <Anime>[];
        for (final title in titles) {
          if (title.isEmpty) continue;
          try {
            final anime = _tousLesAnimes.firstWhere((a) => a.title == title);
            animes.add(anime);
          } catch (e) {
            print('Anime de tier list non trouvé: $title');
          }
        }
        
        if (animes.isNotEmpty) {
          _tierList[tierName] = animes;
        }
      }
    } catch (e) {
      print('Erreur lors du chargement de la tier list: $e');
    }
  }

  /// Sauvegarde les préférences utilisateur (genres, historique)
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('genres_likes', _genresLikes.toList());
      await prefs.setStringList('genres_seen', _genresVus.toList());
      await prefs.setStringList('titles_seen', _titresVus.toList());
      await prefs.setInt('shown_count', _shownCount);
    } catch (e) {
      print('Erreur lors de la sauvegarde des préférences: $e');
    }
  }

  /// Charge les préférences utilisateur depuis SharedPreferences
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final genresLikes = prefs.getStringList('genres_likes') ?? [];
      final genresVus = prefs.getStringList('genres_seen') ?? [];
      final titresVus = prefs.getStringList('titles_seen') ?? [];
      final shownCount = prefs.getInt('shown_count') ?? 0;
      
      _genresLikes.addAll(genresLikes);
      _genresVus.addAll(genresVus);
      _titresVus.addAll(titresVus);
      _shownCount = shownCount;
      
      // Reconstruire les poids des genres depuis genresLikes
      for (final genre in _genresLikes) {
        _poidsGenres[genre] = (_poidsGenres[genre] ?? 0) + 1;
      }
    } catch (e) {
      print('Erreur lors du chargement des préférences: $e');
    }
  }

  // --- Theme Management ---

  ThemeMode _themeMode = ThemeMode.dark; // Default to dark
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _saveThemePreference();
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _themeMode == ThemeMode.dark);
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    // Notify is called safely because this is async and might happen after build
    notifyListeners(); 
  }

  // --- Navigation Management ---
  bool _isNavBarVisible = true;
  bool get isNavBarVisible => _isNavBarVisible;

  void setNavBarVisibility(bool visible) {
    _isNavBarVisible = visible;
    notifyListeners();
  }

  // --- Tournament History Management ---
  List<Map<String, dynamic>> _tournamentHistory = [];
  List<Map<String, dynamic>> get tournamentHistory => List.unmodifiable(_tournamentHistory);

  Future<void> loadTournamentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('tournament_history_v2') ?? [];
    _tournamentHistory = historyJson.map((json) {
      final parts = json.split('|||');
      return {
        'winnerTitle': parts[0],
        'winnerImage': parts[1],
        'date': parts[2],
        'participants': parts.length > 3 ? int.tryParse(parts[3]) ?? 8 : 8,
        'bracketData': parts.length > 4 ? parts[4] : '',
      };
    }).toList();
    notifyListeners();
  }

  Future<void> saveTournamentResult(
    Anime winner, 
    int participantsCount,
    {List<List<String>>? bracketData}
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    
    // Encode bracket data as a single string
    String bracketStr = '';
    if (bracketData != null) {
      bracketStr = bracketData.map((round) => round.join(';;')).join('::');
    }
    
    final entry = {
      'winnerTitle': winner.title,
      'winnerImage': winner.image,
      'date': dateStr,
      'participants': participantsCount,
      'bracketData': bracketStr,
    };
    
    _tournamentHistory.insert(0, entry); // Add at beginning (most recent first)
    
    // Keep only last 20 tournaments
    if (_tournamentHistory.length > 20) {
      _tournamentHistory = _tournamentHistory.take(20).toList();
    }
    
    // Persist
    final historyJson = _tournamentHistory.map((e) => 
      '${e['winnerTitle']}|||${e['winnerImage']}|||${e['date']}|||${e['participants']}|||${e['bracketData']}'
    ).toList();
    await prefs.setStringList('tournament_history_v2', historyJson);
    
    notifyListeners();
  }

  // Parse bracket data from saved string
  List<List<String>> parseBracketData(String bracketStr) {
    if (bracketStr.isEmpty) return [];
    return bracketStr.split('::').map((round) => round.split(';;')).toList();
  }

  Future<void> clearTournamentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tournament_history_v2');
    _tournamentHistory.clear();
    notifyListeners();
  }

  // --- RESET SYSTEM ---
  /// Réinitialise complètement l'application
  /// - Supprime favoris, tier list, histoire utilisateur
  /// - Conserve les préférences de thème
  Future<void> resetAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Réinitialise les données en mémoire
      _favoris.clear();
      _tierList.clear();
      _genresLikes.clear();
      _genresVus.clear();
      _titresVus.clear();
      _shownCount = 0;
      _tournamentHistory.clear();
      
      // Supprime les données persistantes (sauf le thème)
      await prefs.remove('favorites_v2');
      await prefs.remove('tier_list_v2');
      await prefs.remove('genres_likes');
      await prefs.remove('genres_seen');
      await prefs.remove('titles_seen');
      await prefs.remove('tournament_history_v2');
      
      // Recharge un nouvel anime courant
      _courant = _tirerProchaineRecommandation(initial: true);
      if (_courant != null) {
        await _updateCurrentAnimeColor();
      }
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors du reset: $e');
      _erreur = 'Erreur lors de la réinitialisation: $e';
      notifyListeners();
    }
  }

  /// Réinitialise UNIQUEMENT la tier list
  Future<void> resetTierList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _tierList.clear();
      await prefs.remove('tier_list_v2');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du reset tier list: $e');
      _erreur = 'Erreur lors de la réinitialisation: $e';
      notifyListeners();
    }
  }

  /// Réinitialise UNIQUEMENT les préférences de genres
  /// (algorithme de recommandation) sans toucher aux favoris/tier list
  Future<void> resetGenres() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Réinitialise les données en mémoire
      _genresLikes.clear();
      _genresVus.clear();
      _titresVus.clear();
      _poidsGenres.clear();
      _shownCount = 0;
      
      // Supprime les données persistantes
      await prefs.remove('genres_likes');
      await prefs.remove('genres_seen');
      await prefs.remove('titles_seen');
      
      // Recharge un nouvel anime courant
      _courant = _tirerProchaineRecommandation(initial: true);
      if (_courant != null) {
        await _updateCurrentAnimeColor();
      }
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors du reset genres: $e');
      _erreur = 'Erreur lors de la réinitialisation: $e';
      notifyListeners();
    }
  }

  /// Réinitialise UNIQUEMENT les favoris
  Future<void> resetFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoris.clear();
      await prefs.remove('favorites_v2');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du reset favoris: $e');
      _erreur = 'Erreur lors de la réinitialisation: $e';
      notifyListeners();
    }
  }
}
