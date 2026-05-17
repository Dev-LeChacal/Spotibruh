import "dart:developer";
import "dart:math" hide log;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:spotibruh/extensions.dart";
import "package:spotibruh/router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/audio/audio.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/services/prefs.dart";
import "package:spotibruh/widgets/dismissable.dart";

enum MessageType {
  info(label: "INFO  ", ansiCode: "\x1B[31m"),
  success(label: "SUCCESS", ansiCode: "\x1B[32m"),
  warning(label: "WARNING", ansiCode: "\x1B[33m"),
  error(label: "ERROR  ", ansiCode: "\x1B[37m");

  const MessageType({required this.label, required this.ansiCode});

  final String label;
  final String ansiCode;

  Color color(BuildContext context) => switch (this) {
    info => context.c.onSurface,
    success => context.c.secondary,
    warning => context.c.errorContainer,
    error => context.c.error,
  };
}

class Messenger {
  Messenger._();

  static final List<OverlayEntry> _entries = [];

  static void show(String message, {MessageType type = MessageType.info, Object? error}) {
    if (_shouldHide(type)) {
      return _logMessage(type, message, error);
    }

    final state = App.navigatorKey.currentState;
    if (state == null) return;

    final overlay = state.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _SnackBar(
        message: message,
        color: type.color(state.context),
        index: _entries.length - 1 - _entries.indexOf(entry),

        onDismiss: () {
          if (_entries.contains(entry)) {
            entry.remove();
            _entries.remove(entry);

            for (final e in _entries) {
              e.markNeedsBuild();
            }
          }
        },
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entries.add(entry);

      overlay.insert(entry, above: _entries.length > 1 ? _entries[_entries.length - 2] : null);
    });

    _logMessage(type, message, error);
  }

  static bool _shouldHide(MessageType type) {
    return Prefs.showOnlyErrors.value && type != MessageType.error && type != MessageType.warning;
  }

  static void _logMessage(MessageType type, String message, Object? error) {
    if (!kDebugMode) return;

    const reset = "\x1B[0m";
    const bold = "\x1B[1m";

    log("${type.ansiCode}$bold${type.label} | $message$reset");

    if (error != null) {
      log("${type.ansiCode}$bold$error$reset");
    }
  }
}

class _SnackBar extends StatefulWidget {
  final String message;
  final Color color;
  final int index;
  final VoidCallback onDismiss;

  const _SnackBar({required this.message, required this.color, required this.index, required this.onDismiss});

  @override
  State<_SnackBar> createState() => _SnackBarState();
}

class _SnackBarState extends State<_SnackBar> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _exitController;

  final ValueNotifier<bool> _isDismissing = ValueNotifier(false);
  Offset _dismissOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..forward();

    _exitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    router.routerDelegate.addListener(_onRouteChanged);
    Future.delayed(const Duration(seconds: 5), _dismiss);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _exitController.dispose();
    _isDismissing.dispose();

    router.routerDelegate.removeListener(_onRouteChanged);

    super.dispose();
  }

  @override
  void didUpdateWidget(_SnackBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    Future.delayed(const Duration(seconds: 5), _dismiss);
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

  void _dismiss() {
    if (!mounted || _isDismissing.value) return;
    _isDismissing.value = true;
    _exitController.forward().then((_) => widget.onDismiss());
  }

  double _getBottomMargin(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final currentPath = router.state.uri.path;
    const spacing = 11.0;

    double base = bottomPadding;

    if (audio.hasCurrentTrack && currentPath == Routes.home) {
      base += 98;
    } else if (currentPath == Routes.details.player) {
      base += 160;
    } else if (currentPath == Routes.details.track) {
      base += 145;
    } else {
      base += 16;
    }

    return base + (widget.index * spacing);
  }

  double _getSize() => 1 - (widget.index * 0.05);

  double _getOpacity() {
    if (widget.index >= 5) return 0.0;
    return 1 - (widget.index * 0.2);
  }

  @override
  Widget build(BuildContext context) {
    final bottomMargin = _getBottomMargin(context);
    final size = _getSize();
    final opacity = _getOpacity();

    final child = RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        width: double.infinity,

        decoration: BoxDecoration(color: context.c.surfaceContainer, borderRadius: App.borderRadius),

        child: Text(
          widget.message,
          style: TextStyle(color: widget.color, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(child: Container(color: Colors.transparent)),
        ),

        Material(
          type: MaterialType.transparency,

          child: Align(
            alignment: Alignment.bottomCenter,

            child: AnimatedPadding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomMargin),

              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,

              child: IgnorePointer(
                ignoring: widget.index >= 5,

                child: Dismissable(
                  onDismiss: (details) {
                    _dismissOffset = details.velocity.pixelsPerSecond;
                    _dismiss();
                  },

                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isDismissing,

                    builder: (_, _, _) {
                      return AnimatedOpacity(
                        opacity: opacity,

                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,

                        child: AnimatedScale(
                          scale: size,

                          alignment: Alignment.bottomCenter,
                          duration: const Duration(milliseconds: 300),

                          child: child
                              .animate(controller: _entryController, autoPlay: false)
                              .slideX(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeInOut)
                              .animate(controller: _exitController, autoPlay: false)
                              .slideX(
                                begin: 0,
                                end: _dismissOffset.dx <= 0 ? -1 : 1,
                                duration: 500.ms,
                                curve: Curves.easeInOut,
                              )
                              .fadeOut(duration: 300.ms),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
