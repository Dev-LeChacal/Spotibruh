import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:skeletonizer/skeletonizer.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/services/spotify.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/widgets/field.dart";
import "package:spotibruh/widgets/modal.dart";
import "package:spotibruh/widgets/playlist.dart";
import "package:spotibruh/widgets/scaffold.dart";
import "package:spotibruh/widgets/track.dart";
import "package:spotify/spotify.dart";

class SpotifySearchScreen extends StatefulWidget {
  final String query;

  const SpotifySearchScreen({super.key, required this.query});

  @override
  State<SpotifySearchScreen> createState() => _SpotifySearchScreenState();
}

class _SpotifySearchScreenState extends State<SpotifySearchScreen> {
  final _searchController = TextEditingController();

  bool _isLoading = true;
  List<Track> _tracks = [];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;

    search();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> search() async {
    setState(() {
      _isLoading = true;
    });

    final tracks = await SpotifyService.search(_searchController.text);

    await Future.wait(
      tracks.map((t) async {
        final url = ImagesUtils.getWorst(t.album?.images);

        if (url == null) return null;

        await precacheImage(
          CachedNetworkImageProvider(url, maxWidth: App.trackCoverMemSize, maxHeight: App.trackCoverMemSize),
          context,
        );

        return await ColorUtils.getColorForImage(url, App.trackCoverMemSize);
      }),
    );

    setState(() {
      _tracks = tracks.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      actions: [
        App.backButton,

        FieldAction(
          widget: FieldWidget(controller: _searchController, onSubmitted: (_) => search()),
        ),
      ],

      body: SafeArea(
        child: Skeletonizer(enabled: _isLoading, child: _buildTracksList()),
      ),
    );
  }

  Widget _buildTracksList() {
    return ListView.builder(
      itemExtent: App.trackWidgetHeight,
      itemCount: _isLoading ? 50 : _tracks.length,

      padding: const EdgeInsets.only(top: 60, bottom: 12, left: 12, right: 12),

      itemBuilder: (_, index) {
        final track = _isLoading ? App.mockTrack(index) : _tracks[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TrackWidget(
            key: ValueKey(_isLoading ? index : _tracks[index].id),

            heroTag: "track-image-${track.id}-$index",
            track: track,

            onPressed: () => _showModalBottomSheet(track),
          ),
        );
      },
    );
  }

  Future<void> _showModalBottomSheet(Track track) async {
    final playlists = await SpotifyService.getPlaylists().then((value) => value.toList());

    if (!mounted) return;

    await Modal.show(
      "Ajouter à une playlist",
      SizedBox(
        height: 180,

        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: playlists.length,

          itemBuilder: (_, index) {
            final playlist = playlists[index];

            return Padding(
              padding: const EdgeInsets.only(left: 8),

              child: PlaylistWidget(
                playlist: playlist,

                onPressed: () async {
                  context.pop();

                  await SpotifyService.addTrackToPlaylist(playlist, track);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
