import "dart:async";

import "package:hive_flutter/hive_flutter.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/auth/spotify.dart";
import "package:spotibruh/services/storage/database.dart";
import "package:spotibruh/utils/utils.dart";
import "package:spotibruh/widgets/messenger.dart";
import "package:spotify/spotify.dart";

class SpotifyService {
  SpotifyService._();

  static final Map<String, Iterable<Track>> _cachedPlaylistTracks = {};
  static Iterable<PlaylistSimple> _cachedPlaylists = [];

  static final Map<String, Artist> _cachedArtistDetails = {};
  static Iterable<Artist> _cachedArtists = [];

  static String? _userId;

  static Future<void> clear() async {
    _cachedPlaylistTracks.clear();
    _cachedArtistDetails.clear();
    _cachedPlaylists = [];
    _cachedArtists = [];

    _userId = null;

    await Database.playlists.clear();
    await Database.tracks.clear();
    await Database.followedArtists.clear();
  }

  // #region Playlists

  static Future<Iterable<PlaylistSimple>> getPlaylists({bool fromCache = true}) async {
    return Utils.tryCatch(
      () async {
        if (await App.isOffline()) fromCache = true;

        final result = _getFromCache<PlaylistSimple>(
          fromCache,
          _cachedPlaylists,
          Database.playlists,
          Database.data,
          PlaylistSimple.fromJson,
        );

        if (result != null) return result;

        _userId ??= (await SpotifyAuth.spotify.me.get()).id;

        _cachedPlaylists = await SpotifyAuth.spotify.me.playlists.saved().all();

        _cachedPlaylists = [
          PlaylistSimple()
            ..id = "liked"
            ..name = "Titres likés"
            ..images = [
              Image()..url = "https://misc.scdn.co/liked-songs/liked-songs-640.jpg",
              Image()..url = "https://misc.scdn.co/liked-songs/liked-songs-300.jpg",
              Image()..url = "https://misc.scdn.co/liked-songs/liked-songs-64.jpg",
            ]
            ..tracksLink = (TracksLink()..total = await _fetchTotalLikedSongs()),
          ..._cachedPlaylists,
        ];

        await _saveList(Database.playlists, Database.data, _cachedPlaylists);

        return _cachedPlaylists;
      },

      onErrorMessage: "Une erreur s'est produite durant la récupération des playlists",

      fallback: [],
    );
  }

  static Future<Iterable<Track>> getPlaylistTracks(PlaylistSimple playlist, {bool fromCache = true}) async {
    return Utils.tryCatch(
      () async {
        if (await App.isOffline()) fromCache = true;

        final id = Utils.guard(playlist.id);

        if (fromCache) {
          if (_cachedPlaylistTracks.containsKey(id)) {
            return _cachedPlaylistTracks[id]!;
          }

          final stored = Database.tracks.get(id);

          if (stored != null) {
            return _cachedPlaylistTracks[id] = _parseList(stored, Track.fromJson);
          }
        }

        final tracks = await _fetchTracks(id);
        _cachedPlaylistTracks[id] = tracks;

        unawaited(_saveList(Database.tracks, id, tracks));

        return tracks;
      },

      onErrorMessage: "Une erreur s'est produite durant la récupération des chansons",

      fallback: [],
    );
  }

  static Future<void> addTrackToPlaylist(PlaylistSimple playlist, Track track) async {
    if (await App.isOffline()) {
      return Messenger.show("Impossible en mode hors ligne", type: MessageType.warning);
    }

    final trackId = Utils.guard(track.id);
    final trackUri = Utils.guard(track.uri);

    final playlistId = Utils.guard(playlist.id);

    final cached = _cachedPlaylistTracks[playlistId]?.toList();

    await _updateCache(playlistId, track, cached);

    unawaited(router.push(Routes.details.playlist, extra: playlist));

    return Utils.tryCatch(
      () async {
        await _addTrackToPlaylist(playlistId, trackId, trackUri);

        Messenger.show("${track.name} à été ajouté à ${playlist.name}", type: MessageType.success);
      },

      onErrorMessage: "Une erreur est survenue lors de l'ajout de ${track.name}",

      fallback: null,
    );
  }

  static Future<void> createPlaylist(String name, String description) async {
    return Utils.tryCatch(
      () async {
        if (await App.isOffline()) {
          return Messenger.show("Impossible en mode hors ligne", type: MessageType.warning);
        }

        final playlist = await SpotifyAuth.spotify.me.playlists.create(
          name,
          public: false,
          collaborative: false,
          description: description,
        );

        _cachedPlaylists = [_cachedPlaylists.first, playlist, ..._cachedPlaylists.skip(1)];

        await _saveList(Database.playlists, Database.data, _cachedPlaylists);
      },

      onErrorMessage: "Une erreur est survenue lors de la création de $name",
      onSuccessMessage: "$name a été créé",

      fallback: null,
    );
  }

  // #endregion

  // #region Artists

  static Future<Artist> getArtistDetails(Artist simpleArtist, {bool fromCache = true}) async {
    return Utils.tryCatch(
      () async {
        if (await App.isOffline()) fromCache = true;

        final id = Utils.guard(simpleArtist.id);

        if (fromCache) {
          if (_cachedArtistDetails.containsKey(id)) {
            final cached = _cachedArtistDetails[id];

            if (cached != null) {
              return cached;
            }
          }

          final stored = Database.artistDetails.get(id);

          if (stored != null) {
            return _cachedArtistDetails[id] = Artist.fromJson(_deepConvert(stored) as Map<String, dynamic>);
          }
        }

        final artist = await SpotifyAuth.spotify.artists.get(id);
        _cachedArtistDetails[id] = artist;

        unawaited(Database.artistDetails.put(id, artist.toJson()));

        return artist;
      },

      onErrorMessage: "Une erreur s'est produite durant la récupération des détails des artistes",

      fallback: simpleArtist,
    );
  }

  static Future<Iterable<Artist>> getFollowedArtists({bool fromCache = true}) async {
    return Utils.tryCatch(
      () async {
        if (await App.isOffline()) fromCache = true;

        final result = _getFromCache<Artist>(
          fromCache,
          _cachedArtists,
          Database.followedArtists,
          Database.data,
          Artist.fromJson,
        );

        if (result != null) return result;

        _cachedArtists = await SpotifyAuth.spotify.me.following(FollowingType.artist).all();
        await _saveList(Database.followedArtists, Database.data, _cachedArtists);

        return _cachedArtists;
      },

      onErrorMessage: "Une erreur s'est produite durant la récupération des artistes",

      fallback: [],
    );
  }

  // #endregion

  static Future<Iterable<Track>> search(String query) async {
    return Utils.tryCatch(
      () async {
        if (await App.isOffline()) return [];

        final futures = List.generate(5, (i) {
          return SpotifyAuth.spotify.search.get(query, types: [SearchType.track]).getPage(10, i * 10);
        });

        final pages = await Future.wait(futures);

        return pages.expand((page) => page.expand((p) => p.items ?? [])).whereType<Track>();
      },

      onErrorMessage: "Une erreur s'est produite durant la recherche",

      fallback: [],
    );
  }

  // #region Private Methods

  static Iterable<T>? _getFromCache<T>(
    bool fromCache,
    Iterable<T> cached,
    Box box,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (fromCache) {
      if (cached.isNotEmpty) {
        return cached;
      }

      final stored = box.get(key);

      if (stored != null) {
        return _parseList(stored as List, fromJson);
      }
    }

    return null;
  }

  static Future<Iterable<Track>> _fetchTracks(String id) async {
    if (id == "liked") {
      return (await SpotifyAuth.spotify.me.tracks.saved().all()).map((t) => Utils.guard(t.track)).toList();
    }

    final tracks = await SpotifyAuth.spotify.playlists.getPlaylistTracks(id).all();

    return tracks.map((t) => Utils.guard(t.track)).toList();
  }

  static Future<void> _updateCache(String id, Track track, List<Track>? cached) async {
    if (cached == null || cached.any((t) => t.id == track.id)) return;

    cached.insert(0, track);

    _cachedPlaylistTracks[id] = cached;

    await _saveList(Database.tracks, id, cached);
  }

  static Future<void> _addTrackToPlaylist(String playlistId, String trackId, String trackUri) async {
    if (playlistId == "liked") {
      await SpotifyAuth.spotify.me.tracks.save([trackId]);
    } else {
      await SpotifyAuth.spotify.playlists.addTrack(trackUri, playlistId, position: 0);
    }
  }

  static dynamic _deepConvert(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries.map((e) => MapEntry(e.key as String, _deepConvert(e.value))),
      );
    }

    if (value is List) {
      return value.map(_deepConvert).toList();
    }

    return value;
  }

  static List<T> _parseList<T>(List stored, T Function(Map<String, dynamic>) fromJson) {
    return stored.map((e) => _deepConvert(e) as Map<String, dynamic>).map(fromJson).toList();
  }

  static Future<void> _saveList(Box box, String key, Iterable<dynamic> value) {
    return box.put(key, value.map((e) => e.toJson()).toList());
  }

  static Future<int> _fetchTotalLikedSongs() async {
    final page = await SpotifyAuth.spotify.me.tracks.saved().first(1);
    return page.metadata.total;
  }

  // #endregion
}
