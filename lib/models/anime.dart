class Anime {
  final String title;
  final String image;
  final String synopsis;
  final List<String> tags;
  final double score;
  final int episodes;

  Anime({
    required this.title,
    required this.image,
    required this.synopsis,
    required this.tags,
    required this.score,
    required this.episodes,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    // Je combine le genre et le thème pour les tags
    final genres = json['genres'] as String? ?? '';
    final themes = json['themes'] as String? ?? '';
    final tagsList = [
      ...genres.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
      ...themes.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
    ];

    return Anime(
      title: json['name'] as String? ?? 'Unknown Title',
      image: 'assets/images_raw/${(json['image_url'] as String).split('/').last}',
      synopsis: json['synopsis'] as String? ?? '',
      tags: tagsList,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      episodes: json['episodes'] as int? ?? 0,
    );
  }
}
