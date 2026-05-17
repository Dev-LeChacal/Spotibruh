import "package:spotify/spotify.dart";

class ImagesUtils {
  ImagesUtils._();

  static String? getWorst(List<Image>? images) {
    if (images == null || images.isEmpty) return null;

    final sorted = [...images]..sort((a, b) => (a.width ?? 0).compareTo(b.width ?? 0));
    return sorted.first.url;
  }

  static String? getMedium(List<Image>? images) {
    if (images == null || images.isEmpty) return null;

    final sorted = [...images]..sort((a, b) => (b.width ?? 0).compareTo(a.width ?? 0));
    return sorted.length > 1 ? sorted[sorted.length ~/ 2].url : sorted.first.url;
  }

  static String? getBest(List<Image>? images) {
    if (images == null || images.isEmpty) return null;

    final sorted = [...images]..sort((a, b) => (b.width ?? 0).compareTo(a.width ?? 0));
    return sorted.first.url;
  }
}
