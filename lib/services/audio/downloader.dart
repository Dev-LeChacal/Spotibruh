import "dart:async";

import "package:audio_service/audio_service.dart";
import "package:media_kit/media_kit.dart" hide Track;
import "package:spotibruh/services/audio/audio.dart";
import "package:spotibruh/services/downloader.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/utils/path.dart";
import "package:spotibruh/utils/utils.dart";
import "package:spotify/spotify.dart";

class AudioDownloader {
  AudioDownloader._();

  static final Map<String, Completer<void>> downloading = {};

  static void cancel() {
    AudioPlayer.playlistVersion++;
    Downloader.cancel();

    for (var completer in downloading.values) {
      completer.complete();
    }

    downloading.clear();
  }

  static Future<bool> download(Track track) async {
    final id = Utils.guard(track.id);
    final file = await PathUtils.getTrackFile(id);

    final exists = await file.exists();
    if (exists) return true;

    if (downloading.containsKey(id)) {
      await downloading[id]!.future;
      return true;
    }

    final completer = Completer<void>();
    downloading[id] = completer;

    await Downloader.downloadTrack(track);
    downloading[id]!.complete();
    downloading.remove(id);

    return !Downloader.cantDownloadTrack(track);
  }

  static Future<void> downloadRemaining(List<Track> tracks) async {
    if (tracks.length <= 1) return;

    final version = AudioPlayer.playlistVersion;

    for (int i = 1; i < tracks.length; i++) {
      if (version < AudioPlayer.playlistVersion) return;

      final track = tracks[i];
      final success = await download(track);

      if (!success) continue;

      final path = await PathUtils.getTrackPath(track.id!);
      final imageURL = ImagesUtils.getBest(track.album?.images);

      await AudioPlayer.player.add(Media(path));

      final currentQueue = List<MediaItem>.from(audio.queue.value);

      currentQueue.add(
        MediaItem(
          id: track.id!,
          title: track.name ?? "Inconnu",
          artist: track.artists?.map((a) => a.name).join(", "),
          artUri: imageURL != null ? Uri.parse(imageURL) : null,
          duration: track.duration,
        ),
      );

      audio.queue.add(currentQueue);
    }
  }
}
