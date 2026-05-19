import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:skeletonizer/skeletonizer.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/utils/duration.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/widgets/image.dart";
import "package:spotibruh/widgets/pressable.dart";
import "package:spotify/spotify.dart";

class TrackWidget extends StatefulWidget {
  final Track track;
  final VoidCallback onPressed;
  final String? heroTag;

  const TrackWidget({super.key, required this.track, required this.onPressed, this.heroTag});

  @override
  State<TrackWidget> createState() => _TrackWidgetState();
}

class _TrackWidgetState extends State<TrackWidget> {
  late final String? _imageURL = ImagesUtils.getWorst(widget.track.album?.images);
  late final String _duration = DurationUtils.formatDuration(widget.track.durationMs ?? 0);

  Color _color = Colors.transparent;

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded || _imageURL == null) return;
    _loaded = true;

    _loadColor();
  }

  Future<void> _loadColor() async {
    final color = await ColorUtils.getColorForImage(_imageURL!, 16);

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
          width: App.trackCoverSize,
          height: App.trackCoverSize,

          replacement: const Bone.square(borderRadius: App.imageBorderRadius),

          child: Hero(
            tag: widget.heroTag ?? "track-image-${widget.track.id}",

            child: Pressable(
              onPressed: () => context.push(Routes.details.track, extra: widget.track),

              child: ClipRRect(
                borderRadius: App.imageBorderRadius,

                child: ImageWidget(
                  size: App.trackCoverSize,
                  memSize: App.trackCoverMemSize,
                  imageURL: _imageURL,
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: _TrackInfo(
            name: widget.track.name ?? "Inconnu",
            artists: widget.track.artists?.map((a) => a.name).join(", ") ?? "Artiste inconnu",
          ),
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

class _TrackInfo extends StatelessWidget {
  final String name;
  final String artists;

  const _TrackInfo({required this.name, required this.artists});

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(color: context.c.onSurface, fontSize: 16, fontWeight: FontWeight.bold);
    final artistStyle = TextStyle(fontSize: 14, color: context.c.onSurface.withAlpha(160));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 2,

      children: [
        Text(name, style: nameStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(artists, style: artistStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
