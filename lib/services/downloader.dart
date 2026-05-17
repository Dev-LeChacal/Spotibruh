import "dart:io";

import "package:http/http.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/services/auth/youtube.dart";
import "package:spotibruh/services/youtube.dart";
import "package:spotibruh/utils/path.dart";
import "package:spotibruh/utils/utils.dart";
import "package:spotibruh/widgets/messenger.dart";
import "package:spotify/spotify.dart";
import "package:youtube_explode_dart/youtube_explode_dart.dart";
import "package:youtube_explode_webview/youtube_explode_webview.dart";

class VideoIdException implements Exception {}

class NotInitializedException implements Exception {}

class _AuthenticatedHttpClient extends BaseClient {
  final Client _inner = Client();
  final String _cookies;

  _AuthenticatedHttpClient(this._cookies);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    final host = request.url.host;

    if (host.contains("youtube.com") || host.contains("google.com")) {
      request.headers["Cookie"] = _cookies;
      request.headers["User-Agent"] = App.agent;
    }

    return _inner.send(request);
  }
}

class Downloader {
  Downloader._();

  static final Set<String> _cantDownloadTracks = {};

  static bool _initialized = false;
  static late YoutubeExplode _yt;

  static bool _cancelled = false;

  // #region Initialization

  static Future<void> init() async {
    final cookies = await YoutubeAuth.getCookies();

    final httpClient = cookies != null ? YoutubeHttpClient(_AuthenticatedHttpClient(cookies)) : null;

    Utils.tryCatch(
      () async {
        _yt = YoutubeExplode(httpClient: httpClient, jsSolver: await WebviewEJSSolver.init());
        _initialized = true;
      },

      onErrorMessage:
          "Impossible d'initialiser le lecteur YouTube. Les chansons ne pourront pas être téléchargées. Veuillez relancez l'application avec une connexion internet.",
      fallback: null,
    );
  }

  static void dispose() {
    _yt.close();
  }

  // #endregion

  static void cancel() {
    _cancelled = true;
  }

  static void reset() {
    _cancelled = false;
  }

  static Future<void> downloadTrack(Track track, {int retryCount = 0, String? customId}) async {
    return Utils.tryCatch(
      () async {
        if (!_initialized) throw NotInitializedException();

        final id = Utils.guard(track.id);

        if (cantDownloadTrack(track) || await PathUtils.isTrackDownloaded(id) || _cancelled) return;

        final start = DateTime.now();

        if (_cancelled) return;
        final videoId = customId ?? await _getVideoId(track);

        if (_cancelled) return;
        final audioStream = await _getStream(videoId);

        if (_cancelled) return;
        await _downloadStream(id, audioStream);

        final end = DateTime.now();
        final duration = end.difference(start);

        Messenger.show(
          "${track.name} a été téléchargée (${duration.inMilliseconds} ms)",
          type: MessageType.success,
        );

        await Future.delayed(const Duration(seconds: 1));
      },

      onError: (e) async => await _handleError(e, track),
      fallback: null,
    );
  }

  static Future<void> deleteTrack(String id, String name) async {
    return Utils.tryCatch(
      () async {
        final file = await PathUtils.getTrackFile(id);

        if (await file.exists()) {
          await file.delete();
        }
      },

      onErrorMessage: "Une erreur s'est produite lors la supression de $name)",
      onSuccessMessage: "$name a été supprimée",

      fallback: null,
    );
  }

  // static Future<void>

  // #region Helpers

  static Future<void> _handleError(Object e, Track track) async {
    switch (e) {
      case RequestLimitExceededException():
        _showError(track, details: "limite de requêtes, attends 2 minutes");
        return await Future.delayed(const Duration(minutes: 2));

      case ClientException():
        _showError(track, details: "limite de redirections, attends 30 minutes");
        return await Future.delayed(const Duration(seconds: 30));

      case VideoUnplayableException():
        _showError(track, details: "la vidéo YouTube n'est pas lisible");

      case VideoIdException():
        _showError(track, details: "vidéo introuvable");

      case NotInitializedException():
        _showError(track, details: "le lecteur n'a pas été initialisé correctement");

      default:
        _showError(track);
    }

    _cantDownloadTracks.add(track.id!);
  }

  static void _showError(Track track, {String details = ""}) {
    final after = details.isEmpty ? "" : " ($details)";
    Messenger.show("${track.name} ne peut pas être téléchargée$after", type: MessageType.error);
  }

  static Future<void> _downloadStream(String id, Stream<List<int>> audioStream) async {
    final file = await PathUtils.getTrackFile(id);

    if (await file.exists()) {
      await file.delete();
    }

    final output = file.openWrite(mode: FileMode.writeOnly);

    await audioStream.pipe(output);
    await output.flush();
    await output.close();
  }

  static Future<Stream<List<int>>> _getStream(String videoId) async {
    final manifest = await _yt.videos.streamsClient.getManifest(
      videoId,
      ytClients: [YoutubeApiClient.androidVr],
    );

    final audio = manifest.audioOnly.withHighestBitrate();
    return _yt.videos.streamsClient.get(audio);
  }

  static Future<String> _getVideoId(Track track) async {
    final videoId = await YoutubeService.getVideoId(track);

    if (videoId == null) {
      throw VideoIdException();
    }

    return videoId;
  }

  static bool cantDownloadTrack(Track t) => _cantDownloadTracks.contains(t.id);

  // #endregion
}
