import "dart:convert";

import "package:cached_network_image/cached_network_image.dart";
import "package:crypto/crypto.dart";
import "package:flutter/material.dart";
import "package:palette_generator_master/palette_generator_master.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/services/storage/database.dart";
import "package:spotibruh/widgets/messenger.dart";

class ColorUtils {
  ColorUtils._();

  static final Map<String, ImageProvider> _providerCache = {};
  static final Map<String, Color> _cache = {};

  static String _keyFor(String url) => "${md5.convert(utf8.encode(url))}";

  static Future<void> clearCache() async {
    final total = await Database.colors.clear();

    Messenger.show("Le cache des couleurs a été nettoyé ($total)", type: MessageType.success);

    _cache.clear();
    _providerCache.clear();
  }

  static Future<Color> getColorForImage(String url, int maxSize, {int? maxWidth, int? maxHeight}) async {
    try {
      if (_cache.containsKey(url)) {
        return _cache[url]!;
      }

      final key = _keyFor(url);
      final stored = Database.colors.get(key);

      if (stored != null) {
        return _cache[url] = Color(stored);
      }

      final provider = _providerCache.putIfAbsent(
        url,
        () => CachedNetworkImageProvider(url, maxWidth: maxWidth ?? maxSize, maxHeight: maxHeight ?? maxSize),
      );

      final palette = await PaletteGeneratorMaster.fromImageProvider(
        provider,
        maximumColorCount: 12,
        generateHarmony: false,
        targets: [PaletteTargetMaster.darkVibrant, PaletteTargetMaster.darkMuted],
        filters: [],
      );

      final raw =
          palette.darkVibrantColor?.color ??
          palette.darkMutedColor?.color ??
          palette.dominantColor?.color ??
          App.theme.value.surfaceContainerHigh;

      final hsl = HSLColor.fromColor(raw);
      final color = hsl.withLightness(hsl.lightness.clamp(0.15, 0.28)).toColor();

      _cache[url] = color;

      await Database.colors.put(key, color.toARGB32());

      return color;

      // default color
    } catch (_) {
      return App.theme.value.surfaceContainerHigh;
    }
  }

  static LinearGradient getGradientForColor(Color color) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,

      colors: [color, App.theme.value.surfaceContainerLow],
      stops: const [0.0, 0.9],
    );
  }
}
