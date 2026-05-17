import "package:flutter/material.dart";

extension ThemeContext on BuildContext {
  ColorScheme get c => Theme.of(this).colorScheme;
}
