import "package:audio_service/audio_service.dart";
import "package:spotibruh/router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/audio/audio.dart";

mixin AudioBroadcast on BaseAudioHandler {
  void broadcastState({AudioProcessingState processingState = AudioProcessingState.ready}) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          AudioPlayer.player.state.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],

        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],

        processingState: processingState,

        playing: AudioPlayer.player.state.playing,
        updateTime: DateTime.now(),

        updatePosition: AudioPlayer.player.state.position,
        bufferedPosition: AudioPlayer.player.state.buffer,
      ),
    );
  }

  void listenNotificationClicked() {
    AudioService.notificationClicked.listen((clicked) {
      if (clicked && audio.currentTrack != null) {
        router.go(Routes.home);
        router.push(Routes.details.player);
      }
    });
  }
}
