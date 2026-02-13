import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Service to extract dominant colors from anime cover images.
/// Caches results to avoid re-processing the same image.
class ColorExtractorService {
  // Cache for extracted colors
  final Map<String, Color> _colorCache = {};
  
  // Default color if extraction fails
  static const Color defaultColor = Color(0xFF6C5DD3);
  
  /// Extracts the dominant color from an asset image.
  /// Returns cached color if available.
  Future<Color> extractDominantColor(String imagePath) async {
    // Return cached color if available
    if (_colorCache.containsKey(imagePath)) {
      return _colorCache[imagePath]!;
    }
    
    try {
      // Create image provider from asset
      final ImageProvider imageProvider = AssetImage(imagePath);
      
      // Generate palette from image
      final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(100, 100), // Use smaller size for faster processing
        maximumColorCount: 16,
      );
      
      // Get dominant color, fallback to vibrant, then default
      Color extractedColor;
      if (palette.dominantColor != null) {
        extractedColor = palette.dominantColor!.color;
      } else if (palette.vibrantColor != null) {
        extractedColor = palette.vibrantColor!.color;
      } else if (palette.mutedColor != null) {
        extractedColor = palette.mutedColor!.color;
      } else {
        extractedColor = defaultColor;
      }
      
      // Ensure the color is vibrant enough (not too dark or too light)
      extractedColor = _ensureVibrantColor(extractedColor);
      
      // Cache the result
      _colorCache[imagePath] = extractedColor;
      
      return extractedColor;
    } catch (e) {
      // If extraction fails, return and cache default color
      _colorCache[imagePath] = defaultColor;
      return defaultColor;
    }
  }
  
  /// Ensures the color is vibrant enough for UI use.
  /// Adjusts saturation and lightness if needed.
  Color _ensureVibrantColor(Color color) {
    final HSLColor hsl = HSLColor.fromColor(color);
    
    // Ensure minimum saturation of 0.4 and lightness between 0.35 and 0.65
    double saturation = hsl.saturation;
    double lightness = hsl.lightness;
    
    if (saturation < 0.4) {
      saturation = 0.4;
    }
    
    if (lightness < 0.35) {
      lightness = 0.35;
    } else if (lightness > 0.65) {
      lightness = 0.65;
    }
    
    return HSLColor.fromAHSL(1.0, hsl.hue, saturation, lightness).toColor();
  }
  
  /// Pre-caches colors for a list of anime images.
  Future<void> preloadColors(List<String> imagePaths) async {
    for (final path in imagePaths) {
      if (!_colorCache.containsKey(path)) {
        await extractDominantColor(path);
      }
    }
  }
  
  /// Gets a cached color synchronously. Returns null if not cached.
  Color? getCachedColor(String imagePath) {
    return _colorCache[imagePath];
  }
  
  /// Clears the color cache.
  void clearCache() {
    _colorCache.clear();
  }
}
