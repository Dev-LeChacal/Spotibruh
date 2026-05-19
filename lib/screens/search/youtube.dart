import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:skeletonizer/skeletonizer.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/services/youtube.dart";
import "package:spotibruh/utils/color.dart";
import "package:spotibruh/widgets/field.dart";
import "package:spotibruh/widgets/scaffold.dart";
import "package:spotibruh/widgets/video.dart";

class YoutubeSearchScreen extends StatefulWidget {
  final String query;

  const YoutubeSearchScreen({super.key, required this.query});

  @override
  State<YoutubeSearchScreen> createState() => _YoutubeSearchScreenState();
}

class _YoutubeSearchScreenState extends State<YoutubeSearchScreen> {
  final _searchController = TextEditingController();

  bool _isLoading = true;
  List<YoutubeVideo> _videos = [];

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

    final videos = await YoutubeService.getVideos(_searchController.text);

    await Future.wait(
      videos.map((v) async {
        await precacheImage(
          CachedNetworkImageProvider(
            v.imageURL,
            maxWidth: App.videoCoverMemWidth,
            maxHeight: App.videoCoverMemHeight,
          ),
          context,
        );

        return await ColorUtils.getColorForImage(
          v.imageURL,
          0,
          maxWidth: App.videoCoverMemWidth,
          maxHeight: App.videoCoverMemHeight,
        );
      }),
    );

    setState(() {
      _videos = videos.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      widgets: [
        App.backButton,

        FieldWidget(controller: _searchController, onSubmitted: (_) => search()),
      ],

      body: SafeArea(
        child: Skeletonizer(enabled: _isLoading, child: _buildTracksList()),
      ),
    );
  }

  Widget _buildTracksList() {
    return ListView.builder(
      itemCount: _isLoading ? 50 : _videos.length,
      itemExtent: App.videoWidgetHeight,

      padding: const EdgeInsets.only(top: 60, bottom: 12, left: 10, right: 10),

      itemBuilder: (_, index) {
        final video = _isLoading ? App.mockVideo(index) : _videos[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),

          child: VideoWidget(
            key: ValueKey(_isLoading ? index : _videos[index].id),
            video: video,

            onPressed: () => context.pop(video.id),
          ),
        );
      },
    );
  }
}
