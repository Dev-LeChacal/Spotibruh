import "package:spotibruh/router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/audio/audio.dart";
import "package:spotibruh/services/auth/spotify.dart";
import "package:spotibruh/services/auth/youtube.dart";
import "package:spotibruh/services/prefs.dart";
import "package:spotibruh/services/spotify.dart";
import "package:spotibruh/utils/utils.dart";

class Auth {
  Auth._();

  static Future<void> logout() async {
    return Utils.tryCatch(
      () async {
        await SpotifyAuth.logout();
        await YoutubeAuth.logout();

        await SpotifyService.clear();
        await Prefs.clear();

        await audio.logout();

        router.go(Routes.auth.start);
      },

      onErrorMessage: "Une erreur s'est produite lors de la déconnexion",

      fallback: null,
    );
  }
}
