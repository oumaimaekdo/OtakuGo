import 'package:flutter/material.dart';

class AnimeImage extends StatelessWidget {
  const AnimeImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallbackColor = Colors.deepPurple.shade50;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(color: fallbackColor),
          child: Image.asset(
            url,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.deepPurple.shade200,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
