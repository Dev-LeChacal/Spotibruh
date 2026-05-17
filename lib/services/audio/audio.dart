import "package:audio_service/audio_service.dart" hide AudioHandler;
import "package:spotibruh/services/audio/player.dart";

export "package:spotibruh/services/audio/player.dart";
export "package:spotibruh/services/audio/playlist.dart";
export "package:spotibruh/services/audio/downloader.dart";

late final AudioPlayer audio;

class Audio {
  Audio._();

  static Future<void> init() async {
    audio = await AudioService.init(
      builder: () => AudioPlayer(),

      config: const AudioServiceConfig(
        androidNotificationChannelId: "com.lechacal.spotibruh.audio",
        androidNotificationChannelName: "Audio playback",
      ),
    );
  }
}
