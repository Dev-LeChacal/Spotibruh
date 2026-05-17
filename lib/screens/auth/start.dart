import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/widgets/button.dart";

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  static const onboardingText =
      """Spotibruh est une application qui grâce à l'API de Spotify te permet de profiter de ta musique préférée sans les limitations de l'application officielle.

Tu peux y retrouver tes playlists et tes artistes préférés sur la page d'accueil.

Les musiques sont téléchargées depuis Youtube directement sur ton appareil, ce qui te permet de les écouter même sans connexion internet.

Commence par te connecter à ton compte Spotify puis ton compte Youtube.""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Text("Spotibruh", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),

              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12,

                    children: [
                      Text(onboardingText, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: ButtonWidget(onPressed: () => context.go(Routes.auth.spotify), label: "Commencer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
