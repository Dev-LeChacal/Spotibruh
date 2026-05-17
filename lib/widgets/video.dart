import "package:flutter/material.dart";
import "package:skeletonizer/skeletonizer.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/services/youtube.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/utils/duration.dart";
import "package:spotibruh/widgets/cover.dart";
import "package:spotibruh/widgets/pressable.dart";

class VideoWidget extends StatefulWidget {
  final YoutubeVideo video;
  final VoidCallback onPressed;
  final String? heroTag;

  const VideoWidget({super.key, required this.video, required this.onPressed, this.heroTag});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late final _duration = DurationUtils.formatDuration(widget.video.duration.inMilliseconds);
  late final _imageURL = widget.video.imageURL;

  Color _color = Colors.transparent;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;
    _loaded = true;

    _loadColor();
  }

  Future<void> _loadColor() async {
    final color = await ColorUtils.getColorForImage(_imageURL, 16);

    if (!mounted) return;

    setState(() {
      _color = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Pressable(
        onPressed: widget.onPressed,

        child: ClipRRect(
          borderRadius: App.borderRadius,

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(color: _color),

            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      spacing: 14,

      children: [
        Skeleton.replace(
          width: App.videoCoverWidth,
          height: App.videoCoverHeight,

          replacement: const Bone.square(borderRadius: App.imageBorderRadius),

          child: ClipRRect(
            borderRadius: App.imageBorderRadius,

            child: CoverWidget(
              imageURL: _imageURL,

              memWidth: App.videoCoverMemWidth,
              memHeight: App.videoCoverMemHeight,

              width: App.videoCoverWidth,
              height: App.videoCoverHeight,
            ),
          ),
        ),

        Expanded(
          child: _VideoInfo(title: widget.video.title, channel: widget.video.channel),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 4),

          child: Skeleton.ignore(
            child: Text(
              _duration,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                color: context.c.onSurface.withAlpha(160),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoInfo extends StatelessWidget {
  final String title;
  final String channel;

  const _VideoInfo({required this.title, required this.channel});

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(color: context.c.onSurface, fontSize: 16, fontWeight: FontWeight.bold);
    final channelStyle = TextStyle(fontSize: 14, color: context.c.onSurface.withAlpha(160));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 2,

      children: [
        Text(title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(channel, style: channelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
