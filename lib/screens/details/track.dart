import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/audio/audio.dart";
import "package:spotibruh/services/downloader.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/services/spotify.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/utils/path.dart";
import "package:spotibruh/utils/utils.dart";
import "package:spotibruh/widgets/artist.dart";
import "package:spotibruh/widgets/button.dart";
import "package:spotibruh/widgets/cover.dart";
import "package:spotibruh/widgets/pressable.dart";
import "package:spotibruh/widgets/scaffold.dart";
import "package:spotify/spotify.dart";

class TrackScreen extends StatefulWidget {
  final Track track;

  const TrackScreen({super.key, required this.track});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  late final String? _imageURL = ImagesUtils.getBest(widget.track.album?.images);

  Color _color = Colors.transparent;
  bool _isDownloaded = false;

  List<Artist> _artists = [];
  bool _isLoadingArtists = false;

  @override
  void initState() {
    super.initState();

    _loadColor();
    _checkIfDownloaded();
    _loadArtists();
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

  Future<void> _checkIfDownloaded() async {
    final id = Utils.guard(widget.track.id);
    final isDownloaded = await PathUtils.isTrackDownloaded(id);

    setState(() {
      _isDownloaded = isDownloaded;
    });
  }

  Future<void> _loadArtists() async {
    if (widget.track.artists == null) return;

    setState(() {
      _isLoadingArtists = true;
      _artists = widget.track.artists ?? [];
    });

    final artists = await Future.wait(
      widget.track.artists!.map((simpleArtist) => SpotifyService.getArtistDetails(simpleArtist)),
    );

    setState(() {
      _artists = artists;
      _isLoadingArtists = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,

        constraints: const BoxConstraints.expand(),

        decoration: BoxDecoration(gradient: ColorUtils.getGradientForColor(_color)),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 60, bottom: 20),

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,

                children: [_buildCover(), _buildName(), _buildArtists(), _buildButtons()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Hero(
      tag: "track-image-${widget.track.id}",

      child: Pressable(
        child: Center(
          child: ClipRRect(
            borderRadius: App.imageBorderRadius,

            child: CoverWidget(size: 340, memSize: 640, imageURL: _imageURL),
          ),
        ),
      ),
    );
  }

  Widget _buildName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),

      child: Text(
        widget.track.name ?? "Titre inconnu",
        style: TextStyle(color: context.c.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildArtists() {
    return App.buildHorizontalList(
      _isLoadingArtists,
      _artists.map((a) => ArtistWidget(artist: a, key: ValueKey(a.id ?? ""))).toList(),
      (index) => ArtistWidget(artist: App.mockArtist(index)),
      itemCount: _artists.length,
    );
  }

  Widget _buildButtons() {
    return Column(spacing: 8, children: [_buildDownloadPlayButton(), _buildDownloadFromDeleteButton()]);
  }

  Widget _buildDownloadPlayButton() {
    return ButtonWidget(
      onPressed: () async {
        if (_isDownloaded) {
          await audio.playPlaylist([widget.track]);
        } else {
          await Downloader.downloadTrack(widget.track);
        }

        await _checkIfDownloaded();
      },

      label: _isDownloaded ? "Écouter" : "Télécharger",
    );
  }

  Widget _buildDownloadFromDeleteButton() {
    return ButtonWidget(
      onPressed: () async {
        final id = Utils.guard(widget.track.id);
        final name = Utils.guard(widget.track.name);

        if (_isDownloaded) {
          await Downloader.deleteTrack(id, name);

          // select video
        } else {
          final id = await context.push<String?>(
            Routes.search.youtube,
            extra: App.getQueryForTrack(widget.track),
          );

          if (id == null) return;

          await Downloader.downloadTrack(widget.track, customId: id);
        }

        await _checkIfDownloaded();
      },

      isDangerous: _isDownloaded,
      isSecondary: true,

      label: _isDownloaded ? "Supprimer" : "Télécharger depuis une vidéo",
    );
  }
}
