import "dart:io";

import "package:path_provider/path_provider.dart";

class PathUtils {
  PathUtils._();

  static Future<File> getTrackFile(String id) async {
    final path = await getTrackPath(id);
    return File(path);
  }

  static Future<String> getTrackPath(String id) async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/$id.webm";
  }

  static Future<bool> isTrackDownloaded(String id) async {
    return (await getTrackFile(id)).existsSync();
  }
}
