import "package:hive_flutter/hive_flutter.dart";

class Database {
  Database._();

  static const data = "data";

  static late Box colors;
  static late Box playlists;
  static late Box tracks;
  static late Box artistDetails;
  static late Box followedArtists;
  static late Box preferences;

  static Future<void> init() async {
    await Hive.initFlutter();

    colors = await Hive.openBox("colors");
    playlists = await Hive.openBox("playlists");
    tracks = await Hive.openBox("tracks");
    artistDetails = await Hive.openBox("artist_details");
    followedArtists = await Hive.openBox("followed_artists");
    preferences = await Hive.openBox("preferences");
  }
}
