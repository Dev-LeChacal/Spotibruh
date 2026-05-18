import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:media_kit/media_kit.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/main_app.dart";
import "package:spotibruh/services/audio/audio.dart";
import "package:spotibruh/services/downloader.dart";
import "package:spotibruh/services/prefs.dart";
import "package:spotibruh/services/storage/database.dart";
import "package:spotibruh/theme/app_theme.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  MediaKit.ensureInitialized();

  await Database.init();
  await Audio.init();
  await Downloader.init();

  App.theme.value = AppTheme.values[Prefs.theme.value];

  runApp(const MainApp());
}
