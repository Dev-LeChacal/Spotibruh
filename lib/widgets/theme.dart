import "package:flutter/material.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/services/prefs.dart";
import "package:spotibruh/theme/app_theme.dart";
import "package:spotibruh/widgets/pressable.dart";

class ThemeWidget extends StatefulWidget {
  const ThemeWidget({super.key});

  @override
  State<ThemeWidget> createState() => _ThemeWidgetState();
}

class _ThemeWidgetState extends State<ThemeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: App.borderRadius, color: context.c.surfaceContainer),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      width: double.infinity,

      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = (constraints.maxWidth - 6 * 2) / 3;

          return Wrap(
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,

            runSpacing: 6,
            spacing: 6,

            children: AppTheme.values.map((t) => _buildColorSelector(t, App.theme.value, size)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector(AppTheme theme, AppTheme current, double size) {
    final isCurrent = theme == current;
    final color = theme.primary;
    final name = theme.name;

    return Pressable(
      onPressed: () async {
        App.theme.value = theme;
        await Prefs.theme.set(theme.index);

        setState(() {});
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        decoration: BoxDecoration(
          borderRadius: App.borderRadius,
          border: Border.all(color: color, width: isCurrent ? 4 : 1.5),
          color: context.c.surfaceContainer,
        ),

        width: size,
        height: size,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,

          children: [
            Container(
              width: 35,
              height: 35,

              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: theme.onPrimary, width: 2),
                shape: BoxShape.circle,
              ),
            ),

            FittedBox(
              fit: BoxFit.scaleDown,

              child: Text(
                name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
