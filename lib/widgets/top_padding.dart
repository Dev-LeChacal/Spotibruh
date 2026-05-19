import "package:flutter/material.dart";

class ScaffoldTopPadding extends InheritedWidget {
  final double padding;

  const ScaffoldTopPadding({super.key, required this.padding, required super.child});

  static double of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<ScaffoldTopPadding>();
    return widget?.padding ?? 60;
  }

  @override
  bool updateShouldNotify(ScaffoldTopPadding oldWidget) => padding != oldWidget.padding;
}
