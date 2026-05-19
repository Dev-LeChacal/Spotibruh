import "package:flutter/material.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/extensions.dart";

class ContainerWidget extends StatelessWidget {
  final Widget? child;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ContainerWidget({
    super.key,

    this.child,

    this.width,
    this.height,

    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.margin = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: App.borderRadius, color: context.c.surfaceContainer),

      padding: padding,
      margin: margin,

      width: width,
      height: height,

      child: child,
    );
  }
}
