import "package:flutter/material.dart";
import "package:spotibruh/services/auth/spotify.dart";
import "package:spotibruh/widgets/button.dart";

class SpotifyLoginScreen extends StatefulWidget {
  const SpotifyLoginScreen({super.key});

  @override
  State<SpotifyLoginScreen> createState() => _SpotifyLoginScreenState();
}

class _SpotifyLoginScreenState extends State<SpotifyLoginScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _login();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    await SpotifyAuth.login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text("Spotify", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: ButtonWidget(onPressed: _login, label: "Se connecter", isLoading: _isLoading),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
