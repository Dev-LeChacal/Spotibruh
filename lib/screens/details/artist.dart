import "package:flutter/material.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/widgets/cover.dart";
import "package:spotibruh/widgets/pressable.dart";
import "package:spotibruh/widgets/scaffold.dart";
import "package:spotify/spotify.dart";

class ArtistScreen extends StatefulWidget {
  final Artist artist;

  const ArtistScreen({super.key, required this.artist});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  late final String? _imageURL = ImagesUtils.getBest(widget.artist.images);

  Color _color = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _loadColor();
  }

  Future<void> _loadColor() async {
    if (_imageURL == null) return;

    final color = await ColorUtils.getColorForImage(_imageURL, 16);

    if (mounted) {
      setState(() {
        _color = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,

        decoration: BoxDecoration(gradient: ColorUtils.getGradientForColor(_color)),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),

            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,

                    children: [_buildCover(), _buildTrackInfo(widget.artist.name)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Hero(
      tag: "artist-image-${widget.artist.id}",

      child: Pressable(
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),

            child: CoverWidget(size: 340, memSize: 640, imageURL: _imageURL),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(String? name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),

      child: Text(
        name ?? "Artiste inconnu",

        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),

        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
