import "package:flutter/material.dart";

class Dismissable extends StatefulWidget {
  final Widget child;
  final Function(DragEndDetails)? onDismiss;

  const Dismissable({super.key, required this.child, this.onDismiss});

  @override
  State<Dismissable> createState() => _DismissableState();
}

class _DismissableState extends State<Dismissable> {
  double _horizontalOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _horizontalOffset += details.delta.dx;
        });
      },

      onHorizontalDragEnd: widget.onDismiss,

      child: Transform.translate(
        offset: Offset(_horizontalOffset, 0),
        child: widget.child,
      ),
    );
  }
}
