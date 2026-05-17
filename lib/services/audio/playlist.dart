import "package:audio_service/audio_service.dart";
import "package:media_kit/media_kit.dart" hide Track;
import "package:spotibruh/services/audio/broadcast.dart";
import "package:spotibruh/services/audio/downloader.dart";
import "package:spotibruh/services/audio/player.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/utils/path.dart";
import "package:spotibruh/utils/utils.dart";
import "package:spotify/spotify.dart" hide Playlist;

mixin AudioPlaylist on BaseAudioHandler, AudioBroadcast {
  List<Track> tracks = [];
  bool _isShuffling = false;

  void clearTracks() => tracks = [];

  void updateCurrentTrack(Track track);

  void setShuffleEnabled(bool enabled, {bool shuffleTracks = false}) {
    _isShuffling = enabled;

    if (shuffleTracks) {}
  }

  Future<void> playPlaylist(List<Track> rawTracks, {Track? track}) async {
    final shuffled = _isShuffling ? _shuffle(rawTracks) : List<Track>.from(rawTracks);

    if (track != null) {
      final initialIndex = shuffled.indexWhere((t) => t.id == track.id);

      if (_isShuffling) {
        shuffled.removeAt(initialIndex);
        shuffled.insert(0, track);
      } else {
        shuffled.removeRange(0, initialIndex);
      }
    }

    tracks = shuffled;
    AudioPlayer.playlistVersion++;

    final success = await AudioDownloader.download(shuffled.first);
    if (!success) shuffled.removeAt(0);

    final initial = shuffled.first;
    final initialPath = await PathUtils.getTrackPath(initial.id!);
    final imageURL = ImagesUtils.getBest(initial.album?.images);

    final id = Utils.guard(initial.id);
    final name = initial.name ?? "Inconnu";
    final artists = initial.artists?.map((a) => a.name).join(", ");

    queue.add([
      MediaItem(
        id: id,
        title: name,
        artist: artists,
        artUri: Uri.parse(imageURL ?? ""),
        duration: initial.duration,
      ),
    ]);

    updateCurrentTrack(initial);
    mediaItem.add(queue.value.first);
    broadcastState();

    await AudioPlayer.player.open(Playlist([Media(initialPath)]));
    await play();

    AudioDownloader.downloadRemaining(tracks);
  }

  List<Track> _shuffle(List<Track> tracks) => List<Track>.from(tracks)..shuffle();
}
