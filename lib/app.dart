import "dart:math";

import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:internet_connection_checker_plus/internet_connection_checker_plus.dart";
import "package:skeletonizer/skeletonizer.dart";
import "package:spotibruh/router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/prefs.dart";
import "package:spotibruh/services/youtube.dart";
import "package:spotibruh/theme/app_theme.dart";
import "package:spotibruh/widgets/button.dart";
import "package:spotibruh/widgets/scaffold.dart";
import "package:spotify/spotify.dart";

abstract final class App {
  static Future<bool> isOffline() async {
    if (Prefs.offline.value) return true;
    return !await InternetConnection().hasInternetAccess;
  }

  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final theme = ValueNotifier<AppTheme>(AppTheme.purple);
  static const fontFamilly = "SNPro";

  static const borderRadius = BorderRadius.all(Radius.circular(20));
  static const imageBorderRadius = BorderRadius.all(Radius.circular(16));

  static const double trackCoverSize = 58;
  static const int trackCoverMemSize = 180;
  static const double trackWidgetHeight = 78;

  static const double videoCoverWidth = 100;
  static const double videoCoverHeight = 70;
  static const int videoCoverMemWidth = 200;
  static const int videoCoverMemHeight = 140;
  static const double videoWidgetHeight = 94;

  static const double widgetHeight = 40;

  static PlaylistSimple mockPlaylist(int index) {
    final random = Random(index);
    final playlistLength = random.nextInt(10) + 10;

    return PlaylistSimple()
      ..name = String.fromCharCodes(List.generate(playlistLength, (_) => random.nextInt(26) + 97));
  }

  static Artist mockArtist(int index) {
    final random = Random(index);
    final artistLength = random.nextInt(10) + 10;

    return Artist()..name = String.fromCharCodes(List.generate(artistLength, (_) => random.nextInt(26) + 97));
  }

  static Track mockTrack(int index) {
    final random = Random(index);
    final nameLength = random.nextInt(15) + 15;

    return Track()
      ..name = String.fromCharCodes(List.generate(nameLength, (_) => random.nextInt(26) + 97))
      ..artists = [mockArtist(index)];
  }

  static YoutubeVideo mockVideo(int index) {
    final random = Random(index);
    final titleLength = random.nextInt(15) + 15;
    final channelLength = random.nextInt(10) + 8;

    return YoutubeVideo(
      id: random.nextInt(1000000).toString(),
      title: String.fromCharCodes(List.generate(titleLength, (_) => random.nextInt(26) + 97)),
      channel: String.fromCharCodes(List.generate(channelLength, (_) => random.nextInt(26) + 97)),
      imageURL: "https://placehold.jp/150x150.png",
      duration: Duration(minutes: random.nextInt(5) + 2, seconds: random.nextInt(60)),
    );
  }

  static String getQueryForTrack(Track track) {
    return "${track.name} ${track.artists?.map((a) => a.name).join(", ")}";
  }

  static Widget buildContainer(Widget child, {double? width, double? height}) {
    return Container(
      decoration: BoxDecoration(borderRadius: App.borderRadius, color: App.theme.value.surfaceContainer),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      width: width,
      height: height,

      child: child,
    );
  }

  static Widget buildHorizontalList(
    bool isLoading,
    List<Widget> items,
    Widget Function(int) placeholder, {
    EdgeInsetsGeometry? padding,
    int itemCount = 10,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: SizedBox(
        height: 144,

        child: Skeletonizer(
          enabled: isLoading,

          child: Center(
            child: ListView.builder(
              shrinkWrap: true,
              padding: padding,

              scrollDirection: Axis.horizontal,
              itemCount: isLoading ? itemCount : items.length,

              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: isLoading ? placeholder(index) : items[index],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static final backButton = ButtonAction(
    widget: ButtonWidget(onPressed: router.pop, icon: HugeIconsSolid.arrowLeft01),
  );

  static final settingsButton = ButtonAction(
    widget: ButtonWidget(onPressed: () => router.push(Routes.settings), icon: HugeIconsSolid.settings01),
  );

  static const agent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36";
}
