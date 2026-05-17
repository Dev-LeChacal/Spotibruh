import "package:flutter_secure_storage/flutter_secure_storage.dart";

class YoutubeAuth {
  YoutubeAuth._();

  static const _storage = FlutterSecureStorage();
  static const _storageKey = "youtube";

  static Future<bool> isLoggedIn() async {
    return await getCookies() != null;
  }

  static Future<void> logout() async {
    return _storage.delete(key: _storageKey);
  }

  static Future<void> saveCookies(String cookies) async {
    return _storage.write(key: _storageKey, value: cookies);
  }

  static Future<String?> getCookies() async {
    return _storage.read(key: _storageKey);
  }
}
