import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/widgets/card.dart";
import "package:spotify/spotify.dart";

class PlaylistWidget extends StatefulWidget {
  final PlaylistSimple playlist;
  final VoidCallback? onPressed;

  const PlaylistWidget({super.key, required this.playlist, this.onPressed});

  @override
  State<PlaylistWidget> createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<PlaylistWidget> {
  late final String? _imageURL = ImagesUtils.getMedium(widget.playlist.images);

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      heroTag: "playlist-image-${widget.playlist.id}",
      name: widget.playlist.name ?? "Sans nom",
      imageURL: _imageURL,

      onPressed: () {
        if (widget.onPressed != null) {
          widget.onPressed?.call();
        } else {
          context.push(Routes.details.playlist, extra: widget.playlist);
        }
      },
    );
  }
}
