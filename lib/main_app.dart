import "dart:async";

import "package:app_links/app_links.dart";
import "package:flutter/material.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/auth/spotify.dart";
import "package:spotibruh/services/downloader.dart";
import "package:spotibruh/theme/theme.dart";
import "package:spotibruh/theme/app_theme.dart";

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late StreamSubscription _redirectSubscription;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();

    _redirectSubscription = _appLinks.uriLinkStream.listen((uri) {
      SpotifyAuth.handleRedirect(uri).then((_) {
        router.go(Routes.auth.root);
      });
    });
  }

  @override
  void dispose() {
    _redirectSubscription.cancel();
    Downloader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: App.theme,

      builder: (_, t, _) => MaterialApp.router(
        scaffoldMessengerKey: App.messengerKey,
        debugShowCheckedModeBanner: false,

        title: "Spotibruh",
        theme: buildTheme(t),

        routerConfig: router,
      ),
    );
  }
}
