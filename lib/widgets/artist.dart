import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/widgets/card.dart";
import "package:spotify/spotify.dart";

class ArtistWidget extends StatefulWidget {
  final Artist artist;

  const ArtistWidget({super.key, required this.artist});

  @override
  State<ArtistWidget> createState() => _ArtistWidgetState();
}

class _ArtistWidgetState extends State<ArtistWidget> {
  late final String? _imageURL = ImagesUtils.getMedium(widget.artist.images);

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      heroTag: "artist-image-${widget.artist.id}",
      name: widget.artist.name ?? "Artiste inconnu",
      imageURL: _imageURL,

      onPressed: () {
        context.push(Routes.details.artist, extra: widget.artist);
      },
    );
  }
}
