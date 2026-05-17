import "package:flutter/material.dart";
import "package:skeletonizer/skeletonizer.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/widgets/cover.dart";
import "package:spotibruh/widgets/pressable.dart";

class CardWidget extends StatelessWidget {
  final String name;
  final String heroTag;
  final VoidCallback onPressed;
  final String? imageURL;

  const CardWidget({
    super.key,
    required this.name,
    required this.heroTag,
    required this.onPressed,
    this.imageURL,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,

      child: SizedBox(
        width: 120,

        child: Column(
          spacing: 4,

          children: [
            Skeleton.replace(
              width: 120,
              height: 120,

              replacement: const Bone.square(borderRadius: App.borderRadius),

              child: Hero(
                tag: heroTag,

                child: Container(
                  height: 120,
                  width: 120,

                  decoration: const BoxDecoration(borderRadius: App.borderRadius),

                  child: ClipRRect(
                    borderRadius: App.borderRadius,

                    child: CoverWidget(size: 120, memSize: 320, imageURL: imageURL),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),

              child: Text(
                name,

                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,

                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
