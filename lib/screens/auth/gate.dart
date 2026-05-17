import "package:flutter/material.dart";
import "package:spotibruh/router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/auth/spotify.dart";
import "package:spotibruh/services/auth/youtube.dart";
import "package:spotibruh/services/downloader.dart";

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final spotify = await SpotifyAuth.isLoggedIn();
    final youtube = await YoutubeAuth.isLoggedIn();

    if (!mounted) return;

    if (!spotify) {
      router.go(Routes.auth.start);
    } else if (!youtube) {
      router.go(Routes.auth.youtube);
    } else {
      await Downloader.init();
      router.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
