import "package:go_router/go_router.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/screens/auth/gate.dart";
import "package:spotibruh/screens/auth/spotify.dart";
import "package:spotibruh/screens/auth/start.dart";
import "package:spotibruh/screens/auth/youtube.dart";
import "package:spotibruh/screens/details/artist.dart";
import "package:spotibruh/screens/details/playlist.dart";
import "package:spotibruh/screens/details/track.dart";
import "package:spotibruh/screens/home.dart";
import "package:spotibruh/screens/details/player.dart";
import "package:spotibruh/screens/search/spotify.dart";
import "package:spotibruh/screens/search/youtube.dart";
import "package:spotibruh/screens/settings.dart";
import "package:spotify/spotify.dart";

final router = GoRouter(
  navigatorKey: App.navigatorKey,
  initialLocation: Routes.auth.root,

  routes: [
    GoRoute(path: Routes.auth.root, builder: (_, _) => const AuthGateScreen()),
    GoRoute(path: Routes.auth.start, builder: (_, _) => const StartScreen()),
    GoRoute(path: Routes.auth.spotify, builder: (_, _) => const SpotifyLoginScreen()),
    GoRoute(path: Routes.auth.youtube, builder: (_, _) => const YoutubeLoginScreen()),

    GoRoute(
      path: Routes.search.spotify,
      builder: (_, state) {
        final query = state.extra as String;
        return SpotifySearchScreen(query: query);
      },
    ),
    GoRoute(
      path: Routes.search.youtube,
      builder: (_, state) {
        final query = state.extra as String;
        return YoutubeSearchScreen(query: query);
      },
    ),

    GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
    GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),

    GoRoute(path: Routes.details.player, builder: (_, _) => const PlayerScreen()),
    GoRoute(
      path: Routes.details.playlist,
      builder: (_, state) {
        final playlist = state.extra as PlaylistSimple;
        return PlaylistScreen(playlist: playlist);
      },
    ),
    GoRoute(
      path: Routes.details.artist,
      builder: (_, state) {
        final artist = state.extra as Artist;
        return ArtistScreen(artist: artist);
      },
    ),
    GoRoute(
      path: Routes.details.track,
      builder: (_, state) {
        final track = state.extra as Track;
        return TrackScreen(track: track);
      },
    ),
  ],
);
