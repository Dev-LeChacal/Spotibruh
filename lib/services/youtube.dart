import "dart:convert";

import "package:http/http.dart" as http;
import "package:spotibruh/app.dart";
import "package:spotify/spotify.dart";

class YoutubeVideo {
  final String id;
  final String title;
  final String channel;
  final String imageURL;
  final Duration duration;

  const YoutubeVideo({
    required this.id,
    required this.title,
    required this.channel,
    required this.imageURL,
    required this.duration,
  });
}

class YoutubeService {
  YoutubeService._();

  static final uri = Uri.parse("https://www.youtube.com/youtubei/v1/search?prettyPrint=false");

  static const _headers = {
    "Content-Type": "application/json",
    "Origin": "https://www.youtube.com",
    "Referer": "https://www.youtube.com/",
    "User-Agent": App.agent,
    "X-YouTube-Client-Name": "1",
    "X-YouTube-Client-Version": "2.20240101.00.00",
  };

  static Future<List<YoutubeVideo>> getVideos(String query) async {
    final response = await _fetch(query);

    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = _getItems(json);

    if (items == null || items.isEmpty) return [];

    return _parseVideos(items);
  }

  static Future<String?> getVideoId(Track track) async {
    final query = App.getQueryForTrack(track);
    final videos = await getVideos(query);

    return videos.firstOrNull?.id;
  }

  // #region Private Methods

  static Future<http.Response> _fetch(String query) async {
    return await http.post(uri, headers: _headers, body: _getBody(query));
  }

  static List<YoutubeVideo> _parseVideos(dynamic items) {
    return items.map((item) => _parseVideo(item)).whereType<YoutubeVideo>().toList();
  }

  static YoutubeVideo? _parseVideo(dynamic item) {
    final video = item["videoRenderer"];
    if (video == null) return null;

    final id = video["videoId"] as String?;
    final title = video["title"]?["runs"]?[0]?["text"] as String?;
    final channel = video["longBylineText"]?["runs"]?[0]?["text"] as String?;
    final imageURL = video["thumbnail"]?["thumbnails"]?[0]?["url"] as String?;
    final lengthText = video["lengthText"]?["simpleText"] as String?;

    if (id == null || title == null || channel == null || imageURL == null || lengthText == null) return null;

    return YoutubeVideo(
      id: id,
      title: title,
      channel: channel,
      imageURL: imageURL,
      duration: _parseDuration(lengthText),
    );
  }

  static Duration _parseDuration(String text) {
    final parts = text.split(":").map(int.parse).toList();
    return switch (parts.length) {
      3 => Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]),
      2 => Duration(minutes: parts[0], seconds: parts[1]),
      _ => Duration.zero,
    };
  }

  static List<dynamic>? _getItems(Map<String, dynamic> json) {
    final contents = json["contents"]?["twoColumnSearchResultsRenderer"]?["primaryContents"];
    final section = contents?["sectionListRenderer"]?["contents"]?[0]?["itemSectionRenderer"];
    return section?["contents"] as List?;
  }

  static String _getBody(String query) {
    return jsonEncode({
      "context": {
        "client": {"clientName": "WEB", "clientVersion": "2.20240101.00.00", "hl": "fr", "gl": "FR"},
      },
      "query": query,
      "params": "EgIQAQ==",
    });
  }

  // #endregion
}
