import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<List<dynamic>> loadAnimeData() async {

  const assetPath = 'assets/anime_1000.json';
  final stopwatch = Stopwatch()..start();

  final jsonString = await rootBundle.loadString(assetPath);
  final data = json.decode(jsonString) as List<dynamic>;

  stopwatch.stop();

  print(
    'Chargement + decode de $assetPath : '
    '${stopwatch.elapsedMilliseconds} ms | ${data.length} animes',
  );

  return data;
}
