import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/widgets/icon.dart";
import "package:spotibruh/widgets/loading.dart";
import "package:spotibruh/widgets/modal.dart";
import "package:spotibruh/widgets/pressable.dart";

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  final String? label;
  final IconData? icon;

  final bool isSecondary;
  final bool isDangerous;
  final bool isLoading;
  final bool isEnabled;

  const ButtonWidget({
    super.key,
    required this.onPressed,

    this.label,
    this.icon,

    this.isSecondary = false,
    this.isDangerous = false,
    this.isLoading = false,
    this.isEnabled = true,
  });

  bool get _isIcon => icon != null;

  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.easeInOut;

  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await Modal.show<bool>(
          "$label ?",
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,

            children: [
              ButtonWidget(onPressed: () => context.pop(true), label: "Oui"),
              ButtonWidget(onPressed: () => context.pop(false), label: "Non", isSecondary: true),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onPressed(BuildContext context) async {
    if (!isEnabled || isLoading) return;

    if (isDangerous) {
      final confirmed = await _showConfirmDialog(context);

      if (confirmed) {
        onPressed.call();
      }

      return;
    }

    onPressed.call();
  }

  Color _getButtonColor(BuildContext context) {
    return switch ((isEnabled, isDangerous, isSecondary, _isIcon)) {
      (false, _, _, _) => context.c.onInverseSurface,
      (_, true, _, _) => context.c.errorContainer,
      (_, _, true, _) => context.c.surfaceContainerHigh,
      (_, _, _, true) => context.c.surfaceContainer,
      _ => context.c.primary,
    };
  }

  Color _getTextColor(BuildContext context) {
    return switch ((isEnabled, isDangerous)) {
      (false, _) => context.c.outline,
      (_, true) => context.c.error,
      (_, false) => context.c.onPrimary,
    };
  }

  double _getSize(double fallback) {
    return _isIcon ? App.widgetHeight : fallback;
  }

  double _getHorizontalPadding() {
    return _isIcon ? 0 : 16;
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: () => _onPressed(context),
      hasFeedback: isEnabled || isLoading,

      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,

        padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding(), vertical: 8),

        width: _getSize(double.infinity),
        height: _getSize(48),

        decoration: BoxDecoration(color: _getButtonColor(context), borderRadius: App.borderRadius),

        child: Center(
          child: AnimatedSwitcher(
            duration: _duration,

            switchInCurve: _curve,
            switchOutCurve: _curve,

            layoutBuilder: (currentChild, previousChildren) {
              return Stack(alignment: Alignment.center, children: [...previousChildren, ?currentChild]);
            },

            transitionBuilder: (child, animation) {
              final isIncoming = animation.status != AnimationStatus.reverse;

              final slideAnimation = Tween<Offset>(
                begin: isIncoming ? const Offset(0, 0.5) : const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

              final fadeAnimation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

              final scaleAnimation = Tween<double>(
                begin: 0.6,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: ScaleTransition(scale: scaleAnimation, child: child),
                ),
              );
            },

            child: _buildChild(context),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    return isLoading ? _buildLoading() : _buildIconLabel(context);
  }

  Widget _buildLoading() {
    return const LoadingWidget(size: 24);
  }

  Widget _buildIconLabel(BuildContext context) {
    return _isIcon ? _buildIcon(context) : _buildLabel(context);
  }

  Widget _buildIcon(BuildContext context) {
    return IconWidget(icon: icon, color: _getTextColor(context));
  }

  Widget _buildLabel(BuildContext context) {
    return AnimatedDefaultTextStyle(
      style: TextStyle(
        fontFamily: App.fontFamilly,
        color: _getTextColor(context),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),

      duration: _duration,
      curve: _curve,

      child: Text(label ?? ""),
    );
  }
}
