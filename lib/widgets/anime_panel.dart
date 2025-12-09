import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../models/anime.dart';
import 'anime_image.dart';

const Duration panelAnimationDuration = Duration(milliseconds: 280);

class AnimePanel extends StatelessWidget {
  const AnimePanel({
    super.key,
    required this.anime,
    required this.expansion,
    required this.isTop,
    required this.onSelect,
    required this.color,
  });

  final Anime anime;
  final double expansion;
  final bool isTop;
  final void Function(Anime anime) onSelect;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double padding = lerpDouble(16, 28, expansion) ?? 20;
    final double blurStrength = lerpDouble(12, 28, expansion) ?? 18;
    final double spread = lerpDouble(2, 14, expansion) ?? 8;

    return AnimatedContainer(
      duration: panelAnimationDuration,
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.3 + expansion * 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1 + expansion * 0.12),
            blurRadius: blurStrength,
            spreadRadius: spread,
            offset: Offset(0, lerpDouble(6, 24, expansion) ?? 12),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3 + expansion * 0.2),
          width: 2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool useHorizontal = constraints.maxWidth > 520 && constraints.maxHeight > 320;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ExpandedAnimeContent(
                    anime: anime,
                    useHorizontal: useHorizontal,
                    emphasis: expansion,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => onSelect(anime),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Choisir cet anime', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExpandedAnimeContent extends StatelessWidget {
  const ExpandedAnimeContent({
    super.key,
    required this.anime,
    required this.useHorizontal,
    required this.emphasis,
    required this.color,
  });

  final Anime anime;
  final bool useHorizontal;
  final double emphasis;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final poster = AnimeImage(
      url: anime.image,
      width: useHorizontal ? 180 : double.infinity,
      height: useHorizontal ? (180 + (50 * emphasis)) : 220,
    );

    final synopsis = Text(
      anime.synopsis,
      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
    );

    final tagsWrap = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: anime.tags
          .map(
            (tag) => Chip(
              label: Text(tag),
              backgroundColor: color.withOpacity(0.1),
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: color.withOpacity(0.5),
                ),
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
          .toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          anime.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 20),
        if (useHorizontal)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 180, child: poster),
              const SizedBox(width: 22),
              Expanded(child: synopsis),
              const SizedBox(width: 22),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: tagsWrap,
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              poster,
              const SizedBox(height: 20),
              synopsis,
              const SizedBox(height: 20),
              tagsWrap,
            ],
          ),
      ],
    );
  }
}
