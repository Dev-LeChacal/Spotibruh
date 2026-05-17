import "package:flutter/material.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/theme/app_theme.dart";

ThemeData buildTheme(AppTheme theme) => ThemeData(
  fontFamily: App.fontFamilly,
  useMaterial3: true,

  colorScheme: ColorScheme(
    brightness: Brightness.dark,

    primary: theme.primary,
    onPrimary: theme.onPrimary,
    primaryContainer: theme.primaryContainer,
    onPrimaryContainer: theme.onPrimaryContainer,

    secondary: theme.secondary,
    onSecondary: theme.onSecondary,
    secondaryContainer: theme.secondaryContainer,
    onSecondaryContainer: theme.onSecondaryContainer,

    surface: theme.surface,
    onSurface: theme.onSurface,
    surfaceContainerLow: theme.surfaceContainerLow,
    surfaceContainer: theme.surfaceContainer,
    surfaceContainerHigh: theme.surfaceContainerHigh,
    onSurfaceVariant: theme.onSurfaceVariant,

    error: theme.error,
    onError: theme.onError,
    errorContainer: theme.errorContainer,
    onErrorContainer: theme.onErrorContainer,

    outline: theme.outline,
    outlineVariant: theme.outlineVariant,

    shadow: theme.shadow,
    scrim: theme.scrim,

    inverseSurface: theme.inverseSurface,
    onInverseSurface: theme.onInverseSurface,
    inversePrimary: theme.inversePrimary,
  ),

  textTheme: Typography.material2021().white.apply(bodyColor: theme.onSurface, displayColor: theme.onSurface),
  iconTheme: IconThemeData(color: theme.onSurface),
);
