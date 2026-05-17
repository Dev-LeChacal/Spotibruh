class DurationUtils {
  DurationUtils._();

  static String formatDuration(int durationMs) {
    return Duration(milliseconds: durationMs)
        .toString()
        .split(".")
        .first
        .split(":")
        .skip(1)
        .join(":")
        .replaceFirst(RegExp(r"^0"), "");
  }
}
