import "package:flutter/material.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/widgets/field.dart";
import "package:spotibruh/widgets/top_padding.dart";

class ScaffoldWidget extends StatefulWidget {
  final Widget body;
  final List<Widget> widgets;
  final Widget? topWidget;

  const ScaffoldWidget({super.key, required this.body, this.widgets = const [], this.topWidget});

  @override
  State<ScaffoldWidget> createState() => _ScaffoldWidgetState();
}

class _ScaffoldWidgetState extends State<ScaffoldWidget> {
  final topbarKey = GlobalKey();
  double _topPadding = 60;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant ScaffoldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final box = topbarKey.currentContext?.findRenderObject() as RenderBox?;

    if (box == null) return;

    setState(() => _topPadding = box.size.height + 16);
  }

  @override
  Widget build(BuildContext context) {
    final mappedWidgets = widget.widgets.map((e) {
      return switch (e) {
        FieldWidget widget => Expanded(child: widget),
        Widget widget => widget,
      };
    }).toList();

    final children = widget.widgets.isEmpty ? [App.backButton] : mappedWidgets;
    final hasExpanded = widget.widgets.any((e) => e is FieldWidget);

    return Scaffold(
      body: Stack(
        children: [
          ScaffoldTopPadding(padding: _topPadding, child: widget.body),

          Positioned(
            top: 8,
            left: 12,
            right: 12,

            child: SafeArea(
              key: topbarKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,

                children: [
                  ?widget.topWidget,

                  Row(
                    mainAxisSize: hasExpanded ? MainAxisSize.max : MainAxisSize.min,
                    spacing: 5,

                    children: children,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
