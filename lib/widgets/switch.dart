import "package:flutter/material.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/utils/utils.dart";
import "package:spotibruh/widgets/pressable.dart";

class SwitchWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final bool defaultValue;
  final bool value;

  const SwitchWidget({super.key, this.onPressed = Utils.noop, this.defaultValue = false, this.value = false});

  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  static const duration = Duration(milliseconds: 200);
  static const curve = Curves.easeInOut;

  Color _getBackgroundColor() {
    return widget.value ? context.c.primary : context.c.surfaceContainerHigh;
  }

  Color _getThumbColor() {
    return widget.value ? context.c.onPrimary : context.c.outline;
  }

  Color _getBorderColor() {
    return widget.value ? Colors.transparent : context.c.outline;
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: widget.onPressed,
      hasAnimation: false,

      child: AnimatedContainer(
        duration: duration,
        curve: curve,

        padding: const EdgeInsets.all(4),

        height: 32,
        width: 70,

        decoration: BoxDecoration(
          borderRadius: App.borderRadius,
          border: Border.all(color: _getBorderColor(), width: 2),
          color: _getBackgroundColor(),
        ),

        child: _buildThumb(),
      ),
    );
  }

  Widget _buildThumb() {
    return AnimatedAlign(
      alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,

      duration: duration,
      curve: curve,

      child: AnimatedContainer(
        duration: duration,
        curve: curve,

        height: 32,
        width: 32,

        decoration: BoxDecoration(borderRadius: App.borderRadius, color: _getThumbColor()),
      ),
    );
  }
}
