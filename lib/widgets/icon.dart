import "package:flutter/material.dart";
import "package:spotibruh/extensions.dart";

class IconWidget extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final double size;

  const IconWidget({super.key, this.icon, this.color, this.size = 22});

  static const _duration = Duration(milliseconds: 400);
  static const _curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.c.onSurface;

    return AnimatedSwitcher(
      duration: _duration,

      switchInCurve: _curve,
      switchOutCurve: _curve,

      transitionBuilder: (child, animation) {
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        final scaleAnimation = Tween<double>(
          begin: 0.25,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },

      child: Icon(icon, key: ValueKey(icon), color: effectiveColor, size: size),
    );
  }
}
