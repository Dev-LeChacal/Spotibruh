import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:marquee/marquee.dart";
import "package:skeletonizer/skeletonizer.dart";
import "package:spotibruh/services/audio/audio.dart";
import "package:spotibruh/services/storage/prefs.dart";
import "package:spotibruh/services/spotify.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/utils/images.dart";
import "package:spotibruh/widgets/button.dart";
import "package:spotibruh/widgets/image.dart";
import "package:spotibruh/widgets/field.dart";
import "package:spotibruh/widgets/pressable.dart";
import "package:spotibruh/widgets/scaffold.dart";
import "package:spotibruh/widgets/track.dart";
import "package:spotify/spotify.dart";

class PlaylistScreen extends StatefulWidget {
  final PlaylistSimple playlist;

  const PlaylistScreen({super.key, required this.playlist});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _infoText;

  bool _isLoading = true;
  bool _isShuffling = false;
  bool _titleOverflows = false;

  Color _color = Colors.transparent;

  List<Track> _tracks = [];
  List<Track> _searchedTracks = [];

  late final String? _imageURL = ImagesUtils.getBest(widget.playlist.images);

  @override
  void initState() {
    super.initState();
    _getPreferences();
    _loadColor();
    _loadTracks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final painter = TextPainter(
        text: TextSpan(
          text: widget.playlist.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: context.size!.width);

      setState(() => _titleOverflows = painter.didExceedMaxLines);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getPreferences() async {
    final bool isShuffling = Prefs.isShuffling.value;

    if (mounted) {
      setState(() => _isShuffling = isShuffling);
      audio.setShuffleEnabled(_isShuffling);
    }
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

  Future<void> _loadTracks({bool fromCache = true}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _infoText = "Chargement des chansons";
      });
    }

    final tracks = await SpotifyService.getPlaylistTracks(widget.playlist, fromCache: fromCache);

    if (mounted) {
      setState(() {
        _infoText = "Chargement des ressources";
      });
    }

    await Future.wait(
      tracks.map((t) async {
        final url = ImagesUtils.getWorst(t.album?.images);

        if (url == null || !mounted) return null;

        await precacheImage(
          CachedNetworkImageProvider(url, maxWidth: App.trackCoverMemSize, maxHeight: App.trackCoverMemSize),
          context,
        );

        return await ColorUtils.getColorForImage(url, App.trackCoverMemSize);
      }),
    );

    if (mounted) {
      setState(() {
        _tracks = tracks.toList();
        _searchedTracks = _tracks;
        _isLoading = false;
        _infoText = null;
      });
    }
  }

  void _playPlaylist({Track? track}) async {
    if (_isLoading || _searchedTracks.isEmpty) return;
    await audio.playPlaylist(_tracks, track: track);
  }

  Future<void> _toggleShuffle() async {
    setState(() => _isShuffling = !_isShuffling);
    audio.setShuffleEnabled(_isShuffling);

    await Prefs.isShuffling.set(_isShuffling);
  }

  void _onSearch(String q) {
    setState(() {
      _searchedTracks = q.isEmpty
          ? _tracks
          : _tracks.where((t) => t.name?.toLowerCase().contains(q.toLowerCase()) == true).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,

        decoration: BoxDecoration(gradient: ColorUtils.getGradientForColor(_color)),

        child: RefreshIndicator(
          onRefresh: () => _loadTracks(fromCache: false),
          displacement: 50,
          elevation: 0,

          child: CustomScrollView(slivers: [_buildSliverAppBar(), _buildTracks()]),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 380,
      automaticallyImplyLeading: false,

      backgroundColor: Colors.transparent,

      flexibleSpace: FlexibleSpaceBar(background: Stack(children: [_buildImage(), _buildHeader()])),
    );
  }

  Widget _buildImage() {
    return PlaylistImage(imageURL: _imageURL, id: widget.playlist.id!);
  }

  Widget _buildHeader() {
    late final text = _infoText ?? widget.playlist.name;

    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,

      child: Column(
        spacing: 8,

        children: [
          SizedBox(
            height: App.widgetHeight,

            child: _titleOverflows && _infoText == null
                ? Marquee(
                    text: text ?? "",

                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

                    pauseAfterRound: const Duration(seconds: 5),

                    blankSpace: 150,
                    velocity: 30,

                    accelerationCurve: Curves.easeIn,
                    accelerationDuration: const Duration(milliseconds: 1000),

                    decelerationCurve: Curves.easeOut,
                    decelerationDuration: const Duration(milliseconds: 1000),

                    showFadingOnlyWhenScrolling: false,
                    fadingEdgeEndFraction: 0.05,
                    fadingEdgeStartFraction: 0.05,

                    startPadding: 10,
                    startAfter: const Duration(seconds: 1),
                  )
                : Text(text ?? "", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),

          Skeletonizer(
            enabled: _isLoading,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,

              children: [
                Skeleton.replace(
                  replacement: const Bone.iconButton(size: App.widgetHeight, borderRadius: App.borderRadius),

                  child: ButtonWidget(
                    onPressed: _toggleShuffle,
                    icon: _isShuffling ? HugeIconsSolid.shuffleSquare : HugeIconsSolid.shuffle,
                  ),
                ),

                Skeleton.replace(
                  replacement: const Bone.iconButton(size: App.widgetHeight, borderRadius: App.borderRadius),

                  child: ButtonWidget(onPressed: _playPlaylist, icon: HugeIconsSolid.play),
                ),

                Expanded(
                  child: Skeleton.replace(
                    replacement: const Bone.button(
                      height: App.widgetHeight,
                      width: double.infinity,
                      borderRadius: App.borderRadius,
                    ),

                    child: FieldWidget(
                      controller: _searchController,
                      onChanged: _onSearch,
                      hintText: "Rechercher dans la playlist",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracks() {
    if (_isLoading) {
      return Skeletonizer.sliver(child: _buildTracksList());
    }

    return _buildTracksList();
  }

  Widget _buildTracksList() {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 40),

      sliver: SliverFixedExtentList(
        itemExtent: App.trackWidgetHeight,

        delegate: SliverChildBuilderDelegate(
          childCount: _isLoading ? widget.playlist.tracksLink?.total : _searchedTracks.length,
          (_, index) {
            final track = _isLoading ? App.mockTrack(index) : _searchedTracks[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 10, right: 10),

              child: TrackWidget(
                key: ValueKey(track.id),
                track: track,
                onPressed: () => _playPlaylist(track: track),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PlaylistImage extends StatelessWidget {
  final String? imageURL;
  final String id;

  const PlaylistImage({super.key, required this.imageURL, required this.id});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, _) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 80),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220, maxHeight: 220),

              child: Hero(
                tag: "playlist-image-$id",

                child: Pressable(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),

                    child: ImageWidget(size: 220, memSize: 512, imageURL: imageURL),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
