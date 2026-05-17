import "dart:convert";
import "package:oauth2/oauth2.dart" as oauth2;
import "package:spotibruh/app.dart";
import "package:spotibruh/services/downloader.dart";
import "package:spotibruh/services/storage/env.dart";
import "package:spotify/spotify.dart";
import "package:url_launcher/url_launcher.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

class SpotifyAuth {
  SpotifyAuth._();

  static final _scopes = AuthorizationScope.all.cast<String>();

  static const _storage = FlutterSecureStorage();
  static const _storageKey = "spotify";

  static late oauth2.AuthorizationCodeGrant _grant;
  static String? _codeVerifier;

  static late SpotifyApi spotify;

  static Future<bool> isLoggedIn() async {
    final stored = await _storage.read(key: _storageKey);
    if (stored == null) return false;

    final json = jsonDecode(stored);

    if (await App.isOffline()) return true;

    spotify = await SpotifyApi.asyncFromCredentials(
      _loadCredentials(json),
      onCredentialsRefreshed: _saveCredentials,
    );

    return true;
  }

  static Future<void> login() async {
    _codeVerifier = SpotifyApi.generateCodeVerifier();

    final credentials = SpotifyApiCredentials.pkce(Env.getClientId(), codeVerifier: _codeVerifier!);

    final redirectUri = Uri.parse(Env.getRedirectUri());

    _grant = SpotifyApi.authorizationCodeGrant(
      credentials,
      onCredentialsRefreshed: (newCreds) {
        _saveCredentials(newCreds);
      },
    );

    final authUri = _grant.getAuthorizationUrl(redirectUri, scopes: _scopes);

    await launchUrl(authUri, mode: LaunchMode.externalApplication);
  }

  static Future<void> logout() async {
    await _deleteCredentials();
    _codeVerifier = null;
  }

  static Future<void> handleRedirect(Uri uri) async {
    final client = await _grant.handleAuthorizationResponse(uri.queryParameters);
    spotify = SpotifyApi.fromClient(client);

    final credentials = await spotify.getCredentials();

    final credentialsWithVerifier = SpotifyApiCredentials.pkce(
      credentials.clientId!,
      codeVerifier: _codeVerifier!,
      accessToken: credentials.accessToken,
      refreshToken: credentials.refreshToken,
      scopes: credentials.scopes,
      expiration: credentials.expiration,
    );

    await _saveCredentials(credentialsWithVerifier);
    Downloader.reset();
  }

  static SpotifyApiCredentials _loadCredentials(Map<String, dynamic> json) {
    final codeVerifier = json["codeVerifier"] as String?;

    if (codeVerifier != null) {
      return SpotifyApiCredentials.pkce(
        json["clientId"],
        codeVerifier: codeVerifier,
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        scopes: List<String>.from(json["scopes"] ?? []),
        expiration: json["expiration"] != null ? DateTime.parse(json["expiration"]) : null,
      );
    }

    return SpotifyApiCredentials(
      json["clientId"],
      json["clientSecret"],
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      scopes: List<String>.from(json["scopes"] ?? []),
      expiration: json["expiration"] != null ? DateTime.parse(json["expiration"]) : null,
    );
  }

  static Future<void> _saveCredentials(SpotifyApiCredentials credentials) async {
    final json = {
      "clientId": credentials.clientId,
      "clientSecret": credentials.clientSecret,
      "accessToken": credentials.accessToken,
      "refreshToken": credentials.refreshToken,
      "tokenEndpoint": credentials.tokenEndpoint?.toString(),
      "scopes": credentials.scopes,
      "expiration": credentials.expiration?.toIso8601String(),
      "codeVerifier": credentials.codeVerifier,
    };

    await _storage.write(key: _storageKey, value: jsonEncode(json));
  }

  static Future<void> _deleteCredentials() async {
    await _storage.delete(key: _storageKey);
  }
}
