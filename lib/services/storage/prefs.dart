import "package:spotibruh/services/storage/database.dart";

class Pref<T> {
  final String key;
  final T defaultValue;

  Pref(this.key, this.defaultValue);

  T get value => Database.preferences.get(key, defaultValue: defaultValue);
  Future<void> set(T value) => Database.preferences.put(key, value);
}

class Prefs {
  Prefs._();

  static final theme = Pref<int>("theme", 0);
  static final isShuffling = Pref("is_shuffling", false);
  static final showOnlyErrors = Pref("show_only_errors", false);

  static Future<void> clear() async {
    await Database.preferences.clear();

    await theme.set(theme.defaultValue);
    await isShuffling.set(isShuffling.defaultValue);
    await showOnlyErrors.set(showOnlyErrors.defaultValue);
  }
}
