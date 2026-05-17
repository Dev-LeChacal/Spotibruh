import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/spotify.dart";
import "package:spotibruh/widgets/button.dart";
import "package:spotibruh/widgets/field.dart";
import "package:spotibruh/widgets/artist.dart";
import "package:spotibruh/widgets/messenger.dart";
import "package:spotibruh/widgets/modal.dart";
import "package:spotibruh/widgets/player.dart";
import "package:spotibruh/widgets/playlist.dart";
import "package:spotibruh/widgets/scaffold.dart";
import "package:spotify/spotify.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isPlaylistsLoading = true;
  List<PlaylistSimple> _playlists = [];

  bool _isArtistsLoading = true;
  List<Artist> _artists = [];

  @override
  void initState() {
    super.initState();
    _loadFromCache();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFromCache() async {
    await Future.wait([_fetchUserPlaylists(), _fetchFollowedArtists()]);
  }

  Future<void> _loadFromSpotify() async {
    await Future.wait([_fetchUserPlaylists(fromCache: false), _fetchFollowedArtists(fromCache: false)]);
  }

  Future<void> _fetchUserPlaylists({bool fromCache = true}) async {
    if (mounted) setState(() => _isPlaylistsLoading = true);

    final playlists = await SpotifyService.getPlaylists(fromCache: fromCache);

    if (mounted) {
      setState(() {
        _playlists = playlists.toList();
        _isPlaylistsLoading = false;
      });
    }
  }

  Future<void> _fetchFollowedArtists({bool fromCache = true}) async {
    if (mounted) setState(() => _isArtistsLoading = true);

    final artists = await SpotifyService.getFollowedArtists(fromCache: fromCache);

    if (mounted) {
      setState(() {
        _artists = artists.toList();
        _isArtistsLoading = false;
      });
    }
  }

  Future<void> _showCreatePlaylistModal() async {
    if (await App.isOffline()) {
      return Messenger.show("Impossible en mode hors ligne", type: MessageType.warning);
    }

    final result = await Modal.show<(String, String)>("Nouvelle playlist", const _CreatePlaylistForm());

    if (result == null) return;

    final name = result.$1;
    final description = result.$2;

    if (name.isEmpty) return;

    await SpotifyService.createPlaylist(name, description);
    await _loadFromCache();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      actions: [
        App.settingsButton,

        FieldAction(
          widget: FieldWidget(
            controller: _searchController,
            hintText: "Rechercher un artiste, une chanson",

            onSubmitted: (query) async {
              if (query.isEmpty) return;

              await context.push(Routes.search.spotify, extra: query);
              _searchController.clear();
            },
          ),
        ),

        ButtonAction(
          widget: ButtonWidget(onPressed: _showCreatePlaylistModal, icon: HugeIconsSolid.playListAdd),
        ),
      ],

      body: Padding(
        padding: const EdgeInsets.only(top: 60),

        child: SizedBox(
          height: double.infinity,

          child: SafeArea(
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) => notification.depth > 0,

                  child: RefreshIndicator(
                    onRefresh: _loadFromSpotify,

                    child: SizedBox(
                      width: double.infinity,

                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,

                          children: [
                            _buildTitle("Playlists"),
                            _buildPlaylists(),

                            _buildTitle("Artistes suivis"),
                            _buildArtists(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const Positioned(left: 0, right: 0, bottom: 16, child: SafeArea(child: PlayerWidget())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      width: double.infinity,

      child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPlaylists() {
    return App.buildHorizontalList(
      _isPlaylistsLoading,
      _playlists.map((p) => PlaylistWidget(playlist: p, key: ValueKey(p.id ?? ""))).toList(),
      (index) => PlaylistWidget(playlist: App.mockPlaylist(index)),
      padding: const EdgeInsets.only(left: 16),
    );
  }

  Widget _buildArtists() {
    return App.buildHorizontalList(
      _isArtistsLoading,
      _artists.map((a) => ArtistWidget(artist: a, key: ValueKey(a.id ?? ""))).toList(),
      (index) => ArtistWidget(artist: App.mockArtist(index)),
      padding: const EdgeInsets.only(left: 16),
    );
  }
}

class _CreatePlaylistForm extends StatefulWidget {
  const _CreatePlaylistForm();

  @override
  State<_CreatePlaylistForm> createState() => _CreatePlaylistFormState();
}

class _CreatePlaylistFormState extends State<_CreatePlaylistForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _onCreatePressed() {
    context.pop((_nameController.text.trim(), _descriptionController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,

      children: [
        FieldWidget(controller: _nameController, hintText: "Un nom"),
        FieldWidget(controller: _descriptionController, hintText: "Une description (optionnelle)"),
        ButtonWidget(onPressed: _onCreatePressed, label: "Créer"),
      ],
    );
  }
}
