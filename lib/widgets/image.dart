import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/widgets/container.dart";

class ImageWidget extends StatelessWidget {
  final String? imageURL;

  final int? memSize;
  final int? memWidth;
  final int? memHeight;

  final double? size;
  final double? width;
  final double? height;

  const ImageWidget({
    super.key,
    required this.imageURL,

    this.memSize,
    this.memWidth,
    this.memHeight,

    this.size,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return imageURL != null
        ? CachedNetworkImage(
            imageUrl: imageURL!,

            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),

            filterQuality: FilterQuality.high,

            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 200),

            width: width ?? size,
            height: height ?? size,

            memCacheWidth: memWidth ?? memSize,
            memCacheHeight: memHeight ?? memSize,

            placeholder: (_, _) => const CoverLoading(),
            errorWidget: (_, _, _) => const CoverPlaceholder(),
          )
        : const CoverPlaceholder();
  }
}

class CoverPlaceholder extends StatelessWidget {
  const CoverPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(borderRadius: App.borderRadius),
      child: Icon(HugeIconsSolid.wifiError01, size: 48, color: context.c.onError),
    );
  }
}

class CoverLoading extends StatelessWidget {
  const CoverLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContainerWidget();
  }
}
