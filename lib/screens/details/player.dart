import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:marquee/marquee.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/services/audio/audio.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/widgets/image.dart";
import "package:spotibruh/widgets/loading.dart";
import "package:spotibruh/widgets/pressable.dart";
import "package:spotibruh/widgets/scaffold.dart";
import "package:spotify/spotify.dart";
import "package:vibration/vibration.dart";

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late Track _track;
  String? _previousImageURL;

  Color _color = Colors.transparent;

  double? _dragValue;

  Future<void> _loadColor(String? imageURL) async {
    if (imageURL == null || imageURL == _previousImageURL) return;

    _previousImageURL = imageURL;

    final color = await ColorUtils.getColorForImage(imageURL, 16);

    if (mounted) {
      setState(() {
        _color = color;
      });
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, "0");
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();

    _track = audio.currentTrack!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Track?>(
      stream: audio.currentTrackStream,

      builder: (context, snapshot) {
        if (snapshot.data != null) {
          _track = snapshot.data!;
        }

        final imageURL = ImagesUtils.getBest(_track.album!.images!);
        final name = _track.name;
        final artists = _track.artists!.map((a) => a.name).join(", ");

        _loadColor(imageURL);

        return ScaffoldWidget(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,

            decoration: BoxDecoration(gradient: ColorUtils.getGradientForColor(_color)),

            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 100, bottom: 40),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,

                  children: [
                    _buildCover(imageURL!),

                    const Spacer(),

                    _buildTrackInfo(name, artists),

                    const Spacer(),

                    _buildControls(),
                    _buildProgressSlider(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCover(String imageURL) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),

      child: LayoutBuilder(
        builder: (_, constraints) {
          final size = constraints.maxWidth.clamp(0.0, 340.0);

          return Hero(
            tag: "player-${_track.id}",

            child: Pressable(
              child: Center(
                child: ClipRRect(
                  borderRadius: App.imageBorderRadius,

                  child: ImageWidget(size: size, memSize: 640, imageURL: imageURL),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackInfo(String? name, String artists) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Column(
        spacing: 2,

        children: [
          SizedBox(
            height: 32,

            child: LayoutBuilder(
              builder: (context, constraints) {
                final textPainter = TextPainter(
                  text: TextSpan(
                    text: name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                )..layout();

                final overflows = textPainter.width > constraints.maxWidth;

                return overflows
                    ? Marquee(
                        text: name ?? "",

                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),

                        pauseAfterRound: const Duration(seconds: 3),

                        blankSpace: 150,
                        velocity: 30,

                        accelerationCurve: Curves.easeIn,
                        accelerationDuration: const Duration(milliseconds: 1000),

                        decelerationCurve: Curves.easeOut,
                        decelerationDuration: const Duration(milliseconds: 1000),

                        showFadingOnlyWhenScrolling: false,
                        fadingEdgeEndFraction: 0.05,
                        fadingEdgeStartFraction: 0.05,

                        startAfter: const Duration(seconds: 1),
                      )
                    : Text(
                        name ?? "",
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      );
              },
            ),
          ),

          Text(
            artists,
            style: TextStyle(color: context.c.onSurface.withAlpha(160), fontSize: 16),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSlider() {
    return StreamBuilder<Duration?>(
      stream: audio.durationStream,
      builder: (_, durationSnapshot) {
        final realDuration = durationSnapshot.data;
        final duration = realDuration != null && realDuration.inMilliseconds > 0
            ? realDuration
            : _track.duration ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: audio.positionStream,
          builder: (_, snapshot) {
            final position = snapshot.data ?? Duration.zero;

            final sliderValue =
                (_dragValue ??
                        (duration.inMilliseconds > 0
                            ? position.inMilliseconds / duration.inMilliseconds
                            : 0.0))
                    .clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                spacing: 2,

                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,

                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),

                      activeTrackColor: context.c.onSurface,
                      inactiveTrackColor: context.c.onSurface.withAlpha(60),
                      thumbColor: context.c.onSurface,
                      overlayColor: context.c.onSurface.withAlpha(30),
                    ),

                    child: Slider(
                      value: sliderValue,

                      onChangeStart: (v) async {
                        setState(() => _dragValue = v);
                        await Vibration.vibrate(duration: 7);
                      },

                      onChanged: (v) {
                        setState(() => _dragValue = v);
                      },

                      onChangeEnd: (v) async {
                        await audio.seek(Duration(milliseconds: (v * duration.inMilliseconds).round()));

                        await Vibration.vibrate(duration: 7);

                        await Future.delayed(const Duration(milliseconds: 300));
                        setState(() => _dragValue = null);
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          _formatDuration(
                            _dragValue != null
                                ? Duration(milliseconds: (_dragValue! * duration.inMilliseconds).round())
                                : position,
                          ),
                          style: TextStyle(color: context.c.onSurface.withAlpha(160), fontSize: 12),
                        ),

                        Text(
                          _formatDuration(duration),
                          style: TextStyle(color: context.c.onSurface.withAlpha(160), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControls() {
    return StreamBuilder(
      stream: audio.playingStream,

      builder: (_, snapshot) {
        final isPlaying = snapshot.data ?? audio.isPlaying;
        final isLoading = audio.isDownloadingCurrent;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: App.widgetHeight,

          children: [
            Pressable(onPressed: audio.skipToPrevious, child: const Icon(HugeIconsSolid.previous, size: 24)),

            _buildPlayPauseButton(isPlaying, isLoading),

            Pressable(onPressed: audio.skipToNext, child: const Icon(HugeIconsSolid.next, size: 24)),
          ],
        );
      },
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

        replacement: const Center(child: LoadingWidget(size: 30)),

        child: Icon(icon, size: 45),
      ),
    );
  }
}
