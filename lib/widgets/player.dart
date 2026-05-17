import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/audio/audio.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/widgets/cover.dart";
import "package:spotibruh/widgets/loading.dart";
import "package:spotibruh/widgets/pressable.dart";
import "package:spotify/spotify.dart" hide Offset;

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String? _previousImageURL;

  Color _color = Colors.transparent;

  Future<void> _loadColor(String? imageURL) async {
    if (imageURL == null || imageURL == _previousImageURL) return;

    _previousImageURL = imageURL;

    final color = await ColorUtils.getColorForImage(imageURL, App.trackCoverMemSize);

    if (mounted) {
      setState(() {
        _color = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Track?>(
      stream: audio.currentTrackStream,

      builder: (context, snapshot) {
        final track = snapshot.data;

        if (track == null) return const SizedBox.shrink();

        final imageURL = ImagesUtils.getWorst(track.album?.images);
        final name = track.name;
        final artists = track.artists?.map((a) => a.name).join(", ") ?? "Artiste inconnu";

        _loadColor(imageURL);

        return Pressable(
          hasFeedback: false,

          onPressed: () {
            context.push(Routes.details.player);
          },

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,

            decoration: BoxDecoration(color: _color, borderRadius: App.borderRadius),

            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.symmetric(horizontal: 10),

            height: 68,

            child: Row(
              spacing: 12,

              children: [_buildCover(imageURL!, track), _buildTrackInfo(name, artists), _buildControls()],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCover(String imageURL, Track track) {
    return Hero(
      tag: "player-${track.id}",

      child: Pressable(
        onPressed: () {
          context.push(Routes.details.track, extra: track);
        },

        child: ClipRRect(
          borderRadius: App.imageBorderRadius,

          child: CoverWidget(size: App.trackCoverSize, memSize: App.trackCoverMemSize, imageURL: imageURL),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(String? name, String artists) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),

            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,

            layoutBuilder: (currentChild, previousChildren) {
              return Stack(alignment: Alignment.centerLeft, children: [...previousChildren, ?currentChild]);
            },

            transitionBuilder: (child, animation) {
              final isEntering = child.key == ValueKey("$name$artists");

              final slideIn = Tween<Offset>(
                begin: isEntering ? const Offset(0, 0.3) : const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(animation);

              final fastFade = CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
              );

              return FadeTransition(
                opacity: fastFade,
                child: SlideTransition(position: slideIn, child: child),
              );
            },

            child: Column(
              key: ValueKey("$name$artists"),
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  name ?? "Titre inconnu",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  artists,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.c.onSurface.withAlpha(180),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton(bool isPlaying, bool isLoading) {
    final icon = isPlaying ? HugeIconsSolid.pause : HugeIconsSolid.play;

    return Pressable(
      onPressed: () {
        if (isLoading) return;
        isPlaying ? audio.pause() : audio.play();
      },

      child: Visibility(
        visible: !isLoading,

        replacement: const SizedBox(width: 26, height: 26, child: Center(child: LoadingWidget())),

        child: Icon(icon, color: context.c.onSurface, size: 26),
      ),
    );
  }

  Widget _buildControls() {
    return StreamBuilder(
      stream: audio.playingStream,

      builder: (_, snapshot) {
        final data = snapshot.data;

        if (data == null) return const SizedBox.shrink();

        final isPlaying = data;
        final isLoading = audio.isDownloadingCurrent;

        return Padding(
          padding: const EdgeInsets.only(right: 4),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,

            children: [
              Pressable(
                onPressed: audio.skipToPrevious,
                child: Icon(HugeIconsSolid.previous, color: context.c.onSurface, size: 20),
              ),

              _buildPlayPauseButton(isPlaying, isLoading),

              Pressable(
                onPressed: audio.skipToNext,
                child: Icon(HugeIconsSolid.next, color: context.c.onSurface, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}
