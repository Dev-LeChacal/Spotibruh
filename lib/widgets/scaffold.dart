import "package:flutter/material.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/widgets/button.dart";
import "package:spotibruh/widgets/field.dart";

sealed class ScaffoldAction {}

class ButtonAction extends ScaffoldAction {
  final ButtonWidget widget;

  ButtonAction({required this.widget});
}

class FieldAction extends ScaffoldAction {
  final FieldWidget widget;

  FieldAction({required this.widget});
}

class ScaffoldWidget extends StatelessWidget {
  const ScaffoldWidget({super.key, required this.body, this.actions = const []});

  final Widget body;
  final List<ScaffoldAction> actions;

  @override
  Widget build(BuildContext context) {
    final mappedActions = actions.map((e) {
      return switch (e) {
        FieldAction action => Expanded(child: action.widget),
        ButtonAction action => action.widget,
      };
    }).toList();

    final children = actions.isEmpty ? [App.backButton.widget] : mappedActions;
    final hasField = actions.any((e) => e is FieldAction);

    return Scaffold(
      body: Stack(
        children: [
          body,

          Positioned(
            top: 8,
            left: 12,
            right: 12,

            child: SafeArea(
              child: Row(
                mainAxisSize: hasField ? MainAxisSize.max : MainAxisSize.min,
                spacing: 5,

                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
