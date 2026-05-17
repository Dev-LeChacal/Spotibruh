import "dart:async";

import "package:audio_service/audio_service.dart";
import "package:media_kit/media_kit.dart" hide Track;
import "package:spotibruh/services/audio/audio.dart";
import "package:spotibruh/services/audio/broadcast.dart";
import "package:spotify/spotify.dart";

class AudioPlayer extends BaseAudioHandler with QueueHandler, SeekHandler, AudioBroadcast, AudioPlaylist {
  final _currentTrackController = StreamController<Track?>.broadcast();
  Stream<Track?> get currentTrackStream => _currentTrackController.stream;

  Stream<bool> get playingStream => player.stream.playing;
  Stream<Duration> get positionStream => player.stream.position;
  Stream<Duration?> get durationStream => player.stream.duration;

  Track? _currentTrack;
  Track? get currentTrack => _currentTrack;
  bool get hasCurrentTrack => currentTrack != null;
  bool get isPlaying => player.state.playing;

  static int playlistVersion = 0;
  static final player = Player();

  late final StreamSubscription _playlistSub;
  late final StreamSubscription _playingSub;
  late final StreamSubscription _positionSub;
  late final StreamSubscription _completedSub;

  bool get isDownloadingCurrent {
    if (_currentTrack == null) {
      return false;
    }

    final id = _currentTrack!.id;
    final contains = AudioDownloader.downloading.containsKey(id);

    return contains;
  }

  AudioPlayer() {
    _subscribeToStreams();
    listenNotificationClicked();
    _applyNormalization();
  }

  Future<void> logout() async {
    AudioDownloader.cancel();
    await player.stop();

    clearTracks();

    _currentTrack = null;
    _currentTrackController.add(null);

    queue.add([]);
    mediaItem.add(null);

    broadcastState();
  }

  @override
  Future<void> onTaskRemoved() => _dispose();

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> skipToNext() => player.next();

  @override
  Future<void> skipToPrevious() => player.previous();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  void _subscribeToStreams() {
    _playlistSub = player.stream.playlist.distinct((a, b) => a.index == b.index).listen((playlist) async {
      final index = playlist.index;
      if (tracks.isEmpty) return;

      _currentTrack = tracks[index];
      _currentTrackController.add(_currentTrack);
      mediaItem.add(queue.value[index]);

      await pause();

      final success = await AudioDownloader.download(tracks[index]);

      if (!success) {
        return await player.next();
      }

      await play();

      if (index + 1 < tracks.length) {
        AudioDownloader.download(tracks[index + 1]);
      }

      broadcastState();
    });

    _playingSub = player.stream.playing.listen((_) => broadcastState());
    _positionSub = player.stream.position.listen((_) => broadcastState());

    _completedSub = player.stream.completed.listen((completed) {
      if (completed) {
        broadcastState(processingState: AudioProcessingState.completed);
      }
    });
  }

  void _applyNormalization() async {
    final native = player.platform as NativePlayer;
    await native.setProperty("af", "dynaudnorm=f=300:g=31:m=10");
  }

  Future<void> _dispose() async {
    await _playlistSub.cancel();
    await _playingSub.cancel();
    await _positionSub.cancel();
    await _completedSub.cancel();
    await player.stop();
    await player.dispose();
    await _currentTrackController.close();
  }

  @override
  void updateCurrentTrack(Track track) {
    _currentTrack = track;
    _currentTrackController.add(_currentTrack);
  }
}
