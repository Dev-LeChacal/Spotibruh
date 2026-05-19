import "package:flutter/material.dart";
import "package:skeletonizer/skeletonizer.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/widgets/container.dart";
import "package:spotibruh/widgets/image.dart";
import "package:spotibruh/widgets/pressable.dart";
import "package:spotify/spotify.dart";

class UserWidget extends StatelessWidget {
  final String? imageURL;
  final bool isLoading;
  final User user;

  const UserWidget({super.key, required this.isLoading, required this.imageURL, required this.user});

  @override
  Widget build(BuildContext context) {
    return Skeleton.replace(
      replace: isLoading,

      replacement: const ContainerWidget(padding: EdgeInsets.symmetric(horizontal: 12), height: 56),

      child: Pressable(
        child: ContainerWidget(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          height: 56,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,

            children: [
              ClipRRect(
                borderRadius: App.avatarBorderRadius,
                child: ImageWidget(imageURL: imageURL, size: 44),
              ),

              Text(
                "Salut ${user.displayName}, quoi de neuf ?",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
