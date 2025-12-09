  import 'dart:convert';
  import 'package:flutter/services.dart' show AssetBundle;
  import '../models/anime.dart';

  class AnimeRepository {
    AnimeRepository(this._bundle);
    final AssetBundle _bundle;

    Future<List<Anime>> loadFromAsset(String path) async {
      final raw = await _bundle.loadString(path);
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Anime.fromJson(e as Map<String, dynamic>)).toList();
    }
  }
