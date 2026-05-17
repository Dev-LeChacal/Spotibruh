import "package:flutter/material.dart";
import "package:spotibruh/extensions.dart";

class LoadingWidget extends StatelessWidget {
  final double size;

  const LoadingWidget({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,

      child: CircularProgressIndicator(color: context.c.onSurface, strokeWidth: size / 8),
    );
  }
}
