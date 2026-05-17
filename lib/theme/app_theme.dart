import "package:flutter/material.dart";

enum AppTheme {
  purple,
  blue,
  green,
  red,
  orange,
  pink,
  teal,
  gold;

  String get name => switch (this) {
    purple => "Violet",
    blue => "Bleu",
    green => "Vert",
    red => "Rouge",
    orange => "Orange",
    pink => "Rose",
    teal => "Teal",
    gold => "Or",
  };

  Color get primary => switch (this) {
    purple => const Color(0xFF6C63FF),
    blue => const Color(0xFF3D8EFF),
    green => const Color(0xFF3DCC7E),
    red => const Color(0xFFFF5C6C),
    orange => const Color(0xFFFF8C42),
    pink => const Color(0xFFFF6EB4),
    teal => const Color(0xFF00BCD4),
    gold => const Color(0xFFCCA830),
  };

  Color get onPrimary => const Color(0xFFFFFFFF);

  Color get primaryContainer => switch (this) {
    purple => const Color(0xFF8B85FF),
    blue => const Color(0xFF6AACFF),
    green => const Color(0xFF6DDDA0),
    red => const Color(0xFFFF8A94),
    orange => const Color(0xFFFFAA75),
    pink => const Color(0xFFFF9ECE),
    teal => const Color(0xFF4DD6E8),
    gold => const Color(0xFFE8C84A),
  };

  Color get onPrimaryContainer => switch (this) {
    purple => const Color(0xFF2A2240),
    blue => const Color(0xFF001A40),
    green => const Color(0xFF002A18),
    red => const Color(0xFF400010),
    orange => const Color(0xFF401A00),
    pink => const Color(0xFF400020),
    teal => const Color(0xFF002A30),
    gold => const Color(0xFF402E00),
  };

  Color get secondary => switch (this) {
    purple => const Color(0xFFF26CF5),
    blue => const Color(0xFF6CF0F5),
    green => const Color(0xFFA8F56C),
    red => const Color(0xFFFF9A3D),
    orange => const Color(0xFFFFD93D),
    pink => const Color(0xFFB46EFF),
    teal => const Color(0xFF6CFFB4),
    gold => const Color(0xFFFF9A3D),
  };

  Color get onSecondary => switch (this) {
    purple => const Color(0xFF1A001C),
    blue => const Color(0xFF001A1C),
    green => const Color(0xFF0A1C00),
    red => const Color(0xFF1C0800),
    orange => const Color(0xFF1C1000),
    pink => const Color(0xFF1A001C),
    teal => const Color(0xFF001C0E),
    gold => const Color(0xFF1C0800),
  };

  Color get secondaryContainer => switch (this) {
    purple => const Color(0xFF3A1A3F),
    blue => const Color(0xFF1A3A3F),
    green => const Color(0xFF2A3A1A),
    red => const Color(0xFF3F2A1A),
    orange => const Color(0xFF3F3A1A),
    pink => const Color(0xFF2A1A3F),
    teal => const Color(0xFF1A3F2A),
    gold => const Color(0xFF3F3A1A),
  };

  Color get onSecondaryContainer => switch (this) {
    purple => const Color(0xFFF9AAFB),
    blue => const Color(0xFFAAF5FB),
    green => const Color(0xFFD4FBAA),
    red => const Color(0xFFFBD4AA),
    orange => const Color(0xFFFBF0AA),
    pink => const Color(0xFFD4AAFB),
    teal => const Color(0xFFAAFBD4),
    gold => const Color(0xFFFBF0AA),
  };

  Color get inversePrimary => switch (this) {
    purple => const Color(0xFF4A40CC),
    blue => const Color(0xFF1A5FCC),
    green => const Color(0xFF1A9950),
    red => const Color(0xFFCC1A2E),
    orange => const Color(0xFFCC5A1A),
    pink => const Color(0xFFCC1A7A),
    teal => const Color(0xFF008FA6),
    gold => const Color(0xFFCCA800),
  };

  Color get surface => switch (this) {
    purple => const Color(0xFF0F0F1A),
    blue => const Color(0xFF0D0F1C),
    green => const Color(0xFF0F1610),
    red => const Color(0xFF1A0F0F),
    orange => const Color(0xFF1A100D),
    pink => const Color(0xFF1A0F14),
    teal => const Color(0xFF0D1A1A),
    gold => const Color(0xFF1A160D),
  };

  Color get surfaceContainerLow => switch (this) {
    purple => const Color(0xFF141424),
    blue => const Color(0xFF12142A),
    green => const Color(0xFF141A15),
    red => const Color(0xFF1F1414),
    orange => const Color(0xFF1F1712),
    pink => const Color(0xFF1F1419),
    teal => const Color(0xFF121F1F),
    gold => const Color(0xFF1F1B12),
  };

  Color get surfaceContainer => switch (this) {
    purple => const Color(0xFF181828),
    blue => const Color(0xFF16182E),
    green => const Color(0xFF181E19),
    red => const Color(0xFF221818),
    orange => const Color(0xFF221A15),
    pink => const Color(0xFF22181C),
    teal => const Color(0xFF152222),
    gold => const Color(0xFF221E15),
  };

  Color get surfaceContainerHigh => switch (this) {
    purple => const Color(0xFF1E1E35),
    blue => const Color(0xFF1C1E38),
    green => const Color(0xFF1E2420),
    red => const Color(0xFF281E1E),
    orange => const Color(0xFF28201A),
    pink => const Color(0xFF281E22),
    teal => const Color(0xFF1A2828),
    gold => const Color(0xFF28241A),
  };

  Color get outline => switch (this) {
    purple => const Color(0xFF5A5A8A),
    blue => const Color(0xFF5A5F8A),
    green => const Color(0xFF5A8A5F),
    red => const Color(0xFF8A5A5A),
    orange => const Color(0xFF8A705A),
    pink => const Color(0xFF8A5A70),
    teal => const Color(0xFF5A8A8A),
    gold => const Color(0xFF8A7A5A),
  };

  Color get outlineVariant => switch (this) {
    purple => const Color(0xFF2E2E50),
    blue => const Color(0xFF2E3250),
    green => const Color(0xFF2E5032),
    red => const Color(0xFF502E2E),
    orange => const Color(0xFF503C2E),
    pink => const Color(0xFF502E3C),
    teal => const Color(0xFF2E5050),
    gold => const Color(0xFF50462E),
  };

  Color get onSurfaceVariant => switch (this) {
    purple => const Color(0xFF9090B8),
    blue => const Color(0xFF9095B8),
    green => const Color(0xFF90B895),
    red => const Color(0xFFB89090),
    orange => const Color(0xFFB8A090),
    pink => const Color(0xFFB890A0),
    teal => const Color(0xFF90B8B8),
    gold => const Color(0xFFB8AE90),
  };

  Color get onSurface => const Color(0xFFE8E8FF);

  Color get error => const Color(0xFFFF6B6B);
  Color get onError => const Color(0xFF3B0000);
  Color get errorContainer => const Color(0xFF6B1A1A);
  Color get onErrorContainer => const Color(0xFFFFB4AB);

  Color get shadow => const Color(0xFF000000);
  Color get scrim => const Color(0xFF000000);

  Color get inverseSurface => const Color(0xFFE8E8FF);
  Color get onInverseSurface => const Color(0xFF1E1E35);
}
